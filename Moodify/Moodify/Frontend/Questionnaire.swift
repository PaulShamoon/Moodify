import SwiftUI
import PDFKit

struct QuestionnaireView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var agreedToTerms: Bool = false
    @Binding var navigateToMusicPreferences: Bool
    @Binding var isCreatingNewProfile: Bool
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showingTOS = false
    @State private var showingTooltip = false
    @State private var showingTooltip1 = false
    
    @State private var name: String = ""
    @State private var dateOfBirth: Date = Date()
    
    @State private var nameError: String? = nil
    @State private var ageError: String? = nil
    @State private var termsError: String? = nil
    @State private var showErrorMessages = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                headerSection
                
                VStack(spacing: 20) {
                    FormCard(title: "Personal Information") {
                        FormField(
                            title: "Name",
                            tooltip: "We use your name for personalization.",
                            error: showErrorMessages ? nameError : nil
                        ) {
                            CustomTextField(
                                placeholder: "Enter your name",
                                text: $name,
                                icon: "person.fill"
                            )
                        }
                        
                        FormField(
                            title: "Date of Birth",
                            tooltip: "You must be at least 13 years old to use this app.",
                            error: showErrorMessages ? ageError : nil
                        ) {
                            DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                                .frame(height: 100)
                                .colorScheme(.dark)
                                .padding(.vertical, 40)
                        }
                    }
                    if !(profileManager.currentProfile?.hasAgreedToTerms ?? false) {
                        
                        termsSection
                    }
                }
                submitButton
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(white: 0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear(perform: loadProfileData)
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            if isCreatingNewProfile {
                HStack {
                    Button(action: {
                        isCreatingNewProfile = false
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
            }
            
            HStack(spacing: 0) {
                Text("M")
                    .foregroundColor(.green)
                Text("oodify")
                    .foregroundColor(Color(red: 0.96, green: 0.87, blue: 0.70))
            }
            .font(.system(size: 36, weight: .bold, design: .rounded))
            
            Text("Create Your Profile")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .padding(.top, 5)
        }
    }
    
    private var termsSection: some View {
        FormCard(title: "Terms & Conditions") {
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 12) {
                    Toggle("", isOn: $agreedToTerms)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                    
                    Text("I agree to the")
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: TermsOfServiceView(agreedToTerms: $agreedToTerms)) {
                        Text("Terms of Service")
                            .foregroundColor(.green)
                            .underline()
                    }
                }
                
                if showErrorMessages, let termsError = termsError {
                    Text(termsError)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: submitForm) {
            HStack {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.top, 10)
    }
    
    private func submitForm() {
        showErrorMessages = true
        if validateForm() {
            if let profile = profileManager.currentProfile {
                profileManager.updateProfile(
                    profile: profile,
                    name: name,
                    dateOfBirth: dateOfBirth,
                    favoriteGenres: profile.favoriteGenres,
                    hasAgreedToTerms: agreedToTerms,
                    userPin: profile.userPin,
                    personalSecurityQuestion: profile.personalSecurityQuestion,
                    securityQuestionAnswer: profile.personalSecurityQuestion
                )
            } else {
                profileManager.createProfile(
                    name: name,
                    dateOfBirth: dateOfBirth,
                    favoriteGenres: [],
                    hasAgreedToTerms: agreedToTerms
                )
            }
            navigateToMusicPreferences = true
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func loadProfileData() {
        if let profile = profileManager.currentProfile {
            name = profile.name
            dateOfBirth = profile.dateOfBirth
            agreedToTerms = profile.hasAgreedToTerms
        }
    }
    
    private func validateForm() -> Bool {
        nameError = name.isEmpty ? "Name is required." : nil
        let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        ageError = age < 13 ? "You must be at least 13 years old." : nil
        let hasAgreed = profileManager.currentProfile?.hasAgreedToTerms ?? agreedToTerms
        termsError = !hasAgreed ? "You must agree to the Terms of Service." : nil
        return [nameError, ageError, termsError].allSatisfy { $0 == nil }
    }
}

// Custom Components
struct FormCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            content
        }
        .padding(20)
        .background(Color(white: 0.15))
        .cornerRadius(20)
    }
}

struct FormField<Content: View>: View {
    let title: String
    let tooltip: String
    let error: String?
    let content: Content
    @State private var showingTooltip = false
    
    init(
        title: String,
        tooltip: String,
        error: String?,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.tooltip = tooltip
        self.error = error
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Button(action: { showingTooltip.toggle() }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                }
            }
            
            if showingTooltip {
                Text(tooltip)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
            }
            
            content
            
            if let error = error {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
            }
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(white: 0.2))
        .cornerRadius(10)
    }
}
