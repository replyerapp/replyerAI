//
//  AppStoreScreenshotsView.swift
//  Replyer
//
//  DEBUG utility to generate App Store screenshots via ImageRenderer.
//

#if DEBUG

import SwiftUI
import Photos

@MainActor
struct AppStoreScreenshotsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var isExporting = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // iPhone 6.7" @3x → 1290×2796 px → 430×932 pt
    private let canvasSize = CGSize(width: 430, height: 932)
    private let renderScale: CGFloat = 3
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("App Store Screenshots")
                        .font(.title2).bold()
                    
                    Text("This debug tool renders 6 clean screenshots at iPhone 6.7\" size and saves them to Photos.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        Task { await exportAll() }
                    } label: {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isExporting ? "Exporting…" : "Export 6 Screenshots to Photos")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.purple, .pink, .orange], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isExporting)
                    
                    Divider().padding(.vertical, 6)
                    
                    Text("Preview")
                        .font(.headline)
                    
                    ForEach(shots) { shot in
                        ShotPreviewCard(title: shot.title, subtitle: shot.subtitle) {
                            shot.view
                                .frame(width: canvasSize.width, height: canvasSize.height)
                                .clipped()
                                .cornerRadius(24)
                                .shadow(radius: 8, y: 4)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Screenshots")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var shots: [AppStoreShot] {
        [
            AppStoreShot(
                id: "01-home",
                title: "Smart replies from a screenshot",
                subtitle: "Upload a chat and get a ready-to-send reply.",
                view: AnyView(ShotHome())
            ),
            AppStoreShot(
                id: "02-pro",
                title: "Premium Pro features",
                subtitle: "Full Story, My Style, Decode, and more.",
                view: AnyView(ShotProFeatures())
            ),
            AppStoreShot(
                id: "03-fullstory",
                title: "Full Story mode",
                subtitle: "Add multiple screenshots for better context.",
                view: AnyView(ShotFullStory())
            ),
            AppStoreShot(
                id: "04-mystyle",
                title: "Reply like you",
                subtitle: "Teach Replyer your style from past texts.",
                view: AnyView(ShotMyStyle())
            ),
            AppStoreShot(
                id: "05-decode",
                title: "Decode what they mean",
                subtitle: "Get a psychological breakdown and suggestions.",
                view: AnyView(ShotDecode())
            ),
            AppStoreShot(
                id: "06-contacts",
                title: "Contact profiles",
                subtitle: "Save notes and tones for each person.",
                view: AnyView(ShotContacts())
            )
        ]
    }
    
    private func exportAll() async {
        guard !isExporting else { return }
        isExporting = true
        defer { isExporting = false }
        
        let auth = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard auth == .authorized || auth == .limited else {
            alertTitle = "Photos Permission Needed"
            alertMessage = "Please allow Photos access (Add Only) to save screenshots."
            showAlert = true
            return
        }
        
        var successCount = 0
        for shot in shots {
            if let image = render(shot.view) {
                let saved = await saveToPhotos(image)
                if saved { successCount += 1 }
            }
        }
        
        alertTitle = "Done"
        alertMessage = "Saved \(successCount)/\(shots.count) screenshots to Photos."
        showAlert = true
    }
    
    private func render(_ view: AnyView) -> UIImage? {
        let content = view
            .frame(width: canvasSize.width, height: canvasSize.height)
            .environment(\.colorScheme, .light)
        
        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = .init(canvasSize)
        renderer.scale = renderScale
        renderer.isOpaque = true
        return renderer.uiImage
    }
    
    private func saveToPhotos(_ image: UIImage) async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, _ in
                continuation.resume(returning: success)
            })
        }
    }
}

// MARK: - Models

private struct AppStoreShot: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let view: AnyView
}

// MARK: - Preview Card

private struct ShotPreviewCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
            content
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Shared Components

private struct ShotChrome: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 26)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private struct GradientBG: View {
    var body: some View {
        LinearGradient(
            colors: [Color.purple.opacity(0.95), Color.pink.opacity(0.75), Color.orange.opacity(0.65)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct Card: View {
    let title: String
    let systemImage: String
    let detail: String
    var tint: Color = .accentColor
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(tint.opacity(0.16))
                    .frame(width: 44, height: 44)
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(tint)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 1)
        )
    }
}

private struct PrimaryCTA: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [.purple, .pink, .orange], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct MockScreenshotStrip: View {
    let count: Int
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<count, id: \.self) { idx in
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.tertiarySystemBackground),
                                Color(.secondarySystemBackground)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "message.fill")
                                .font(.title2)
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                            Text("#\(idx + 1)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    )
                    .frame(width: 96, height: 132)
            }
        }
    }
}

// MARK: - 6 Screenshot Views

