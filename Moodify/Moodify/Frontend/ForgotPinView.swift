import SwiftUI

struct ForgotPinView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var enteredAnswer: String = ""
    @State private var newPin: String = ""
    @State private var confirmNewPin: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    @Binding var navigateBackToSelection: Bool
    
    var profile: Profile
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 100)
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 30) {
                Text("Forgot PIN")
                    .font(.title)
                    .foregroundColor(.green)
                    .padding(.top)
                
                Spacer()
                Text("Your Security Question")
                    .font(.title2)
                    .foregroundColor(.white)
                Text(profile.personalSecurityQuestion ?? "No security question set")
                    .font(.headline)
                    .foregroundColor(.white)
                SecureField("Enter your answer", text: $enteredAnswer)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                Text("Enter your new 4 digit PIN")
                    .font(.title2)
                    .foregroundColor(.white)
                SecureField("Enter New 4-digit PIN", text: $newPin)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .frame(width: 200)
                SecureField("Confirm New PIN", text: $confirmNewPin)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .frame(width: 200)

                Button(action: resetPin) {
                    Text("Reset PIN")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: 400)
        }
        .onDisappear {
            // Ensure the profile data is reloaded when this view is dismissed
            profileManager.loadProfiles()
        }
    }
    
    private func resetPin() {
        guard !enteredAnswer.isEmpty else {
            errorMessage = "Security answer cannot be empty."
            showError = true
            return
        }

        guard enteredAnswer == profile.securityQuestionAnswer else {
            errorMessage = "Incorrect security answer. Please try again."
            showError = true
            return
        }
        
        errorMessage = ""
        showError = false

        guard newPin.count == 4 else {
            errorMessage = "PIN must be 4 digits."
            showError = true
            return
        }
        
        guard confirmNewPin.count == 4 else {
            errorMessage = "New PIN must be 4 digits."
            showError = true
            return
        }

        guard newPin == confirmNewPin else {
            errorMessage = "PINs do not match. Please try again."
            showError = true
            return
        }
        
        errorMessage = ""
        showError = false

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
