import SwiftUI

struct ProfileSelectionView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var navigateToHomePage: Bool
    @State private var showingQuestionnaire = false

    var body: some View {
        VStack {
            Text("Select a Profile")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(profileManager.profiles, id: \.id) { profile in
                    Button(action: {
                        profileManager.selectProfile(profile)
                        navigateToHomePage = true
                    }) {
                        Text(profile.name)
                            .foregroundColor(.primary)
                    }
                }
                .onDelete(perform: deleteProfile)
            }

            // Button to add a new profile
            Button(action: {
                showingQuestionnaire = true
            }) {
                Text("Add Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showingQuestionnaire) {
                QuestionnaireView(navigateToMusicPreferences: .constant(false))
                    .environmentObject(profileManager)
            }
        }
    }

    private func deleteProfile(at offsets: IndexSet) {
        offsets.forEach { index in
            let profile = profileManager.profiles[index]
            profileManager.deleteProfile(profile: profile)
        }
    }
}

struct ProfileSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSelectionView(navigateToHomePage: .constant(false))
            .environmentObject(ProfileManager()) // Provide a mock ProfileManager for preview
    }
}
