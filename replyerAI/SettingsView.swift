//
//  SettingsView.swift
//  replyerAI
//
//  Created by Ege Can Koç on 4.12.2025.
//

import SwiftUI
import StoreKit
import RevenueCat

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @State private var appearanceManager = AppearanceManager.shared
    @State private var subscriptionService = SubscriptionService.shared
    @State private var showManageSubscription = false
    @State private var showPaywall = false
    
    // App version from bundle
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version).\(build)"
    }
    
    // URLs - Update these with your actual GitHub Gist URLs before release
    // Example placeholders:
    // Terms:   https://gist.github.com/replyerapp/TERMS_GIST_ID
    // Privacy: https://gist.github.com/replyerapp/PRIVACY_GIST_ID
    private let termsURL = URL(string: "https://gist.github.com/replyerapp")!
    private let privacyURL = URL(string: "https://gist.github.com/replyerapp")!
    private let supportEmail = "replyderv@gmail.com"
    private let feedbackEmail = "replyderv@gmail.com"
    private let appStoreID = "YOUR_APP_STORE_ID" // Replace with your actual App Store ID
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Subscription Section
                Section {
                    if subscriptionService.isPro {
                        // Manage Subscription
                        Button {
                            showManageSubscription = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: "crown.fill")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Replyer Pro")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    
                                    Text(L10n.manageSubscription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    } else {
                        // Upgrade to Pro
                        Button {
                            showPaywall = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "star.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.yellow)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(L10n.upgradeToPro)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    
                                    Text(L10n.unlockAllFeatures)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(L10n.upgrade)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.accentColor)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Restore Purchases
                    Button {
                        Task {
                            try? await subscriptionService.restorePurchases()
                        }
                    } label: {
                        SettingsRow(
                            title: L10n.restorePurchases,
                            icon: "arrow.clockwise",
                            iconColor: .blue
                        )
                    }
                } header: {
                    Text(L10n.subscription)
                }
                
                // MARK: - Appearance Section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: appearanceManager.appearanceMode.icon)
                            .font(.body)
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 24)
                        
                        Picker(L10n.appearance, selection: $appearanceManager.appearanceMode) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.localizedName).tag(mode)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text(L10n.appearance)
                } footer: {
                    Text(L10n.appearanceFooter)
                }
                
                // MARK: - General Section
                Section {
                    // Share App
                    ShareLink(item: URL(string: "https://apps.apple.com/app/id\(appStoreID)")!) {
                        SettingsRow(
                            title: L10n.shareApp,
                            icon: "square.and.arrow.up",
                            iconColor: .blue
                        )
                    }
                    
                    // Rate Us
                    Button {
                        requestReview()
                    } label: {
                        SettingsRow(
                            title: L10n.rateUs,
                            icon: "star.fill",
                            iconColor: .yellow
                        )
                    }
                    
                    // Terms of Use
                    Link(destination: termsURL) {
                        SettingsRow(
                            title: L10n.termsOfUse,
                            icon: "doc.text",
                            iconColor: .gray
                        )
                    }
                    
                    // Privacy Policy
                    Link(destination: privacyURL) {
                        SettingsRow(
                            title: L10n.privacyPolicy,
                            icon: "hand.raised.fill",
                            iconColor: .green
                        )
                    }
                    
                    // App Version
                    HStack {
                        SettingsRow(
                            title: L10n.appVersion,
                            icon: "info.circle",
                            iconColor: .secondary,
                            showChevron: false
                        )
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(L10n.general)
                }
                
                // MARK: - Support Section
                Section {
                    // Support
                    Button {
                        openMail(to: supportEmail, subject: "Replyer Support Request")
                    } label: {
                        SettingsRow(
                            title: L10n.support,
                            icon: "questionmark.circle",
                            iconColor: .purple
                        )
                    }
                    
                    // Feedback & Suggestions
                    Button {
                        openMail(to: feedbackEmail, subject: "Replyer Feedback")
                    } label: {
                        SettingsRow(
                            title: L10n.feedbackSuggestions,
                            icon: "envelope.fill",
                            iconColor: .orange
                        )
                    }
                } header: {
                    Text(L10n.support)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(L10n.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showManageSubscription) {
                ManageSubscriptionView()
            }
            .paywallSheet(isPresented: $showPaywall)
        }
    }
    
    // MARK: - Helper Methods
    
    private func openMail(to email: String, subject: String) {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Manage Subscription View

struct ManageSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptionService = SubscriptionService.shared
    @State private var customerInfo: CustomerInfo?
    @State private var isLoading = true
    
    // Use the same GitHub Gist URLs as in SettingsView
    private let termsURL = URL(string: "https://gist.github.com/replyerapp")!
    private let privacyURL = URL(string: "https://gist.github.com/replyerapp")!
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Subscription Status
                Section {
                    VStack(spacing: 16) {
                        // Pro Badge
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "crown.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 8)
                        
                        Text("Replyer Pro")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else if let info = customerInfo,
                                  let entitlement = info.entitlements["pro"],
                                  entitlement.isActive {
                            
                            VStack(spacing: 8) {
                                // Subscription Type
                                HStack {
                                    Text(L10n.plan)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(formatProductName(entitlement.productIdentifier))
                                        .fontWeight(.medium)
                                }
                                
                                Divider()
                                
                                // Expiration Date
                                if let expirationDate = entitlement.expirationDate {
                                    HStack {
                                        Text(L10n.renewsOn)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(formatDate(expirationDate))
                                            .fontWeight(.medium)
                                    }
                                } else {
                                    // Lifetime purchase
                                    HStack {
                                        Text(L10n.status)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(L10n.lifetime)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
                
                // MARK: - Cancel Subscription Section
                Section {
                    Button {
                        openSubscriptionManagement()
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(.red)
                            
                            Text(L10n.cancelSubscription)
                                .foregroundStyle(.red)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.forward.app")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(L10n.manageSubscription)
                } footer: {
                    Text(L10n.cancelSubscriptionFooter)
                        .font(.caption)
                }
                
                // MARK: - Important Info
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(
                            icon: "calendar.badge.clock",
                            text: L10n.subscriptionActiveUntilEnd
                        )
                        
                        InfoRow(
                            icon: "arrow.clockwise.circle",
                            text: L10n.autoRenewInfo
                        )
                        
                        InfoRow(
                            icon: "creditcard",
                            text: L10n.billedThroughApple
                        )
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text(L10n.importantInformation)
                }
                
                // MARK: - Legal
                Section {
                    Link(destination: termsURL) {
                        SettingsRow(
                            title: L10n.termsOfUse,
                            icon: "doc.text",
                            iconColor: .gray
                        )
                    }
                    
                    Link(destination: privacyURL) {
                        SettingsRow(
                            title: L10n.privacyPolicy,
                            icon: "hand.raised.fill",
                            iconColor: .green
                        )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(L10n.subscription)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task {
                await loadCustomerInfo()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadCustomerInfo() async {
        isLoading = true
        do {
            customerInfo = try await Purchases.shared.customerInfo()
        } catch {
            print("Failed to load customer info: \(error)")
        }
        isLoading = false
    }
    
    private func formatProductName(_ productId: String) -> String {
        if productId.contains("monthly") {
            return L10n.monthlyPlan
        } else if productId.contains("yearly") || productId.contains("annual") {
            return L10n.yearlyPlan
        } else if productId.contains("lifetime") {
            return L10n.lifetimePlan
        }
        return L10n.proPlan
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func openSubscriptionManagement() {
        // Apple requires cancellation to go through the App Store
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Settings Row Component

struct SettingsRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    var showChevron: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 24)
            
            Text(title)
                .foregroundStyle(.primary)
            
            if showChevron {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

