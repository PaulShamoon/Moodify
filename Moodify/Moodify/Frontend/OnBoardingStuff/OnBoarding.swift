/*
 * OnboardingView.swift
 * Main view controller for the app's onboarding experience.
 * Displays a series of introductory screens to new users.
 * Created by: Nazanin Mahmoudi
 */

import SwiftUI

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
            AnimatedDarkBackground()
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
                            .fill(index == currentPage ? Color.green : Color.white.opacity(0.3))
                            .frame(width: 10, height: 10)
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
                    Text(currentPage < totalPages - 1 ? "Next" : "Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180)
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(color: Color.green.opacity(0.5), radius: 10, x: 0, y: 10)
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
                .foregroundColor(.white)
                .shadow(radius: 10)
                .padding(.bottom, 20)
            
            /* Title text */
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            /* Description text */
            Text(description)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding()
    }
}

/**
 * AnimatedDarkBackground
 * Creates an animated gradient background with floating circles.
 * Features:
 * - Gradient background
 * - Animated floating circles
 * - Random circle sizes and animation durations
 */
struct AnimatedDarkBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.hex("#1A1A2E"), Color.hex("#16213E"), Color.hex("#0F3460")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            
            /* Animated floating circles */
            ForEach(0..<15) { _ in
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: CGFloat.random(in: 50...120), height: CGFloat.random(in: 50...120))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                    .offset(y: animate ? -50 : 50)
                    .animation(Animation.easeInOut(duration: Double.random(in: 4...8)).repeatForever(autoreverses: true))
            }
        }
        .onAppear {
            animate = true
        }
    }
}

/*
 * Preview Provider for the OnboardingView
 */

#Preview {
    OnboardingView(onCompletion: {})
}
