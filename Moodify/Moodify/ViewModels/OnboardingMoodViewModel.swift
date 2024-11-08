/*
 This is the onboarding mood view model for the Moodify app.
 With this view model, we can control the mood cards and the get started card.
 Created by: Nazanin Mahmoudi
 */

import SwiftUI

class OnboardingMoodViewModel: ObservableObject {
    @Published var currentIndex = 0
    @Published var dragOffset: CGSize = .zero
    @Published var showGetStarted = false
    
    let moods: [MoodOnboarding] = [
        MoodOnboarding(
            mood: Mood(
                name: "Happy",
                colors: [Color.yellow, Color.orange],
                darkColors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.7)],
                icon: "sun.max.fill"
            ),
            message: "Discover music that lifts your spirits and keeps you energized."
        ),
        MoodOnboarding(
            mood: Mood(
                name: "Anxious",
                colors: [Color.blue.opacity(0.8), Color.cyan],
                darkColors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7)],
                icon: "exclamationmark.triangle.fill"
            ),
            message: "Find calming music to ease your mind and help you relax."
        ),
        MoodOnboarding(
            mood: Mood(
                name: "Angry",
                colors: [Color.red, Color.orange],
                darkColors: [Color.red.opacity(0.9), Color.orange.opacity(0.7)],
                icon: "flame.fill"
            ),
            message: "Channel your anger with powerful and intense music."
        ),
        MoodOnboarding(
            mood: Mood(
                name: "Sad",
                colors: [Color.purple, Color.indigo],
                darkColors: [Color.purple.opacity(0.9), Color.indigo.opacity(0.7)],
                icon: "cloud.drizzle.fill"
            ),
            message: "When you're feeling low, find comforting music to lift you up."
        )
    ]
    
    func nextMood() {
        if currentIndex < moods.count - 1 {
            currentIndex += 1
            dragOffset = .zero
        } else {
            showGetStarted = true
        }
    }
    
    func previousMood() {
        if currentIndex > 0 {
            currentIndex -= 1
            dragOffset = .zero
        }
    }
    
    func handleDragEnd(gesture: DragGesture.Value) {
        if gesture.translation.width < -100 {
            nextMood()
        } else if gesture.translation.width > 100 {
            previousMood()
        } else {
            dragOffset = .zero
        }
    }
}
