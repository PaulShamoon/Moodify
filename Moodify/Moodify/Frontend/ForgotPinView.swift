import SwiftUI

struct ForgotPinView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var enteredAnswer: String = ""
    @State private var newPin: String = ""
    @State private var confirmNewPin: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    @Binding var navigateBackToSelection: Bool
    
    var profile: Profile

    var body: some View {
        VStack {
            Text("Forgot PIN")
                .font(.largeTitle)
                .padding()

            Text(profile.personalSecurityQuestion ?? "No security question set")
                .font(.headline)
                .padding()

            SecureField("Enter your answer", text: $enteredAnswer)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            SecureField("Enter New 4-digit PIN", text: $newPin)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .frame(width: 200)

            SecureField("Confirm New PIN", text: $confirmNewPin)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .frame(width: 200)

            Button(action: resetPin) {
                Text("Reset PIN")
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

    private func resetPin() {
        guard !enteredAnswer.isEmpty else {
            errorMessage = "Answer cannot be empty."
            showError = true
            return
        }

        guard enteredAnswer == profile.securityQuestionAnswer else {
            errorMessage = "Incorrect answer. Please try again."
            showError = true
            return
        }

        guard newPin.count == 4 else {
            errorMessage = "PIN must be 4 digits."
            showError = true
            return
        }

        guard newPin == confirmNewPin else {
            errorMessage = "PINs do not match. Please try again."
            showError = true
            return
        }

        // Update the profile with the new PIN
        if let profileIndex = profileManager.profiles.firstIndex(where: { $0.id == profile.id }) {
            profileManager.updateProfile(
                profile: profileManager.profiles[profileIndex],
                name: profile.name,
                dateOfBirth: profile.dateOfBirth,
                favoriteGenres: profile.favoriteGenres,
                hasAgreedToTerms: profile.hasAgreedToTerms,
                userPin: newPin,
                personalSecurityQuestion: profile.personalSecurityQuestion,
                securityQuestionAnswer: profile.securityQuestionAnswer
            )

            print("PIN reset successfully for profile: \(profileManager.profiles[profileIndex].name)")
            navigateBackToSelection = true // Navigate back to the selection page
        } else {
            errorMessage = "Profile not found. Please try again."
            showError = true
        }
    }
}
