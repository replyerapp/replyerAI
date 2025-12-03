//
//  GeminiService.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import Foundation
import UIKit
import GoogleGenerativeAI

/// Service class for interacting with Google's Gemini AI model.
@MainActor
final class GeminiService: ObservableObject {
    
    /// The Gemini generative model instance
    private let model: GenerativeModel
    
    /// Shared singleton instance
    static let shared = GeminiService()
    
    /// Initializes the Gemini service with the API key from Secrets
    private init() {
        self.model = GenerativeModel(
            name: "gemini-2.0-flash",
            apiKey: Secrets.geminiAPIKey
        )
    }
    
    /// Generates a response from the Gemini model for the given prompt
    /// - Parameter prompt: The text prompt to send to the model
    /// - Returns: The generated text response
    /// - Throws: An error if the generation fails
    func generateResponse(prompt: String) async throws -> String {
        let response = try await model.generateContent(prompt)
        
        guard let text = response.text else {
            throw GeminiError.noTextInResponse
        }
        
        return text
    }
    
    /// Generates a response from the Gemini model using an image and prompt
    /// - Parameters:
    ///   - image: The UIImage to analyze
    ///   - prompt: The text prompt to send with the image
    /// - Returns: The generated text response
    /// - Throws: An error if the generation fails
    func generateResponse(image: UIImage, prompt: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw GeminiError.imageConversionFailed
        }
        
        let response = try await model.generateContent(
            prompt,
            imageData,
            "image/jpeg"
        )
        
        guard let text = response.text else {
            throw GeminiError.noTextInResponse
        }
        
        return text
    }
    
    /// Generates a response using a chat conversation
    /// - Parameters:
    ///   - messages: Array of previous messages in the conversation
    ///   - newMessage: The new message to send
    /// - Returns: The generated text response
    /// - Throws: An error if the generation fails
    func chat(history: [ModelContent], message: String) async throws -> String {
        let chat = model.startChat(history: history)
        let response = try await chat.sendMessage(message)
        
        guard let text = response.text else {
            throw GeminiError.noTextInResponse
        }
        
        return text
    }
}

/// Custom errors for the Gemini service
enum GeminiError: LocalizedError {
    case noTextInResponse
    case imageConversionFailed
    
    var errorDescription: String? {
        switch self {
        case .noTextInResponse:
            return "The model did not return any text in the response."
        case .imageConversionFailed:
            return "Failed to convert the image to the required format."
        }
    }
}

