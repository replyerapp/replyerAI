# replyerAI - Changelog

## [1.4.0] - 2025-12-03

### Added - Multi-Screenshot Context (Full Story Mode)

#### Overview
Pro users can now upload up to 5 screenshots of a conversation to provide the AI with full context. This results in more accurate and contextually appropriate replies.

#### Updated Files

**ReplyViewModel.swift**:
- Changed `selectedImage: UIImage?` to `selectedImages: [UIImage]` for multi-image support
- Changed `imageSelection: PhotosPickerItem?` to `imageSelections: [PhotosPickerItem]`
- Added `MultiScreenshotConstants` enum:
  - `freeMaxScreenshots`: 1 (free users)
  - `proMaxScreenshots`: 5 (Pro users)
- Added computed properties:
  - `maxScreenshots`: Returns limit based on subscription
  - `canAddMoreScreenshots`: Whether more images can be added
  - `isMultiScreenshotAvailable`: Whether feature is available
  - `hasImages`: Whether any images are selected
  - `selectedImage`: First image (backward compatibility)
- Added methods:
  - `loadImages()`: Loads multiple images from PhotosPickerItems
  - `removeImage(at:)`: Remove specific image by index
  - `clearImages()`: Clear all selected images
- Updated `generateReply()` to use multi-image methods when multiple images selected

**GeminiService.swift**:
- Added `generateReplyMultiImage(images:relationship:tone:context:)`:
  - Accepts array of UIImages in chronological order
  - Prompt instructs AI to consider full conversation history
  - Returns contextually accurate reply
- Added `generateStyledReplyMultiImage(images:relationship:context:styleProfile:)`:
  - Multi-image support with style mimicry
  - Combines full context with user's writing style

**ContentView.swift**:
- Completely redesigned Photo Picker Section:
  - Header showing screenshot count (e.g., "2/5")
  - "Full Story Mode" badge for Pro users
  - Horizontal scrolling gallery of selected screenshots
  - Order indicators (1, 2, 3...) on each screenshot
  - Individual delete buttons on each image
  - "Add More" button when below limit
  - "Clear All" button
- Added `fullStoryFeatureRow` in Pro Features section:
  - Shows lock for free users
  - Shows checkmark and "Active" for Pro users
- Updated empty state:
  - Different icon and text for Pro vs Free users
  - "Upgrade for Multi-Screenshot" button for free users
- Added Pro tip: "Screenshots are analyzed in order. Add oldest first, newest last."
- Updated generate button to use `hasImages` instead of single image check

#### How It Works

1. **Pro Users**: Can select up to 5 screenshots
2. **Free Users**: Limited to 1 screenshot (with upgrade prompt)
3. **Order Matters**: Screenshots should be added oldest to newest
4. **AI Analysis**: Gemini analyzes ALL screenshots together for full context
5. **Better Replies**: More context = more accurate and appropriate replies

#### Use Cases

- Long conversations that span multiple screen lengths
- Complex discussions where context from earlier messages matters
- Arguments or emotional conversations where history is important
- Business negotiations where previous terms were discussed

---

## [1.3.0] - 2025-12-03

### Added - Decode Message (Dating Coach Analysis) Feature

#### New Files

**DecodeMessage/DecodeAnalysis.swift**:
- `DecodeAnalysis` model with comprehensive psychological insights
- `TextCue` model for specific text pattern observations
- `MoodIndicator` enum for visual mood representation
- Properties: mood score, emotional state, hidden meaning, text cues, relationship dynamics, what they want, red/green flags, recommended approach

**DecodeMessage/DecodeMessageView.swift**:
- Complete UI for psychological message analysis
- Image picker for conversation screenshots
- Relationship and context input
- Beautiful analysis results display:
  - Mood score with visual bar (1-10 scale)
  - Emoji mood indicator
  - Hidden meaning insights
  - Emotional state analysis
  - Text cue breakdown with significance levels
  - Red flags and green flags sections
  - Recommended response approach

#### Updated Files

