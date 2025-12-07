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
final class GeminiService {
    
    /// The Gemini generative model instance
    private let model: GenerativeModel
    
    /// Shared singleton instance
    static let shared = GeminiService()
    
    /// Initializes the Gemini service with the API key from Secrets
    private init() {
        self.model = GenerativeModel(
            name: "gemini-2.5-flash",
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
            image
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
    
    // MARK: - Style Mimicry
    
    /// Analyzes multiple message screenshots to learn the user's writing style
    /// - Parameter samples: Array of UIImages containing the user's messages
    /// - Returns: A JSON string describing the user's writing style
    /// - Throws: An error if the analysis fails
    func analyzeWritingStyle(samples: [UIImage]) async throws -> String {
        guard !samples.isEmpty else {
            throw GeminiError.noSamplesProvided
        }
        
        let prompt = """
        You are a writing style analyst. Analyze the following screenshots of text messages sent by the user and create a detailed profile of their unique writing style.
        
        Analyze and identify:
        
        1. **Tone & Personality**: Are they formal, casual, playful, sarcastic, warm, etc.?
        
        2. **Emoji Usage**: 
           - Do they use emojis? How frequently?
           - Which emojis do they prefer?
           - Where do they place emojis (beginning, end, inline)?
        
        3. **Punctuation Style**:
           - Do they use periods at the end of messages?
           - Multiple exclamation marks or question marks?
           - Ellipsis usage?
        
        4. **Capitalization**:
           - Proper capitalization, all lowercase, or mixed?
           - Do they capitalize for emphasis?
        
        5. **Message Length**:
           - Short and concise or longer explanations?
           - Single messages or multiple short ones?
        
        6. **Slang & Vocabulary**:
           - Common slang terms they use
           - Abbreviations (lol, omg, btw, etc.)
           - Unique phrases or expressions
        
        7. **Response Patterns**:
           - How do they start messages?
           - How do they end messages?
           - Filler words they use
        
        Return your analysis as a JSON object with these exact keys:
        {
            "tone": "description of their tone",
            "emoji_usage": "description of emoji patterns",
            "favorite_emojis": ["list", "of", "emojis"],
            "punctuation_style": "description",
            "capitalization": "description",
            "average_message_length": "short/medium/long",
            "common_slang": ["list", "of", "slang"],
            "common_abbreviations": ["list", "of", "abbreviations"],
            "greeting_style": "how they start messages",
            "closing_style": "how they end messages",
            "unique_traits": ["list", "of", "unique", "characteristics"],
            "overall_summary": "2-3 sentence summary of their writing style"
        }
        
        Respond ONLY with the JSON object, no other text.
        """
        
        // Build content array with all images
        var content: [any ThrowingPartsRepresentable] = [prompt]
        for image in samples {
            content.append(image)
        }
        
        let response = try await model.generateContent(content)
        
        guard let text = response.text else {
            throw GeminiError.noTextInResponse
        }
        
        return text
    }
    
    /// Generates a reply using the user's personal writing style
    /// - Parameters:
    ///   - image: The conversation screenshot to reply to
    ///   - relationship: The relationship with the message sender
    ///   - context: Additional context
    ///   - styleProfile: The user's analyzed writing style (JSON string)
    ///   - contactNotes: Notes about this specific contact (optional)
    /// - Returns: A reply matching the user's style
    /// - Throws: An error if generation fails
    func generateStyledReply(
        image: UIImage,
        relationship: String,
        context: String,
        styleProfile: String,
        contactNotes: String = ""
    ) async throws -> String {
        var prompt = """
        You are a message reply assistant that MUST match the user's personal writing style exactly.
        
        ## USER'S WRITING STYLE PROFILE:
        \(styleProfile)
        
        ## TASK:
        Analyze the conversation screenshot and generate a reply that:
        1. Responds appropriately to the conversation
        2. EXACTLY matches the user's writing style from the profile above
        3. Uses their emoji patterns, slang, punctuation, and tone
        4. Feels like the user actually wrote it
        
        ## CONTEXT:
        - Relationship with sender: \(relationship)
        \(context.isEmpty ? "" : "- Additional context: \(context)")
        """
        
        if !contactNotes.isEmpty {
            prompt += """
            
            
            ## IMPORTANT - CONTACT-SPECIFIC RULES:
            \(contactNotes)
            
            You MUST follow these rules when generating the reply for this specific person.
            """
        }
        
        prompt += """
        
        
        ## RULES:
        - Match the language of the conversation
        - Use the EXACT style characteristics from the profile
        - If they use lowercase, use lowercase
        - If they use specific emojis, use those emojis
        - If they use slang, use that slang
        - Match their typical message length
        
        Generate ONLY the reply message text, nothing else.
        """
        
        let response = try await model.generateContent(prompt, image)
        
        guard let text = response.text else {
            throw GeminiError.noTextInResponse
        }
        
        return text
    }
    
    // MARK: - Multi-Screenshot Context (Full Story)
    
    /// Generates a reply using multiple conversation screenshots for full context
    /// - Parameters:
    ///   - images: Array of conversation screenshots (in chronological order)
    ///   - relationship: The relationship with the message sender
    ///   - tone: The desired tone for the reply
    ///   - context: Additional context
    ///   - contactNotes: Notes about this specific contact (optional)
    /// - Returns: A contextually accurate reply
    /// - Throws: An error if generation fails
    func generateReplyMultiImage(
        images: [UIImage],
        relationship: String,
        tone: String,
        context: String,
        contactNotes: String = ""
    ) async throws -> String {
        guard !images.isEmpty else {
            throw GeminiError.noSamplesProvided
        }
        
        var prompt = """
        You are a helpful assistant that generates reply messages. 
        
        I'm showing you \(images.count) screenshots of a message conversation in chronological order (first image = earliest messages, last image = most recent messages). Please analyze the FULL conversation history across all screenshots and generate an appropriate reply.
        
        **Instructions:**
        - The person I'm replying to is my \(relationship.lowercased()).
        - I want the reply to have a \(tone.lowercased()) tone.
        - Consider the ENTIRE conversation context from all screenshots.
        - Pay attention to how the conversation has evolved over time.
        - Generate ONLY the reply message text, nothing else.
        - Keep the reply natural and conversational.
        - Match the language used in the conversation.
        """
        
        if !contactNotes.isEmpty {
            prompt += """
            
            
            **IMPORTANT - Remember these things about this person:**
            \(contactNotes)
            
            You MUST follow these rules when generating the reply.
            """
        }
        
        if !context.isEmpty {
            prompt += """
            
            
            **Additional context from me:**
            \(context)
            """
        }
        
        prompt += """
        
        
        Now, analyze ALL the images together and generate an appropriate reply message that takes into account the full conversation history.
        """
        
        // Build content array with prompt and all images
        var content: [any ThrowingPartsRepresentable] = [prompt]
        for image in images {
            content.append(image)
        }
        
        let response = try await model.generateContent(content)
        
        guard let text = response.text else {
            throw GeminiError.noTextInResponse
        }
        
        return text
    }
    
    /// Generates a styled reply using multiple conversation screenshots
    /// - Parameters:
    ///   - images: Array of conversation screenshots (in chronological order)
    ///   - relationship: The relationship with the message sender
    ///   - context: Additional context
    ///   - styleProfile: The user's analyzed writing style (JSON string)
    ///   - contactNotes: Notes about this specific contact (optional)
    /// - Returns: A reply matching the user's style with full context
    /// - Throws: An error if generation fails
    func generateStyledReplyMultiImage(
        images: [UIImage],
        relationship: String,
        context: String,
        styleProfile: String,
        contactNotes: String = ""
    ) async throws -> String {
        guard !images.isEmpty else {
            throw GeminiError.noSamplesProvided
        }
        
        var prompt = """
        You are a message reply assistant that MUST match the user's personal writing style exactly.
        
        ## USER'S WRITING STYLE PROFILE:
        \(styleProfile)
        
        ## TASK:
        I'm showing you \(images.count) screenshots of a message conversation in chronological order (first image = earliest messages, last image = most recent messages). Analyze the FULL conversation history and generate a reply that:
        1. Responds appropriately to the conversation considering ALL context
        2. EXACTLY matches the user's writing style from the profile above
        3. Uses their emoji patterns, slang, punctuation, and tone
        4. Feels like the user actually wrote it
        5. Takes into account how the conversation has evolved
        
        ## CONTEXT:
        - Relationship with sender: \(relationship)
        \(context.isEmpty ? "" : "- Additional context: \(context)")
        """
        
        if !contactNotes.isEmpty {
            prompt += """
            
            
            ## IMPORTANT - CONTACT-SPECIFIC RULES:
            \(contactNotes)
            
            You MUST follow these rules when generating the reply for this specific person.
            """
        }
        
        prompt += """
        
        
        ## RULES:
        - Consider the ENTIRE conversation from all screenshots
        - Match the language of the conversation
        - Use the EXACT style characteristics from the profile
        - If they use lowercase, use lowercase
        - If they use specific emojis, use those emojis
        - If they use slang, use that slang
        - Match their typical message length
        
        Generate ONLY the reply message text, nothing else.
        """
        
        // Build content array with prompt and all images
        var content: [any ThrowingPartsRepresentable] = [prompt]
        for image in images {
            content.append(image)
        }
        
        let response = try await model.generateContent(content)
        
        guard let text = response.text else {
            throw GeminiError.noTextInResponse
        }
        
        return text
    }
    
    // MARK: - Decode Message (Dating Coach Analysis)
    
    /// Analyzes a message screenshot to decode the sender's psychology
    /// - Parameters:
    ///   - image: The conversation screenshot to analyze
    ///   - relationship: The relationship with the message sender
    ///   - context: Additional context about the situation
    /// - Returns: A DecodeAnalysis object with psychological insights
    /// - Throws: An error if analysis fails
    func decodeMessage(
        image: UIImage,
        relationship: String,
        context: String
    ) async throws -> DecodeAnalysis {
        let prompt = """
        You are an expert dating coach and communication psychologist. Analyze this message screenshot and provide a detailed psychological breakdown of the sender.
        
        ## CONTEXT:
        - Relationship: \(relationship)
        \(context.isEmpty ? "" : "- Background: \(context)")
        
        ## ANALYZE THE FOLLOWING:
        
        1. **Overall Mood**: What is the sender's general mood/vibe?
        2. **Mood Score**: Rate their mood from 1-10 (1=very negative/angry, 5=neutral, 10=very positive/happy)
        3. **Emotional State**: What emotions are they experiencing?
        4. **Hidden Meaning**: What are they REALLY trying to say? Read between the lines.
        5. **Text Cues**: Identify specific text patterns that reveal their psychology:
           - Punctuation choices (periods = coldness, exclamation = enthusiasm, etc.)
           - Emoji usage or lack thereof
           - Response length and timing implications
           - Word choices and tone indicators
        6. **Relationship Dynamics**: What does this message reveal about how they view the relationship?
        7. **What They Want**: What outcome or response are they hoping for?
        8. **Red Flags**: Any concerning patterns or warning signs?
        9. **Green Flags**: Any positive signs or healthy communication?
        10. **Recommended Approach**: How should the recipient respond?
        
        Return your analysis as a JSON object with these EXACT keys:
        {
            "overall_mood": "description of their mood",
            "mood_score": 7,
            "emotional_state": "description of emotions",
            "hidden_meaning": "what they really mean",
            "text_cues": [
                {
                    "observation": "what you noticed (e.g., 'They ended with a period')",
                    "meaning": "what it means (e.g., 'This suggests coldness or finality')",
                    "significance": "low/medium/high"
                }
            ],
            "relationship_dynamics": "analysis of relationship dynamics",
            "what_they_want": "what they're hoping for",
            "recommended_approach": "how to respond",
            "red_flags": ["list of concerns if any"],
            "green_flags": ["list of positive signs if any"],
            "summary": "One powerful sentence summarizing the key insight"
        }
        
        Be insightful, specific, and helpful. Focus on actionable insights.
        Respond ONLY with the JSON object, no other text.
        """
        
        let response = try await model.generateContent(prompt, image)
        
        guard let text = response.text else {
            throw GeminiError.noTextInResponse
        }
        
        // Parse the JSON response
        return try parseDecodeAnalysis(from: text)
    }
    
    /// Parses JSON response into DecodeAnalysis object
    private func parseDecodeAnalysis(from jsonString: String) throws -> DecodeAnalysis {
        // Clean up the JSON string (remove markdown code blocks if present)
        var cleanedJSON = jsonString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedJSON.data(using: .utf8) else {
            throw GeminiError.jsonParsingFailed
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let json = json else {
                throw GeminiError.jsonParsingFailed
            }
            
            // Parse text cues
            var textCues: [TextCue] = []
            if let cuesArray = json["text_cues"] as? [[String: Any]] {
                for cue in cuesArray {
                    let textCue = TextCue(
                        observation: cue["observation"] as? String ?? "",
                        meaning: cue["meaning"] as? String ?? "",
                        significance: cue["significance"] as? String ?? "medium"
                    )
                    textCues.append(textCue)
                }
            }
            
            return DecodeAnalysis(
                overallMood: json["overall_mood"] as? String ?? "Unknown",
                moodScore: json["mood_score"] as? Int ?? 5,
                emotionalState: json["emotional_state"] as? String ?? "Unknown",
                hiddenMeaning: json["hidden_meaning"] as? String ?? "Unable to determine",
                textCues: textCues,
                relationshipDynamics: json["relationship_dynamics"] as? String ?? "Unknown",
                whatTheyWant: json["what_they_want"] as? String ?? "Unknown",
                recommendedApproach: json["recommended_approach"] as? String ?? "Respond thoughtfully",
                redFlags: json["red_flags"] as? [String] ?? [],
                greenFlags: json["green_flags"] as? [String] ?? [],
                summary: json["summary"] as? String ?? "Analysis complete"
            )
        } catch {
            throw GeminiError.jsonParsingFailed
        }
    }
}

/// Custom errors for the Gemini service
enum GeminiError: LocalizedError {
    case noTextInResponse
    case imageConversionFailed
    case noSamplesProvided
    case jsonParsingFailed
    case networkError
    case apiKeyInvalid
    case rateLimitExceeded
    case serverError
    case safetyBlocked
    case invalidRequest
    case modelNotFound
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .noTextInResponse:
            return "The AI couldn't generate a response. Please try again."
        case .imageConversionFailed:
            return "Unable to process the image. Please try a different screenshot."
        case .noSamplesProvided:
            return "Please select at least one screenshot to analyze."
        case .jsonParsingFailed:
            return "Something went wrong while processing the response. Please try again."
        case .networkError:
            return "No internet connection. Please check your network and try again."
        case .apiKeyInvalid:
            return "Invalid API key. Please check your configuration."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        case .serverError:
            return "The AI service is temporarily unavailable. Please try again later."
        case .safetyBlocked:
            return "The content was blocked by safety filters. Please try a different screenshot."
        case .invalidRequest:
            return "Unable to process this request. Please try again with a different image."
        case .modelNotFound:
            return "AI model not available. Please update the app or try again later."
        case .unknown(let message):
            return "Something went wrong. Please try again. (\(message))"
        }
    }
}

