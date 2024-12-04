/*
 * OnboardingView.swift
 * Main view controller for the app's onboarding experience.
 * Displays a series of introductory screens to new users.
 * Created by: Nazanin Mahmoudi
 */

import SwiftUI

// Add this near the top of the file, before the OnboardingView struct
let milkyBeige = Color(hex: "#F5E6D3")

/**
 * OnboardingView
 * A SwiftUI view that manages the onboarding flow with multiple pages and animations.
 * Features:
 * - Paginated content with dots indicator
 * - Animated background
 * - Next/Get Started button
 */
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showMoodView = false
    private let totalPages = 3
    var onCompletion: () -> Void
    
    var body: some View {
        ZStack {
            if showMoodView {
                OnboardingMoodView(onCompletion: onCompletion)
                    .transition(.opacity)
            } else {
                mainOnboardingContent
            }
        }
        .animation(.easeInOut, value: showMoodView)
    }
    
    private var mainOnboardingContent: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(hex: "0A2F23"),
                    Color(hex: "0A2F23")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                /* TabView for swipeable onboarding pages */
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        title: "Welcome to Moodify",
                        description: "Discover music that perfectly matches your mood.",
                        imageName: "music.note"
                    ).tag(0)
                    
                    OnboardingPageView(
                        title: "Capture Your Mood",
                        description: "Use your camera to detect your mood effortlessly.",
                        imageName: "camera.fill"
                    ).tag(1)
                    
                    OnboardingPageView(
                        title: "Personalized Playlists",
                        description: "Get Spotify playlists curated just for your current vibe.",
                        imageName: "headphones"
                    ).tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                /* Page indicator dots */
                HStack(spacing: 8) {
                    ForEach(0..<totalPages) { index in
                        Circle()
                            .fill(index == currentPage ? Color(hex: "22C55E") : Color(hex: "94A3B8").opacity(0.3))
                            .frame(width: 12, height: 12)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 40)
                
                /* Navigation button */
                Button(action: {
                    if currentPage < totalPages - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        withAnimation {
                            showMoodView = true
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Text(currentPage < totalPages - 1 ? "Next" : "Continue")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .lineLimit(1)
                    }
                    .foregroundColor(Color(hex: "#F5E6D3"))
                    .frame(maxWidth: 180)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#1A2F2A"), Color(hex: "#243B35")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(
                        color: Color(hex: "#243B35").opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .padding(.bottom, 50)
            }
        }
    }
}

/**
 * OnboardingPageView
 * Individual page view for each onboarding screen.
 * Contains:
 * - SF Symbol icon
 * - Title
 * - Description
 */
struct OnboardingPageView: View {
    let title: String
    let description: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            /* Main icon */
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(hex: "4ADE80"),
                            Color(hex: "22C55E")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(radius: 10)
                .padding(.bottom, 20)
            
            /* Title text */
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(hex: "4ADE80"),
                            Color(hex: "22C55E")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            /* Description text */
            Text(description)
                .font(.subheadline)
                .foregroundColor(Color(hex: "94A3B8"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(4)
            
            Spacer()
        }
        .padding()
    }
}

/*
 * Preview Provider for the OnboardingView
 */

#Preview {
    OnboardingView(onCompletion: {})
}
