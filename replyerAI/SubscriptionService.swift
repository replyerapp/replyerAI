//
//  SubscriptionService.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import Foundation
import RevenueCat
import RevenueCatUI
import SwiftUI

// MARK: - Constants

enum SubscriptionConstants {
    /// The entitlement ID configured in RevenueCat dashboard
    static let proEntitlementID = "Replyer Pro"
    
    /// Free tier daily usage limit
    static let freeUsageLimit = 3
    
    /// UserDefaults key for tracking daily usage
    static let dailyUsageKey = "daily_usage_count"
    
    /// UserDefaults key for tracking the last usage date
    static let lastUsageDateKey = "last_usage_date"
    
    /// Product identifiers (configure these in App Store Connect & RevenueCat)
    enum ProductID {
        static let monthly = "monthly"
        static let sixMonth = "six_month"
        static let yearly = "yearly"
        static let lifetime = "lifetime"
    }
}

// MARK: - Subscription Error

enum SubscriptionError: LocalizedError {
    case noOfferingsAvailable
    case purchaseFailed(String)
    case restoreFailed(String)
    case customerInfoFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noOfferingsAvailable:
            return "No subscription options are currently available."
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        case .customerInfoFailed(let message):
            return "Failed to get subscription info: \(message)"
        }
    }
}

// MARK: - Subscription Service

/// Service for managing subscriptions via RevenueCat
@MainActor
@Observable
final class SubscriptionService {
    
    // MARK: - Properties
    
    /// Whether the user has pro access
    var isPro: Bool = false
    
    /// Current daily usage count for free users
    var dailyUsageCount: Int = 0
    
    /// Whether the service is currently loading
    var isLoading: Bool = false
    
    /// Current offerings from RevenueCat
    var offerings: Offerings?
    
    /// Current customer info
    var customerInfo: CustomerInfo?
    
    /// Error message for display
    var errorMessage: String?
    
    /// Whether to show Customer Center
    var showCustomerCenter: Bool = false
    
    /// Shared singleton instance
    static let shared = SubscriptionService()
    
    // MARK: - Initialization
    
    private init() {
        loadDailyUsage()
    }
    
    // MARK: - Configuration
    
    /// Configure RevenueCat SDK - call this in App init
    func configure() {
        #if DEBUG
        Purchases.logLevel = .debug
        let apiKeyType = Secrets.revenueCatAPIKey.hasPrefix("test_") ? "Test Store" : "Production"
        print("🔑 RevenueCat API Key Type: \(apiKeyType)")
        print("🔑 Using API Key: \(Secrets.revenueCatAPIKey.prefix(20))...")
        #else
        Purchases.logLevel = .error
        #endif
        
        Purchases.configure(withAPIKey: Secrets.revenueCatAPIKey)
        
        // Listen for customer info updates
        Purchases.shared.delegate = RevenueCatDelegate.shared
        
        // Fetch initial data
        Task {
            await fetchInitialData()
        }
    }
    
    /// Fetch initial subscription status and offerings
    private func fetchInitialData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Fetch customer info and offerings in parallel
        async let customerInfoTask = fetchCustomerInfo()
        async let offeringsTask = fetchOfferings()
        
