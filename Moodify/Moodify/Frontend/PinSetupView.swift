import SwiftUI

struct PinSetupView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.presentationMode) var presentationMode
    // State variables
    @State private var currentPin: String = ""
    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var securityQuestion: String = ""
    @State private var securityQuestionAnswer: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""
    @State private var isCurrentPinVisible = false
    @State private var isNewPinVisible = false
    @State private var isConfirmPinVisible = false
    @State private var isAnswerVisible = false
    @State private var currentStep = 1
    @State private var isPinFieldsDisabled = false
    var profile: Profile?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.1), Color.purple.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    // Progress indicator for new PIN setup
                    if profile?.userPin == nil {
                        ProgressView(value: Double(currentStep), total: 2)
                            .tint(.green)
                            .padding(.horizontal)
                    }
                    // Main content
                    Group {
                        if profile?.userPin != nil {
                            currentPinSection
                        }
                        newPinSection
                        if profile?.userPin == nil && currentStep == 2 {
                            securityQuestionSection
                        }
                    }
                    .transition(.opacity)
                    // Error message
                    if showError {
                        ErrorBanner(message: errorMessage)
                    }
                    // Action buttons
                    buttonSection
                }
                .padding()
            }
        }
    }
    
    private var headerView: some View {
        Text(profile?.userPin == nil ? "Create Your PIN" : "Change PIN")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .padding(.top)
    }
    
    private var currentPinSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current PIN")
                .font(.headline)
                .foregroundColor(.secondary)
            PinInputField(
                text: $currentPin,
                isSecure: !isCurrentPinVisible,
                placeholder: "Enter current PIN",
                toggleVisibility: { isCurrentPinVisible.toggle() }
            )
            .disabled(isPinFieldsDisabled)
            .opacity(isPinFieldsDisabled ? 0.6 : 1)
            InfoText(tooltip: "Enter your current PIN to proceed")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private var newPinSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New PIN")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if currentStep == 1 {
                PinInputField(
                    text: $pin,
                    isSecure: !isNewPinVisible,
                    placeholder: "Enter new 4-digit PIN",
                    toggleVisibility: { isNewPinVisible.toggle() }
                )
                .disabled(isPinFieldsDisabled)
                .opacity(isPinFieldsDisabled ? 0.6 : 1)
                
                PinInputField(
                    text: $confirmPin,
                    isSecure: !isConfirmPinVisible,
                    placeholder: "Confirm new PIN",
                    toggleVisibility: { isConfirmPinVisible.toggle() }
                )
                .disabled(isPinFieldsDisabled)
                .opacity(isPinFieldsDisabled ? 0.6 : 1)
                
                InfoText(tooltip: "PIN must be 4 digits")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private var securityQuestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Security Question")
                .font(.headline)
                .foregroundColor(.secondary)
            CustomTextField(
                placeholder: "Enter your security question",
                text: $securityQuestion,
                icon: "questionmark.circle"
            )
            SecureInputField(
                text: $securityQuestionAnswer,
                isSecure: !isAnswerVisible,
                placeholder: "Enter your answer",
                toggleVisibility: { isAnswerVisible.toggle() }
            )
            InfoText(tooltip: "This helps you recover your PIN if you forgot it")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private var buttonSection: some View {
        HStack(spacing: 16) {
            if currentStep > 1 && profile?.userPin == nil {
                Button(action: {
                    // Reset showError when going back
                    showError = false
                    currentStep -= 1
                    isPinFieldsDisabled = false // Re-enable PIN fields when going back
                }) {
                    Text("Back")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            Button(action: handleNextStep) {
                Text(getButtonTitle())
                    .frame(maxWidth: .infinity)
                    .font(.title2)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
        }
        .padding(.top)
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.blue)
            .font(.system(size: 16, weight: .medium))
        }
    }
    
    private func handleNextStep() {
        // Reset the error flag when the user clicks "Next"
        showError = false

        if profile?.userPin == nil {
            handleNewPinSetup()
        } else {
            savePin()
        }
    }
    
    private func handleNewPinSetup() {
        switch currentStep {
        case 1:
            if validateNewPin() {
                withAnimation {
                    currentStep = 2
                }
            }
        case 2:
            if validateSecurityQuestion() {
                isPinFieldsDisabled = true
                savePin()
            }
        default:
            break
        }
    }
    
    private func getButtonTitle() -> String {
        if profile?.userPin == nil {
            return currentStep == 2 ? "Complete Setup" : "Next"
        }
        return "Save Changes"
    }
    
    private func validateNewPin() -> Bool {
        // Reset showError flag before starting validation
        showError = false

        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else {
            showError = true
            errorMessage = "PIN must be exactly 4 digits"
            return false
        }
        guard !confirmPin.isEmpty else {
            showError = true
            errorMessage = "Please confirm your PIN"
            return false
        }
        guard pin == confirmPin else {
            showError = true
            errorMessage = "PINs don't match"
            return false
        }
        guard !pin.allSatisfy({ $0 == pin[pin.startIndex] }) else {
            showError = true
            errorMessage = "PIN cannot be all same digits"
            return false
        }
        guard !["0000", "1111", "1234", "4321"].contains(pin) else {
            showError = true
            errorMessage = "PIN is too common. Please choose a more secure PIN"
            return false
        }
        return true
    }
    
    private func validateSecurityQuestion() -> Bool {
        // Reset showError flag before starting validation
        showError = false

        guard !securityQuestion.isEmpty && !securityQuestionAnswer.isEmpty else {
            showError = true
            errorMessage = "Please complete security question and answer"
            return false
        }
        return true
    }
    
    private func savePin() {
        if let profile = profile {
            if let existingPin = profile.userPin {
                guard currentPin == existingPin else {
                    showError = true
                    errorMessage = "Current PIN is incorrect"
                    return
                }
                guard pin == confirmPin else {
                    showError = true
                    errorMessage = "PINs do not match"
                    return
                }
            }
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
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// Supporting Views
struct PinInputField: View {
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
            .keyboardType(.numberPad)
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

struct SecureInputField: View {
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

struct InfoText: View {
    let tooltip: String
    @State private var showingTooltip = false
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Button(action: { showingTooltip.toggle() }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                }
                if showingTooltip {
                    Text(tooltip)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showingTooltip)
    }
}

struct ErrorBanner: View {
    let message: String
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(.red)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }
}
