//
//  OnboardingView.swift
//  replyerAI
//
//  Created by AI Assistant on 7.12.2025.
//

import SwiftUI

/// Root onboarding flow shown on first launch.
struct OnboardingView: View {
    /// Called when the user finishes onboarding.
    let onFinished: () -> Void
    
    @State private var currentPage: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                // Screen 1 – App overview
                OnboardingPageView(
                    media: {
                        OnboardingMediaBubble {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 54))
                                .foregroundStyle(Color.purple)
                        }
                    },
                    title: L10n.onboardingTitle1,
                    subtitle: L10n.onboardingSubtitle1
                )
                .tag(0)
                
                // Screen 2 – Reply Like Me (My Style)
                OnboardingPageView(
                    media: {
                        OnboardingMediaBubble {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 54))
                                .foregroundStyle(Color.purple)
                        }
                    },
                    title: L10n.onboardingTitle2,
                    subtitle: L10n.onboardingSubtitle2
                )
                .tag(1)
                
                // Screen 3 – Decode Message
                OnboardingPageView(
                    media: {
                        OnboardingMediaBubble {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 54))
                                .foregroundStyle(Color.pink)
                        }
                    },
                    title: L10n.onboardingTitle3,
                    subtitle: L10n.onboardingSubtitle3
                )
                .tag(2)
                
                // Screen 4 – Contact Profiles
                OnboardingPageView(
                    media: {
                        OnboardingMediaBubble {
                            Image(systemName: "person.2.circle.fill")
                                .font(.system(size: 54))
                                .foregroundStyle(Color.orange)
                        }
                    },
                    title: L10n.onboardingTitle4,
                    subtitle: L10n.onboardingSubtitle4
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            
            // Primary button - outside TabView so it's higher
            Button {
                if currentPage < 3 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    onFinished()
                }
            } label: {
                Text(currentPage == 3 ? L10n.onboardingStart : L10n.onboardingNext)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.pink, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 50)
        }
    }
}

/// A single onboarding page.
struct OnboardingPageView<Media: View>: View {
    let media: () -> Media
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack {
            Spacer(minLength: 60)
            
            // Top media area – can be replaced with custom images or videos.
            media()
                .padding(.bottom, 40)
            
            // Text content
            VStack(spacing: 16) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
    }
}

/// Circular gradient bubble container for any custom media.
/// You can swap the inner content for your own images or videos.
struct OnboardingMediaBubble<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.1),
                            Color.orange.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 220, height: 220)
            
            content
        }
    }
}


