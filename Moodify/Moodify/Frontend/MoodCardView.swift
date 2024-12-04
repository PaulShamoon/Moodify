/*
    This is the mood card view for the Moodify app.
    Created by: Nazanin Mahmoudi
*/

import SwiftUI

/**
 * MoodCardOnboardingView
 * Shows onboarding cards for different moods with descriptions
 * Features:
 * - Custom gradient background per mood
 * - Icon and text display
 * - Shadow and rounded corner styling
 */

struct MoodCardOnboardingView: View {
    let moodOnboarding: MoodOnboarding
    
    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(
                    gradient: Gradient(colors: moodOnboarding.mood.colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.15))
                )
                .frame(width: 300, height: 400)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Content
            VStack(spacing: 0) {
                // Top spacing
                Spacer()
                    .frame(height: 50)
                
                // Icon
                Image(systemName: moodOnboarding.mood.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                // Spacing between icon and title
                Spacer()
                    .frame(height: 30)
                
                // Title
                Text(moodOnboarding.mood.name)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                // Spacing between title and description
                Spacer()
                    .frame(height: 30)
                
                // Description with background
                Text(moodOnboarding.message)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .frame(maxWidth: 260) // Fixed width for consistent alignment
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.15))
                            .blur(radius: 5)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
                
                // Bottom spacing
                Spacer()
                    .frame(height: 50)
            }
            .frame(width: 300) // Match parent width
        }
    }
}

/**
 * AnimatedGradientBackground 
 * Creates smooth animated gradient transitions between colors
 * Features:
 * - Alternates between normal and dark color sets
 * - Full screen gradient background
 * - Continuous animation loop
 */

struct AnimatedGradientBackground: View {
    var colors: [Color]
    var darkColors: [Color]
    
    @State private var isDarkened = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: isDarkened ? darkColors : colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isDarkened.toggle()
            }
        }
    }
}

#Preview("Mood Card with Background") {
    ZStack {
        AnimatedGradientBackground(
            colors: [.yellow, .orange],
            darkColors: [.yellow.opacity(0.6), .orange.opacity(0.6)]
        )
        
        MoodCardOnboardingView(
            moodOnboarding: MoodOnboarding(
                mood: Mood(
                    name: "Happy",
                    colors: [.yellow, .orange],
                    darkColors: [.yellow.opacity(0.6), .orange.opacity(0.6)],
                    icon: "sun.max.fill"
                ),
                message: "Discover music that\nlifts your spirits and\nkeeps you energized."
            )
        )
    }
}

#Preview("Different Moods") {
    VStack(spacing: 20) {
        ZStack {
            AnimatedGradientBackground(
                colors: [.blue, .purple],
                darkColors: [.blue.opacity(0.6), .purple.opacity(0.6)]
            )
            
            MoodCardOnboardingView(
                moodOnboarding: MoodOnboarding(
                    mood: Mood(
                        name: "Calm",
                        colors: [.blue, .purple],
                        darkColors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                        icon: "cloud.moon.fill"
                    ),
                    message: "Find comfort in melodies\nthat understand and\nsupport your feelings."
                )
            )
        }
    }
}
