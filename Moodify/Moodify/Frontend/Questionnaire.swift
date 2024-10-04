import SwiftUI
import PDFKit

struct QuestionnaireView: View {
    @State private var name: String = ""
    @State private var age: Int = 18
    @State private var agreedToTerms: Bool = false
    @Binding var navigateToMusicPreferences: Bool // Binding to control navigation

    @Environment(\.presentationMode) var presentationMode // Used to dismiss the view smoothly
    @State private var showingPDF = false
    @State private var showingTooltip = false // State to control showing tooltip for the name
    @State private var hasAgreedToTerms: Bool = false // Flag to track if the user already agreed to terms
    
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
                HStack {
                    // Name input with info button
                    Text("Name:")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 7)
                    
                    Button(action: {
                        showingTooltip.toggle() // Toggle tooltip visibility
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                    }
                    
                    // Tooltip text
                    if showingTooltip {
                        Text("We use your name for personalization and to provide a better interactive experience within the app.")
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
                
                // Age input
                Text("Age:")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 7)
                
                // Age picker
                Picker("Age", selection: $age) {
                    ForEach(0..<100) { age in
                        Text("\(age)").tag(age)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                .foregroundColor(.white)
                
                // "Read Terms of Service" Button
                Button(action: {
                    showingPDF = true // Show the PDF when button is clicked
                }) {
                    Text("Read Terms of Service")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                        .padding(.top)
                }

                // Only show Terms of Service toggle if they haven't agreed yet
                if !hasAgreedToTerms {
                    Toggle(isOn: $agreedToTerms) {
                        Text("I agree to the Terms of Service")
                            .foregroundColor(.white)
                    }
                }
                
                // Red warning text if form is incomplete
                if !validateForm() {
                    Text("All fields must be filled before submitting.")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                // Submit button
                Button(action: {
                    if validateForm() {
                        submitForm()
                        if !hasAgreedToTerms {
                            UserDefaults.standard.set(true, forKey: "hasAgreedToTerms") // Save agreement
                        }
                        navigateToMusicPreferences = true // Trigger navigation
                        presentationMode.wrappedValue.dismiss() // Dismiss the view smoothly to return to the menu
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
                        .opacity(validateForm() ? 1.0 : 0.7)
                }
                .disabled(!validateForm())
                
                Spacer()
            }
            .padding()
            .onAppear {
                loadFormData() // Load the saved data when the view appears
                checkAgreedToTerms() // Check if the user already agreed to terms
            }
            // Present the PDF viewer in a sheet
            .sheet(isPresented: $showingPDF) {
                PDFViewerView()
            }
        }
    }
    
    // Form validation
    func validateForm() -> Bool {
        // Validate only if terms of service toggle is visible and terms are agreed
        return !name.isEmpty && age > 0 && (hasAgreedToTerms || agreedToTerms)
    }
    
    // Form submission
    func submitForm() {
        print("Name: \(name)")
        print("Age: \(age)")
        print("Agreed to Terms: \(agreedToTerms)")
        // Save form data to UserDefaults
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(age, forKey: "age")
    }

    // Load saved form data from UserDefaults
    func loadFormData() {
        name = UserDefaults.standard.string(forKey: "name") ?? ""
        age = UserDefaults.standard.integer(forKey: "age")
    }
    
    // Check if the user has already agreed to the terms
    func checkAgreedToTerms() {
        hasAgreedToTerms = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")
    }
}

// PDF Viewer to display the PDF file
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
