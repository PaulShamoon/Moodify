/**************************
 Filename: generalMusicPreferences.swift
 Author: Mohammad Sulaiman
 Date: September 13, 2024
 Purpose: Questionnaire for the application's initial setup.
 
 Update September 16, 2024: Removed the toggles from the genres, instead used checkmarks
 *******************************************/

import SwiftUI

struct GeneralMusicPreferencesView: View {
    @State private var selectedGenres: Set<String> = []
    @State private var isPlaying = false
    @State private var navigateToHomePage: Bool = false
    @State private var firstname: String = "" // Holds the user's first name
    @State private var navigateToNextPage: Bool = false // State to control navigation
    
    let genres = ["Pop", "Classical", "Regional", "Hip Hop", "Country", "Dance"]
    
    var body: some View {
        ZStack {
            // Spotify-inspired dark mode background with gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Title
                Text("What are your favorite genres?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Grid of genre cards with Spotify-like style
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 20)], spacing: 20) {
                    ForEach(genres, id: \.self) { genre in
                        Button(action: {
                            withAnimation {
                                toggleGenreSelection(genre: genre)
                            }
                        }) {
                            ZStack {
                                // Card background
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedGenres.contains(genre) ? Color.green.opacity(0.8) : Color.gray.opacity(0.2))
                                    .shadow(radius: 5)
                                
                                VStack {
                                    // Genre text
                                    Text(genre)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    // Checkmark for selected genres
                                    if selectedGenres.contains(genre) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 24))
                                            .padding(.top, 10)
                                    }
                                }
                            }
                            .frame(height: 120)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Display the selected genres
                if !selectedGenres.isEmpty {
                    Text("Selected Genres: \(selectedGenres.joined(separator: ", "))")
                        .font(.system(size: 16, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 20)
                }
                
                // Next/Skip button styled to match Spotify's premium look
                Button(action: {
                    if selectedGenres.isEmpty {
                        print("Skipped genre selection")
                        navigateToHomePage = true  // Navigate even if no genre is selected
                    } else {
                        submitGenres()
                        navigateToHomePage = true  // Navigate after genres are selected
                    }
                }) {
                    Text(selectedGenres.isEmpty ? "Skip" : "Next")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .opacity(selectedGenres.isEmpty ? 0.7 : 1.0)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                Spacer()
                
                // Bottom music player bar to fill empty space
                BottomMusicPlayer(isPlaying: $isPlaying)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
            .padding()
            .navigationDestination(isPresented: $navigateToHomePage) {
                homePageView() // Navigates to homePageView after submitting genres
            }
        }
    }

        private func loadFirstName() {
        firstname = UserDefaults.standard.string(forKey: "firstname") ?? "User"
        print("Loaded First Name: \(firstname)")
    }
    
    private func toggleGenreSelection(genre: String) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
    }
    
    // Submit the selected genres
    func submitGenres() {
        print("Selected Genres: \(selectedGenres.joined(separator: ", "))")
        // Backend logic here
    }
}

struct BottomMusicPlayer: View {
    @Binding var isPlaying: Bool
    var songTitle = "Let's get Moody"
    var artistName = "Moodify"
    
    var body: some View {
        ZStack {
            // Background of the music player bar
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .shadow(radius: 10)
            
            HStack {
                // Album art placeholder
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .padding(10)
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                VStack(alignment: .leading) {
                    // Song title and artist
                    Text(songTitle)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(artistName)
                        .font(.system(size: 14, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                
               
                Button(action: {
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 28))
                }
                .padding(.horizontal, 10)
            }
            .padding(.horizontal)
        }
        .frame(height: 80)
        // Backend logic here
        UserDefaults.standard.set(Array(selectedGenres), forKey: "selectedGenres")

    }
}

struct GeneralMusicPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralMusicPreferencesView()
    }
}
