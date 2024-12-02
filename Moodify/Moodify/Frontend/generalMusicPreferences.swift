import SwiftUI

struct GeneralMusicPreferencesView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var selectedGenres: Set<String> = []
    @Binding var navigateToHomePage: Bool
    @Binding var navigateToProfilePicture: Bool
    @Binding var navigateToMusicPreferences: Bool
    @State private var isPlaying = false
    @State private var isFirstTimeUser: Bool = true
    @State private var showError: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let genres = [
        "Pop", "Hip-Hop", "Rock", "Electronic", "R&B", "Classical", "Jazz", "Dance", "K-Pop",
        "Country", "Soul", "EDM", "Latin", "Reggae", "Lo-Fi", "Blues", "Funk", "Ambient",
        "Techno", "Indie", "Disco", "Synth-Pop", "Garage", "Punk", "Acoustic", "Folk",
        "World Music", "Film Scores", "Metal", "Opera", "Tango", "Bluegrass", "Samba"
    ]
    
    var sortedGenres: [String] {
        let selected = genres.filter { selectedGenres.contains($0) }
        let unselected = genres.filter { !selectedGenres.contains($0) }
        return selected + unselected
    }
    
    var genrePages: [[String]] {
        sortedGenres.chunked(into: 12)
    }
    
    @State private var currentPage = 0

    func genreIcon(for genre: String) -> String {
        switch genre {
        case "Pop": return "star.fill"
        case "Hip-Hop": return "headphones"
        case "Rock": return "guitars"
        case "Indie": return "music.microphone"
        case "Electronic": return "bolt"
        case "Jazz": return "music.quarternote.3"
        case "Dance": return "music.note"
        case "R&B": return "music.mic"
        case "Classical": return "music.note.list"
        case "Reggae": return "music.quarternote.3"
        case "Soul": return "music.note.tv"
        case "Country": return "guitars.fill"
        case "Metal": return "guitars.fill"
        case "Techno": return "music.note.tv"
        case "Latin": return "music.mic"
        case "Punk": return "guitars.fill"
        case "Blues": return "music.quarternote.3"
        case "Ambient": return "cloud.fill"
        case "Acoustic": return "music.note"
        case "Folk": return "guitars.fill"
        case "K-Pop": return "music.note.house"
        case "Lo-Fi": return "cloud.fill"
        case "EDM": return "bolt"
        case "Disco": return "music.note"
        case "Funk": return "music.mic"
        case "Garage": return "guitars.fill"
        case "Synth-Pop": return "music.note"
        case "Opera": return "music.note"
        case "Bluegrass": return "guitars.fill"
        case "Film Scores": return "film.fill"
        case "World Music": return "globe"
        case "Samba": return "music.note"
        case "Tango": return "music.note"
        default: return "music.note"
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color(white: 0.1)]),
                           startPoint: .top,
                           endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 32) {
                // Title Section
                VStack(spacing: 8) {
                    Text("\(profileManager.currentProfile?.name ?? "User"),")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    Text("Select your favorite genres")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "94A3B8"))
                        .multilineTextAlignment(.center)
                    
                    Text("The more genres you choose, the better your recommendations.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.green.opacity(0.9), Color.green.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                }
                .padding(.horizontal)
                
                // Genre Pages
                TabView(selection: $currentPage) {
                    ForEach(genrePages.indices, id: \.self) { index in
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                            ForEach(genrePages[index], id: \.self) { genre in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        toggleGenreSelection(genre: genre)
                                        showError = false
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedGenres.contains(genre) ?
                                                  LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                                                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .shadow(color: selectedGenres.contains(genre) ? Color.green.opacity(0.3) : Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                                        
                                        VStack(spacing: 8) {
                                            Image(systemName: genreIcon(for: genre))
                                                .font(.system(size: 22))
                                                .foregroundColor(selectedGenres.contains(genre) ? .black : .gray)
                                            
                                            Text(genre)
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundColor(selectedGenres.contains(genre) ? .black : .white)
                                            
                                            if selectedGenres.contains(genre) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 16))
                                            }
                                        }
                                        .padding(.vertical, 6)
                                    }
                                    .frame(height: 100)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 510)
                
                // Error Message
                if showError {
                    Text("Please select at least one genre to proceed.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
                
                // Submit Button
                Button(action: {
                    if selectedGenres.isEmpty {
                        showError = true
                    } else if let currentProfile = profileManager.currentProfile {
                        profileManager.updateProfile(
                            profile: currentProfile,
                            name: currentProfile.name,
                            dateOfBirth: currentProfile.dateOfBirth,
                            favoriteGenres: Array(selectedGenres),
                            hasAgreedToTerms: currentProfile.hasAgreedToTerms,
                            userPin: currentProfile.userPin,
                            personalSecurityQuestion: currentProfile.personalSecurityQuestion,
                            securityQuestionAnswer: currentProfile.personalSecurityQuestion
                        )
                        navigateToMusicPreferences = false
                        navigateToProfilePicture = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Text("Save preferences")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Group {
                            if selectedGenres.isEmpty {
                                Color.gray.opacity(0.5)
                            } else {
                                LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                            }
                        }
                    )
                    .cornerRadius(16)
                    .shadow(color: selectedGenres.isEmpty ? .clear : Color.green.opacity(0.3),
                            radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            loadSelectedGenres()
        }
    }
    
    private func loadSelectedGenres() {
        selectedGenres = Set(profileManager.currentProfile?.favoriteGenres ?? [])
    }
    
    private func toggleGenreSelection(genre: String) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

struct GeneralMusicPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralMusicPreferencesView(navigateToHomePage: .constant(false), navigateToProfilePicture: .constant(false), navigateToMusicPreferences: .constant(true))
            .environmentObject(ProfileManager())
    }
}