/// Helper to convert API errors to user-friendly messages
func mapAPIError(_ error: Error) -> GeminiError {
    let errorString = String(describing: error).lowercased()
    let localizedString = error.localizedDescription.lowercased()
    
    // Check for GoogleGenerativeAI specific errors
    if errorString.contains("generatecontenterror") {
        // GenerateContentError cases
        if errorString.contains("internalerror") || errorString.contains("error 0") {
            return .serverError
        } else if errorString.contains("promptblocked") || errorString.contains("safety") || errorString.contains("error 2") {
            return .safetyBlocked
        } else if errorString.contains("responsestopped") || errorString.contains("error 3") {
            return .safetyBlocked
        } else if errorString.contains("invalidapikey") || errorString.contains("error 1") {
            return .apiKeyInvalid
        } else if errorString.contains("unsupporteduserinput") {
            return .invalidRequest
        }
    }
    
    // Network errors
    if localizedString.contains("network") || localizedString.contains("internet") || 
       localizedString.contains("offline") || localizedString.contains("connection") ||
       localizedString.contains("timed out") || errorString.contains("nsurlerror") {
        return .networkError
    }
    
    // API key errors
    if localizedString.contains("api key") || localizedString.contains("invalid key") || 
       localizedString.contains("unauthorized") || localizedString.contains("401") ||
       localizedString.contains("permission") || localizedString.contains("forbidden") {
        return .apiKeyInvalid
    }
    
    // Rate limiting
    if localizedString.contains("rate limit") || localizedString.contains("quota") || 
       localizedString.contains("429") || localizedString.contains("too many") {
        return .rateLimitExceeded
    }
    
    // Server errors
    if localizedString.contains("500") || localizedString.contains("502") || 
       localizedString.contains("503") || localizedString.contains("server") ||
       localizedString.contains("internal error") {
        return .serverError
    }
    
    // Model errors
    if localizedString.contains("model") && (localizedString.contains("not found") || localizedString.contains("unavailable")) {
        return .modelNotFound
    }
    
    // Default: return simplified message
    return .unknown("Please check your internet connection and try again")
}

