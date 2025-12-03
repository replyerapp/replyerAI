//
//  ReplyViewModel.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI
import PhotosUI

// MARK: - Enums

/// Represents the relationship with the message sender
enum Relationship: String, CaseIterable, Identifiable {
    case wife = "Wife"
    case husband = "Husband"
    case girlfriend = "Girlfriend"
    case boyfriend = "Boyfriend"
    case boss = "Boss"
    case coworker = "Coworker"
    case friend = "Friend"
    case bestFriend = "Best Friend"
    case parent = "Parent"
    case sibling = "Sibling"
    case exPartner = "Ex Partner"
    case acquaintance = "Acquaintance"
    case stranger = "Stranger"
    
    var id: String { rawValue }
}

/// Represents the desired tone for the reply
enum Tone: String, CaseIterable, Identifiable {
    case angry = "Angry"
    case funny = "Funny"
    case professional = "Professional"
    case sarcastic = "Sarcastic"
    case romantic = "Romantic"
    case apologetic = "Apologetic"
    case assertive = "Assertive"
    case friendly = "Friendly"
    case formal = "Formal"
    case casual = "Casual"
    case sympathetic = "Sympathetic"
    case flirty = "Flirty"
    
    var id: String { rawValue }
}

// MARK: - ViewModel

/// ViewModel for managing reply generation state and logic
@MainActor
@Observable
final class ReplyViewModel {
    
    // MARK: - Published Properties
    
    /// The selected image from the photo picker
    var selectedImage: UIImage?
    
    /// The photo picker item selection
    var imageSelection: PhotosPickerItem?
    
    /// The selected relationship with the message sender
    var selectedRelationship: Relationship = .friend
    
    /// The selected tone for the reply
    var selectedTone: Tone = .friendly
    
    /// Additional context provided by the user
    var contextText: String = ""
    
    /// The generated reply result
    var generatedReply: String = ""
    
    /// Loading state for async operations
    var isLoading: Bool = false
    
    /// Error message if generation fails
    var errorMessage: String?
    
    /// Whether to show the paywall
    var showPaywall: Bool = false
    
    /// Reference to subscription service
    private let subscriptionService = SubscriptionService.shared
    
    // MARK: - Computed Properties
    
    /// Whether the user has pro access
    var isPro: Bool {
        subscriptionService.isPro
    }
    
    /// Whether the user can generate (pro or within free limit)
    var canGenerate: Bool {
        subscriptionService.canGenerate
    }
    
    /// Remaining free generations
    var remainingFreeGenerations: Int {
        subscriptionService.remainingFreeGenerations
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Methods
    
    /// Generates a reply based on the selected parameters
    /// Returns true if generation was attempted, false if paywall should be shown
    func generateReply() async -> Bool {
        guard let image = selectedImage else {
            errorMessage = "Please select an image first."
            return true
        }
        
        // Check if user can generate (pro or within free limit)
        if !canGenerate {
            showPaywall = true
            return false
        }
        
        isLoading = true
        errorMessage = nil
        generatedReply = ""
        
        do {
            let prompt = buildPrompt()
            let response = try await GeminiService.shared.generateResponse(image: image, prompt: prompt)
            generatedReply = response
            
            // Increment usage count for free users
            subscriptionService.incrementUsage()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        return true
    }
    
    /// Builds the prompt string based on user selections
    private func buildPrompt() -> String {
        var prompt = """
        You are a helpful assistant that generates reply messages. 
        
        I'm showing you a screenshot of a message conversation. Please analyze the messages in the image and generate a reply.
        
        **Instructions:**
        - The person I'm replying to is my \(selectedRelationship.rawValue.lowercased()).
        - I want the reply to have a \(selectedTone.rawValue.lowercased()) tone.
        - Generate ONLY the reply message text, nothing else.
        - Keep the reply natural and conversational.
        - Match the language used in the conversation (if they write in Spanish, reply in Spanish, etc.).
        """
        
        if !contextText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            prompt += """
            
            
            **Additional context from me:**
            \(contextText)
            """
        }
        
        prompt += """
        
        
        Now, analyze the image and generate an appropriate reply message.
        """
        
        return prompt
    }
    
    /// Loads the image from the PhotosPickerItem
    func loadImage() async {
        guard let imageSelection else { return }
        
        do {
            if let data = try await imageSelection.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            errorMessage = "Failed to load image: \(error.localizedDescription)"
        }
    }
    
    /// Clears all input and output data
    func reset() {
        selectedImage = nil
        imageSelection = nil
        selectedRelationship = .friend
        selectedTone = .friendly
        contextText = ""
        generatedReply = ""
        errorMessage = nil
    }
}

