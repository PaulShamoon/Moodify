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

    // Form fields for the new profile
    @State private var name: String = ""
    @State private var dateOfBirth: Date = Date()
    
    // Error states
    @State private var nameError: String? = nil
    @State private var ageError: String? = nil
    @State private var termsError: String? = nil
    @State private var showErrorMessages = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                // App title
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

                TextField("Enter your name", text: $name)
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

                DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(height: 100)
                    .foregroundColor(.white)
                    .padding(.vertical, 25)
                    .padding(.leading, 25)
                
                // Show error if age is less than 13
                if showErrorMessages, let ageError = ageError {
                    Text(ageError)
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
                if !(profileManager.currentProfile?.hasAgreedToTerms ?? false) {
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
                        // Save or update the profile based on whether we're creating or editing
                        if let profile = profileManager.currentProfile {
                            profileManager.updateProfile(profile: profile, name: name, dateOfBirth: dateOfBirth, favoriteGenres: profile.favoriteGenres, hasAgreedToTerms: agreedToTerms, userPin: profile.userPin, personalSecurityQuestion: profile.personalSecurityQuestion, securityQuestionAnswer: profile.personalSecurityQuestion)
                        } else {
                            profileManager.createProfile(name: name, dateOfBirth: dateOfBirth, favoriteGenres: [], hasAgreedToTerms: agreedToTerms)
                        }
                        
                        print("Saved profile: \(profileManager.currentProfile?.name ?? "New Profile")")
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
            }
            .sheet(isPresented: $showingPDF) {
                PDFViewerView()
            }
        }
    }

    // Load data into the form fields from currentProfile, if it exists
    func loadProfileData() {
        if let profile = profileManager.currentProfile {
            name = profile.name
            dateOfBirth = profile.dateOfBirth
            agreedToTerms = profile.hasAgreedToTerms
            print("Loaded profile data: \(profile.name)")
        }
    }

    // Validation function
    func validateForm() -> Bool {
        nameError = name.isEmpty ? "Name is required." : nil

        let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        ageError = age < 13 ? "You must be at least 13 years old." : nil

        let hasAgreed = profileManager.currentProfile?.hasAgreedToTerms ?? agreedToTerms
        termsError = !hasAgreed ? "You must agree to the Terms of Service." : nil

        return [nameError, ageError, termsError].allSatisfy { $0 == nil }
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
            QuestionnaireView(navigateToMusicPreferences: $navigateToMusicPreferences)
                .environmentObject(ProfileManager()) // Mock ProfileManager for preview
        }
    }
}
