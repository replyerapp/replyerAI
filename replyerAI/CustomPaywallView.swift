//
//  CustomPaywallView.swift
//  Replyer
//
//  Custom fullscreen paywall that mirrors the RevenueCat offerings,
//  exposes Restore/Terms/Privacy buttons, and keeps all price labels uniform.
//

import SwiftUI
import RevenueCat

struct CustomPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var subscriptionService = SubscriptionService.shared

    var onPurchaseCompleted: ((CustomerInfo?) -> Void)?
    var onRestoreCompleted: ((CustomerInfo?) -> Void)?

    @State private var processingPackageID: String?
    @State private var showingError: String?

    private let termsURL = URL(string: "https://raw.githubusercontent.com/replyerapp/replyerAI/main/TERMS_OF_USE.md")!
    private let privacyURL = URL(string: "https://raw.githubusercontent.com/replyerapp/replyerAI/main/PRIVACY_POLICY.md")!

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(subscriptionService.availablePackages, id: \RevenueCat.Package.identifier) { package in
                            packageCard(for: package)
                        }

                        if subscriptionService.availablePackages.isEmpty {
                            ProgressView("Loading subscription options…")
                                .padding(.top, 24)
                        }
                    }
                    .padding()
                }

                Divider()

                footer
                    .padding(.horizontal)
                    .padding(.bottom, 24)
            }

            closeButton
        }
        .alert("Oops", isPresented: Binding(
            get: { showingError != nil },
            set: { if !$0 { showingError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(showingError ?? "")
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Replyer Pro")
                .font(.system(size: 32, weight: .bold))
            Text("Unlimited replies, My Style, Full Story, Decode, and more.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func packageCard(for package: Package) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.storeProduct.subscriptionPeriod?.localizedDescription ?? "Subscription")
                        .font(.headline)
                Text(package.storeProduct.localizedDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(package.storeProduct.localizedPriceString)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Price \(package.storeProduct.localizedPriceString)")
            }

            Button {
                Task {
                    await purchase(package: package)
                }
            } label: {
                Text(processingPackageID == package.identifier ? "Processing…" : "Choose")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemFill))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(processingPackageID != nil && processingPackageID != package.identifier)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }

    private var footer: some View {
        VStack(spacing: 6) {
            HStack(spacing: 16) {
                Button("Restore Purchases") {
                    Task {
                        await restore()
                    }
                }
                Spacer()
                Button("Terms") {
                    openURL(termsURL)
                }
                Button("Privacy") {
                    openURL(privacyURL)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
        }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
                .padding()
        }
    }

    private func purchase(package: Package) async {
        Task {
            processingPackageID = package.identifier
            do {
                try await subscriptionService.purchase(package: package)
                onPurchaseCompleted?(subscriptionService.customerInfo)
                dismiss()
            } catch {
                showingError = error.localizedDescription
            }
            processingPackageID = nil
        }
    }

    private func restore() async {
        processingPackageID = "restore"
        do {
            try await subscriptionService.restorePurchases()
            onRestoreCompleted?(subscriptionService.customerInfo)
        } catch {
            showingError = error.localizedDescription
        }
        processingPackageID = nil
    }
}

// MARK: - Extensions

private extension SubscriptionPeriod {
    var localizedDescription: String {
        switch unit {
        case .day:
            return "\(value)-day"
        case .week:
            return "\(value)-week"
        case .month:
            return "\(value)-month"
        case .year:
            return "\(value)-year"
        @unknown default:
            return "\(value)-period"
        }
    }
}

