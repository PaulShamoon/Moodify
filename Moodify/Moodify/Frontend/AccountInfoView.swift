import SwiftUI

struct AccountInfoView: View {
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account Information")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 20)

            if let profile = profileManager.currentProfile {
                Text("Name: \(profile.name)")
                    .font(.title2)
                    .foregroundColor(.white)

                Text("Age: \(calculateAge(from: profile.dateOfBirth))")
                    .font(.title2)
                    .foregroundColor(.white)

                if !profile.favoriteGenres.isEmpty {
                    Text("Favorite Genres: \(profile.favoriteGenres.joined(separator: ", "))")
                        .font(.title2)
                        .foregroundColor(.white)
                } else {
                    Text("Favorite Genres: Not Set")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 20) {
                    NavigationLink(destination: QuestionnaireView(navigateToMusicPreferences: .constant(true)).environmentObject(profileManager)) {
                        Text("Edit User Information")
                            .font(.title2.italic())
                            .foregroundColor(.green)
                            .padding(.leading, 50)
                    }
                }
            } else {
                Text("No Profile Selected")
                    .foregroundColor(.red)
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
