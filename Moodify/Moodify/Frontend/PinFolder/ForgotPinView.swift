import SwiftUI

struct ForgotPinView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var enteredAnswer: String = ""
    @State private var newPin: String = ""
    @State private var confirmNewPin: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isAnswerVisible: Bool = false
    @State private var isNewPinVisible: Bool = false
    @State private var isConfirmPinVisible: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var navigateBackToSelection: Bool
    
    var profile: Profile
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 10)
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 50)
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
                
                // Display the security question
                Text(profile.personalSecurityQuestion ?? "No security question set")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Security answer input with visibility toggle inside the input field
                TextInputField(
                    text: $enteredAnswer,
                    isSecure: !isAnswerVisible,
                    placeholder: "Enter your answer",
                    toggleVisibility: { isAnswerVisible.toggle() }
                )
                
                Text("Enter your new 4 digit PIN")
                    .font(.title2)
                    .foregroundColor(.white)
                
                // New PIN input with visibility toggle inside the input field
                PinInputField(
                    text: $newPin,
                    isSecure: !isNewPinVisible,
                    placeholder: "Enter New 4-digit PIN",
                    toggleVisibility: { isNewPinVisible.toggle() }
                )
                
                // Confirm PIN input with visibility toggle inside the input field
                PinInputField(
                    text: $confirmNewPin,
                    isSecure: !isConfirmPinVisible,
                    placeholder: "Confirm New PIN",
                    toggleVisibility: { isConfirmPinVisible.toggle() }
                )
                
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
        .navigationBarBackButtonHidden(true) // Hides the default back button
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

struct TextInputField: View {
    @Binding var text: String
    var isSecure: Bool
    var placeholder: String
    var toggleVisibility: () -> Void
    var body: some View {
        HStack {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .keyboardType(.alphabet)
            .textContentType(.oneTimeCode)
            Button(action: toggleVisibility) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
