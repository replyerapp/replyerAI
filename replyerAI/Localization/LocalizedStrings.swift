//
//  LocalizedStrings.swift
//  replyerAI
//
//  Created by Ege Can Koç on 4.12.2025.
//

import Foundation
import SwiftUI

// MARK: - Localization Helper
/// A centralized place for all localized strings in the app
/// Usage: Text(L10n.appName) or String(localized: "key")

enum L10n {
    // MARK: - App General
    static let appName = String(localized: "app_name")
    static let pro = String(localized: "pro")
    static let done = String(localized: "done")
    static let cancel = String(localized: "cancel")
    static let save = String(localized: "save")
    static let delete = String(localized: "delete")
    static let close = String(localized: "close")
    static let upgrade = String(localized: "upgrade")
    static let select = String(localized: "select")
    static let none = String(localized: "none")
    static let add = String(localized: "add")
    static let edit = String(localized: "edit")
    static let reset = String(localized: "reset")
    
    // MARK: - Subscription
    static let freePlan = String(localized: "free_plan")
    static func generationsLeftToday(_ remaining: Int, _ total: Int) -> String {
        String(format: String(localized: "generations_left_today"), remaining, total)
    }
    static let dailyLimitReached = String(localized: "daily_limit_reached")
    static func freeGenerationsRemaining(_ count: Int) -> String {
        String(format: String(localized: "free_generations_remaining"), count)
    }
    
    // MARK: - Photo Picker
    static let screenshots = String(localized: "screenshots")
    static let fullStoryMode = String(localized: "full_story_mode")
    static let selectScreenshot = String(localized: "select_screenshot")
    static let selectScreenshots = String(localized: "select_screenshots")
    static let tapToChooseScreenshot = String(localized: "tap_to_choose_screenshot")
    static func addScreenshotsForContext(_ max: Int) -> String {
        String(format: String(localized: "add_screenshots_for_context"), max)
    }
    static let upgradeForMultiScreenshot = String(localized: "upgrade_for_multi_screenshot")
    static let addMore = String(localized: "add_more")
    static let clearAll = String(localized: "clear_all")
    static let screenshotTip = String(localized: "screenshot_tip")
    static let removeImage = String(localized: "remove_image")
    
    // MARK: - Pro Features
    static let proFeatures = String(localized: "pro_features")
    static let fullStoryModeTitle = String(localized: "full_story_mode_title")
    static func fullStoryModeDescActive(_ max: Int) -> String {
        String(format: String(localized: "full_story_mode_desc_active"), max)
    }
    static let fullStoryModeDescLocked = String(localized: "full_story_mode_desc_locked")
    static let myStyle = String(localized: "my_style")
    static let myStyleActive = String(localized: "my_style_active")
    static let myStyleConfigure = String(localized: "my_style_configure")
    static let myStyleTrain = String(localized: "my_style_train")
    static let decodeMessage = String(localized: "decode_message")
    static let decodeMessageDesc = String(localized: "decode_message_desc")
    static let contactProfiles = String(localized: "contact_profiles")
    static let contactProfilesDesc = String(localized: "contact_profiles_desc")
    static func profilesSaved(_ count: Int) -> String {
        String(format: String(localized: "profiles_saved"), count)
    }
    
    // MARK: - Settings Section
    static let settings = String(localized: "settings")
    static let relationship = String(localized: "relationship")
    static let tone = String(localized: "tone")
    static let useMyStyle = String(localized: "use_my_style")
    static func settingsFromProfile(_ name: String) -> String {
        String(format: String(localized: "settings_from_profile"), name)
    }
    
    // MARK: - Relationships
    static let wife = String(localized: "wife")
    static let husband = String(localized: "husband")
    static let girlfriend = String(localized: "girlfriend")
    static let boyfriend = String(localized: "boyfriend")
    static let situationship = String(localized: "situationship")
    static let boss = String(localized: "boss")
    static let coworker = String(localized: "coworker")
    static let friend = String(localized: "friend")
    static let bestFriend = String(localized: "best_friend")
    static let parent = String(localized: "parent")
    static let sibling = String(localized: "sibling")
    static let exPartner = String(localized: "ex_partner")
    static let acquaintance = String(localized: "acquaintance")
    static let stranger = String(localized: "stranger")
    
    // MARK: - Tones
    static let angry = String(localized: "angry")
    static let funny = String(localized: "funny")
    static let professional = String(localized: "professional")
    static let sarcastic = String(localized: "sarcastic")
    static let passiveAggressive = String(localized: "passive_aggressive")
    static let romantic = String(localized: "romantic")
    static let apologetic = String(localized: "apologetic")
    static let assertive = String(localized: "assertive")
    static let friendly = String(localized: "friendly")
    static let formal = String(localized: "formal")
    static let casual = String(localized: "casual")
    static let sympathetic = String(localized: "sympathetic")
    static let flirty = String(localized: "flirty")
    
