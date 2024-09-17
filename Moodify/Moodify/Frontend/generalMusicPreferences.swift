/**************************
Filename: generalMusicPreferences.swift
Author: Mohammad Sulaiman
Date: September 13, 2024
Purpose: Questionnaire for the application's initial setup.

Update September 16, 2024: Removed the toggles from the genres, instead used checkmarks
*******************************************/
import Foundation
import SwiftUI

struct GeneralMusicPreferencesView: View {
    @State private var selectedGenres: Set<String> = [] // Allows storing multiple genres
    
    let genres = ["Pop", "Classical", "Regional", "Hip Hop", "Country", "Dance"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Thank you for completing the questionnaire!")
                    .font(.headline)
                    .padding(.vertical)
                
                Text("What are some genres you are interested in?")
                    .font(.headline)
                    .padding(.bottom, 20)
                
                // Loops through the genres and displays a button with checkmarks
                ForEach(genres, id: \.self) { genre in
                    Button(action: {
                        toggleGenreSelection(genre: genre)
                    }) {
                        HStack {
                            Text(genre)
                                .foregroundStyle(.primary)
                            
                            
                            // Displays a checkmark if the genre is selected
                            if selectedGenres.contains(genre) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Display the user's selected genres
                Text("Selected Genres: \(selectedGenres.joined(separator: ", "))")
                    .font(.subheadline)
                    .padding(.top, 20)
                
                // Conditional button for Skip or Next
                Button(action: {
                    if selectedGenres.isEmpty {
                        print("Skipped genre selection")
                    } else {
                        submitGenres()
                    }
                }) {
                    Text(selectedGenres.isEmpty ? "Skip" : "Next")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedGenres.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Music Preferences")
        }
    }
    
    // Toggle genre selection
    private func toggleGenreSelection(genre: String) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre) // Removes the genre if it's already selected
        } else {
            selectedGenres.insert(genre) // Adds a genre to selection if it's not selected
        }
    }
    
    // Submits the selected genres
    func submitGenres() {
        print("Selected Genres: \(selectedGenres.joined(separator: ", "))")
        //Backend logic here
    }
}

struct GeneralMusicPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralMusicPreferencesView()
    }
}
