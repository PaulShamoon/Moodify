import SwiftUI

struct MenuView: View {
    @Binding var showMenu: Bool
    @EnvironmentObject var profileManager: ProfileManager // Use the existing profile manager
    @Binding var navigateToHomePage: Bool // navigation to home
    @Binding var isCreatingNewProfile: Bool
    @Binding var navigateToMusicPreferences: Bool


    var body: some View {
        ZStack {
            // Dim background with gradient when menu is shown
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

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
}
