//
//  generalMusicPreferences.swift
//  Moodify
//
//  Created by Mahdi Sulaiman on 9/13/24.
//

import Foundation
import SwiftUI

struct GeneralMusicPreferencesView: View {
    @State private var selectedGenres: Set<String> = [] // allows storing of multiple generes
    
    let genres = ["Pop", "Classical", "Regional", "Hip Hop", "Country", "Dance"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Thank you for completing the questionnaire!")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Text("What are some genres you are interested in?")
                    .font(.headline)
                    .padding(.bottom, 20)
                
                // Loops through the genres and displays a toggle for every genre
                ForEach(genres, id: \.self) { genre in
                    Toggle(isOn: Binding(
                        get: { selectedGenres.contains(genre) },
                        set: { isSelected in
                            if isSelected {
                                selectedGenres.insert(genre) // Adds genre to selected set
                            } else {
                                selectedGenres.remove(genre) // Removes genres from selected sets
                            }
                        }
                    )) {
                        Text(genre)
                    }
                }
                
                Spacer()
                
                // Displays the user's selected genres
                Text("Selected Genres: \(selectedGenres.joined(separator: ", "))")
                    .font(.subheadline)
                    .padding(.top, 20)
            }
            .padding()
            .navigationTitle("Music Preferences")
        }
    }
}

struct GeneralMusicPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralMusicPreferencesView()
    }
}
