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
import Photos

struct ContentView: View {
    @State private var viewModel = ReplyViewModel()
    @State private var showShareSheet = false
    @State private var showCopiedToast = false
    @State private var showStyleMimicry = false
    @State private var showDecodeMessage = false
    @State private var showContactProfiles = false
    @State private var showSettings = false
    @State private var showResultPopup = false
    @State private var styleManager = StyleProfileManager.shared
    @State private var contactProfileManager = ContactProfileManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Subscription Status
                    if viewModel.isPro {
                        proStatusBanner
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
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
        .sheet(isPresented: $showStyleMimicry) {
            StyleMimicryView()
        }
        .sheet(isPresented: $showDecodeMessage) {
            DecodeMessageView()
        }
        .sheet(isPresented: $showContactProfiles) {
            ContactProfilesView()
        }
        .onChange(of: viewModel.generatedReply) { oldValue, newValue in
            if !newValue.isEmpty && oldValue.isEmpty {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showResultPopup = true
                }
            }
        }
        .fullScreenCover(isPresented: $showResultPopup) {
            ResultPopupView(
                reply: viewModel.generatedReply,
                showCopiedToast: $showCopiedToast,
                onDismiss: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showResultPopup = false
                    }
                },
                onShareAsImage: { }
            )
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
    
    // MARK: - Pro Status Banner
    
    private var proStatusBanner: some View {
        HStack(spacing: 12) {
            // Crown icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Replyer Pro")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Unlimited access to all features")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundStyle(.green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.4), .pink.opacity(0.4), .orange.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
    }
    
    // MARK: - Free Usage Banner
    
    private var freeUsageBanner: some View {
        Button {
            viewModel.showPaywall = true
        } label: {
            HStack {
                // Warning icon when out of generations
                if viewModel.remainingFreeGenerations == 0 {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(L10n.freePlan)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if viewModel.remainingFreeGenerations == 0 {
                            Text("• Limit Reached")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.orange)
                        }
                    }
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
                    .background(viewModel.remainingFreeGenerations == 0 ? Color.orange : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        viewModel.remainingFreeGenerations == 0 ?
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.5), lineWidth: 1.5)
                        : nil
                    )
            )
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
                // Use centered layout for single image, scrollable for multiple
                if viewModel.selectedImages.count == 1 {
                    // Single image - centered
                    VStack(spacing: 12) {
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 4) {
                                Image(uiImage: viewModel.selectedImages[0])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Delete button
                            Button {
                                viewModel.removeImage(at: 0)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white, .red)
                            }
                            .offset(x: 8, y: -8)
                        }
                        
                        // Add more button (if Pro and allowed)
                        if viewModel.canAddMoreScreenshots {
                            PhotosPicker(
                                selection: $viewModel.imageSelections,
                                maxSelectionCount: viewModel.maxScreenshots,
                                matching: .images
                            ) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.body)
                                    Text(L10n.addMore)
                                        .font(.subheadline)
                                }
                                .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    // Multiple images - horizontal scroll
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

            // Privacy notice for screenshots
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "lock.shield")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(L10n.screenshotPrivacyNotice)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
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
        VStack(alignment: .leading, spacing: 0) {
            // Premium Header
            HStack {
                Image(systemName: "crown.fill")
                    .font(.subheadline)
                    .foregroundStyle(.yellow)
                Text(L10n.proFeatures)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
                if !viewModel.isPro {
                    Text("PRO")
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            VStack(spacing: 0) {
                // Full Story (Multi-Screenshot) - Pro Feature (ON TOP)
                fullStoryFeatureRow
                
                Divider()
                    .padding(.leading, 56)
                
                // My Style - Pro Feature (with toggle)
                myStyleFeatureRow
                
                Divider()
                    .padding(.leading, 56)
                
                // Decode Message - Pro Feature
                decodeMessageFeatureRow
                
                Divider()
                    .padding(.leading, 56)
                
                // Contact Profiles - Pro Feature
                contactProfilesFeatureRow
            }
            .padding(.bottom, 8)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.5), .pink.opacity(0.5), .orange.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .purple.opacity(0.1), radius: 8, x: 0, y: 4)
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
                    .foregroundStyle(Color.orange)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(L10n.contactProfiles)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        if !viewModel.isPro {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        } else if contactProfileManager.hasProfiles {
                            Text("\(contactProfileManager.profileCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var fullStoryFeatureRow: some View {
        if viewModel.isPro {
            // Pro users - just display, no button action needed
            HStack(spacing: 12) {
                Image(systemName: "photo.stack.fill")
                    .font(.title2)
                    .foregroundStyle(Color.blue)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(L10n.fullStoryModeTitle)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    
                    Text(L10n.fullStoryModeDescActive(MultiScreenshotConstants.proMaxScreenshots))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        } else {
            // Non-Pro users - button to show paywall
            Button {
                viewModel.showPaywall = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "photo.stack.fill")
                        .font(.title2)
                        .foregroundStyle(Color.blue)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(L10n.fullStoryModeTitle)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        
                        Text(L10n.fullStoryModeDescLocked)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
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
                    .foregroundStyle(Color.pink)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(L10n.decodeMessage)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        if !viewModel.isPro {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.purple)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(L10n.myStyle)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            if !viewModel.isPro {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
                .background(
                    Group {
                        if !viewModel.hasImages {
                            Color.gray
                        } else {
                            AnimatedGradientView()
                        }
                    }
                )
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


// MARK: - Result Popup View

struct ResultPopupView: View {
    let reply: String
    @Binding var showCopiedToast: Bool
    let onDismiss: () -> Void
    let onShareAsImage: () -> Void
    
    // Random gradient colors for text - generated on init
    @State private var textGradientColors: [Color] = ResultPopupView.randomGradientColors()
    
    // Image editing options
    @State private var selectedBackgroundColor: Color = .black
    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""
    
    // Preset color options
    private let backgroundPresets: [Color] = [
        .black, Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f0f23"),
        Color(hex: "2d132c"), Color(hex: "1e3a5f"), Color(hex: "2c3e50"),
        .white, Color(hex: "f5f5dc"), Color(hex: "faf0e6")
    ]
    
    private let gradientPresets: [[Color]] = [
        [Color(hex: "667eea"), Color(hex: "764ba2")],
        [Color(hex: "f093fb"), Color(hex: "f5576c")],
        [Color(hex: "4facfe"), Color(hex: "00f2fe")],
        [Color(hex: "43e97b"), Color(hex: "38f9d7")],
        [Color(hex: "fa709a"), Color(hex: "fee140")],
        [Color(hex: "a18cd1"), Color(hex: "fbc2eb")],
        [Color(hex: "ff0844"), Color(hex: "ffb199")],
        [Color(hex: "00c6fb"), Color(hex: "005bea")]
    ]
    
    static func randomGradientColors() -> [Color] {
        let allGradients: [[Color]] = [
            [Color(hex: "667eea"), Color(hex: "764ba2")],
            [Color(hex: "f093fb"), Color(hex: "f5576c")],
            [Color(hex: "4facfe"), Color(hex: "00f2fe")],
            [Color(hex: "43e97b"), Color(hex: "38f9d7")],
            [Color(hex: "fa709a"), Color(hex: "fee140")],
            [Color(hex: "a18cd1"), Color(hex: "fbc2eb")],
            [Color(hex: "ff0844"), Color(hex: "ffb199")],
            [Color(hex: "00c6fb"), Color(hex: "005bea")],
            [Color(hex: "f857a6"), Color(hex: "ff5858")],
            [Color(hex: "7f7fd5"), Color(hex: "86a8e7"), Color(hex: "91eae4")],
            [Color(hex: "654ea3"), Color(hex: "eaafc8")],
            [Color(hex: "ff416c"), Color(hex: "ff4b2b")]
        ]
        return allGradients.randomElement() ?? [.purple, .pink]
    }
    
    var body: some View {
        ZStack {
            // Fully opaque black background - hides everything
            Color.black
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Text("Your Reply")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview Card (what will be shared/downloaded)
                        ShareableReplyCard(
                            reply: reply,
                            backgroundColor: selectedBackgroundColor,
                            gradientColors: textGradientColors
                        )
                        .padding(.horizontal, 20)
                        
                        // Editing Options
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Customize")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                            
                            // Background Color
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Background")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(backgroundPresets, id: \.self) { color in
                                            ColorButton(
                                                color: color,
                                                isSelected: selectedBackgroundColor == color
                                            ) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    selectedBackgroundColor = color
                                                }
                                            }
                                        }
                                        
                                        // Custom color picker
                                        ColorPicker("", selection: $selectedBackgroundColor)
                                            .labelsHidden()
                                            .frame(width: 36, height: 36)
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            
                            // Text Gradient
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Text Gradient")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(0..<gradientPresets.count, id: \.self) { index in
                                            GradientButton(
                                                colors: gradientPresets[index],
                                                isSelected: textGradientColors == gradientPresets[index]
                                            ) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    textGradientColors = gradientPresets[index]
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        
                        // Action Buttons - Order: Share, Copy, Download
                        VStack(spacing: 12) {
                            // Share as Image button
                            Button {
                                shareImage()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share as Image")
                                }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            
                            // Copy Text button
                            Button {
                                UIPasteboard.general.string = reply
                                withAnimation(.spring(response: 0.3)) {
                                    showCopiedToast = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation {
                                        showCopiedToast = false
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "doc.on.doc")
                                    Text(showCopiedToast ? "Copied!" : "Copy Text")
                                }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            
                            // Download Image button
                            Button {
                                downloadImage()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: showSaveSuccess ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                                    Text(showSaveSuccess ? "Saved to Photos!" : "Download Image")
                                }
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .alert("Saved!", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Image saved to your photo library.")
        }
        .alert("Error", isPresented: $showSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveErrorMessage)
        }
    }
    
    @MainActor
    private func renderShareableImage() -> UIImage? {
        let cardView = ShareableReplyCard(
            reply: reply,
            backgroundColor: selectedBackgroundColor,
            gradientColors: textGradientColors,
            forExport: true
        )
        .frame(width: 600)
        .padding(20)
        .background(selectedBackgroundColor)
        
        let renderer = ImageRenderer(content: cardView)
        // Use high fixed scale for crisp, non-blurry images
        renderer.scale = 4.0
        return renderer.uiImage
    }
    
    @MainActor
    private func shareImage() {
        guard let image = renderShareableImage() else { return }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            // Find the topmost presented view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            activityVC.popoverPresentationController?.sourceView = topVC.view
            topVC.present(activityVC, animated: true)
        }
    }
    
    @MainActor
    private func downloadImage() {
        guard let image = renderShareableImage() else {
            saveErrorMessage = "Failed to create image"
            showSaveError = true
            return
        }
        
        // Request photo library permission and save
        ImageSaver.shared.saveImage(image) { success, error in
            DispatchQueue.main.async {
                if success {
                    withAnimation(.spring(response: 0.3)) {
                        showSaveSuccess = true
                    }
                    // Reset after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSaveSuccess = false
                        }
                    }
                } else {
                    saveErrorMessage = error ?? "Failed to save image"
                    showSaveError = true
                }
            }
        }
    }
}

// MARK: - Shareable Reply Card (for export)

struct ShareableReplyCard: View {
    let reply: String
    let backgroundColor: Color
    let gradientColors: [Color]
    var forExport: Bool = false
    
    // Fixed corner radius - max roundness
    private let cornerRadius: Double = 40
    
    var body: some View {
        VStack {
            Spacer(minLength: 24)
            
            // Reply text with gradient
            Text(reply)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.horizontal, 28)
            
            Spacer(minLength: 24)
        }
        .frame(minHeight: 180)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(0.3) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: gradientColors.first?.opacity(0.3) ?? .purple.opacity(0.3), radius: forExport ? 0 : 15, x: 0, y: 8)
    }
}

