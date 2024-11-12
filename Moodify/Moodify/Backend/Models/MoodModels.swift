/*
    This file contains the models for the moods in the Moodify app.
    Created by: Nazanin Mahmoudi
*/

import SwiftUI

struct MoodOnboarding: Identifiable {
    let id = UUID()
    let mood: Mood
    let message: String
}

struct Mood: Identifiable {
    let id = UUID()
    let name: String
    let colors: [Color]
    let darkColors: [Color]
    let icon: String
}
