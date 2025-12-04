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
    @State private var showStyleMimicry = false
    @State private var showDecodeMessage = false
    @State private var showContactProfiles = false
    @State private var showSettings = false
    @State private var styleManager = StyleProfileManager.shared
    @State private var contactProfileManager = ContactProfileManager.shared
    
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
                    
                    // MARK: - Contact Profile Section (Pro)
                    if viewModel.isPro {
                        contactProfileSection
                    }
                    
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
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                hideKeyboard()
            }
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
                    HStack(spacing: 16) {
                        Button {
                            viewModel.reset()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .disabled(viewModel.isLoading)
                        
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onChange(of: viewModel.imageSelections) {
            Task {
                await viewModel.loadImages()
            }
        }
        .paywallSheet(isPresented: $viewModel.showPaywall)
        .customerCenterSheet(isPresented: $showCustomerCenter)
        .sheet(isPresented: $showStyleMimicry) {
            StyleMimicryView()
        }
        .sheet(isPresented: $showDecodeMessage) {
            DecodeMessageView()
        }
        .sheet(isPresented: $showContactProfiles) {
            ContactProfilesView()
        }
    }
    
    // MARK: - Contact Profile Section
    
    private var contactProfileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Contact Profile")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    showContactProfiles = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gear")
                        Text("Manage")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
                }
            }
            
            ContactProfilePicker(selectedProfile: $viewModel.selectedContactProfile)
        }
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
            // Header with screenshot count
            if !viewModel.selectedImages.isEmpty {
                HStack {
                    Text("Screenshots (\(viewModel.selectedImages.count)/\(viewModel.maxScreenshots))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if viewModel.isPro {
                        Text("Full Story Mode")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
            
            // Display selected images
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                VStack(spacing: 4) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 180)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    // Order indicator
                                    Text("\(index + 1)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Color.accentColor)
                                        .clipShape(Circle())
                                }
                                
                                // Delete button
                                Button {
                                    viewModel.removeImage(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white, .red)
                                }
                                .offset(x: 8, y: -8)
                            }
                        }
                        
                        // Add more button (if allowed)
                        if viewModel.canAddMoreScreenshots {
                            PhotosPicker(
                                selection: $viewModel.imageSelections,
                                maxSelectionCount: viewModel.maxScreenshots,
                                matching: .images
                            ) {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(Color.accentColor)
                                    Text("Add More")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 100, height: 180)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemBackground))
                                        .strokeBorder(Color(.separator), style: StrokeStyle(lineWidth: 1, dash: [6]))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                // Clear all button
                Button {
                    viewModel.clearImages()
                } label: {
                    Label("Clear All", systemImage: "trash")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            } else {
                // Empty state - Photo picker
                PhotosPicker(
                    selection: $viewModel.imageSelections,
                    maxSelectionCount: viewModel.maxScreenshots,
                    matching: .images
                ) {
                    VStack(spacing: 12) {
                        Image(systemName: viewModel.isPro ? "photo.stack" : "photo.badge.plus")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text(viewModel.isPro ? "Select Screenshots" : "Select Screenshot")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(viewModel.isPro 
                             ? "Add up to \(viewModel.maxScreenshots) screenshots for full context"
                             : "Tap to choose a message screenshot")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if !viewModel.isPro {
                            Button {
                                viewModel.showPaywall = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                    Text("Upgrade for Multi-Screenshot")
                                }
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                            .strokeBorder(Color(.separator), style: StrokeStyle(lineWidth: 1, dash: [8]))
                    }
                }
                .buttonStyle(.plain)
            }
            
            // Pro tip for multi-screenshot
            if viewModel.isPro && viewModel.selectedImages.count > 1 {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text("Tip: Screenshots are analyzed in order. Add oldest first, newest last.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
                // Relationship Picker (disabled if contact profile selected)
                HStack {
                    Label("Relationship", systemImage: "person.2")
                        .foregroundStyle(viewModel.hasContactProfile ? .secondary : .primary)
                    Spacer()
                    if viewModel.hasContactProfile {
                        Text(viewModel.effectiveRelationship)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Relationship", selection: $viewModel.selectedRelationship) {
                            ForEach(Relationship.allCases) { relationship in
                                Text(relationship.rawValue).tag(relationship)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.primary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                
                Divider()
                    .padding(.leading)
                
                // Style Selection: My Style Toggle or Tone Picker
                if viewModel.isPro && styleManager.hasCompleteProfile {
                    // My Style Toggle (Pro users with style profile)
                    HStack {
                        Label("Use My Style", systemImage: "person.text.rectangle")
                            .foregroundStyle(.primary)
                        Spacer()
                        Toggle("", isOn: $viewModel.useMyStyle)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    
                    // Show Tone picker only if not using My Style
                    if !viewModel.useMyStyle {
                        Divider()
                            .padding(.leading)
                        
                        tonePickerRow
                    }
                } else {
                    // Regular Tone Picker for free users or Pro without style
                    tonePickerRow
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Show contact profile info hint
            if viewModel.hasContactProfile {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color.accentColor)
                    Text("Settings from \(viewModel.selectedContactProfile?.name ?? "profile") are being used.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var tonePickerRow: some View {
        HStack {
            Label("Tone", systemImage: "face.smiling")
                .foregroundStyle(viewModel.hasContactProfile && viewModel.selectedContactProfile?.preferredTone != nil ? .secondary : .primary)
            Spacer()
            if viewModel.hasContactProfile, let preferredTone = viewModel.selectedContactProfile?.preferredTone {
                Text(preferredTone)
                    .foregroundStyle(.secondary)
            } else {
                Picker("Tone", selection: $viewModel.selectedTone) {
                    ForEach(Tone.allCases) { tone in
                        Text(tone.rawValue).tag(tone)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
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
                // Contact Profiles - Pro Feature
                contactProfilesFeatureRow
                
                // Full Story (Multi-Screenshot) - Pro Feature
                fullStoryFeatureRow
                
                // Decode Message - Pro Feature
                decodeMessageFeatureRow
                
                // My Style - Pro Feature
                myStyleFeatureRow
            }
        }
    }
    
    private var contactProfilesFeatureRow: some View {
        Button {
            if viewModel.isPro {
                showContactProfiles = true
            } else {
                viewModel.showPaywall = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title2)
                    .foregroundStyle(!viewModel.isPro ? .secondary : Color.accentColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Contact Profiles")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        if !viewModel.isPro {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if contactProfileManager.hasProfiles {
                            Text("\(contactProfileManager.profileCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(contactProfileManager.hasProfiles 
                         ? "\(contactProfileManager.profileCount) profile\(contactProfileManager.profileCount == 1 ? "" : "s") saved • Tap to manage"
                         : "Save preferences for specific people")
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
            .opacity(!viewModel.isPro ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    private var fullStoryFeatureRow: some View {
        Button {
            if !viewModel.isPro {
                viewModel.showPaywall = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "photo.stack")
                    .font(.title2)
                    .foregroundStyle(!viewModel.isPro ? .secondary : Color.accentColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Full Story Mode")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        if !viewModel.isPro {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Text(viewModel.isPro 
                         ? "Upload up to \(MultiScreenshotConstants.proMaxScreenshots) screenshots • Active"
                         : "Add multiple screenshots for better context")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if !viewModel.isPro {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(!viewModel.isPro ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isPro) // No action needed for Pro users, feature is already active
    }
    
    private var decodeMessageFeatureRow: some View {
        Button {
            if viewModel.isPro {
                showDecodeMessage = true
            } else {
                viewModel.showPaywall = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(!viewModel.isPro ? .secondary : Color.accentColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Decode Message")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        if !viewModel.isPro {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Text("Analyze psychology, mood & hidden meanings")
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
            .opacity(!viewModel.isPro ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    private var myStyleFeatureRow: some View {
        Button {
            if viewModel.isPro {
                showStyleMimicry = true
            } else {
                viewModel.showPaywall = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.text.rectangle")
                    .font(.title2)
                    .foregroundStyle(!viewModel.isPro ? .secondary : Color.accentColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("My Style")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        if !viewModel.isPro {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if styleManager.hasCompleteProfile {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Text(styleManager.hasCompleteProfile 
                         ? "Style profile active • Tap to update"
                         : "Train AI to match your writing style")
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
            .opacity(!viewModel.isPro ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    private func proFeatureRow(icon: String, title: String, description: String, isLocked: Bool, action: @escaping () -> Void) -> some View {
        Button {
            if isLocked {
                viewModel.showPaywall = true
            } else {
                action()
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
                .background(!viewModel.hasImages ? Color.gray : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!viewModel.hasImages || viewModel.isLoading)
            
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

// MARK: - Keyboard Dismissal Helper

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
