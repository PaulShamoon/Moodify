import SwiftUI
import PDFKit

struct QuestionnaireView: View {
    @State private var name: String = ""
    @State private var dateOfBirth = Date() // State for date of birth
    @State private var agreedToTerms: Bool = false
    @Binding var navigateToMusicPreferences: Bool // Binding to control navigation

    @Environment(\.presentationMode) var presentationMode // Used to dismiss the view smoothly
    @State private var showingPDF = false
    @State private var showingTooltip = false
    @State private var showingTooltip1 = false

    @State private var hasAgreedToTerms: Bool = false // Flag to track if the user already agreed to terms
    
    // Constant for minimum age requirement
    let minimumAgeRequirement = 13

    // Error states
    @State private var nameError: String? = nil
    @State private var ageError: String? = nil
    @State private var termsError: String? = nil
    
    // Flag to show errors only after hitting the submit button
    @State private var showErrorMessages = false

    var body: some View {
        ZStack {
            // Dark background with gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                // Title
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
                        Text("We use your name for personalization and to provide a better interactive experience.")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Name input
                TextField("Enter your name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                // Name error message
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

                // DatePicker for Date of Birth
                DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(height: 100)
                    .foregroundColor(.white)
                    .padding(.vertical, 25) // Restore spacing
                    .padding(.leading, 25) // Restore left padding
                
                // Age error message
                if showErrorMessages, let ageError = ageError {
                    Text(ageError)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                
                // "Read Terms of Service" Button
                Button(action: {
                    showingPDF = true // Show the PDF when button is clicked
                }) {
                    Text("Read Terms of Service")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                }

                // Terms of Service toggle (only if the user hasn't agreed yet)
                if !hasAgreedToTerms {
                    Toggle(isOn: $agreedToTerms) {
                        Text("I agree to the Terms of Service")
                            .foregroundColor(.white)
                    }
                    
                    // Terms error message
                    if showErrorMessages, let termsError = termsError {
                        Text(termsError)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                }

                // Submit button
                Button(action: {
                    showErrorMessages = true // Show errors when the user clicks Submit
                    if validateForm() {
                        submitForm()
                        navigateToMusicPreferences = true // Trigger navigation
                        presentationMode.wrappedValue.dismiss() // Dismiss the view smoothly
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
                loadFormData() // Load saved data
                checkAgreedToTerms() // Check if the user already agreed to terms
            }
            .sheet(isPresented: $showingPDF) {
                PDFViewerView()
            }
        }
    }

    // Validation Function
    func validateForm() -> Bool {
        var isValid = true
        
        // Name Validation
        if name.isEmpty {
            nameError = "Name is required."
            isValid = false
        } else {
            nameError = nil
        }
        
        // Age Validation
        if !ageRestriction() {
            ageError = "You must be at least 13 years old."
            isValid = false
        } else {
            ageError = nil
        }
        
        // Terms of Service Validation
        if !agreedToTerms && !hasAgreedToTerms {
            termsError = "You must agree to the Terms of Service."
            isValid = false
        } else {
            termsError = nil
        }
        
        return isValid
    }

    // Check if the user is at least 13 years old
    func ageRestriction() -> Bool {
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        return age >= minimumAgeRequirement
    }

    // Submit Form Data
    func submitForm() {
        print("Name: \(name)")
        print("Date of Birth: \(dateOfBirth)")
        print("Agreed to Terms: \(agreedToTerms)")
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(dateOfBirth, forKey: "dateOfBirth")
        UserDefaults.standard.set(true, forKey: "hasAgreedToTerms") // Save that the user agreed to terms
    }

    // Load saved form data
    func loadFormData() {
        name = UserDefaults.standard.string(forKey: "name") ?? ""
        dateOfBirth = UserDefaults.standard.object(forKey: "dateOfBirth") as? Date ?? Date()
    }

    // Check if the user already agreed to terms
    func checkAgreedToTerms() {
        hasAgreedToTerms = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")
        agreedToTerms = hasAgreedToTerms // Make sure the toggle reflects the agreement state
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
    static var previews: some View {
        QuestionnaireView(navigateToMusicPreferences: .constant(false))
    }
}
