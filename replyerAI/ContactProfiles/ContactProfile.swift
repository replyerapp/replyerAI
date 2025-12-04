//
//  ContactProfile.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import Foundation
import SwiftUI

// MARK: - Contact Profile Model

/// Represents a saved contact profile with custom preferences
struct ContactProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var relationship: String
    var notes: String
    var preferredTone: String?
    var customEmoji: String?
    var createdAt: Date
    var updatedAt: Date
    
    /// Display emoji - custom or based on relationship
    var emoji: String {
        if let custom = customEmoji, !custom.isEmpty {
            return custom
        }
        return defaultEmoji
    }
    
    /// Default emoji based on relationship
    var defaultEmoji: String {
        switch relationship.lowercased() {
        case "wife", "husband":
            return "💍"
        case "girlfriend", "boyfriend":
            return "❤️"
        case "boss":
            return "👔"
        case "coworker":
            return "💼"
        case "friend":
            return "😊"
        case "best friend":
            return "🤝"
        case "parent":
            return "👨‍👩‍👧"
        case "sibling":
            return "👫"
        case "ex partner":
            return "💔"
        case "acquaintance":
            return "👋"
        case "stranger":
            return "❓"
        default:
            return "👤"
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        relationship: String,
        notes: String = "",
        preferredTone: String? = nil,
        customEmoji: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.notes = notes
        self.preferredTone = preferredTone
        self.customEmoji = customEmoji
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Common Emojis for Contacts

enum ContactEmojis {
    static let all: [String] = [
        "😊", "😎", "🥰", "😍", "🤗", "😇", "🙂", "😏",
        "❤️", "💕", "💖", "💗", "💘", "💝", "💍", "💔",
        "👨", "👩", "👴", "👵", "👶", "🧑", "👤", "👥",
        "👨‍👩‍👧", "👨‍👩‍👦", "👫", "👭", "👬", "🤝", "👋", "✌️",
        "👔", "💼", "🏢", "💻", "📱", "🎓", "🏆", "⭐",
        "🔥", "✨", "💫", "🌟", "⚡", "💎", "🎯", "🎪",
        "🐱", "🐶", "🦊", "🐻", "🐼", "🐨", "🦁", "🐯",
        "🌸", "🌺", "🌹", "🌷", "🌻", "🌼", "💐", "🍀"
    ]
}

// MARK: - Contact Profile Manager

/// Manages saving and loading contact profiles
@MainActor
@Observable
final class ContactProfileManager {
    
    // MARK: - Singleton
    
    static let shared = ContactProfileManager()
    
    // MARK: - Properties
    
    /// All saved contact profiles
    private(set) var profiles: [ContactProfile] = []
    
    /// Currently selected profile
    var selectedProfile: ContactProfile?
    
    // MARK: - UserDefaults Keys
    
    private let profilesKey = "savedContactProfiles"
    
    // MARK: - Initialization
    
    private init() {
        loadProfiles()
    }
    
    // MARK: - Public Methods
    
    /// Adds a new contact profile
    func addProfile(_ profile: ContactProfile) {
        profiles.append(profile)
        saveProfiles()
    }
    
    /// Updates an existing profile
    func updateProfile(_ profile: ContactProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            var updated = profile
            updated.updatedAt = Date()
            profiles[index] = updated
            saveProfiles()
            
            // Update selected profile if it was the one updated
            if selectedProfile?.id == profile.id {
                selectedProfile = updated
            }
        }
    }
    
    /// Deletes a profile
    func deleteProfile(_ profile: ContactProfile) {
        profiles.removeAll { $0.id == profile.id }
        saveProfiles()
        
        // Clear selection if deleted profile was selected
        if selectedProfile?.id == profile.id {
            selectedProfile = nil
        }
    }
    
    /// Deletes profile at index
    func deleteProfile(at offsets: IndexSet) {
        let profilesToDelete = offsets.map { profiles[$0] }
        profiles.remove(atOffsets: offsets)
        saveProfiles()
        
        // Clear selection if deleted profile was selected
        if let selected = selectedProfile, profilesToDelete.contains(where: { $0.id == selected.id }) {
            selectedProfile = nil
        }
    }
    
    /// Selects a profile
    func selectProfile(_ profile: ContactProfile?) {
        selectedProfile = profile
    }
    
    /// Clears the selected profile
    func clearSelection() {
        selectedProfile = nil
    }
    
    /// Gets a profile by ID
    func getProfile(by id: UUID) -> ContactProfile? {
        profiles.first { $0.id == id }
    }
    
    /// Checks if any profiles exist
    var hasProfiles: Bool {
        !profiles.isEmpty
    }
    
    /// Number of saved profiles
    var profileCount: Int {
        profiles.count
    }
    
    // MARK: - Private Methods
    
    private func loadProfiles() {
        guard let data = UserDefaults.standard.data(forKey: profilesKey) else {
            profiles = []
            return
        }
        
        do {
            profiles = try JSONDecoder().decode([ContactProfile].self, from: data)
            // Sort by name
            profiles.sort { $0.name.lowercased() < $1.name.lowercased() }
        } catch {
            print("Failed to decode profiles: \(error)")
            profiles = []
        }
    }
    
    private func saveProfiles() {
        do {
            // Sort by name before saving
            profiles.sort { $0.name.lowercased() < $1.name.lowercased() }
            let data = try JSONEncoder().encode(profiles)
            UserDefaults.standard.set(data, forKey: profilesKey)
        } catch {
            print("Failed to encode profiles: \(error)")
        }
    }
    
    /// Resets all profiles (for testing)
    func resetAllProfiles() {
        profiles.removeAll()
        selectedProfile = nil
        UserDefaults.standard.removeObject(forKey: profilesKey)
    }
}