        _ = await (customerInfoTask, offeringsTask)
    }
    
    // MARK: - Customer Info
    
    /// Fetch and update customer info
    @discardableResult
    func fetchCustomerInfo() async -> CustomerInfo? {
        do {
            let info = try await Purchases.shared.customerInfo()
            self.customerInfo = info
            updateProStatus(from: info)
            return info
        } catch {
            print("❌ Error fetching customer info: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    /// Update pro status from customer info
    func updateProStatus(from customerInfo: CustomerInfo) {
        self.customerInfo = customerInfo
        // Be resilient to entitlement ID mismatches by treating any active entitlement as Pro.
        // This prevents “paid but still locked” cases when the dashboard entitlement ID differs.
        isPro =
            customerInfo.entitlements[SubscriptionConstants.proEntitlementID]?.isActive == true ||
            !customerInfo.entitlements.active.isEmpty
        
        #if DEBUG
        print("📱 Pro Status Updated: \(isPro)")
        print("📱 Entitlement ID we're checking: '\(SubscriptionConstants.proEntitlementID)'")
        print("📱 All Entitlements: \(customerInfo.entitlements.all.keys.map { "'\($0)'" })")
        print("📱 Active Entitlements: \(customerInfo.entitlements.active.keys.map { "'\($0)'" })")
        print("📱 Active Products: \(customerInfo.activeSubscriptions)")
        if let entitlement = customerInfo.entitlements[SubscriptionConstants.proEntitlementID] {
            print("📱 Entitlement '\(SubscriptionConstants.proEntitlementID)' found - isActive: \(entitlement.isActive)")
        } else {
            print("⚠️ Entitlement '\(SubscriptionConstants.proEntitlementID)' NOT FOUND")
            print("⚠️ Available entitlement IDs: \(customerInfo.entitlements.all.keys.joined(separator: ", "))")
        }
        #endif
    }
    
    // MARK: - Offerings
    
    /// Fetch available offerings/products
    @discardableResult
    func fetchOfferings() async -> Offerings? {
        do {
            let offerings = try await Purchases.shared.offerings()
            self.offerings = offerings
            
            #if DEBUG
            print("📦 Offerings fetched: \(offerings.current?.availablePackages.count ?? 0) packages")
            if let current = offerings.current {
                print("📦 Current Offering ID: \(current.identifier)")
                print("📦 Available Packages: \(current.availablePackages.map { $0.identifier })")
            } else {
                print("⚠️ No current offering available")
            }
            #endif
            
            return offerings
        } catch {
            print("❌ Error fetching offerings: \(error.localizedDescription)")
            print("❌ Full error: \(error)")
            #if DEBUG
            if let rcError = error as? RevenueCat.ErrorCode {
                print("❌ RevenueCat Error Code: \(rcError)")
            }
            #endif
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    /// Get the current offering's packages
    var availablePackages: [Package] {
        return offerings?.current?.availablePackages ?? []
    }
    
    // MARK: - Purchases
    
    /// Purchase a specific package
    func purchase(package: Package) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let result = try await Purchases.shared.purchase(package: package)
            
            if !result.userCancelled {
                updateProStatus(from: result.customerInfo)
                
                // Force a fresh fetch to ensure we have the latest status
                try? await Task.sleep(nanoseconds: 500_000_000) // Wait 0.5s
                await fetchCustomerInfo()
                
                #if DEBUG
                print("✅ Purchase successful!")
                print("✅ Pro status after purchase: \(isPro)")
                #endif
            }
        } catch {
            errorMessage = error.localizedDescription
            throw SubscriptionError.purchaseFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Restore Purchases
    
    /// Restore previous purchases
    func restorePurchases() async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            updateProStatus(from: customerInfo)
            
            // Force a fresh fetch to ensure we have the latest status
            try? await Task.sleep(nanoseconds: 500_000_000) // Wait 0.5s
            await fetchCustomerInfo()
            
            #if DEBUG
            print("✅ Restore successful! Pro: \(isPro)")
            #endif
        } catch {
            errorMessage = error.localizedDescription
            throw SubscriptionError.restoreFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Usage Tracking
    
    /// Check if the user can generate (either pro or within free limit)
    var canGenerate: Bool {
        return isPro || dailyUsageCount < SubscriptionConstants.freeUsageLimit
    }
    
    /// Remaining free generations for today
    var remainingFreeGenerations: Int {
        return max(0, SubscriptionConstants.freeUsageLimit - dailyUsageCount)
    }
    
    /// Increment usage count after a successful generation
    func incrementUsage() {
        guard !isPro else { return } // Pro users don't have limits
        
        dailyUsageCount += 1
        saveDailyUsage()
    }
    
    /// Load daily usage from UserDefaults, resetting if it's a new day
    private func loadDailyUsage() {
        let defaults = UserDefaults.standard
        let lastDate = defaults.object(forKey: SubscriptionConstants.lastUsageDateKey) as? Date
        
        if let lastDate = lastDate, Calendar.current.isDateInToday(lastDate) {
            dailyUsageCount = defaults.integer(forKey: SubscriptionConstants.dailyUsageKey)
        } else {
            // New day - reset usage
            dailyUsageCount = 0
            saveDailyUsage()
        }
    }
    
    /// Save daily usage to UserDefaults
    private func saveDailyUsage() {
        let defaults = UserDefaults.standard
        defaults.set(dailyUsageCount, forKey: SubscriptionConstants.dailyUsageKey)
        defaults.set(Date(), forKey: SubscriptionConstants.lastUsageDateKey)
    }
    
    // MARK: - Subscription Info Helpers
    
    /// Get the active subscription's expiration date
    var subscriptionExpirationDate: Date? {
        return customerInfo?.entitlements[SubscriptionConstants.proEntitlementID]?.expirationDate
    }
    
    /// Check if subscription will renew
    var willRenew: Bool {
        return customerInfo?.entitlements[SubscriptionConstants.proEntitlementID]?.willRenew ?? false
    }
    
    /// Get subscription management URL
    var managementURL: URL? {
        return customerInfo?.managementURL
    }
}

// MARK: - Purchases Delegate

/// Delegate to handle RevenueCat updates
final class RevenueCatDelegate: NSObject, PurchasesDelegate, @unchecked Sendable {
    
    static let shared = RevenueCatDelegate()
    
    private override init() {
        super.init()
    }
    
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            SubscriptionService.shared.updateProStatus(from: customerInfo)
        }
    }
}

// MARK: - View Modifiers

extension View {
    /// Present a paywall as fullscreen using RevenueCatUI
    func paywallSheet(isPresented: Binding<Bool>) -> some View {
        self.fullScreenCover(isPresented: isPresented) {
            DismissablePaywallView(isPresented: isPresented)
        }
    }
}

/// Paywall view - Full Screen (uses RevenueCat's built-in X button)
struct DismissablePaywallView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        PaywallView()
            .onPurchaseCompleted { customerInfo in
                Task { @MainActor in
                    SubscriptionService.shared.updateProStatus(from: customerInfo)
                    isPresented = false
                }
            }
            .onRestoreCompleted { customerInfo in
                Task { @MainActor in
                    SubscriptionService.shared.updateProStatus(from: customerInfo)
                }
            }
    }
}

