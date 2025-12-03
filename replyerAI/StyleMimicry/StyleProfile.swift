//
//  StyleProfile.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import Foundation
import SwiftUI

// MARK: - Style Profile Model

/// Represents the user's personal writing style learned from their messages
struct StyleProfile: Codable, Equatable {
    /// Unique identifier
    let id: UUID
    
    /// When the profile was created
    let createdAt: Date
    
    /// When the profile was last updated
    var updatedAt: Date
    
    /// Number of sample messages analyzed
    var sampleCount: Int
    
    /// The analyzed style characteristics (stored as JSON string from AI)
    var styleAnalysis: String
    
    /// Whether the profile is complete and ready to use
    var isComplete: Bool {
        sampleCount >= StyleConstants.minimumSamples && !styleAnalysis.isEmpty
    }
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sampleCount: Int = 0,
        styleAnalysis: String = ""
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sampleCount = sampleCount
        self.styleAnalysis = styleAnalysis
    }
}

// MARK: - Style Sample

/// A sample message screenshot used to learn the user's style
struct StyleSample: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    let addedAt: Date
    
    init(id: UUID = UUID(), image: UIImage, addedAt: Date = Date()) {
        self.id = id
        self.image = image
        self.addedAt = addedAt
    }
    
    static func == (lhs: StyleSample, rhs: StyleSample) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Constants

enum StyleConstants {
    /// Minimum number of samples needed to create a style profile
    static let minimumSamples = 3
    
    /// Maximum number of samples allowed
    static let maximumSamples = 5
    
    /// UserDefaults key for storing the style profile
    static let profileStorageKey = "user_style_profile"
}

// MARK: - Style Profile Manager

/// Manages saving and loading the user's style profile
@MainActor
@Observable
final class StyleProfileManager {
    
    // MARK: - Properties
    
    /// The current style profile
    var profile: StyleProfile?
    
    /// Current samples being collected (before analysis)
    var pendingSamples: [StyleSample] = []
    
    /// Whether style analysis is in progress
    var isAnalyzing: Bool = false
    
    /// Error message if any
    var errorMessage: String?
    
    /// Shared instance
    static let shared = StyleProfileManager()
    
    // MARK: - Computed Properties
    
    /// Whether the user has a complete style profile
    var hasCompleteProfile: Bool {
        profile?.isComplete ?? false
    }
    
    /// Number of samples still needed
    var samplesNeeded: Int {
        max(0, StyleConstants.minimumSamples - pendingSamples.count)
    }
    
    /// Whether we can add more samples
    var canAddMoreSamples: Bool {
        pendingSamples.count < StyleConstants.maximumSamples
    }
    
    /// Progress towards minimum samples (0.0 to 1.0)
    var sampleProgress: Double {
        Double(pendingSamples.count) / Double(StyleConstants.minimumSamples)
    }
    
    // MARK: - Initialization
    
    private init() {
        loadProfile()
    }
    
    // MARK: - Sample Management
    
    /// Add a new sample image
    func addSample(_ image: UIImage) {
        guard canAddMoreSamples else {
            errorMessage = "Maximum \(StyleConstants.maximumSamples) samples allowed"
            return
        }
        
        let sample = StyleSample(image: image)
        pendingSamples.append(sample)
    }
    
    /// Remove a sample by ID
    func removeSample(id: UUID) {
        pendingSamples.removeAll { $0.id == id }
    }
    
    /// Clear all pending samples
    func clearSamples() {
        pendingSamples.removeAll()
    }
    
    // MARK: - Style Analysis
    
    /// Analyze the pending samples and create/update the style profile
    func analyzeStyle() async {
        guard pendingSamples.count >= StyleConstants.minimumSamples else {
            errorMessage = "Please add at least \(StyleConstants.minimumSamples) samples"
            return
        }
        
        isAnalyzing = true
        errorMessage = nil
        
        do {
            // Analyze all samples with Gemini
            let analysis = try await GeminiService.shared.analyzeWritingStyle(
                samples: pendingSamples.map { $0.image }
            )
            
            // Create or update profile
            var newProfile = profile ?? StyleProfile()
            newProfile.styleAnalysis = analysis
            newProfile.sampleCount = pendingSamples.count
            newProfile.updatedAt = Date()
            
            self.profile = newProfile
            saveProfile()
            
            // Clear pending samples after successful analysis
            pendingSamples.removeAll()
            
        } catch {
            errorMessage = "Failed to analyze style: \(error.localizedDescription)"
        }
        
        isAnalyzing = false
    }
    
    // MARK: - Profile Management
    
    /// Delete the current style profile
    func deleteProfile() {
        profile = nil
        pendingSamples.removeAll()
        UserDefaults.standard.removeObject(forKey: StyleConstants.profileStorageKey)
    }
    
    // MARK: - Persistence
    
    private func saveProfile() {
        guard let profile = profile else { return }
        
        do {
            let data = try JSONEncoder().encode(profile)
            UserDefaults.standard.set(data, forKey: StyleConstants.profileStorageKey)
        } catch {
            print("Failed to save style profile: \(error)")
        }
    }
    
    private func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: StyleConstants.profileStorageKey) else {
            return
        }
        
        do {
            profile = try JSONDecoder().decode(StyleProfile.self, from: data)
        } catch {
            print("Failed to load style profile: \(error)")
        }
    }
}

