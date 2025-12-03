//
//  replyerAIApp.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI

@main
struct replyerAIApp: App {
    
    init() {
        // Configure RevenueCat on app launch
        SubscriptionService.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
