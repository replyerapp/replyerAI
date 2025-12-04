//
//  ContactProfilesView.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI

// MARK: - Contact Profiles List View

struct ContactProfilesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var profileManager = ContactProfileManager.shared
    @State private var showAddProfile = false
    @State private var profileToEdit: ContactProfile?
    
    var body: some View {
        NavigationStack {
            Group {
                if profileManager.profiles.isEmpty {
                    emptyStateView
                } else {
                    profilesList
                }
            }
            .navigationTitle("Contact Profiles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddProfile = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddProfile) {
                AddEditProfileView(mode: .add)
            }
            .sheet(item: $profileToEdit) { profile in
                AddEditProfileView(mode: .edit(profile))
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Contact Profiles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Save profiles for people you message frequently. Add notes like \"hates emojis\" or \"loves sarcasm\" and the AI will remember!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                showAddProfile = true
            } label: {
                Label("Create First Profile", systemImage: "plus.circle.fill")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Profiles List
    
    private var profilesList: some View {
        List {
            Section {
                ForEach(profileManager.profiles) { profile in
                    ProfileRowView(profile: profile) {
                        profileToEdit = profile
                    }
                }
                .onDelete { offsets in
                    profileManager.deleteProfile(at: offsets)
                }
            } header: {
                Text("\(profileManager.profileCount) Profile\(profileManager.profileCount == 1 ? "" : "s")")
            } footer: {
                Text("Swipe left to delete a profile. Tap to edit.")
            }
        }
    }
}

// MARK: - Profile Row View

struct ProfileRowView: View {
    let profile: ContactProfile
    let onEdit: () -> Void
    
    var body: some View {
        Button {
            onEdit()
        } label: {
            HStack(spacing: 12) {
                // Emoji avatar
                Text(profile.emoji)
                    .font(.title)
                    .frame(width: 44, height: 44)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(profile.relationship)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if !profile.notes.isEmpty {
                        Text(profile.notes)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add/Edit Profile View

struct AddEditProfileView: View {
    enum Mode: Identifiable {
        case add
        case edit(ContactProfile)
        
        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let profile): return profile.id.uuidString
            }
        }
    }
    
    let mode: Mode
    
    @Environment(\.dismiss) private var dismiss
    @State private var profileManager = ContactProfileManager.shared
    
    @State private var name: String = ""
    @State private var selectedRelationship: Relationship = .friend
    @State private var notes: String = ""
    @State private var selectedTone: Tone? = nil
    @State private var usePreferredTone: Bool = false
    @State private var selectedEmoji: String = ""
    @State private var showEmojiPicker: Bool = false
    
    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    private var existingProfile: ContactProfile? {
        if case .edit(let profile) = mode { return profile }
        return nil
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Info Section
                Section {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    
                    Picker("Relationship", selection: $selectedRelationship) {
                        ForEach(Relationship.allCases) { relationship in
                            Text(relationship.rawValue).tag(relationship)
                        }
                    }
                    
                    // Emoji Picker
                    Button {
                        showEmojiPicker = true
                    } label: {
                        HStack {
                            Text("Emoji")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(selectedEmoji.isEmpty ? defaultEmojiForRelationship : selectedEmoji)
                                .font(.title2)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("Basic Info")
                }
                
                // Notes Section
                Section {
                    TextField("e.g., Hates emojis, loves sarcasm, always busy...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes for AI")
                } footer: {
                    Text("Add any details the AI should remember when generating replies for this person.")
                }
                
                // Preferred Tone Section
                Section {
                    Toggle("Set Preferred Tone", isOn: $usePreferredTone)
                    
                    if usePreferredTone {
                        Picker("Tone", selection: $selectedTone) {
                            Text("None").tag(nil as Tone?)
                            ForEach(Tone.allCases) { tone in
                                Text(tone.rawValue).tag(tone as Tone?)
                            }
                        }
                    }
                } header: {
                    Text("Default Tone")
                } footer: {
                    Text("Automatically use this tone when this contact is selected.")
                }
                
                // Delete Section (Edit mode only)
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            if let profile = existingProfile {
                                profileManager.deleteProfile(profile)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Profile")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Profile" : "New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .onAppear {
                loadExistingProfile()
            }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiPickerView(selectedEmoji: $selectedEmoji)
            }
        }
    }
    
    private var defaultEmojiForRelationship: String {
        switch selectedRelationship {
        case .wife, .husband: return "💍"
        case .girlfriend, .boyfriend: return "❤️"
        case .boss: return "👔"
        case .coworker: return "💼"
        case .friend: return "😊"
        case .bestFriend: return "🤝"
        case .parent: return "👨‍👩‍👧"
        case .sibling: return "👫"
        case .exPartner: return "💔"
        case .acquaintance: return "👋"
        case .stranger: return "❓"
        }
    }
    
    private func loadExistingProfile() {
        guard let profile = existingProfile else { return }
        
        name = profile.name
        notes = profile.notes
        selectedEmoji = profile.customEmoji ?? ""
        
        // Find matching relationship
        if let relationship = Relationship.allCases.first(where: { $0.rawValue == profile.relationship }) {
            selectedRelationship = relationship
        }
        
        // Load preferred tone
        if let toneName = profile.preferredTone,
           let tone = Tone.allCases.first(where: { $0.rawValue == toneName }) {
            selectedTone = tone
            usePreferredTone = true
        }
    }
    
    private func saveProfile() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let preferredTone = usePreferredTone ? selectedTone?.rawValue : nil
        
        let customEmoji = selectedEmoji.isEmpty ? nil : selectedEmoji
        
        if let existing = existingProfile {
            // Update existing profile
            let updated = ContactProfile(
                id: existing.id,
                name: trimmedName,
                relationship: selectedRelationship.rawValue,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                preferredTone: preferredTone,
                customEmoji: customEmoji,
                createdAt: existing.createdAt,
                updatedAt: Date()
            )
            profileManager.updateProfile(updated)
        } else {
            // Create new profile
            let newProfile = ContactProfile(
                name: trimmedName,
                relationship: selectedRelationship.rawValue,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                preferredTone: preferredTone,
                customEmoji: customEmoji
            )
            profileManager.addProfile(newProfile)
        }
        
        dismiss()
    }
}

// MARK: - Contact Profile Picker

struct ContactProfilePicker: View {
    @Binding var selectedProfile: ContactProfile?
    @State private var profileManager = ContactProfileManager.shared
    @State private var showProfilesList = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with manage button
            HStack {
                Label("Contact", systemImage: "person.crop.circle")
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if profileManager.hasProfiles {
                    Menu {
                        // None option
                        Button {
                            selectedProfile = nil
                        } label: {
                            if selectedProfile == nil {
                                Label("None (Manual)", systemImage: "checkmark")
                            } else {
                                Text("None (Manual)")
                            }
                        }
                        
                        Divider()
                        
                        // Profile options
                        ForEach(profileManager.profiles) { profile in
                            Button {
                                selectedProfile = profile
                            } label: {
                                if selectedProfile?.id == profile.id {
                                    Label("\(profile.emoji) \(profile.name)", systemImage: "checkmark")
                                } else {
                                    Text("\(profile.emoji) \(profile.name)")
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Manage profiles
                        Button {
                            showProfilesList = true
                        } label: {
                            Label("Manage Profiles...", systemImage: "gear")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if let profile = selectedProfile {
                                Text("\(profile.emoji) \(profile.name)")
                                    .foregroundStyle(.primary)
                            } else {
                                Text("Select")
                                    .foregroundStyle(.secondary)
                            }
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Button {
                        showProfilesList = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("Add Profile")
                                .foregroundStyle(Color.accentColor)
                            Image(systemName: "plus.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            // Selected profile info
            if let profile = selectedProfile, !profile.notes.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color.accentColor)
                    Text(profile.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.1))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showProfilesList) {
            ContactProfilesView()
        }
    }
}

// MARK: - Emoji Picker View

struct EmojiPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEmoji: String
    
    private let columns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Clear option
                    Button {
                        selectedEmoji = ""
                        dismiss()
                    } label: {
                        HStack {
                            Text("Use Default")
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedEmoji.isEmpty {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    // Emoji grid
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(ContactEmojis.all, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                                dismiss()
                            } label: {
                                Text(emoji)
                                    .font(.title)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        selectedEmoji == emoji
                                            ? Color.accentColor.opacity(0.2)
                                            : Color(.secondarySystemBackground)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedEmoji == emoji ? Color.accentColor : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContactProfilesView()
}

