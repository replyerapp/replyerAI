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
    @State private var subscriptionService = SubscriptionService.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasRequestedTracking") private var hasRequestedTracking: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showTrackingThenPaywall: Bool = false
    
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
                            // Show paywall on every app open (unless Pro)
                            if !subscriptionService.isPro {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showPaywall = true
                                }
                            }
                        }
                        .paywallSheet(isPresented: $showPaywall)
                } else {
                    OnboardingView {
                        // Onboarding completed - now show tracking, then paywall
                        hasCompletedOnboarding = true
                        showTrackingThenPaywall = true
                    }
                    .onChange(of: showTrackingThenPaywall) { oldValue, newValue in
                        if newValue {
                            // First request tracking
                            requestTrackingThenShowPaywall()
                        }
                    }
                }
            }
            .preferredColorScheme(appearanceManager.colorScheme)
        }
    }
    
    private func requestTrackingThenShowPaywall() {
        // Request tracking authorization first
        if !hasRequestedTracking {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    hasRequestedTracking = true
                    print("📊 Tracking authorization status: \(status.rawValue)")
                    // After tracking prompt, show paywall
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if !subscriptionService.isPro {
                            showPaywall = true
                        }
                    }
                }
            }
        } else {
            // Tracking already requested, just show paywall
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !subscriptionService.isPro {
                    showPaywall = true
                }
            }
        }
        showTrackingThenPaywall = false
    }
}
