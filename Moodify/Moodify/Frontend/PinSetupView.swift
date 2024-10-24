import SwiftUI

struct PinSetupView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var currentPin: String = ""
    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var securityQuestion: String = ""
    @State private var securityQuestionAnswer: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var showingTooltip = false
    @State private var showingTooltip1 = false
    @State private var showingTooltip2 = false

    var profile: Profile?

    var body: some View {
        VStack {
            Text(profile?.userPin == nil ? "Set Your PIN" : "Change PIN")
                .font(.largeTitle)
                .padding()
            
            if profile?.userPin != nil {
                HStack {
                    // If the user already has a PIN, ask for the current PIN for verification
                    Text("Enter Current PIN:")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Button(action: {
                        showingTooltip1.toggle()
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.green)
                    }
                    if showingTooltip1 {
                        Text("We need your current pin to verify your identity.")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity)
                    }
                }
                SecureField("Enter Current PIN", text: $currentPin)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(width: 200)
            }

            HStack {
                Text("Enter New PIN:")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Button(action: {
                    showingTooltip2.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.green)
                }
                if showingTooltip2 {
                    Text("You can set a PIN to secure your profile from other users.")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                        .frame(maxWidth: .infinity)
                }
            }

            SecureField("Enter New 4-digit PIN", text: $pin)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .frame(width: 200)

            SecureField("Confirm New PIN", text: $confirmPin)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .frame(width: 200)

            // Show security question input only when setting a new PIN
            if profile?.userPin == nil {
                HStack {
                    Text("Set Security Question:")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Button(action: {
                        showingTooltip.toggle()
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.green)
                    }
                    if showingTooltip {
                        Text("Set a security question to recover your PIN if forgotten.")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                TextField("Enter Security Question", text: $securityQuestion)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                SecureField("Answer", text: $securityQuestionAnswer)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: savePin) {
                Text("Save")
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
        .onAppear {
            if let existingSecurityQuestion = profile?.personalSecurityQuestion {
                securityQuestion = existingSecurityQuestion
            }
        }
    }

    private func savePin() {
        if let existingPin = profile?.userPin {
            // If the user already has a PIN, verify the current PIN before allowing changes
            guard currentPin == existingPin else {
                errorMessage = "Current PIN is incorrect."
                showError = true
                print("Current PIN entered is incorrect.")
                return
            }
            print("Current PIN is correct.")
        }

        // Validate the new PIN
        guard pin.count == 4 else {
            errorMessage = "PINs must be 4 digits."
            showError = true
            print("New PIN is not 4 digits.")
            return
        }
        
        guard pin == confirmPin else {
            errorMessage = "The Confirm PIN must match your New PIN."
            showError = true
            print("New PIN and Confirm PIN do not match.")
            return
        }

        // Ensure security question and answer are set only if the user is setting a new PIN
        if profile?.userPin == nil {
            guard !securityQuestion.isEmpty && !securityQuestionAnswer.isEmpty else {
                errorMessage = "Security Question and Answer are required for setting a PIN."
                showError = true
                print("Security Question or Answer is empty.")
                return
            }
            print("Security Question and Answer are set.")
        }

        if let profile = profile {
            // Update the profile with the new PIN
            profileManager.updateProfile(
                profile: profile,
                name: profile.name,
                dateOfBirth: profile.dateOfBirth,
                favoriteGenres: profile.favoriteGenres,
                hasAgreedToTerms: profile.hasAgreedToTerms,
                userPin: pin,
                personalSecurityQuestion: profile.userPin == nil ? securityQuestion : profile.personalSecurityQuestion,
                securityQuestionAnswer: profile.userPin == nil ? securityQuestionAnswer : profile.securityQuestionAnswer
            )
            
            print("Profile updated with new PIN: \(pin)")
            print("Stored Security Question: \(profileManager.currentProfile?.personalSecurityQuestion ?? "No question set")")
            print("Stored Security Question Answer: \(profileManager.currentProfile?.securityQuestionAnswer ?? "No answer set")")
            presentationMode.wrappedValue.dismiss()
        } else {
            print("No profile found to update.")
        }
    }
}

/*
struct PinSetupView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock profiles for preview
        let profileWithPin = Profile(
            name: "User with PIN",
            dateOfBirth: Date(),
            favoriteGenres: ["Rock", "Pop"],
            hasAgreedToTerms: true,
            userPin: "1234", // Simulate an existing PIN
            userEmail: "user@example.com"
        )
        
        let profileWithoutPin = Profile(
            name: "User without PIN",
            dateOfBirth: Date(),
            favoriteGenres: ["Jazz", "Blues"],
            hasAgreedToTerms: true,
            userPin: nil, // No existing PIN
            userEmail: nil
        )
        
        // Mock profile manager
        let profileManager = ProfileManager()
        
        // Inject the mock profile into the profile manager for each view
        profileManager.profiles = [profileWithPin, profileWithoutPin]
        profileManager.currentProfile = profileWithPin
        
        return Group {
            // Preview with an existing PIN
            PinSetupView(profile: profileWithPin)
                .environmentObject(profileManager)
                .previewDisplayName("With Existing PIN")
            
            // Preview without an existing PIN
            PinSetupView(profile: profileWithoutPin)
                .environmentObject(profileManager)
                .previewDisplayName("Without Existing PIN")
        }
    }
}
*/
