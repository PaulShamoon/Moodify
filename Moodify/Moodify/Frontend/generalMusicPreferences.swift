import SwiftUICore
import SwiftUI

struct PreferenceInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct GeneralMusicPreferencesView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var selectedGenres: Set<String> = []
    @Binding var navigateToHomePage: Bool
    @State private var isPlaying = false
    @State private var isFirstTimeUser: Bool = true
    @State private var showAllGenres: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let genres = [
        "Pop", "Hip-Hop", "Rock", "Indie", "Electronic", "Jazz", "Dance", "R&B", "House", "Classical",
        "Reggae", "Soul", "Country", "Metal", "Techno", "Latin", "Punk", "Blues", "Ambient", "Acoustic",
        "Folk", "Alternative", "K-Pop", "Chill", "Lo-Fi", "EDM", "Disco", "Trance", "Ska", "Gospel",
        "Funk", "Garage", "Grunge", "Synth-Pop", "Opera", "Bluegrass", "Film Scores", "World Music",
        "Samba", "Tango"
    ]
    
    func genreIcon(for genre: String) -> String {
        switch genre {
        case "Pop": return "star.fill"
        case "Hip-Hop": return "headphones"
        case "Rock": return "guitars"
        case "Indie": return "music.microphone"
        case "Electronic": return "airplayaudio"
        case "Jazz": return "music.quarternote.3"
        case "Dance": return "music.note"
        case "R&B": return "music.mic"
        case "House": return "music.note.house"
        case "Classical": return "music.note.list"
        case "Reggae": return "music.quarternote.3"
        case "Soul": return "music.note.tv"
        case "Country": return "guitars.fill"
        case "Metal": return "guitar.fill"
        case "Techno": return "music.note.tv"
        case "Latin": return "music.mic"
        case "Punk": return "guitars.fill"
        case "Blues": return "music.quarternote.3"
        case "Ambient": return "cloud.fill"
        case "Acoustic": return "music.note"
        case "Folk": return "guitars.fill"
        case "Alternative": return "music.note.list"
        case "K-Pop": return "music.note.house"
        case "Chill": return "music.note"
        case "Lo-Fi": return "cloud.fill"
        case "EDM": return "airplayaudio"
        case "Disco": return "music.note"
        case "Trance": return "music.note.house"
        case "Ska": return "music.note"
        case "Gospel": return "music.mic"
        case "Funk": return "music.mic"
        case "Garage": return "guitars.fill"
        case "Grunge": return "music.note"
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
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("\(profileManager.currentProfile?.name ?? "User"), select your favorite genres")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                        ForEach(Array(genres.prefix(showAllGenres ? genres.count : 12)), id: \.self) { genre in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    toggleGenreSelection(genre: genre)
                                    if !isFirstTimeUser {
                                        savePreferences()
                                    }
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
                                            .foregroundColor(selectedGenres.contains(genre) ? .white : .gray)
                                        
                                        Text(genre)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        if selectedGenres.contains(genre) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
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
                    
                    if !showAllGenres && genres.count > 12 {
                        Button(action: {
                            withAnimation {
                                showAllGenres.toggle()
                            }
                        }) {
                            Text("Show more...")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.blue)
                                .padding(.vertical, 12)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        PreferenceInfoRow(
                            icon: "music.note.list",
                            title: "Selected Genres",
                            value: selectedGenres.isEmpty ? "No genres selected" : selectedGenres.joined(separator: ", "),
                            iconColor: .green
                        )
                        
                        PreferenceInfoRow(
                            icon: "number.circle.fill",
                            title: "Total Selected",
                            value: "\(selectedGenres.count) of \(genres.count) genres",
                            iconColor: .blue
                        )
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if isFirstTimeUser {
                        Button(action: {
                            savePreferences()
                            navigateToHomePage = true
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text(selectedGenres.isEmpty ? "Skip for now" : "Save preferences")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                
                                if !selectedGenres.isEmpty {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 20))
                                }
                            }
                            .foregroundColor(selectedGenres.isEmpty ? .gray : .black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                selectedGenres.isEmpty ?
                                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)]), startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: selectedGenres.isEmpty ? .clear : Color.green.opacity(0.3),
                                    radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            if !isFirstTimeUser {
                savePreferences()
            }
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text(isFirstTimeUser ? "Back" : "Save")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.blue)
        })
        .onAppear {
            checkIfFirstTimeUser()
            loadSelectedGenres()
        }
    }
    
    private func checkIfFirstTimeUser() {
        if let profile = profileManager.currentProfile {
            let status = profileManager.verifyCompletedMusicPreferences(profile: profile)
            isFirstTimeUser = !status
        }
    }
    
    private func loadSelectedGenres() {
        selectedGenres = Set(profileManager.currentProfile?.favoriteGenres ?? [])
    }
    
    private func savePreferences() {
        if let currentProfile = profileManager.currentProfile {
            profileManager.updateProfile(
                profile: currentProfile,
                name: currentProfile.name,
                dateOfBirth: currentProfile.dateOfBirth,
                favoriteGenres: Array(selectedGenres),
                hasAgreedToTerms: currentProfile.hasAgreedToTerms,
                completedMusicPreferences: true,
                userPin: currentProfile.userPin,
                personalSecurityQuestion: currentProfile.personalSecurityQuestion,
                securityQuestionAnswer: currentProfile.personalSecurityQuestion
            )
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
    let profileManager = ProfileManager()
    static var previews: some View {
        GeneralMusicPreferencesView(navigateToHomePage: .constant(false))
            .environmentObject(ProfileManager())
    }
}