// MARK: - Color Button

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.5), radius: isSelected ? 6 : 2)
        }
    }
}

// MARK: - Gradient Button

struct GradientButton: View {
    let colors: [Color]
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                )
                .shadow(color: colors.first?.opacity(0.5) ?? .purple.opacity(0.5), radius: isSelected ? 6 : 2)
        }
    }
}

// MARK: - Image Saver Helper

class ImageSaver: NSObject {
    static let shared = ImageSaver()
    
    private var completion: ((Bool, String?) -> Void)?
    
    func saveImage(_ image: UIImage, completion: @escaping (Bool, String?) -> Void) {
        self.completion = completion
        
        // Check photo library permission
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            performSave(image)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.performSave(image)
                    } else {
                        completion(false, "Photo library access denied. Please enable in Settings.")
                    }
                }
            }
        case .denied, .restricted:
            completion(false, "Photo library access denied. Please enable in Settings > Privacy > Photos.")
        @unknown default:
            completion(false, "Unable to access photo library.")
        }
    }
    
    private func performSave(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            completion?(false, error.localizedDescription)
        } else {
            completion?(true, nil)
        }
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Animated Gradient View

struct AnimatedGradientView: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.purple,
                Color.pink,
                Color.orange,
                Color.yellow,
                Color.pink,
                Color.purple
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(
                .linear(duration: 3.0)
                .repeatForever(autoreverses: true)
            ) {
                animateGradient.toggle()
            }
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
