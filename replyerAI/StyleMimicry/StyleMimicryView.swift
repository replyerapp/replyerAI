//
//  StyleMimicryView.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI
import PhotosUI

/// View for teaching the AI the user's personal writing style
struct StyleMimicryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var styleManager = StyleProfileManager.shared
    @State private var imageSelection: PhotosPickerItem?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header explanation
                    headerSection
                    
                    // Current profile status (if exists)
                    if styleManager.hasCompleteProfile {
                        currentProfileSection
                    }
                    
                    // Sample collection section
                    sampleCollectionSection
                    
                    // Analyze button
                    if styleManager.pendingSamples.count >= StyleConstants.minimumSamples {
                        analyzeButton
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.myStyle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.cancel) {
                        dismiss()
                    }
                }
                
                if styleManager.hasCompleteProfile {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                showDeleteConfirmation = true
                            } label: {
                                Label(L10n.deleteStyleProfile, systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .onChange(of: imageSelection) {
                loadSelectedImage()
            }
            .confirmationDialog(
                L10n.deleteStyleProfile,
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(L10n.delete, role: .destructive) {
                    styleManager.deleteProfile()
                }
                Button(L10n.cancel, role: .cancel) { }
            } message: {
                Text(L10n.deleteStyleConfirm)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.text.rectangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)
            
            Text(L10n.teachAIYourStyle)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(L10n.styleMimicryDesc)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    // MARK: - Current Profile Section
    
    private var currentProfileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Text(L10n.styleProfileActive)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.samplesAnalyzed)
                    Spacer()
                    Text("\(styleManager.profile?.sampleCount ?? 0)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text(L10n.lastUpdated)
                    Spacer()
                    if let date = styleManager.profile?.updatedAt {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .font(.subheadline)
            
            Text(L10n.styleActiveDesc)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Sample Collection Section
    
    private var sampleCollectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(styleManager.hasCompleteProfile ? L10n.updateYourStyle : L10n.addYourMessages)
                    .font(.headline)
                
                Spacer()
                
                Text(L10n.minimumSamples(styleManager.pendingSamples.count, StyleConstants.minimumSamples))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Progress bar
            ProgressView(value: styleManager.sampleProgress)
                .tint(styleManager.pendingSamples.count >= StyleConstants.minimumSamples ? Color.green : Color.accentColor)
            
            // Sample grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Existing samples
                ForEach(styleManager.pendingSamples) { sample in
                    SampleThumbnail(sample: sample) {
                        styleManager.removeSample(id: sample.id)
                    }
                }
                
                // Add button (if can add more)
                if styleManager.canAddMoreSamples {
                    addSampleButton
                }
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                instructionRow(icon: "checkmark.circle.fill", text: L10n.useYourMessages, color: .green)
                instructionRow(icon: "checkmark.circle.fill", text: L10n.includeDifferentTypes, color: .green)
                instructionRow(icon: "xmark.circle.fill", text: L10n.dontUseOthers, color: .red)
            }
            .padding(.top, 8)
            
            // Error message
            if let error = styleManager.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private func instructionRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Add Sample Button
    
    private var addSampleButton: some View {
        PhotosPicker(selection: $imageSelection, matching: .images) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.accentColor)
                Text(L10n.add)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color(.separator))
            )
        }
    }
    
    // MARK: - Analyze Button
    
    private var analyzeButton: some View {
        Button {
            Task {
                await styleManager.analyzeStyle()
            }
        } label: {
            HStack(spacing: 8) {
                if styleManager.isAnalyzing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "wand.and.stars")
                }
                Text(styleManager.isAnalyzing ? L10n.analyzingStyle : L10n.analyzeSaveStyle)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(styleManager.isAnalyzing)
    }
    
    // MARK: - Helper Methods
    
    private func loadSelectedImage() {
        guard let imageSelection else { return }
        
        Task {
            if let data = try? await imageSelection.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                styleManager.addSample(image)
            }
            self.imageSelection = nil
        }
    }
}

// MARK: - Sample Thumbnail

struct SampleThumbnail: View {
    let sample: StyleSample
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: sample.image)
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .background(Circle().fill(.black.opacity(0.5)))
            }
            .padding(4)
        }
    }
}

// MARK: - Preview

#Preview {
    StyleMimicryView()
}

