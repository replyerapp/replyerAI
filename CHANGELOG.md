# replyerAI - Changelog

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
│   ├── ReplyViewModel.swift      ← Main ViewModel
│   ├── ShareSheet.swift          ← Native iOS share sheet
│   └── SubscriptionService.swift ← RevenueCat subscription management
├── replyerAI.xcodeproj/
│   └── project.pbxproj        ← MODIFIED: Added package dependency
└── CHANGELOG.md               ← NEW: This documentation file
```

