import SwiftUI

struct ProfileSelectionView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var navigateToHomePage: Bool
    @State private var showingQuestionnaire = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                Text("Select a Profile")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                List {
                    ForEach(profileManager.profiles, id: \.id) { profile in
                        Button(action: {
                            profileManager.selectProfile(profile)
                            // Ensure the profile is selected and navigate to the home page
                            print("Selected profile: \(profile.name)") // Debugging to ensure correct profile
                            navigateToHomePage = true // Navigate to home after selecting
                        }) {
                            Text(profile.name)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .onDelete(perform: deleteProfile)
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color.clear)
                .onAppear {
                    profileManager.loadProfiles() // Reload profiles on view load
                }

                Spacer()

                // Add Profile Button
                Button(action: {
                    profileManager.startNewProfile() // Start a new profile creation
                    showingQuestionnaire = true
                }) {
                    Text("Add Profile")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showingQuestionnaire) {
                    QuestionnaireView(navigateToMusicPreferences: .constant(false))
                        .environmentObject(profileManager)
                        .onDisappear {
                            profileManager.loadProfiles() // Reload profiles after dismissing the sheet
                        }
                }
            }
            .padding()
        }
    }

    private func deleteProfile(at offsets: IndexSet) {
        offsets.forEach { index in
            let profile = profileManager.profiles[index]
            profileManager.deleteProfile(profile)
        }
    }
}

struct ProfileSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSelectionView(navigateToHomePage: .constant(false))
            .environmentObject(ProfileManager()) // Provide a mock ProfileManager for preview
    }
}