**GeminiService.swift**:
- Added `decodeMessage(image:relationship:context:)` - Full psychological analysis
- Added `parseDecodeAnalysis(from:)` - JSON parsing for analysis results
- Added `jsonParsingFailed` error case
- Prompt engineered for dating coach / communication psychologist insights

**ContentView.swift**:
- Added `showDecodeMessage` state
- Added `decodeMessageFeatureRow` with brain icon
- Navigation to DecodeMessageView for Pro users
- Updated description: "Analyze psychology, mood & hidden meanings"

#### Analysis Includes

1. **Mood Score** (1-10): Visual representation of sender's mood
2. **Emotional State**: What emotions they're experiencing
3. **Hidden Meaning**: What they're REALLY trying to say
4. **Text Cues**: Specific patterns analyzed:
   - Punctuation choices (periods = coldness)
   - Emoji usage or absence
   - Response length implications
   - Word choice analysis
5. **Relationship Dynamics**: How they view the relationship
6. **What They Want**: Their desired outcome
7. **Red Flags**: Warning signs to watch for
8. **Green Flags**: Positive communication signs
9. **Recommended Approach**: How to respond effectively

---

## [1.2.0] - 2025-12-03

### Added - Style Mimicry (Reply Like Me) Feature

#### New Files

**StyleMimicry/StyleProfile.swift**:
- `StyleProfile` model for storing analyzed writing style
- `StyleSample` model for sample screenshots
- `StyleProfileManager` singleton for managing style profiles
- Persistence via UserDefaults
- Constants: minimum 3 samples, maximum 5 samples

**StyleMimicry/StyleMimicryView.swift**:
- Complete UI for teaching AI your writing style
- Multi-image PhotosPicker for sample collection
- Progress indicator for sample collection
- Sample thumbnail grid with delete option
- Instructions for best results
- Analyze & Save button with loading state
- Profile status display for existing profiles

#### Updated Files

**GeminiService.swift**:
- Added `analyzeWritingStyle(samples:)` - Analyzes multiple screenshots to learn user's style
- Added `generateStyledReply(image:relationship:context:styleProfile:)` - Generates replies matching user's style
- Style analysis returns JSON with: tone, emoji usage, punctuation, slang, abbreviations, etc.

**ReplyViewModel.swift**:
- Added `useMyStyle: Bool` toggle for using personal style
- Added `hasStyleProfile` computed property
- Updated `generateReply()` to use styled generation when enabled

**ContentView.swift**:
- Added "Use My Style" toggle in Settings (for Pro users with style profile)
- Updated My Style feature row to show profile status
- Navigation to StyleMimicryView
- Conditional tone picker (hidden when using My Style)

#### How It Works

1. **Collect Samples**: User uploads 3-5 screenshots of their OWN sent messages
2. **AI Analysis**: Gemini analyzes the samples to identify:
   - Tone & personality
   - Emoji usage patterns
   - Punctuation style
   - Capitalization habits
   - Message length preferences
   - Slang & vocabulary
   - Greeting/closing styles
3. **Generate Styled Replies**: When "Use My Style" is enabled, replies match the user's unique writing style

---

## [1.1.0] - 2025-12-03

### Added - RevenueCat Subscription Integration

#### RevenueCat Package Dependency
- Added `RevenueCat/purchases-ios-spm` package dependency (version 5.0.0+)
- Includes both `RevenueCat` and `RevenueCatUI` products
- Package repository: https://github.com/RevenueCat/purchases-ios-spm

#### SubscriptionService.swift
- Created `replyerAI/SubscriptionService.swift` for managing subscriptions
- **Constants**:
  - `proEntitlementID`: "pro_access" - The entitlement ID in RevenueCat
  - `freeUsageLimit`: 3 - Daily free generations
- **Properties**:
  - `isPro: Bool` - Whether user has pro access
  - `dailyUsageCount: Int` - Current daily usage for free users
  - `canGenerate: Bool` - Whether user can generate (pro or within limit)
  - `remainingFreeGenerations: Int` - Remaining free generations today
- **Methods**:
  - `configure()` - Initialize RevenueCat SDK (call in App init)
  - `checkSubscriptionStatus()` - Fetch and update subscription status
  - `incrementUsage()` - Track usage for free users
  - `restorePurchases()` - Restore previous purchases
