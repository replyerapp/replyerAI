//
//  AppearanceManager.swift
//  replyerAI
//
//  Created by Ege Can Koç on 4.12.2025.
//

import SwiftUI

/// Appearance mode options
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .system: return String(localized: "system")
        case .light: return String(localized: "light")
        case .dark: return String(localized: "dark")
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

/// Manages app appearance/theme settings
@MainActor
@Observable
final class AppearanceManager {
    
    // MARK: - Singleton
    
    static let shared = AppearanceManager()
    
    // MARK: - Properties
    
    /// Current appearance mode
    var appearanceMode: AppearanceMode {
        didSet {
            saveAppearance()
        }
    }
    
    /// The color scheme to apply (nil = follow system)
    var colorScheme: ColorScheme? {
        appearanceMode.colorScheme
    }
    
    // MARK: - UserDefaults Key
    
    private let appearanceKey = "appAppearanceMode"
    
    // MARK: - Initialization
    
    private init() {
        // Load saved appearance or default to system
        if let savedValue = UserDefaults.standard.string(forKey: appearanceKey),
           let mode = AppearanceMode(rawValue: savedValue) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .system
        }
    }
    
    // MARK: - Private Methods
    
    private func saveAppearance() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceKey)
    }
}

