//
//  ShareSheet.swift
//  replyerAI
//
//  Created by Ege Can Koç on 3.12.2025.
//

import SwiftUI

/// A SwiftUI wrapper for UIActivityViewController to share content
struct ShareSheet: UIViewControllerRepresentable {
    
    /// The items to share (text, images, URLs, etc.)
    let items: [Any]
    
    /// Optional activities to exclude from the share sheet
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    /// Completion handler called when the share sheet is dismissed
    var onComplete: ((Bool) -> Void)? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onComplete?(completed)
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Convenience Extensions

extension View {
    /// Presents a share sheet with the given text
    /// - Parameters:
    ///   - isPresented: Binding to control sheet presentation
    ///   - text: The text to share
    ///   - onComplete: Optional completion handler
    func shareSheet(
        isPresented: Binding<Bool>,
        text: String,
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            ShareSheet(items: [text], onComplete: onComplete)
                .presentationDetents([.medium, .large])
        }
    }
    
    /// Presents a share sheet with the given items
    /// - Parameters:
    ///   - isPresented: Binding to control sheet presentation
    ///   - items: The items to share
    ///   - onComplete: Optional completion handler
    func shareSheet(
        isPresented: Binding<Bool>,
        items: [Any],
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            ShareSheet(items: items, onComplete: onComplete)
                .presentationDetents([.medium, .large])
        }
    }
}