- **Helper Views**:
  - `ProFeatureLock` - Locked feature placeholder view
  - `.paywallSheet()` - View modifier for presenting RevenueCatUI paywall

#### Subscription Plans (Configure in RevenueCat Dashboard)
- Monthly subscription
- 6-month subscription
- Yearly subscription
- Lifetime purchase

#### Updated Files for Subscription Support

**Secrets.swift**:
- Added `revenueCatAPIKey` for RevenueCat Public API Key

**ReplyViewModel.swift**:
- Added `showPaywall: Bool` for paywall presentation
- Added `isPro`, `canGenerate`, `remainingFreeGenerations` computed properties
- Updated `generateReply()` to check subscription status before generating
- Automatically shows paywall when free limit reached

**ContentView.swift**:
- Added free usage banner showing remaining generations
- Added "PRO" badge in toolbar for pro users
- Added Pro Features section with locked features:
  - "Decode Message" (Pro only)
  - "My Style" (Pro only)
- Generate button shows remaining generations
- Integrated RevenueCatUI PaywallView via `.paywallSheet()` modifier

**replyerAIApp.swift**:
- Added `SubscriptionService.shared.configure()` in init

---

## [1.0.0] - 2025-12-03

### Added

#### GoogleGenerativeAI Package Dependency
- Added `google/generative-ai-swift` package dependency (version 0.5.0+) to the Xcode project
- Package repository: https://github.com/google/generative-ai-swift
- Modified `project.pbxproj` to include:
  - `XCRemoteSwiftPackageReference` for the package
  - `XCSwiftPackageProductDependency` linking to the main target

#### Secrets.swift
- Created `replyerAI/Secrets.swift` for storing sensitive API keys
- Contains `Secrets` enum with `geminiAPIKey` static property
- **⚠️ IMPORTANT**: Replace `"YOUR_API_KEY_HERE"` with your actual Gemini API key
- **⚠️ SECURITY**: Add this file to `.gitignore` before committing to version control
- Get your API key from: https://aistudio.google.com/app/apikey

#### ShareSheet.swift
- Created `replyerAI/ShareSheet.swift` for native iOS sharing functionality
- `UIViewControllerRepresentable` wrapper for `UIActivityViewController`
- Features:
  - Share any content (text, images, URLs)
  - Optional excluded activity types
  - Completion handler callback
  - Convenience View extensions: `.shareSheet(isPresented:text:)` and `.shareSheet(isPresented:items:)`
  - Presentation detents for medium/large sizes

#### Info.plist Updates
- Added `NSPhotoLibraryUsageDescription` to both Debug and Release build configurations
- Message: "ReplyerAI needs access to your photo library to select message screenshots for generating replies."

#### ContentView.swift (Updated)
- Rebuilt `replyerAI/ContentView.swift` with a complete modern UI
- **Structure**:
  - `NavigationStack` with "ReplyerAI" title
  - `ScrollView` for scrollable content
  - Reset button in toolbar
- **Photo Picker Section**:
  - `PhotosPicker` for selecting message screenshots
  - Dashed border placeholder when no image selected
  - Selected image preview with rounded corners
  - Remove image button
- **Settings Section**:
  - Relationship picker (menu style)
  - Tone picker (menu style)
  - Grouped in rounded card with SF Symbols
- **Context Section**:
  - Multi-line `TextField` for additional context
  - Expandable 3-6 lines
- **Generate Button**:
  - Full-width accent color button
  - Sparkles icon
  - Loading state with spinner
  - Disabled when no image selected
- **Result Section**:
  - Shows generated reply text
  - Copy button to clipboard
  - **Share button** to open native iOS share sheet
  - Text selection enabled
- **Error Handling**:
  - Orange warning banner for errors
- **Styling**: Clean iOS system design with `secondarySystemBackground`, rounded corners, proper spacing

