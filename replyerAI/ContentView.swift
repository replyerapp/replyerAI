//
//  ContentView.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI
import PhotosUI
import RevenueCatUI

struct ContentView: View {
    @State private var viewModel = ReplyViewModel()
    @State private var showShareSheet = false
    @State private var showCustomerCenter = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Subscription Status
                    if viewModel.isPro {
                        SubscriptionStatusView(showCustomerCenter: $showCustomerCenter)
                    } else {
                        freeUsageBanner
                    }
                    
                    // MARK: - Photo Picker Section
                    photoPickerSection
                    
                    // MARK: - Settings Section
                    settingsSection
                    
                    // MARK: - Context Section
                    contextSection
                    
                    // MARK: - Pro Features Section (Locked for free users)
                    proFeaturesSection
                    
                    // MARK: - Generate Button
                    generateButton
                    
                    // MARK: - Result Section
                    if !viewModel.generatedReply.isEmpty {
                        resultSection
                    }
                    
                    // MARK: - Error Message
                    if let error = viewModel.errorMessage {
                        errorView(error)
                    }
                }
                .padding()
            }
            .navigationTitle("ReplyerAI")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isPro {
                        Text("PRO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .onChange(of: viewModel.imageSelection) {
            Task {
                await viewModel.loadImage()
            }
        }
        .paywallSheet(isPresented: $viewModel.showPaywall)
        .customerCenterSheet(isPresented: $showCustomerCenter)
    }
    
    // MARK: - Free Usage Banner
    
    private var freeUsageBanner: some View {
        Button {
            viewModel.showPaywall = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Free Plan")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(viewModel.remainingFreeGenerations) of \(SubscriptionConstants.freeUsageLimit) generations left today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("Upgrade")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Photo Picker Section
    
    private var photoPickerSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Group {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("Select Screenshot")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Tap to choose a message screenshot")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                                .strokeBorder(Color(.separator), style: StrokeStyle(lineWidth: 1, dash: [8]))
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            
            if viewModel.selectedImage != nil {
                Button {
                    viewModel.selectedImage = nil
                    viewModel.imageSelection = nil
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: 0) {
                // Relationship Picker
                HStack {
                    Label("Relationship", systemImage: "person.2")
                        .foregroundStyle(.primary)
                    Spacer()
                    Picker("Relationship", selection: $viewModel.selectedRelationship) {
                        ForEach(Relationship.allCases) { relationship in
                            Text(relationship.rawValue).tag(relationship)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                
                Divider()
                    .padding(.leading)
                
                // Tone Picker
                HStack {
                    Label("Tone", systemImage: "face.smiling")
                        .foregroundStyle(.primary)
                    Spacer()
                    Picker("Tone", selection: $viewModel.selectedTone) {
                        ForEach(Tone.allCases) { tone in
                            Text(tone.rawValue).tag(tone)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Context Section
    
    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Context")
                .font(.headline)
                .foregroundStyle(.primary)
            
            TextField("e.g., We had a fight yesterday...", text: $viewModel.contextText, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Pro Features Section
    
    private var proFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pro Features")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                // Decode Message - Pro Feature
                proFeatureRow(
                    icon: "text.magnifyingglass",
                    title: "Decode Message",
                    description: "Analyze hidden meanings & emotions",
                    isLocked: !viewModel.isPro
                )
                
                // My Style - Pro Feature
                proFeatureRow(
                    icon: "person.text.rectangle",
                    title: "My Style",
                    description: "Train AI to match your writing style",
                    isLocked: !viewModel.isPro
                )
            }
        }
    }
    
    private func proFeatureRow(icon: String, title: String, description: String, isLocked: Bool) -> some View {
        Button {
            if isLocked {
                viewModel.showPaywall = true
            } else {
                // TODO: Navigate to pro feature
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isLocked ? .secondary : Color.accentColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(isLocked ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Generate Button
    
    private var generateButton: some View {
        VStack(spacing: 8) {
            Button {
                Task {
                    await viewModel.generateReply()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(viewModel.isLoading ? "Generating..." : "Generate Reply")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.selectedImage == nil ? Color.gray : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(viewModel.selectedImage == nil || viewModel.isLoading)
            
            // Show remaining generations for free users
            if !viewModel.isPro && viewModel.remainingFreeGenerations > 0 {
                Text("\(viewModel.remainingFreeGenerations) free generation\(viewModel.remainingFreeGenerations == 1 ? "" : "s") remaining today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if !viewModel.isPro && viewModel.remainingFreeGenerations == 0 {
                Button {
                    viewModel.showPaywall = true
                } label: {
                    Text("Daily limit reached. Upgrade to Pro for unlimited access.")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
    
    // MARK: - Result Section
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Generated Reply")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = viewModel.generatedReply
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
            }
            
            Text(viewModel.generatedReply)
                .font(.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
        .shareSheet(isPresented: $showShareSheet, text: viewModel.generatedReply)
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
}

#Preview {
    ContentView()
}
