import SwiftUI

struct GeneralMusicPreferencesView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var selectedGenres: Set<String> = []
    @Binding var navigateToHomePage: Bool
    @State private var isPlaying = false
    
    @Environment(\.presentationMode) var presentationMode

    let genres = ["Pop", "Classical", "Regional", "Hip Hop", "Country", "Dance"]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("\(profileManager.tempName), what are your favorite genres?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 20)], spacing: 20) {
                    ForEach(genres, id: \.self) { genre in
                        Button(action: {
                            toggleGenreSelection(genre: genre)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedGenres.contains(genre) ? Color.green.opacity(0.8) : Color.gray.opacity(0.2))
                                    .shadow(radius: 5)
                                
                                VStack {
                                    Text(genre)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    
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

                if !selectedGenres.isEmpty {
                    Text("Selected Genres: \(selectedGenres.joined(separator: ", "))")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }

                Button(action: {
                    if !selectedGenres.isEmpty {
                        profileManager.tempSelectedGenres = Array(selectedGenres) // Save selected genres to profile
                        profileManager.saveProfile() // Save the profile after genre selection
                    }
                    navigateToHomePage = true
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Submit")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                Spacer()
            }
            .padding()
            .onAppear {
                loadSelectedGenres()
            }
        }
    }

    private func loadSelectedGenres() {
        if let profileGenres = profileManager.currentProfile?.favoriteGenres {
            selectedGenres = Set(profileGenres)
        }
    }

    private func toggleGenreSelection(genre: String) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
    }
}

struct GeneralMusicPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralMusicPreferencesView(navigateToHomePage: .constant(false))
            .environmentObject(ProfileManager()) // Provide mock ProfileManager for preview
    }
}
