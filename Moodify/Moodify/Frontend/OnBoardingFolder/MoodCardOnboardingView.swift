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
            // Card Background
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(
                    gradient: Gradient(colors: moodOnboarding.mood.colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 300, height: 400)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 24) {
                Image(systemName: moodOnboarding.mood.icon)
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(darkerShade(of: moodOnboarding.mood.colors))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Text(moodOnboarding.mood.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "#F5E6D3"))
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                
                Text(moodOnboarding.message)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#F5E6D3"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: 240)
                    .minimumScaleFactor(0.8)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .frame(width: 280)
        }
    }
    
    private func darkerShade(of colors: [Color]) -> Color {
        let uiColors = colors.map { UIColor($0) }
        let averageColor = uiColors.reduce(UIColor.black) { (result, color) -> UIColor in
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            result.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
            return UIColor(red: (r1 + r2) / 2, green: (g1 + g2) / 2, blue: (b1 + b2) / 2, alpha: (a1 + a2) / 2)
        }
        return Color(averageColor).opacity(0.7)
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
