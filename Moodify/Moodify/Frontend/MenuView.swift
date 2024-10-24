import SwiftUI

struct MenuView: View {
    @Binding var showMenu: Bool
    @EnvironmentObject var profileManager: ProfileManager // Use the existing profile manager
    @Binding var navigateToHomePage: Bool // navigation to home
    @Binding var isCreatingNewProfile: Bool
    @Binding var navigateToMusicPreferences: Bool
    @State private var showingDeleteAlert = false
    @State private var showingPinSetup = false // State to control showing the PIN setup view


    var body: some View {
        ZStack {
            // Dim background with gradient when menu is shown
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .opacity(showMenu ? 1 : 0) // Show only when menu is visible
                .disabled(!showMenu) // Disable interaction when menu is hidden

            HStack {
                Spacer() // Pushes the menu to the right side

                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            withAnimation {
                                showMenu = false // Close menu on button click
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        .padding(.leading, 20)
                        Spacer()
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 20) {
                        // Account Information Link
                        NavigationLink(destination: AccountInfoView().environmentObject(profileManager)) { // Use the shared ProfileManager
                            Text("Account Information")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                                .padding(.top, 100)
                        }

                        // Music Preferences Link
                        NavigationLink(destination: GeneralMusicPreferencesView(navigateToHomePage: .constant(false)).environmentObject(profileManager)) { // Use the shared ProfileManager
                            Text("Music Preferences")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                        }

                        // Switch User Button
                        Button(action: {
                            switchUser() // Call the switch user function
                            showMenu = false
                        }) {
                            Text("Switch User")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                        }

                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Text("Delete Profile")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                        }
                        .alert(isPresented: $showingDeleteAlert) {
                            Alert(
                                title: Text("Delete Profile"),
                                message: Text("Are you sure you want to delete the current profile?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    deleteProfile()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
                        Button(action: {
                            showingPinSetup = true // Show the PIN setup view
                        }) {
                            Text("Set/Change PIN")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                        }
                        .sheet(isPresented: $showingPinSetup) {
                            if let currentProfile = profileManager.currentProfile {
                                PinSetupView(profile: currentProfile)
                                    .environmentObject(profileManager)
                            }
                        }

                        Spacer()
                    }
                    .padding(.top, 40)
                }
                .frame(width: 250)
                .background(Color.black.opacity(0.8))
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .navigationBarHidden(true)
    }

    private func switchUser() {
        // Reset the app states to ensure proper navigation
        profileManager.currentProfile = nil
        isCreatingNewProfile = false
        navigateToHomePage = false
        navigateToMusicPreferences = false
    }

    private func deleteProfile() {
        if let currentProfile = profileManager.currentProfile {
            profileManager.deleteProfile(profile: currentProfile)
            profileManager.currentProfile = nil
            isCreatingNewProfile = false
            navigateToHomePage = false
            navigateToMusicPreferences = false
        }
    }
}
