/*
 This is the onboarding mood view model for the Moodify app.
 With this view model, we can control the mood cards and the get started card.
 Created by: Nazanin Mahmoudi
 */

import SwiftUI

class OnboardingMoodViewModel: ObservableObject {
    @Published var currentIndex = 0
    @Published var dragOffset = CGSize.zero
    @Published var showGetStarted = false
    
    let moods = [
        MoodOnboarding(
            mood: Mood(
                name: "Happy",
                colors: [.yellow, .orange],
                darkColors: [.yellow.opacity(0.6), .orange.opacity(0.6)],
                icon: "sun.max.fill"
            ),
            message: "Discover music that\nbrings joy and keeps\nyou energized"
        ),
        MoodOnboarding(
            mood: Mood(
                name: "Sad",
                colors: [.blue, .purple],
                darkColors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                icon: "cloud.rain.fill"
            ),
            message: "Find melodies that\ncomfort and help you\nfeel understood"
        ),
        MoodOnboarding(
            mood: Mood(
                name: "Angry",
                colors: [.red, .orange],
                darkColors: [.red.opacity(0.6), .orange.opacity(0.6)],
                icon: "flame.fill"
            ),
            message: "Release tension with\npowerful tracks that\nmatch your energy"
        ),
        MoodOnboarding(
            mood: Mood(
                name: "Chill",
                colors: [.mint, .blue],
                darkColors: [.mint.opacity(0.6), .blue.opacity(0.6)],
                icon: "leaf.fill"
            ),
            message: "Find peaceful tunes\nthat help you relax\nand unwind"
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
    
    func handleDragEnd(gesture: DragGestureType, maxIndex: Int) {
        let dragThreshold: CGFloat = 50
        
        if gesture.translation.width < -dragThreshold && currentIndex < maxIndex {
            currentIndex += 1
        } else if gesture.translation.width > dragThreshold && currentIndex > 0 {
            currentIndex -= 1
        }
        
        dragOffset = .zero
    }
}

protocol DragGestureType {
    var translation: CGSize { get }
}

extension DragGesture.Value: DragGestureType {}

