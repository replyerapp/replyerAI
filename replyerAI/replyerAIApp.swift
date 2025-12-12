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
                            // Show paywall once after completing onboarding
                            if !hasSeenInitialPaywall {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showInitialPaywall = true
                                }
                            }
                            // Request tracking after initial paywall
                            if !hasRequestedTracking && hasSeenInitialPaywall {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    requestTracking()
                                }
                            }
                        }
                        .paywallSheet(isPresented: $showInitialPaywall)
                        .onChange(of: showInitialPaywall) { oldValue, newValue in
                            // When paywall is dismissed, mark it as seen and request tracking
                            if oldValue == true && newValue == false {
                                hasSeenInitialPaywall = true
                                // Request tracking right after paywall dismissal
                                if !hasRequestedTracking {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        requestTracking()
                                    }
                                }
                            }
                        }
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .preferredColorScheme(appearanceManager.colorScheme)
        }
    }
    
    private func requestTracking() {
        // Request tracking authorization (shows standard iOS ATT prompt)
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                hasRequestedTracking = true
                print("📊 Tracking authorization status: \(status.rawValue)")
            }
        }
    }
}
