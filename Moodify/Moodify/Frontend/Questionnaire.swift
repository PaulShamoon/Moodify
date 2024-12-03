import SwiftUI
import PDFKit

struct QuestionnaireView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var agreedToTerms: Bool = false
    @Binding var isEditingProfile: Bool
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
            VStack(spacing: 15) {
                Spacer()
                
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
                gradient: Gradient(colors: [Color(hex: "#1A2F2A"), Color(hex: "#243B35")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear(perform: loadProfileData)
    }
    
    private var headerSection: some View {
        VStack() {
            if isCreatingNewProfile || isEditingProfile {
                HStack {
                    Button(action: {
                        if isCreatingNewProfile {
                            isCreatingNewProfile = false
                        }
                        if isEditingProfile {
                            isEditingProfile = false
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "#F5E6D3"))
                        .font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                }
            }
            
            HStack(spacing: 0) {
                Text("M")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("oodify")
                    .foregroundColor(Color(hex: "#F5E6D3"))
            }
            .font(.system(size: 36, weight: .bold, design: .rounded))
            
            Text(isCreatingNewProfile ? "Create Your Profile" : "Edit Your Profile")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(hex: "#F5E6D3"))
                .padding(.top, 5)
        }
    }
    
    private var termsSection: some View {
        FormCard(title: "Terms & Conditions") {
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 12) {
                    Toggle("", isOn: $agreedToTerms)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4ADE80")))
                    
                    Text("I agree to the")
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: 
                        TermsOfServiceView(
                            agreedToTerms: $agreedToTerms,
                            showBackButton: false
                        )
                        .tint(Color(hex: "#F5E6D3"))
                    ) {
                        Text("Terms of Service")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
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
            .foregroundColor(Color(hex: "#F5E6D3"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#1A2F2A"), Color(hex: "#243B35")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(hex: "#F5E6D3").opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color(hex: "#243B35").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
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
        // Unique name check
        if profileManager.profiles.contains(where: { $0.name.lowercased() == name.lowercased() && $0.id != profileManager.currentProfile?.id }) {
            nameError = "This name is already taken. Please choose another."
        }
        // Only allows alphanumeric 
        if !name.trimmingCharacters(in: .whitespaces).allSatisfy({ $0.isLetter || $0.isNumber }) {
            nameError = "Only alphanumeric characters are allowed."
        }
        
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
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#F5E6D3"))
            
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
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                
                Button(action: { showingTooltip.toggle() }) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .font(.system(size: 14, weight: .medium))
                }
            }
            
            if showingTooltip {
                Text(tooltip)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                    .padding(.bottom, 5)
            }
            
            content
            
            if let error = error {
                Text(error)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
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
                .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(hex: "#F5E6D3"))
        }
        .padding()
        .background(Color(white: 0.2))
        .cornerRadius(10)
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        let profileManager = ProfileManager()
        let navigateToMusicPreferences = Binding.constant(false)
        let isCreatingNewProfile = Binding.constant(true)
        let isEditingProfile = Binding.constant(false)
        QuestionnaireView(
            isEditingProfile: isEditingProfile, navigateToMusicPreferences: navigateToMusicPreferences,
            isCreatingNewProfile: isCreatingNewProfile
        )
        .environmentObject(profileManager)
    }
}
