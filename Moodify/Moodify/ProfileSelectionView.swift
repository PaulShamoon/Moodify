import SwiftUI

struct ProfileSelectionView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var navigateToHomePage: Bool
    @Binding var isCreatingNewProfile: Bool // Binding to track new profile creation
    @State private var showingQuestionnaire = false
    @Binding var navigateToMusicPreferences: Bool

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
                resetProfileCreationState()
                showingQuestionnaire = true  // Open questionnaire for adding a new profile
            }) {
                Text("Add Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showingQuestionnaire) {
                QuestionnaireView(navigateToMusicPreferences: $navigateToMusicPreferences)
                    .environmentObject(profileManager)
            }
        }
        .onChange(of: navigateToMusicPreferences) { value in
            if value {
                // Navigate to music preferences after completing the questionnaire
                navigateToHomePage = false
                showingQuestionnaire = false
            }
        }
    }

    private func deleteProfile(at offsets: IndexSet) {
        offsets.forEach { index in
            let profile = profileManager.profiles[index]
            profileManager.deleteProfile(profile: profile)
        }
    }

    private func resetProfileCreationState() {
        isCreatingNewProfile = true
        navigateToHomePage = false
        navigateToMusicPreferences = false
    }
}