// MARK: - Customer Center View

/// Custom subscription management view
struct CustomerCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    private let subscriptionService = SubscriptionService.shared
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Subscription Status Section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Replyer Pro")
                                .font(.headline)
                            if subscriptionService.isPro {
                                if let expirationDate = subscriptionService.subscriptionExpirationDate {
                                    Text("Renews \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Lifetime Access")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Spacer()
                        Text(subscriptionService.isPro ? "Active" : "Inactive")
                            .font(.subheadline)
                            .foregroundStyle(subscriptionService.isPro ? .green : .secondary)
                    }
                } header: {
                    Text("Current Plan")
                }
                
                // Manage Section
                Section {
                    // Manage in App Store
                    if let managementURL = subscriptionService.managementURL {
                        Button {
                            openURL(managementURL)
                        } label: {
                            Label("Manage in App Store", systemImage: "arrow.up.forward.app")
                        }
                    }
                    
                    // Restore Purchases
                    Button {
                        restorePurchases()
                    } label: {
                        HStack {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                            Spacer()
                            if isRestoring {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isRestoring)
                } header: {
                    Text("Options")
                }
                
                // Help Section
                Section {
                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                } header: {
                    Text("Legal")
                }
            }
            .navigationTitle("Manage Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
        }
    }
    
    private func restorePurchases() {
        isRestoring = true
        Task {
            do {
                try await subscriptionService.restorePurchases()
                restoreMessage = subscriptionService.isPro 
                    ? "Your Pro subscription has been restored!" 
                    : "No previous purchases found."
            } catch {
                restoreMessage = "Failed to restore: \(error.localizedDescription)"
            }
            isRestoring = false
            showRestoreAlert = true
        }
    }
}

// MARK: - Pro Feature Lock View

/// A view that shows locked content for non-pro users
struct ProFeatureLock: View {
    let featureName: String
    @Binding var showPaywall: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("\(featureName)")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Upgrade to Pro to unlock this feature")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showPaywall = true
            } label: {
                Text("Unlock Pro")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Subscription Status View

/// A view showing the current subscription status
struct SubscriptionStatusView: View {
    let subscriptionService = SubscriptionService.shared
    @Binding var showCustomerCenter: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Replyer Pro")
                            .font(.headline)
                        
                        if subscriptionService.isPro {
                            Text("ACTIVE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    
                    if subscriptionService.isPro {
                        if let expirationDate = subscriptionService.subscriptionExpirationDate {
                            Text("Renews \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Lifetime Access")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Unlock unlimited generations")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if subscriptionService.isPro {
                    Button {
                        showCustomerCenter = true
                    } label: {
                        Text("Manage")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