private struct ShotHome: View {
    var body: some View {
        ZStack {
            GradientBG()
            VStack(spacing: 16) {
                ShotChrome(title: "Replyer", subtitle: "Smart replies from screenshots")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 12) {
                    Card(
                        title: "Upload a chat screenshot",
                        systemImage: "photo.on.rectangle.angled",
                        detail: "We’ll read the conversation and suggest a reply.",
                        tint: .blue
                    )
                    Card(
                        title: "Choose relationship & tone",
                        systemImage: "slider.horizontal.3",
                        detail: "Situationship • Flirty",
                        tint: .purple
                    )
                    PrimaryCTA(title: "Generate Reply")
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 26)
            }
        }
    }
}

private struct ShotProFeatures: View {
    var body: some View {
        ZStack {
            GradientBG()
            VStack(spacing: 16) {
                ShotChrome(title: "Pro Features", subtitle: "Unlock smarter conversations")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 12) {
                    Card(title: "Full Story", systemImage: "square.stack.3d.up.fill", detail: "Use 3–5 screenshots for full context.", tint: .blue)
                    Card(title: "My Style", systemImage: "pencil.and.outline", detail: "Teach Replyer your texting style.", tint: .purple)
                    Card(title: "Decode", systemImage: "brain.head.profile", detail: "Understand their mood and intent.", tint: .pink)
                    Card(title: "Contact Profiles", systemImage: "person.crop.circle.badge.checkmark", detail: "Save notes and preferences per person.", tint: .orange)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 26)
            }
        }
    }
}

private struct ShotFullStory: View {
    var body: some View {
        ZStack {
            GradientBG()
            VStack(spacing: 14) {
                ShotChrome(title: "Full Story", subtitle: "More context = better replies")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Conversation screenshots")
                        .font(.headline)
                        .padding(.horizontal, 18)
                    
                    MockScreenshotStrip(count: 3)
                        .padding(.horizontal, 18)
                    
                    Card(
                        title: "Tip",
                        systemImage: "lightbulb.fill",
                        detail: "Add screenshots in chronological order (oldest → newest).",
                        tint: .yellow
                    )
                    .padding(.horizontal, 18)
                    
                    PrimaryCTA(title: "Generate Reply")
                        .padding(.horizontal, 18)
                }
                .padding(.bottom, 26)
            }
        }
    }
}

private struct ShotMyStyle: View {
    var body: some View {
        ZStack {
            GradientBG()
            VStack(spacing: 14) {
                ShotChrome(title: "My Style", subtitle: "Replies that sound like you")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 12) {
                    Card(
                        title: "Upload 3–4 of your messages",
                        systemImage: "photo.stack",
                        detail: "We’ll learn your slang, emojis, and length.",
                        tint: .purple
                    )
                    Card(
                        title: "Style profile ready",
                        systemImage: "checkmark.seal.fill",
                        detail: "Use your style anytime with one toggle.",
                        tint: .green
                    )
                    PrimaryCTA(title: "Analyze & Save My Style")
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 26)
            }
        }
    }
}

private struct ShotDecode: View {
    var body: some View {
        ZStack {
            GradientBG()
            VStack(spacing: 14) {
                ShotChrome(title: "Decode", subtitle: "Read between the lines")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 12) {
                    Card(
                        title: "Overall mood",
                        systemImage: "face.smiling.inverse",
                        detail: "Neutral but slightly guarded.",
                        tint: .blue
                    )
                    Card(
                        title: "Hidden meaning",
                        systemImage: "quote.opening",
                        detail: "They want reassurance without sounding needy.",
                        tint: .pink
                    )
                    Card(
                        title: "Recommended approach",
                        systemImage: "sparkles",
                        detail: "Keep it warm, short, and confident.",
                        tint: .orange
                    )
                    PrimaryCTA(title: "Decode Message")
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 26)
            }
        }
    }
}

private struct ShotContacts: View {
    var body: some View {
        ZStack {
            GradientBG()
            VStack(spacing: 14) {
                ShotChrome(title: "Contact Profiles", subtitle: "Remember everyone’s rules")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 12) {
                    Card(
                        title: "🧠 Sarah",
                        systemImage: "person.crop.circle",
                        detail: "Hates emojis. Loves sarcasm. Prefer: Funny.",
                        tint: .purple
                    )
                    Card(
                        title: "💼 Boss",
                        systemImage: "briefcase.fill",
                        detail: "Keep it concise and professional.",
                        tint: .blue
                    )
                    Card(
                        title: "💖 Alex",
                        systemImage: "heart.fill",
                        detail: "Flirty but not desperate.",
                        tint: .pink
                    )
                    PrimaryCTA(title: "Generate Reply")
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 26)
            }
        }
    }
}

#endif


