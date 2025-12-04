//
//  SettingsView.swift
//  replyerAI
//
//  Created by Ege Can Koç on 4.12.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @State private var appearanceManager = AppearanceManager.shared
    
    // App version from bundle
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version).\(build)"
    }
    
    // URLs - Update these with your actual URLs
    private let termsURL = URL(string: "https://example.com/terms")!
    private let privacyURL = URL(string: "https://example.com/privacy")!
    private let supportEmail = "support@example.com"
    private let feedbackEmail = "feedback@example.com"
    private let appStoreID = "YOUR_APP_STORE_ID" // Replace with your actual App Store ID
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Appearance Section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: appearanceManager.appearanceMode.icon)
                            .font(.body)
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 24)
                        
                        Picker("Appearance", selection: $appearanceManager.appearanceMode) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose how ReplyerAI looks. System follows your device settings.")
                }
                
                // MARK: - General Section
                Section {
                    // Share App
                    ShareLink(item: URL(string: "https://apps.apple.com/app/id\(appStoreID)")!) {
                        SettingsRow(
                            title: "Share ReplyerAI",
                            icon: "square.and.arrow.up",
                            iconColor: .blue
                        )
                    }
                    
                    // Rate Us
                    Button {
                        requestReview()
                    } label: {
                        SettingsRow(
                            title: "Rate Us",
                            icon: "star.fill",
                            iconColor: .yellow
                        )
                    }
                    
                    // Terms of Use
                    Link(destination: termsURL) {
                        SettingsRow(
                            title: "Terms of Use",
                            icon: "doc.text",
                            iconColor: .gray
                        )
                    }
                    
                    // Privacy Policy
                    Link(destination: privacyURL) {
                        SettingsRow(
                            title: "Privacy Policy",
                            icon: "hand.raised.fill",
                            iconColor: .green
                        )
                    }
                    
                    // App Version
                    HStack {
                        SettingsRow(
                            title: "App Version",
                            icon: "info.circle",
                            iconColor: .secondary,
                            showChevron: false
                        )
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("General")
                }
                
                // MARK: - Support Section
                Section {
                    // Support
                    Button {
                        openMail(to: supportEmail, subject: "ReplyerAI Support Request")
                    } label: {
                        SettingsRow(
                            title: "Support",
                            icon: "questionmark.circle",
                            iconColor: .purple
                        )
                    }
                    
                    // Feedback & Suggestions
                    Button {
                        openMail(to: feedbackEmail, subject: "ReplyerAI Feedback")
                    } label: {
                        SettingsRow(
                            title: "Feedback & Suggestions",
                            icon: "envelope.fill",
                            iconColor: .orange
                        )
                    }
                } header: {
                    Text("Support")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
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
        }
    }
    
    // MARK: - Helper Methods
    
    private func openMail(to email: String, subject: String) {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Settings Row Component

struct SettingsRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    var showChevron: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 24)
            
            Text(title)
                .foregroundStyle(.primary)
            
            if showChevron {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

