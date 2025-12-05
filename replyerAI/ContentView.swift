//
//  ContentView.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI
import PhotosUI
import RevenueCatUI
import Combine

struct ContentView: View {
    @State private var viewModel = ReplyViewModel()
    @State private var showShareSheet = false
    @State private var showShareCard = false
    @State private var showCopiedToast = false
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
                    
                    // MARK: - Pro Features Section (Between screenshot and settings)
                    proFeaturesSection
                    
                    // MARK: - Contact Profile Section (Pro)
                    if viewModel.isPro {
                        contactProfileSection
                    }
                    
                    // MARK: - Settings Section
                    settingsSection
                    
                    // MARK: - Context Section
                    contextSection
                    
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
            .navigationTitle(L10n.appName)
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                hideKeyboard()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isPro {
                        Text(L10n.pro)
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
                Text(L10n.contactProfile)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    showContactProfiles = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gear")
                        Text(L10n.manage)
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
                    Text(L10n.freePlan)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(L10n.generationsLeftToday(viewModel.remainingFreeGenerations, SubscriptionConstants.freeUsageLimit))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(L10n.upgrade)
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
                    Text("\(L10n.screenshots) (\(viewModel.selectedImages.count)/\(viewModel.maxScreenshots))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if viewModel.isPro {
                        Text(L10n.fullStoryMode)
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
                                    Text(L10n.addMore)
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
                    Label(L10n.clearAll, systemImage: "trash")
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
                        Text(viewModel.isPro ? L10n.selectScreenshots : L10n.selectScreenshot)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(viewModel.isPro 
                             ? L10n.addScreenshotsForContext(viewModel.maxScreenshots)
                             : L10n.tapToChooseScreenshot)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if !viewModel.isPro {
                            Button {
                                viewModel.showPaywall = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                    Text(L10n.upgradeForMultiScreenshot)
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
                    Text(L10n.screenshotTip)
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
            Text(L10n.settings)
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: 0) {
                // Relationship Picker (disabled if contact profile selected)
                HStack {
                    Label(L10n.relationship, systemImage: "person.2")
                        .foregroundStyle(viewModel.hasContactProfile ? .secondary : .primary)
                    Spacer()
                    if viewModel.hasContactProfile {
                        Text(viewModel.effectiveRelationship)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker(L10n.relationship, selection: $viewModel.selectedRelationship) {
                            ForEach(Relationship.allCases) { relationship in
                                Text(relationship.localizedName).tag(relationship)
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
                        Label(L10n.useMyStyle, systemImage: "person.text.rectangle")
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
                    Text(L10n.settingsFromProfile(viewModel.selectedContactProfile?.name ?? "profile"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var tonePickerRow: some View {
        HStack {
            Label(L10n.tone, systemImage: "face.smiling")
                .foregroundStyle(viewModel.hasContactProfile && viewModel.selectedContactProfile?.preferredTone != nil ? .secondary : .primary)
            Spacer()
            if viewModel.hasContactProfile, let preferredTone = viewModel.selectedContactProfile?.preferredTone {
                Text(preferredTone)
                    .foregroundStyle(.secondary)
            } else {
                Picker(L10n.tone, selection: $viewModel.selectedTone) {
                    ForEach(Tone.allCases) { tone in
                        Text(tone.localizedName).tag(tone)
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
            Text(L10n.additionalContext)
                .font(.headline)
                .foregroundStyle(.primary)
            
            TextField(L10n.contextPlaceholder, text: $viewModel.contextText, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Pro Features Section
    
    private var proFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.proFeatures)
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                // Full Story (Multi-Screenshot) - Pro Feature (ON TOP)
                fullStoryFeatureRow
                
                // My Style - Pro Feature (with toggle)
                myStyleFeatureRow
                
                // Decode Message - Pro Feature
                decodeMessageFeatureRow
                
                // Contact Profiles - Pro Feature
                contactProfilesFeatureRow
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
                        Text(L10n.contactProfiles)
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
                         ? L10n.profilesSaved(contactProfileManager.profileCount)
                         : L10n.contactProfilesDesc)
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
                        Text(L10n.fullStoryModeTitle)
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
                         ? L10n.fullStoryModeDescActive(MultiScreenshotConstants.proMaxScreenshots)
                         : L10n.fullStoryModeDescLocked)
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
                        Text(L10n.decodeMessage)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        if !viewModel.isPro {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Text(L10n.decodeMessageDesc)
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
        HStack(spacing: 0) {
            // Main button area
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
                            Text(L10n.myStyle)
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
                             ? (viewModel.useMyStyle ? L10n.myStyleActive : L10n.myStyleConfigure)
                             : L10n.myStyleTrain)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            
            // Toggle button (only for Pro users with style profile)
            if viewModel.isPro && styleManager.hasCompleteProfile {
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 8)
                
                Toggle("", isOn: $viewModel.useMyStyle)
                    .labelsHidden()
                    .padding(.trailing, 4)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.trailing, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(!viewModel.isPro ? 0.7 : 1.0)
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
                    await generateWithDelay()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        LoadingDotsView()
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(viewModel.isLoading ? L10n.generating : L10n.generateReply)
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
                Text(L10n.freeGenerationsRemaining(viewModel.remainingFreeGenerations))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if !viewModel.isPro && viewModel.remainingFreeGenerations == 0 {
                Button {
                    viewModel.showPaywall = true
                } label: {
                    Text(L10n.dailyLimitReached)
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
    
    /// Generate reply with minimum 5 second delay for better UX
    private func generateWithDelay() async {
        let startTime = Date()
        
        // Start the actual generation
        async let generation: Bool = viewModel.generateReply()
        
        // Wait for both generation and minimum delay
        let _ = await generation
        
        // Calculate remaining time to reach 5 seconds
        let elapsed = Date().timeIntervalSince(startTime)
        let minimumDelay: TimeInterval = 5.0
        
        if elapsed < minimumDelay {
            try? await Task.sleep(nanoseconds: UInt64((minimumDelay - elapsed) * 1_000_000_000))
        }
    }
    
    // MARK: - Result Section
    
    private var resultSection: some View {
        VStack(spacing: 16) {
            // Beautiful Reply Card
            ReplyCardView(
                reply: viewModel.generatedReply,
                tone: viewModel.effectiveTone,
                relationship: viewModel.effectiveRelationship
            )
            .overlay(alignment: .topTrailing) {
                // Copied toast
                if showCopiedToast {
                    Text(L10n.copied)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                        .padding(12)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                // Copy Text Button
                Button {
                    UIPasteboard.general.string = viewModel.generatedReply
                    withAnimation(.spring(response: 0.3)) {
                        showCopiedToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showCopiedToast = false
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                        Text(L10n.copyText)
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Share Card Button
                Button {
                    showShareCard = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text(L10n.shareCard)
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.top, 8)
        .sheet(isPresented: $showShareCard) {
            ShareCardSheet(
                reply: viewModel.generatedReply,
                tone: viewModel.effectiveTone,
                relationship: viewModel.effectiveRelationship
            )
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
}

// MARK: - Reply Card View

struct ReplyCardView: View {
    let reply: String
    let tone: String
    let relationship: String
    
    private var gradientColors: [Color] {
        switch tone.lowercased() {
        case "angry": return [Color.red, Color.orange]
        case "funny": return [Color.yellow, Color.orange]
        case "professional": return [Color.blue, Color.indigo]
        case "sarcastic": return [Color.purple, Color.pink]
        case "passive aggressive": return [Color.gray, Color.purple]
        case "romantic": return [Color.pink, Color.red]
        case "apologetic": return [Color.blue, Color.cyan]
        case "assertive": return [Color.orange, Color.red]
        case "friendly": return [Color.green, Color.teal]
        case "formal": return [Color.gray, Color.blue]
        case "casual": return [Color.teal, Color.green]
        case "sympathetic": return [Color.purple, Color.blue]
        case "flirty": return [Color.pink, Color.purple]
        default: return [Color.accentColor, Color.purple]
        }
    }
    
    private var toneEmoji: String {
        switch tone.lowercased() {
        case "angry": return "😤"
        case "funny": return "😂"
        case "professional": return "💼"
        case "sarcastic": return "😏"
        case "passive aggressive": return "🙃"
        case "romantic": return "💕"
        case "apologetic": return "🥺"
        case "assertive": return "💪"
        case "friendly": return "😊"
        case "formal": return "🎩"
        case "casual": return "✌️"
        case "sympathetic": return "🤗"
        case "flirty": return "😘"
        default: return "✨"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with tone badge
            HStack {
                HStack(spacing: 6) {
                    Text(toneEmoji)
                    Text(tone)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            // Reply text
            Text(reply)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .textSelection(.enabled)
                .lineSpacing(4)
            
            // Footer
            HStack {
                Text(L10n.generatedBy)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
                
                Spacer()
                
                Text(L10n.forRelationship(relationship))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: gradientColors[0].opacity(0.4), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Share Card Sheet

struct ShareCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    let reply: String
    let tone: String
    let relationship: String
    
    @State private var renderedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(L10n.shareYourReply)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Preview card
                ReplyCardView(reply: reply, tone: tone, relationship: relationship)
                    .padding(.horizontal)
                
                // Share buttons
                VStack(spacing: 12) {
                    // Share as Image
                    Button {
                        shareAsImage()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "photo")
                            Text(L10n.shareAsImage)
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // Share as Text
                    Button {
                        shareAsText()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "text.bubble")
                            Text(L10n.shareAsText)
                        }
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 24)
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
        }
    }
    
    @MainActor
    private func shareAsImage() {
        let cardView = ReplyCardView(reply: reply, tone: tone, relationship: relationship)
            .padding(20)
            .frame(width: 350)
            .background(Color(.systemBackground))
        
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0
        
        if let image = renderer.uiImage {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }
    
    private func shareAsText() {
        let activityVC = UIActivityViewController(activityItems: [reply], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Loading Dots Animation

struct LoadingDotsView: View {
    @State private var dotCount = 0
    
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .scaleEffect(dotCount == index ? 1.2 : 0.8)
                    .opacity(dotCount == index ? 1.0 : 0.5)
                    .animation(.easeInOut(duration: 0.3), value: dotCount)
            }
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 3
        }
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
