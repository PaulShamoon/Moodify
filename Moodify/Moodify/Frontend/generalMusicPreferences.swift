// Add text to inform user to select in order of preference
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
    
    @Environment(\.presentationMode) var presentationMode
    
    let genres = ["Pop", "Rock", "Hip-Hop", "Indie", "Classical", "Jazz", "Electronic", "House", "Dance", "Metal", "Country", "R&B", "Reggae", "Blues", "Latin", "Soul", "Punk", "Techno", "K-Pop", "Lo-Fi", "Chill", "Acoustic"]
    
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
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                        ForEach(genres, id: \.self) { genre in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    toggleGenreSelection(genre: genre)
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedGenres.contains(genre) ?
                                              LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                                                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .shadow(color: selectedGenres.contains(genre) ? Color.green.opacity(0.3) : Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    
                                    VStack(spacing: 12) {
                                        Image(systemName: genreIcon(for: genre))
                                            .font(.system(size: 30))
                                            .foregroundColor(selectedGenres.contains(genre) ? .white : .gray)
                                        
                                        Text(genre)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        if selectedGenres.contains(genre) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 20))
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .frame(height: 130)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
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
                    
                    // Submit Button
                    Button(action: {
                        if let currentProfile = profileManager.currentProfile {
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
                        }
                        
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
    
    private func genreIcon(for genre: String) -> String {
        switch genre {
        case "Pop":
            return "star.fill"
        case "Classical":
            return "music.note.list"
        case "Hip-Hop":
            return "beats.headphones"
        case "Country":
            return "guitars.fill"
        case "Dance":
            return "music.note"
        default:
            return "music.note"
        }
    }
}

struct GeneralMusicPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralMusicPreferencesView(navigateToHomePage: .constant(false))
            .environmentObject(ProfileManager())
    }
}
