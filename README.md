# ReplyerAI

An iOS app that generates smart reply suggestions for your messages using Google's Gemini AI.

## Features

- 📸 **Screenshot Analysis** - Select a screenshot of a conversation
- 👥 **Relationship Context** - Specify your relationship (Wife, Boss, Friend, etc.)
- 🎭 **Tone Selection** - Choose the reply tone (Funny, Professional, Romantic, etc.)
- 📝 **Additional Context** - Add extra context for better replies
- ✨ **AI-Powered Replies** - Generate contextual replies using Gemini AI
- 📋 **Copy & Share** - Easily copy or share the generated reply

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/replyerAI.git
cd replyerAI
```

### 2. Configure API Key

1. Get your Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Copy the example secrets file:
   ```bash
   cp replyerAI/Secrets.example.swift replyerAI/Secrets.swift
   ```
3. Open `replyerAI/Secrets.swift` and replace `YOUR_API_KEY_HERE` with your actual API key

### 3. Open in Xcode

1. Open `replyerAI.xcodeproj` in Xcode
2. Wait for Swift Package Manager to fetch the GoogleGenerativeAI package
3. Build and run on your device or simulator

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Google Gemini API Key

## Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **GoogleGenerativeAI** - Google's Gemini AI SDK for Swift
- **PhotosUI** - Native photo picker

## Project Structure

```
replyerAI/
├── replyerAI/
│   ├── replyerAIApp.swift      # App entry point
│   ├── ContentView.swift        # Main UI
│   ├── ReplyViewModel.swift     # Business logic & state
│   ├── GeminiService.swift      # Gemini AI integration
│   ├── ShareSheet.swift         # Native share functionality
│   ├── Secrets.swift            # API keys (gitignored)
│   └── Secrets.example.swift    # Template for secrets
├── .gitignore
├── README.md
└── CHANGELOG.md
```

## Privacy

- Your API key is stored locally and never shared
- Images are processed directly with Google's Gemini API
- No data is stored on external servers by this app

## License

MIT License

