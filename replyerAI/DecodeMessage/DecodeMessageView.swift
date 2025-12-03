//
//  DecodeMessageView.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI
import PhotosUI

/// View for analyzing and decoding message psychology
struct DecodeMessageView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedImage: UIImage?
    @State private var imageSelection: PhotosPickerItem?
    @State private var relationship: Relationship = .friend
    @State private var additionalContext: String = ""
    @State private var analysis: DecodeAnalysis?
    @State private var isAnalyzing: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Image Selection
                    imageSection
                    
                    // Settings
                    if selectedImage != nil {
                        settingsSection
                    }
                    
                    // Decode Button
                    if selectedImage != nil {
                        decodeButton
                    }
                    
                    // Analysis Results
                    if let analysis = analysis {
                        analysisResultsSection(analysis)
                    }
                    
                    // Error
                    if let error = errorMessage {
                        errorView(error)
                    }
                }
                .padding()
            }
            .navigationTitle("Decode Message")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                hideKeyboard()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if analysis != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            reset()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
            }
            .onChange(of: imageSelection) {
                loadImage()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)
            
            Text("Decode Their Message")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Upload a screenshot and discover what they're really thinking. Get psychological insights into their mood, hidden meanings, and what they want from you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    // MARK: - Image Section
    
    private var imageSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $imageSelection, matching: .images) {
                Group {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "message.badge.waveform")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("Select Message Screenshot")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Choose a conversation to analyze")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                                .strokeBorder(Color(.separator), style: StrokeStyle(lineWidth: 1, dash: [8]))
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            
            if selectedImage != nil {
                Button {
                    selectedImage = nil
                    imageSelection = nil
                    analysis = nil
                } label: {
                    Label("Remove Image", systemImage: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Context")
                .font(.headline)
            
            // Relationship
            HStack {
                Label("Relationship", systemImage: "person.2")
                    .foregroundStyle(.primary)
                Spacer()
                Picker("Relationship", selection: $relationship) {
                    ForEach(Relationship.allCases) { rel in
                        Text(rel.rawValue).tag(rel)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Additional Context
            TextField("Any backstory? (optional)", text: $additionalContext, axis: .vertical)
                .lineLimit(2...4)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Decode Button
    
    private var decodeButton: some View {
        Button {
            Task {
                await decodeMessage()
            }
        } label: {
            HStack(spacing: 8) {
                if isAnalyzing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "brain.head.profile")
                }
                Text(isAnalyzing ? "Analyzing..." : "Decode Message")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isAnalyzing)
    }
    
    // MARK: - Analysis Results Section
    
    private func analysisResultsSection(_ analysis: DecodeAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Mood Overview Card
            moodOverviewCard(analysis)
            
            // Summary
            summaryCard(analysis)
            
            // Hidden Meaning
            insightCard(
                icon: "eye.fill",
                title: "What They Really Mean",
                content: analysis.hiddenMeaning,
                color: .purple
            )
            
            // Emotional State
            insightCard(
                icon: "heart.fill",
                title: "Emotional State",
                content: analysis.emotionalState,
                color: .pink
            )
            
            // What They Want
            insightCard(
                icon: "target",
                title: "What They Want",
                content: analysis.whatTheyWant,
                color: .blue
            )
            
            // Text Cues
            if !analysis.textCues.isEmpty {
                textCuesSection(analysis.textCues)
            }
            
            // Relationship Dynamics
            insightCard(
                icon: "person.2.fill",
                title: "Relationship Dynamics",
                content: analysis.relationshipDynamics,
                color: .orange
            )
            
            // Flags Section
            if !analysis.redFlags.isEmpty || !analysis.greenFlags.isEmpty {
                flagsSection(analysis)
            }
            
            // Recommended Approach
            insightCard(
                icon: "lightbulb.fill",
                title: "How to Respond",
                content: analysis.recommendedApproach,
                color: .yellow
            )
        }
    }
    
    // MARK: - Mood Overview Card
    
    private func moodOverviewCard(_ analysis: DecodeAnalysis) -> some View {
        let mood = MoodIndicator(score: analysis.moodScore)
        
        return VStack(spacing: 16) {
            HStack {
                Text("Mood Analysis")
                    .font(.headline)
                Spacer()
                Text(mood.emoji)
                    .font(.title)
            }
            
            HStack(spacing: 16) {
                // Mood Score
                VStack(spacing: 4) {
                    Text("\(analysis.moodScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(moodColor(for: analysis.moodScore))
                    Text("/ 10")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 70)
                
                // Mood Bar
                VStack(alignment: .leading, spacing: 8) {
                    Text(analysis.overallMood)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(moodColor(for: analysis.moodScore))
                                .frame(width: geo.size.width * CGFloat(analysis.moodScore) / 10)
                        }
                    }
                    .frame(height: 8)
                    
                    Text(mood.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func moodColor(for score: Int) -> Color {
        switch score {
        case 1...2: return .red
        case 3...4: return .orange
        case 5...6: return .yellow
        case 7...8: return .green
        default: return .mint
        }
    }
    
    // MARK: - Summary Card
    
    private func summaryCard(_ analysis: DecodeAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Quick Summary", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
            
            Text(analysis.summary)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Insight Card
    
    private func insightCard(icon: String, title: String, content: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            
            Text(content)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Text Cues Section
    
    private func textCuesSection(_ cues: [TextCue]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Text Cues Detected", systemImage: "text.magnifyingglass")
                .font(.headline)
            
            ForEach(cues) { cue in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(significanceColor(cue.significance))
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\"\(cue.observation)\"")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .italic()
                        
                        Text(cue.meaning)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private func significanceColor(_ significance: String) -> Color {
        switch significance.lowercased() {
        case "high": return .red
        case "medium": return .orange
        default: return .green
        }
    }
    
    // MARK: - Flags Section
    
    private func flagsSection(_ analysis: DecodeAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Red Flags
            if !analysis.redFlags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Red Flags", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                    
                    ForEach(analysis.redFlags, id: \.self) { flag in
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                            Text(flag)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Green Flags
            if !analysis.greenFlags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Green Flags", systemImage: "checkmark.seal.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                    
                    ForEach(analysis.greenFlags, id: \.self) { flag in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                            Text(flag)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Error View
    
    private func errorView(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Methods
    
    private func loadImage() {
        guard let imageSelection else { return }
        
        Task {
            if let data = try? await imageSelection.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                analysis = nil
            }
        }
    }
    
    private func decodeMessage() async {
        guard let image = selectedImage else { return }
        
        isAnalyzing = true
        errorMessage = nil
        
        do {
            analysis = try await GeminiService.shared.decodeMessage(
                image: image,
                relationship: relationship.rawValue,
                context: additionalContext
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isAnalyzing = false
    }
    
    private func reset() {
        selectedImage = nil
        imageSelection = nil
        analysis = nil
        additionalContext = ""
        errorMessage = nil
    }
}

// MARK: - Keyboard Dismissal Helper

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview

#Preview {
    DecodeMessageView()
}

