//
//  ManualMoodSelectorView.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 11/17/24.
//

import SwiftUI

struct ManualMoodSelector: View {
    @Binding var isPresented: Bool
    let spotifyController: SpotifyController
    let profile: Profile
    @Binding var currentMood: String
    @Binding var currentMoodText: String
    let updateBackgroundColors: (String) -> Void
    
    private let moods: [(name: String, emoji: String, color: Color, icon: String)] = [
        ("Happy", "😄", .yellow, "sun.max.fill"),
        ("Sad", "😢", .blue, "cloud.rain"),
        ("Angry", "😡", .red, "flame.fill"),
        ("Chill", "😌", .mint, "leaf.fill")
    ]
    
    @State private var selectedMood: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    Text("How are you feeling?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Display mood options
                    ForEach(0..<moods.count, id: \.self) { index in
                        MoodCard(
                            mood: moods[index],
                            isSelected: selectedMood == moods[index].name,
                            action: { selectedMood = moods[index].name; updateMood(mood: moods[index].name.lowercased()) }
                        )
                    }
                }
                .padding(.vertical)
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
    
    private func updateMood(mood: String) {
        currentMood = moods.first(where: { $0.name.lowercased() == mood.lowercased() })?.emoji ?? "😶"
        currentMoodText = "You're feeling \(mood.capitalized)"
        updateBackgroundColors(mood)
        isPresented = false
    }
}

struct MoodCard: View {
    let mood: (name: String, emoji: String, color: Color, icon: String)
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(mood.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.system(size: 30))
                        
                        Image(systemName: mood.icon)
                            .font(.system(size: 12))
                            .foregroundColor(mood.color)
                            .opacity(0.8)
                    }
                }
                
                Text(mood.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: isSelected ? mood.color.opacity(0.3) : Color.black.opacity(0.1),
                            radius: isSelected ? 10 : 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// Preview for ManualMoodSelector
struct ManualMoodSelector_Previews: PreviewProvider {
    static var previews: some View {
        ManualMoodSelector(
            isPresented: .constant(true),
            spotifyController: SpotifyController(),
            profile: Profile(name: "Test User", dateOfBirth: Date(), favoriteGenres: ["Pop", "Rock"], hasAgreedToTerms: true),
            currentMood: .constant("😌"),
            currentMoodText: .constant("Chill"),
            updateBackgroundColors: { _ in }
        )
    }
}