    // MARK: - Context
    static let additionalContext = String(localized: "additional_context")
    static let contextPlaceholder = String(localized: "context_placeholder")
    
    // MARK: - Generate Button
    static let generateReply = String(localized: "generate_reply")
    static let generating = String(localized: "generating")

    // MARK: - Onboarding
    static let onboardingTitle1 = String(localized: "onboarding_title_1")
    static let onboardingSubtitle1 = String(localized: "onboarding_subtitle_1")
    static let onboardingTitle2 = String(localized: "onboarding_title_2")
    static let onboardingSubtitle2 = String(localized: "onboarding_subtitle_2")
    static let onboardingTitle3 = String(localized: "onboarding_title_3")
    static let onboardingSubtitle3 = String(localized: "onboarding_subtitle_3")
    static let onboardingTitle4 = String(localized: "onboarding_title_4")
    static let onboardingSubtitle4 = String(localized: "onboarding_subtitle_4")
    static let onboardingNext = String(localized: "onboarding_next")
    static let onboardingStart = String(localized: "onboarding_start")

    // MARK: - Privacy Notices
    static let screenshotPrivacyNotice = String(localized: "screenshot_privacy_notice")
    
    // MARK: - Result Section
    static let generatedReply = String(localized: "generated_reply")
    static let copyText = String(localized: "copy_text")
    static let shareCard = String(localized: "share_card")
    static let copied = String(localized: "copied")
    static let shareYourReply = String(localized: "share_your_reply")
    static let shareAsImage = String(localized: "share_as_image")
    static let shareAsText = String(localized: "share_as_text")
    static let generatedBy = String(localized: "generated_by")
    static func forRelationship(_ relationship: String) -> String {
        String(format: String(localized: "for_relationship"), relationship)
    }
    
    // MARK: - Contact Profiles
    static let contactProfile = String(localized: "contact_profile")
    static let manage = String(localized: "manage")
    static let noContactProfiles = String(localized: "no_contact_profiles")
    static let contactProfilesEmptyDesc = String(localized: "contact_profiles_empty_desc")
    static let createFirstProfile = String(localized: "create_first_profile")
    static let addProfile = String(localized: "add_profile")
    static let editProfile = String(localized: "edit_profile")
    static let newProfile = String(localized: "new_profile")
    static let basicInfo = String(localized: "basic_info")
    static let name = String(localized: "name")
    static let emoji = String(localized: "emoji")
    static let notesForAI = String(localized: "notes_for_ai")
    static let notesPlaceholder = String(localized: "notes_placeholder")
    static let notesFooter = String(localized: "notes_footer")
    static let defaultTone = String(localized: "default_tone")
    static let setPreferredTone = String(localized: "set_preferred_tone")
    static let toneFooter = String(localized: "tone_footer")
    static let deleteProfile = String(localized: "delete_profile")
    static let swipeToDelete = String(localized: "swipe_to_delete")
    static let noneManual = String(localized: "none_manual")
    static let manageProfiles = String(localized: "manage_profiles")
    static let chooseEmoji = String(localized: "choose_emoji")
    static let useDefault = String(localized: "use_default")
    
    // MARK: - Style Mimicry
    static let teachAIYourStyle = String(localized: "teach_ai_your_style")
    static let styleMimicryDesc = String(localized: "style_mimicry_desc")
    static let styleProfileActive = String(localized: "style_profile_active")
    static let samplesAnalyzed = String(localized: "samples_analyzed")
    static let lastUpdated = String(localized: "last_updated")
    static let styleActiveDesc = String(localized: "style_active_desc")
    static let updateYourStyle = String(localized: "update_your_style")
    static let addYourMessages = String(localized: "add_your_messages")
    static func minimumSamples(_ current: Int, _ required: Int) -> String {
        String(format: String(localized: "minimum_samples"), current, required)
    }
    static let useYourMessages = String(localized: "use_your_messages")
    static let includeDifferentTypes = String(localized: "include_different_types")
    static let dontUseOthers = String(localized: "dont_use_others")
    static let analyzeSaveStyle = String(localized: "analyze_save_style")
    static let analyzingStyle = String(localized: "analyzing_style")
    static let deleteStyleProfile = String(localized: "delete_style_profile")
    static let deleteStyleConfirm = String(localized: "delete_style_confirm")
    
