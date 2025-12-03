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

// MARK: - Multi-Screenshot Constants

enum MultiScreenshotConstants {
    /// Maximum screenshots for free users
    static let freeMaxScreenshots = 1
    
    /// Maximum screenshots for pro users
    static let proMaxScreenshots = 5
}

// MARK: - ViewModel

/// ViewModel for managing reply generation state and logic
@MainActor
@Observable
final class ReplyViewModel {
    
    // MARK: - Published Properties
    
    /// The selected images from the photo picker (multiple for Pro)
    var selectedImages: [UIImage] = []
    
    /// The photo picker item selections (multiple)
    var imageSelections: [PhotosPickerItem] = []
    
    /// The selected relationship with the message sender
    var selectedRelationship: Relationship = .friend
    
    /// The selected tone for the reply
    var selectedTone: Tone = .friendly
    
    /// Whether to use the user's personal style instead of tone
    var useMyStyle: Bool = false
    
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
    
    /// Reference to style profile manager
    private let styleManager = StyleProfileManager.shared
    
    // MARK: - Computed Properties
    
    /// Whether the user has pro access
    var isPro: Bool {
        subscriptionService.isPro
    }
    
    /// Whether the user has a complete style profile
    var hasStyleProfile: Bool {
        styleManager.hasCompleteProfile
    }
    
    /// Whether the user can generate (pro or within free limit)
    var canGenerate: Bool {
        subscriptionService.canGenerate
    }
    
    /// Remaining free generations
    var remainingFreeGenerations: Int {
        subscriptionService.remainingFreeGenerations
    }
    
    /// Maximum allowed screenshots based on subscription
    var maxScreenshots: Int {
        isPro ? MultiScreenshotConstants.proMaxScreenshots : MultiScreenshotConstants.freeMaxScreenshots
    }
    
    /// Whether user can add more screenshots
    var canAddMoreScreenshots: Bool {
        selectedImages.count < maxScreenshots
    }
    
    /// Whether multi-screenshot is available (Pro feature)
    var isMultiScreenshotAvailable: Bool {
        isPro
    }
    
    /// First selected image (for backward compatibility)
    var selectedImage: UIImage? {
        selectedImages.first
    }
    
    /// Whether any images are selected
    var hasImages: Bool {
        !selectedImages.isEmpty
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Methods
    
    /// Generates a reply based on the selected parameters
    /// Returns true if generation was attempted, false if paywall should be shown
    func generateReply() async -> Bool {
        guard !selectedImages.isEmpty else {
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
            let response: String
            
            // Use styled reply if user has a style profile and wants to use it
            if useMyStyle && hasStyleProfile, let styleProfile = styleManager.profile {
                if selectedImages.count > 1 {
                    // Multi-screenshot with style
                    response = try await GeminiService.shared.generateStyledReplyMultiImage(
                        images: selectedImages,
                        relationship: selectedRelationship.rawValue,
                        context: contextText,
                        styleProfile: styleProfile.styleAnalysis
                    )
                } else {
                    response = try await GeminiService.shared.generateStyledReply(
                        image: selectedImages[0],
                        relationship: selectedRelationship.rawValue,
                        context: contextText,
                        styleProfile: styleProfile.styleAnalysis
                    )
                }
            } else {
                if selectedImages.count > 1 {
                    // Multi-screenshot without style
                    response = try await GeminiService.shared.generateReplyMultiImage(
                        images: selectedImages,
                        relationship: selectedRelationship.rawValue,
                        tone: selectedTone.rawValue,
                        context: contextText
                    )
                } else {
                    let prompt = buildPrompt()
                    response = try await GeminiService.shared.generateResponse(image: selectedImages[0], prompt: prompt)
                }
            }
            
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
    
    /// Loads images from the PhotosPickerItems
    func loadImages() async {
        guard !imageSelections.isEmpty else { return }
        
        var loadedImages: [UIImage] = []
        
        for selection in imageSelections {
            do {
                if let data = try await selection.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    loadedImages.append(image)
                }
            } catch {
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
        
        // Respect the max limit
        selectedImages = Array(loadedImages.prefix(maxScreenshots))
        
        // Show paywall prompt if they tried to add more than allowed
        if loadedImages.count > maxScreenshots && !isPro {
            errorMessage = "Upgrade to Pro to add up to \(MultiScreenshotConstants.proMaxScreenshots) screenshots for better context!"
        }
    }
    
    /// Removes an image at the specified index
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        if index < imageSelections.count {
            imageSelections.remove(at: index)
        }
    }
    
    /// Clears all images
    func clearImages() {
        selectedImages.removeAll()
        imageSelections.removeAll()
    }
    
    /// Clears all input and output data
    func reset() {
        selectedImages.removeAll()
        imageSelections.removeAll()
        selectedRelationship = .friend
        selectedTone = .friendly
        useMyStyle = false
        contextText = ""
        generatedReply = ""
        errorMessage = nil
    }
}
