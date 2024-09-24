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
    @State private var firstname: String = "" // Holds the user's first name
    @State private var navigateToNextPage: Bool = false // State to control navigation
    
    let genres = ["Pop", "Classical", "Regional", "Hip Hop", "Country", "Dance"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title (Display first name)
                    Text("Hello, \(firstname)!")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("Thank you for completing the questionnaire!")
                        .font(.system(size: 16, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Text("What are some genres you are interested in?")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    // Genre selection with checkmarks
                    ForEach(genres, id: \.self) { genre in
                        Button(action: {
                            toggleGenreSelection(genre: genre)
                        }) {
                            HStack {
                                Text(genre)
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                
                                Spacer()
                                
                                // Displays a checkmark if the genre is selected
                                if selectedGenres.contains(genre) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.2))
                                }
                            }
                            .padding()
                            .background(Color(red: 0.96, green: 0.87, blue: 0.70))
                            .cornerRadius(10)
                        }
                    }
                    
                    // Display selected genres
                    Text("Selected Genres: \(selectedGenres.joined(separator: ", "))")
                        .font(.system(size: 16, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 20)
                    
                    // Conditional button for Skip or Next
                    Button(action: {
                        if selectedGenres.isEmpty {
                            print("Skipped genre selection")
                        } else {
                            submitGenres()
                        }
                        navigateToNextPage = true
                    }) {
                        Text(selectedGenres.isEmpty ? "Skip" : "Next")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedGenres.isEmpty ? Color.gray : Color(red: 0.0, green: 0.5, blue: 0.2))
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
                .onAppear(perform: loadFirstName) // Load first name when the view appears
                .navigationDestination(isPresented: $navigateToNextPage) {
                    homePageView() // Navigate to homePageView after selection
                }
            }
        }
    }
    
    // Load the user's first name from UserDefaults
    private func loadFirstName() {
        firstname = UserDefaults.standard.string(forKey: "firstname") ?? "User"
        print("Loaded First Name: \(firstname)")
    }
    
    // Toggle genre selection
    private func toggleGenreSelection(genre: String) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre) // Removes the genre if it's already selected
        } else {
            selectedGenres.insert(genre) // Adds a genre to selection if it's not selected
        }
    }
    
    // Submit the selected genres
    func submitGenres() {
        print("Selected Genres: \(selectedGenres.joined(separator: ", "))")
        // Backend logic here
        UserDefaults.standard.set(Array(selectedGenres), forKey: "selectedGenres")

    }
}

struct GeneralMusicPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralMusicPreferencesView()
    }
}
