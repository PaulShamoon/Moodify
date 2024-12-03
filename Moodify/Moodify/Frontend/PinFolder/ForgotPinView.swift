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
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E6D3"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "1A2F2A"), Color(hex: "243B35")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3"))
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
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E6D3"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "1A2F2A"), Color(hex: "243B35")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(35)
                        .shadow(
                            color: Color.black.opacity(0.2),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                
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
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(Color(hex: "#F5E6D3"))
            .keyboardType(.alphabet)
            .textContentType(.oneTimeCode)
            
            Button(action: toggleVisibility) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "1A2F2A"))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
