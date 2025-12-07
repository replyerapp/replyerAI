//
//  replyerAIApp.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI
import Adapty
import RevenueCatUI

@main
struct ReplyerAIApp: App {
    @State private var appearanceManager = AppearanceManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasSeenInitialPaywall") private var hasSeenInitialPaywall: Bool = false
    @State private var showInitialPaywall: Bool = false
    
    init() {
        // Configure RevenueCat on app launch
        SubscriptionService.shared.configure()
        
        // Configure Adapty SDK
        Adapty.activate(Secrets.adaptyAPIKey)
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
        }
    }
}
