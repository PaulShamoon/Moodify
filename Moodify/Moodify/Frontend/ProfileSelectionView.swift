import SwiftUI

struct ProfileSelectionView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var navigateToHomePage: Bool
    @Binding var isCreatingNewProfile: Bool // Binding to track new profile creation
    @State private var showingQuestionnaire = false
    @Binding var navigateToMusicPreferences: Bool
    @State private var enteredPin: String = "" // State for the entered PIN
    @State private var showingPinPrompt = false // State to control the PIN input view
    @State private var selectedProfile: Profile? = nil // Store the profile being selected

    var body: some View {
        VStack {
            Text("Select a Profile")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(profileManager.profiles, id: \.id) { profile in
                    Button(action: {
                        // Check if the profile has a PIN
                        if let pin = profile.userPin, !pin.isEmpty {
                            selectedProfile = profile
                            showingPinPrompt = true
                        } else {
                            // Directly select the profile if no PIN is set
                            selectProfile(profile)
                        }
                    }) {
                        Text(profile.name)
                            .foregroundColor(.primary)
                    }
                }
            }

            // Button to add a new profile
            Button(action: {
                resetProfileCreationState()
                isCreatingNewProfile = true
                showingQuestionnaire = true
            }) {
                Text("Add Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .onChange(of: navigateToMusicPreferences) { value in
        handleMusicPreferenceNavigation(value)
        }
        // Display the custom PIN input view as a sheet when showingPinPrompt is true
        .sheet(isPresented: $showingPinPrompt) {
            PinInputView(
                profile: selectedProfile ?? Profile(name: "", dateOfBirth: Date(), favoriteGenres: [], hasAgreedToTerms: false),
                onPinEntered: { enteredPin in
                    if let profile = selectedProfile {
                        verifyPin(for: profile, enteredPin: enteredPin)
                    }
                }
            )
        }
    }

    private func resetProfileCreationState() {
        isCreatingNewProfile = true
        navigateToHomePage = false
        navigateToMusicPreferences = false
    }
    
    private func handleMusicPreferenceNavigation(_ isNavigating: Bool) {
        if isNavigating {
            navigateToHomePage = false
            showingQuestionnaire = false
        }
    }


    private func selectProfile(_ profile: Profile) {
        profileManager.selectProfile(profile)
        navigateToHomePage = true
    }

    private func verifyPin(for profile: Profile, enteredPin: String) {
        if enteredPin == profile.userPin {
            selectProfile(profile) // Select profile if the PIN matches
            showingPinPrompt = false
        } else {
            // Handle showing the error inside `PinInputView` itself.
            showingPinPrompt = true // This ensures the sheet stays open for another attempt.
        }
    }
}
