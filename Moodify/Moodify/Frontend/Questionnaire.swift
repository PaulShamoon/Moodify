import SwiftUI
import PDFKit

struct QuestionnaireView: View {
    @EnvironmentObject var profileManager: ProfileManager // Inject ProfileManager
    @State private var agreedToTerms: Bool = false
    @Binding var navigateToMusicPreferences: Bool // Binding to control navigation

    @Environment(\.presentationMode) var presentationMode
    @State private var showingPDF = false
    @State private var showingTooltip = false
    @State private var showingTooltip1 = false

    @State private var hasAgreedToTerms: Bool = false // Track terms agreement
    
    // Error states
    @State private var nameError: String? = nil
    @State private var ageError: String? = nil
    @State private var termsError: String? = nil
    
    // Show errors only after submit attempt
    @State private var showErrorMessages = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 0) {
                    Text("M")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.2))
                    Text("oodify")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.96, green: 0.87, blue: 0.70))
                }
                
                // Name input with tooltip
                HStack {
                    Text("Name:")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        showingTooltip.toggle() // Toggle tooltip visibility
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.green)
                    }
                    
                    if showingTooltip {
                        Text("We use your name for personalization.")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity)
                    }
                }

                TextField("Enter your name", text: $profileManager.tempName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                // Show error if name is missing
                if showErrorMessages, let nameError = nameError {
                    Text(nameError)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }

                // Date of Birth input with tooltip
                HStack {
                    Text("Date of Birth:")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        showingTooltip1.toggle()
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.green)
                    }
                    
                    if showingTooltip1 {
                        Text("You must be at least 13 years old to use this app.")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity)
                    }
                }

                DatePicker("", selection: $profileManager.tempDateOfBirth, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(height: 100)
                    .foregroundColor(.white)
                    .padding(.vertical, 25)
                    .padding(.leading, 25)
                
                // Show error if age is less than 13
                if showErrorMessages, let ageError = ageError {
                    Text(ageError)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }

                // Terms of Service button and toggle
                Button(action: {
                    showingPDF = true // Show the PDF when clicked
                }) {
                    Text("Read Terms of Service")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                }

                // Show the terms toggle only if the user hasn't agreed
                if !profileManager.tempHasAgreedToTerms {
                    Toggle(isOn: $agreedToTerms) {
                        Text("I agree to the Terms of Service")
                            .foregroundColor(.white)
                    }
                    
                    // Show error if terms are not agreed
                    if showErrorMessages, let termsError = termsError {
                        Text(termsError)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                }

                // Submit button
                Button(action: {
                    showErrorMessages = true
                    if validateForm() {
                        profileManager.tempHasAgreedToTerms = agreedToTerms || profileManager.tempHasAgreedToTerms // Save the terms agreement status only if applicable
                        profileManager.saveProfile() // Save profile before moving to next page
                        navigateToMusicPreferences = true // Go to music preferences after questionnaire
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Submit")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                loadProfileData() // Load the current profile's data when editing
                checkAgreedToTerms()
            }
            .sheet(isPresented: $showingPDF) {
                PDFViewerView()
            }
        }
    }

    // Validation function
    func validateForm() -> Bool {
        var isValid = true
        
        if profileManager.tempName.isEmpty {
            nameError = "Name is required."
            isValid = false
        } else {
            nameError = nil
        }
        
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: profileManager.tempDateOfBirth, to: Date()).year ?? 0
        if age < 13 {
            ageError = "You must be at least 13 years old."
            isValid = false
        } else {
            ageError = nil
        }
        
        if !agreedToTerms && !profileManager.tempHasAgreedToTerms {
            termsError = "You must agree to the Terms of Service."
            isValid = false
        } else {
            termsError = nil
        }
        
        return isValid
    }

    func loadProfileData() {
        if let profile = profileManager.currentProfile {
            profileManager.tempName = profile.name
            profileManager.tempDateOfBirth = profile.dateOfBirth
            hasAgreedToTerms = profile.hasAgreedToTerms // Load whether the user has agreed to the terms
        }
    }

    func checkAgreedToTerms() {
        hasAgreedToTerms = profileManager.tempHasAgreedToTerms // Check if the terms were already agreed upon
        agreedToTerms = hasAgreedToTerms // Set the agreed toggle appropriately
    }
}

// PDF Viewer
struct PDFViewerView: View {
    var body: some View {
        if let pdfURL = Bundle.main.url(forResource: "TermsofService", withExtension: "pdf") {
            PDFKitView(url: pdfURL)
        } else {
            Text("PDF not found")
        }
    }
}

// PDFKit View for displaying PDFs
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct QuestionnaireView_Previews: PreviewProvider {
    @State static var navigateToMusicPreferences = false

    static var previews: some View {
        NavigationView {
            if navigateToMusicPreferences {
                GeneralMusicPreferencesView(navigateToHomePage: .constant(false))
                    .environmentObject(ProfileManager()) // Mock ProfileManager for preview
            } else {
                QuestionnaireView(navigateToMusicPreferences: $navigateToMusicPreferences)
                    .environmentObject(ProfileManager()) // Mock ProfileManager for preview
            }
        }
    }
}