    // MARK: - Decode Message
    static let decodeTheirMessage = String(localized: "decode_their_message")
    static let decodeDesc = String(localized: "decode_desc")
    static let selectMessageScreenshot = String(localized: "select_message_screenshot")
    static let chooseConversation = String(localized: "choose_conversation")
    static let context = String(localized: "context")
    static let backstoryOptional = String(localized: "backstory_optional")
    static let decodeMessageButton = String(localized: "decode_message_button")
    static let analyzing = String(localized: "analyzing")
    static let moodAnalysis = String(localized: "mood_analysis")
    static let quickSummary = String(localized: "quick_summary")
    static let whatTheyReallyMean = String(localized: "what_they_really_mean")
    static let emotionalState = String(localized: "emotional_state")
    static let whatTheyWant = String(localized: "what_they_want")
    static let textCuesDetected = String(localized: "text_cues_detected")
    static let relationshipDynamics = String(localized: "relationship_dynamics")
    static let howToRespond = String(localized: "how_to_respond")
    static let redFlags = String(localized: "red_flags")
    static let greenFlags = String(localized: "green_flags")
    
    // MARK: - Settings Screen
    static let appearance = String(localized: "appearance")
    static let appearanceFooter = String(localized: "appearance_footer")
    static let system = String(localized: "system")
    static let light = String(localized: "light")
    static let dark = String(localized: "dark")
    static let general = String(localized: "general")
    static let shareApp = String(localized: "share_app")
    static let rateUs = String(localized: "rate_us")
    static let termsOfUse = String(localized: "terms_of_use")
    static let privacyPolicy = String(localized: "privacy_policy")
    static let appVersion = String(localized: "app_version")
    static let support = String(localized: "support")
    static let feedbackSuggestions = String(localized: "feedback_suggestions")
    
    // MARK: - Subscription Management
    static let subscription = String(localized: "subscription")
    static let manageSubscription = String(localized: "manage_subscription")
    static let upgradeToPro = String(localized: "upgrade_to_pro")
    static let unlockAllFeatures = String(localized: "unlock_all_features")
    static let restorePurchases = String(localized: "restore_purchases")
    static let plan = String(localized: "plan")
    static let renewsOn = String(localized: "renews_on")
    static let status = String(localized: "status")
    static let lifetime = String(localized: "lifetime")
    static let cancelSubscription = String(localized: "cancel_subscription")
    static let cancelSubscriptionFooter = String(localized: "cancel_subscription_footer")
    static let subscriptionActiveUntilEnd = String(localized: "subscription_active_until_end")
    static let autoRenewInfo = String(localized: "auto_renew_info")
    static let billedThroughApple = String(localized: "billed_through_apple")
    static let importantInformation = String(localized: "important_information")
    static let monthlyPlan = String(localized: "monthly_plan")
    static let yearlyPlan = String(localized: "yearly_plan")
    static let lifetimePlan = String(localized: "lifetime_plan")
    static let proPlan = String(localized: "pro_plan")
    
    // MARK: - Image Editor
    static let yourReply = String(localized: "your_reply")
    static let customize = String(localized: "customize")
    static let background = String(localized: "background")
    static let textColor = String(localized: "text_color")
    static let textGradient = String(localized: "text_gradient")
    static let shuffle = String(localized: "shuffle")
    static let cornerStyle = String(localized: "corner_style")
    static let sharp = String(localized: "sharp")
    static let smooth = String(localized: "smooth")
    static let round = String(localized: "round")
    static let downloadImage = String(localized: "download_image")
    static let savedToPhotos = String(localized: "saved_to_photos")
    static let imageSaved = String(localized: "image_saved")
    static let imageSavedMessage = String(localized: "image_saved_message")
    static let createdWithReplyer = String(localized: "created_with_replyer")
    
    // MARK: - Errors
    static let pleaseSelectImage = String(localized: "please_select_image")
    static let errorOccurred = String(localized: "error_occurred")
}

// MARK: - Relationship Localization Extension
extension Relationship {
    var localizedName: String {
        switch self {
        case .wife: return L10n.wife
        case .husband: return L10n.husband
        case .girlfriend: return L10n.girlfriend
        case .boyfriend: return L10n.boyfriend
        case .situationship: return L10n.situationship
        case .boss: return L10n.boss
        case .coworker: return L10n.coworker
        case .friend: return L10n.friend
        case .bestFriend: return L10n.bestFriend
        case .parent: return L10n.parent
        case .sibling: return L10n.sibling
        case .exPartner: return L10n.exPartner
        case .acquaintance: return L10n.acquaintance
        case .stranger: return L10n.stranger
        }
    }
}

// MARK: - Tone Localization Extension
extension Tone {
    var localizedName: String {
        switch self {
        case .angry: return L10n.angry
        case .funny: return L10n.funny
        case .professional: return L10n.professional
        case .sarcastic: return L10n.sarcastic
        case .passiveAggressive: return L10n.passiveAggressive
        case .romantic: return L10n.romantic
        case .apologetic: return L10n.apologetic
        case .assertive: return L10n.assertive
        case .friendly: return L10n.friendly
        case .formal: return L10n.formal
        case .casual: return L10n.casual
        case .sympathetic: return L10n.sympathetic
        case .flirty: return L10n.flirty
        }
    }
}

