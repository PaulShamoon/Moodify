import SwiftUI

struct PinSetupView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var email: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var profile: Profile?

    var body: some View {
        VStack {
            Text("Set or Change PIN")
                .font(.largeTitle)
                .padding()

            SecureField("Enter 4-digit PIN", text: $pin)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .frame(width: 200)

            SecureField("Confirm PIN", text: $confirmPin)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .frame(width: 200)

            if profile?.userPin == nil {
                TextField("Enter Recovery Email", text: $email)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .autocapitalization(.none)
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
    }

    private func savePin() {
        guard pin.count == 4, pin == confirmPin else {
            errorMessage = "PINs must match and be 4 digits."
            showError = true
            return
        }

        if profile?.userPin == nil, email.isEmpty {
            errorMessage = "Recovery email is required for setting a PIN."
            showError = true
            return
        }

        if let profile = profile {
            // Update profile with new PIN and email if it's a new setup
            profileManager.updateProfile(
                profile: profile,
                name: profile.name,
                dateOfBirth: profile.dateOfBirth,
                favoriteGenres: profile.favoriteGenres,
                hasAgreedToTerms: profile.hasAgreedToTerms
            )
            profileManager.currentProfile?.userPin = pin
            profileManager.currentProfile?.userEmail = email
            presentationMode.wrappedValue.dismiss()
        }
    }
}
