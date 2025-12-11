//
//  replyerAIApp.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI
import RevenueCatUI
import AppTrackingTransparency

@main
struct ReplyerAIApp: App {
    @State private var appearanceManager = AppearanceManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasSeenInitialPaywall") private var hasSeenInitialPaywall: Bool = false
    @AppStorage("hasRequestedTracking") private var hasRequestedTracking: Bool = false
    @State private var showInitialPaywall: Bool = false
    @State private var showTrackingPrompt: Bool = false
    
    init() {
        // Configure RevenueCat on app launch
        SubscriptionService.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .onAppear {
                            // Request tracking once after onboarding/completion
                            if !hasRequestedTracking {
                                showTrackingPrompt = true
                            }
                            // Show paywall once after completing onboarding
                            if !hasSeenInitialPaywall {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showInitialPaywall = true
                                }
                            }
                        }
                        .paywallSheet(isPresented: $showInitialPaywall)
                        .onChange(of: showInitialPaywall) { oldValue, newValue in
                            // When paywall is dismissed, mark it as seen
                            if oldValue == true && newValue == false {
                                hasSeenInitialPaywall = true
                            }
                        }
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .preferredColorScheme(appearanceManager.colorScheme)
            .alert("Allow tracking to help us improve?", isPresented: $showTrackingPrompt) {
                Button("Not Now", role: .cancel) {
                    hasRequestedTracking = true
                }
                Button("Allow") {
                    requestTracking()
                }
            } message: {
                Text(L10n.trackingPermissionReason)
            }
        }
    }
    
    private func requestTracking() {
        ATTrackingManager.requestTrackingAuthorization { _ in
            DispatchQueue.main.async {
                hasRequestedTracking = true
            }
        }
    }
}
