//
//  DecodeAnalysis.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import Foundation

// MARK: - Decode Analysis Model

/// Represents a psychological analysis of a message
struct DecodeAnalysis: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    
    /// Overall mood assessment
    let overallMood: String
    
    /// Mood score from 1-10 (1 = very negative, 10 = very positive)
    let moodScore: Int
    
    /// Emotional state of the sender
    let emotionalState: String
    
    /// What they're really trying to say
    let hiddenMeaning: String
    
    /// Specific text cues and what they mean
    let textCues: [TextCue]
    
    /// Relationship dynamics assessment
    let relationshipDynamics: String
    
    /// What they want from you
    let whatTheyWant: String
    
    /// Recommended approach for responding
    let recommendedApproach: String
    
    /// Red flags or concerns (if any)
    let redFlags: [String]
    
    /// Green flags or positive signs (if any)
    let greenFlags: [String]
    
    /// One-line summary
    let summary: String
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        overallMood: String,
        moodScore: Int,
        emotionalState: String,
        hiddenMeaning: String,
        textCues: [TextCue],
        relationshipDynamics: String,
        whatTheyWant: String,
        recommendedApproach: String,
        redFlags: [String],
        greenFlags: [String],
        summary: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.overallMood = overallMood
        self.moodScore = moodScore
        self.emotionalState = emotionalState
        self.hiddenMeaning = hiddenMeaning
        self.textCues = textCues
        self.relationshipDynamics = relationshipDynamics
        self.whatTheyWant = whatTheyWant
        self.recommendedApproach = recommendedApproach
        self.redFlags = redFlags
        self.greenFlags = greenFlags
        self.summary = summary
    }
}

// MARK: - Text Cue

/// A specific text element and its psychological meaning
struct TextCue: Codable, Identifiable {
    let id: UUID
    
    /// The actual text or pattern observed
    let observation: String
    
    /// What it means psychologically
    let meaning: String
    
    /// Significance level: low, medium, high
    let significance: String
    
    init(id: UUID = UUID(), observation: String, meaning: String, significance: String) {
        self.id = id
        self.observation = observation
        self.meaning = meaning
        self.significance = significance
    }
}

// MARK: - Mood Indicator

/// Visual representation of mood
enum MoodIndicator {
    case veryNegative  // 1-2
    case negative      // 3-4
    case neutral       // 5-6
    case positive      // 7-8
    case veryPositive  // 9-10
    
    init(score: Int) {
        switch score {
        case 1...2: self = .veryNegative
        case 3...4: self = .negative
        case 5...6: self = .neutral
        case 7...8: self = .positive
        default: self = .veryPositive
        }
    }
    
    var emoji: String {
        switch self {
        case .veryNegative: return "😠"
        case .negative: return "😕"
        case .neutral: return "😐"
        case .positive: return "🙂"
        case .veryPositive: return "😊"
        }
    }
    
    var color: String {
        switch self {
        case .veryNegative: return "red"
        case .negative: return "orange"
        case .neutral: return "yellow"
        case .positive: return "green"
        case .veryPositive: return "mint"
        }
    }
    
    var label: String {
        switch self {
        case .veryNegative: return "Very Negative"
        case .negative: return "Negative"
        case .neutral: return "Neutral"
        case .positive: return "Positive"
        case .veryPositive: return "Very Positive"
        }
    }
}

