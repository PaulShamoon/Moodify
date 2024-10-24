import SwiftUI

struct AccountInfoView: View {
    @EnvironmentObject var profileManager: ProfileManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            
            Text("Account Information")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            if let profile = profileManager.currentProfile {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.green)
                                    .padding(12)
                            )
                        
                        Text(profile.name)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(
                            icon: "calendar",
                            title: "Age",
                            value: "\(calculateAge(from: profile.dateOfBirth)) years old"
                        )
                        
                        InfoRow(
                            icon: "music.note.list",
                            title: "Favorite Genres",
                            value: profile.favoriteGenres.isEmpty ?
                                "Not Set" :
                                profile.favoriteGenres.joined(separator: ", ")
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(white: 0.15))
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                NavigationLink(
                    destination: QuestionnaireView(
                        navigateToMusicPreferences: .constant(true),
                        isCreatingNewProfile: .constant(false)
                    ).environmentObject(profileManager)
                ) {
                    HStack {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                        Text("Edit Profile")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green.opacity(0.2))
                    )
                }
                .padding(.top, 10)
                
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.red.opacity(0.8))
                    
                    Text("No Profile Selected")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.red.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(white: 0.15))
                )
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year ?? 0
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}
