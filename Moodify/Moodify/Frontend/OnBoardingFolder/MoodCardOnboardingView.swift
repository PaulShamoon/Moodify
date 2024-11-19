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
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(
                    gradient: Gradient(colors: moodOnboarding.mood.colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 300, height: 400)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 20) {
                Image(systemName: moodOnboarding.mood.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text(moodOnboarding.mood.name)
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(moodOnboarding.message)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .frame(width: 280)
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
                message: "Feel the joy and energy with upbeat tunes!"
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
                    message: "Relax and unwind with soothing melodies."
                )
            )
        }
    }
}
