# ReplyerAI

An iOS app that generates smart reply suggestions for your messages using Google's Gemini AI.

## Features

### Free Features
- 📸 **Screenshot Analysis** - Select a screenshot of a conversation
- 👥 **Relationship Context** - Specify your relationship (Wife, Boss, Friend, etc.)
- 🎭 **Tone Selection** - Choose the reply tone (Funny, Professional, Romantic, etc.)
- 📝 **Additional Context** - Add extra context for better replies
- ✨ **AI-Powered Replies** - Generate contextual replies using Gemini AI
- 📋 **Copy & Share** - Easily copy or share the generated reply
- 🆓 **3 Free Generations/Day** - Try before you subscribe

### Pro Features (Subscription)
- ♾️ **Unlimited Generations** - No daily limits
- 🔍 **Decode Message** - Analyze hidden meanings & emotions
- ✍️ **My Style** - Train AI to match your writing style

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/replyerapp/replyerAI.git
cd replyerAI
```

### 2. Configure API Keys

1. Copy the example secrets file:
   ```bash
   cp Secrets.example.txt replyerAI/Secrets.swift
   ```

2. Get your **Gemini API key** from [Google AI Studio](https://aistudio.google.com/app/apikey)

3. Get your **RevenueCat API key** from [RevenueCat Dashboard](https://app.revenuecat.com) → Project Settings → API Keys

4. Open `replyerAI/Secrets.swift` and add your keys:
   ```swift
   enum Secrets {
       static let geminiAPIKey = "YOUR_GEMINI_API_KEY"
       static let revenueCatAPIKey = "YOUR_REVENUECAT_API_KEY"
   }
   ```

### 3. Configure RevenueCat Dashboard

1. Create a project at [RevenueCat](https://app.revenuecat.com)
2. Add your iOS app with Bundle ID
3. Create **Products** in App Store Connect:
   - `monthly` - Monthly subscription
   - `six_month` - 6-month subscription
   - `yearly` - Yearly subscription
   - `lifetime` - Lifetime purchase
4. Import products into RevenueCat
5. Create **Entitlement**: `replyerAI Pro`
6. Attach all products to the entitlement
7. Create an **Offering** and add packages

### 4. Open in Xcode

1. Open `replyerAI.xcodeproj` in Xcode
2. Wait for Swift Package Manager to fetch packages:
   - GoogleGenerativeAI
   - RevenueCat
   - RevenueCatUI
3. Build and run on your device or simulator

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Google Gemini API Key
- RevenueCat Account (for subscriptions)

## Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **GoogleGenerativeAI** - Google's Gemini AI SDK for Swift
- **RevenueCat** - Subscription management
- **RevenueCatUI** - Pre-built paywall UI
- **PhotosUI** - Native photo picker

## Project Structure

```
replyerAI/
├── replyerAI/
│   ├── replyerAIApp.swift         # App entry point
│   ├── ContentView.swift          # Main UI
│   ├── ReplyViewModel.swift       # Business logic & state
│   ├── GeminiService.swift        # Gemini AI integration
│   ├── SubscriptionService.swift  # RevenueCat integration
│   ├── ShareSheet.swift           # Native share functionality
│   └── Secrets.swift              # API keys (gitignored)
├── Secrets.example.txt            # Template for secrets
├── .gitignore
├── README.md
└── CHANGELOG.md
```

## Subscription Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    RevenueCat Dashboard                  │
├─────────────────────────────────────────────────────────┤
│  Entitlement: "replyerAI Pro"                           │
│  ├── monthly    → $X.XX/month                           │
│  ├── six_month  → $X.XX/6 months                        │
│  ├── yearly     → $X.XX/year                            │
│  └── lifetime   → $X.XX one-time                        │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  SubscriptionService                     │
├─────────────────────────────────────────────────────────┤
│  • configure()         - Initialize SDK                  │
│  • fetchCustomerInfo() - Get subscription status         │
│  • fetchOfferings()    - Get available products          │
│  • purchase(package:)  - Make a purchase                 │
│  • restorePurchases()  - Restore previous purchases      │
│  • isPro               - Check entitlement status        │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                      UI Components                       │
├─────────────────────────────────────────────────────────┤
│  • PaywallView         - RevenueCatUI paywall            │
│  • CustomerCenterView  - Manage subscription             │
│  • SubscriptionStatus  - Show current status             │
│  • ProFeatureLock      - Locked feature placeholder      │
└─────────────────────────────────────────────────────────┘
```

## Privacy

- Your API keys are stored locally and never shared
- Images are processed directly with Google's Gemini API
- Subscription data is managed securely by RevenueCat
- No personal data is stored on external servers by this app

## Legal

- [Privacy Policy](PRIVACY_POLICY.md)
- [Terms of Use](TERMS_OF_USE.md)

## License

MIT License