#### ReplyViewModel.swift
- Created `replyerAI/ReplyViewModel.swift` as the main ViewModel for the reply generation feature
- **Enums**:
  - `Relationship`: Wife, Husband, Girlfriend, Boyfriend, Boss, Coworker, Friend, Best Friend, Parent, Sibling, Ex Partner, Acquaintance, Stranger
  - `Tone`: Angry, Funny, Professional, Sarcastic, Romantic, Apologetic, Assertive, Friendly, Formal, Casual, Sympathetic, Flirty
- **Published Properties**:
  - `selectedImage: UIImage?` - The selected screenshot/image
  - `imageSelection: PhotosPickerItem?` - Photo picker selection
  - `selectedRelationship: Relationship` - Who sent the message
  - `selectedTone: Tone` - Desired reply tone
  - `contextText: String` - Additional context from user
  - `generatedReply: String` - The AI-generated reply
  - `isLoading: Bool` - Loading state
  - `errorMessage: String?` - Error handling
- **Methods**:
  - `generateReply()` - Fully implemented reply generation using GeminiService with image
  - `buildPrompt()` - Constructs the AI prompt with relationship, tone, and context
  - `loadImage()` - Loads image from PhotosPickerItem
  - `reset()` - Clears all data

#### GeminiService.swift
- Created `replyerAI/GeminiService.swift` as the main service for Gemini AI interactions
- Uses the `gemini-2.0-flash` model (note: the latest flash model, as `gemini-3-flash` doesn't exist yet)
- Features:
  - Singleton pattern with `GeminiService.shared`
  - `@MainActor` annotation for thread safety
  - `ObservableObject` conformance for SwiftUI integration
  - `generateResponse(prompt:)` - Single text prompt generation
  - `generateResponse(image:prompt:)` - Image + text multimodal generation (converts UIImage to JPEG data)
  - `chat(history:message:)` - Conversational chat with history support
  - Custom `GeminiError` enum for error handling (`noTextInResponse`, `imageConversionFailed`)

---

## Setup Instructions

1. **Add your API Keys**:
   - Open `replyerAI/Secrets.swift`
   - Replace `"YOUR_GEMINI_API_KEY_HERE"` with your Gemini API key
   - Replace `"YOUR_REVENUECAT_API_KEY_HERE"` with your RevenueCat Public API key

2. **Configure RevenueCat Dashboard**:
   - Create a project at https://app.revenuecat.com
   - Add your App Store app
   - Create products: monthly, 6-month, yearly, lifetime
   - Create entitlement: `pro_access`
   - Attach products to the entitlement

3. **Secure your secrets**:
   - Add `Secrets.swift` to your `.gitignore` file:
     ```
     # Secrets
     **/Secrets.swift
     ```

4. **Build the project**:
   - Open `replyerAI.xcodeproj` in Xcode
   - Xcode will automatically fetch the packages
   - Build and run the project

---

## Usage Example

```swift
import SwiftUI

struct ContentView: View {
    @State private var response = ""
    
    var body: some View {
        VStack {
            Text(response)
            Button("Generate") {
                Task {
                    do {
                        response = try await GeminiService.shared.generateResponse(
                            prompt: "Hello, how are you?"
                        )
                    } catch {
                        response = "Error: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
```

---

## File Structure

```
replyerAI/
├── replyerAI/
│   ├── Assets.xcassets/
│   ├── ContentView.swift
│   ├── replyerAIApp.swift
│   ├── Secrets.swift             ← API keys (Gemini + RevenueCat)
│   ├── GeminiService.swift       ← Gemini AI service
│   ├── ReplyViewModel.swift      ← Main ViewModel (multi-image support)
│   ├── ShareSheet.swift          ← Native iOS share sheet
│   ├── SubscriptionService.swift ← RevenueCat subscription management
│   ├── StyleMimicry/
│   │   ├── StyleProfile.swift    ← Style profile model & manager
│   │   └── StyleMimicryView.swift ← Style training UI
│   └── DecodeMessage/
│       ├── DecodeAnalysis.swift  ← Decode analysis model
│       └── DecodeMessageView.swift ← Decode message UI
├── replyerAI.xcodeproj/
│   └── project.pbxproj        ← MODIFIED: Added package dependencies
└── CHANGELOG.md               ← This documentation file
```

