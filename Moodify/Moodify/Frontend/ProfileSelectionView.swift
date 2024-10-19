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

// Custom PIN Input View
struct PinInputView: View {
    let profile: Profile
    @State private var enteredPin: String = ""
    @State private var showError: Bool = false // State for error display
    var onPinEntered: (String) -> Void

    var body: some View {
        VStack {
            Text("Enter PIN for \(profile.name)")
                .font(.headline)
                .padding()

            SecureField("Enter PIN", text: $enteredPin)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .frame(width: 200)

            if showError {
                Text("Incorrect PIN. Please try again.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }

            Button(action: {
                if enteredPin.count == 4 {
                    onPinEntered(enteredPin)
                } else {
                    showError = true
                }
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

