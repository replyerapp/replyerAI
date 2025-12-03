//
//  ContentView.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var viewModel = ReplyViewModel()
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Photo Picker Section
                    photoPickerSection
                    
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
            .navigationTitle("ReplyerAI")
            .toolbar {
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
    
    // MARK: - Generate Button
    
    private var generateButton: some View {
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
