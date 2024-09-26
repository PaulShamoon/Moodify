import SwiftUI

struct QuestionnaireView: View {
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var age: Int = 18
    @State private var selectedGender: String = "Male"
    @State private var agreedToTerms: Bool = false
    @Binding var navigateToMusicPreferences: Bool // Binding to control navigation
    
    @Environment(\.presentationMode) var presentationMode // Used to dismiss the view smoothly

    let genders = ["Male", "Female", "Prefer not to say"]
    
    // Determine if the user is editing through the hamburger menu (i.e., they've already agreed to terms)
    @State private var hasAgreedToTerms: Bool = false // Flag to track if the user already agreed to terms
    
    var body: some View {
        ZStack {
            // Dark background with gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("User Information")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text("First Name:")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 7)
                
                // First name input
                TextField("First Name", text: $firstname)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                Text("Last Name:")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 7)
                
                // Last name input
                TextField("Last Name", text: $lastname)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
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
                
                // Gender selection
                Picker("Gender", selection: $selectedGender) {
                    ForEach(genders, id: \.self) { gender in
                        Text(gender).tag(gender)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(.white)
                
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
        }
    }
    
    // Form validation
    func validateForm() -> Bool {
        // Validate only if terms of service toggle is visible and terms are agreed
        return !firstname.isEmpty &&
               !lastname.isEmpty &&
               age > 0 &&
               !selectedGender.isEmpty &&
               (hasAgreedToTerms || agreedToTerms)
    }
    
    // Form submission
    func submitForm() {
        print("First Name: \(firstname)")
        print("Last Name: \(lastname)")
        print("Age: \(age)")
        print("Gender: \(selectedGender)")
        print("Agreed to Terms: \(agreedToTerms)")
        // Save form data to UserDefaults
        UserDefaults.standard.set(firstname, forKey: "firstname")
        UserDefaults.standard.set(lastname, forKey: "lastname")
        UserDefaults.standard.set(age, forKey: "age")
        UserDefaults.standard.set(selectedGender, forKey: "gender")
    }

    // Load saved form data from UserDefaults
    func loadFormData() {
        firstname = UserDefaults.standard.string(forKey: "firstname") ?? ""
        lastname = UserDefaults.standard.string(forKey: "lastname") ?? ""
        age = UserDefaults.standard.integer(forKey: "age")
        selectedGender = UserDefaults.standard.string(forKey: "gender") ?? "Male"
    }
    
    // Check if the user has already agreed to the terms
    func checkAgreedToTerms() {
        hasAgreedToTerms = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView(navigateToMusicPreferences: .constant(false))
    }
}
