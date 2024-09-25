import SwiftUI

struct QuestionnaireView: View {
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var age: Int = 18
    @State private var selectedGender: String = "Male"
    @State private var agreedToTerms: Bool = false
    @Binding var navigateToMusicPreferences: Bool // Binding to control navigation
    
    let genders = ["Male", "Female", "Prefer not to say"]
    
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
                
                // First name input
                TextField("First Name", text: $firstname)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                // Last name input
                TextField("Last Name", text: $lastname)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                // Age picker
                Picker("Age", selection: $age) {
                    ForEach(8..<100) { age in
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
                
                // Terms of Service Toggle
                Toggle(isOn: $agreedToTerms) {
                    Text("I agree to the Terms of Service")
                        .foregroundColor(.white)
                }
                
                // Submit button
                Button(action: {
                    if validateForm() {
                        submitForm()
                        navigateToMusicPreferences = true // Trigger navigation
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
        }
    }
    
    // Form validation
    func validateForm() -> Bool {
        return !firstname.isEmpty &&
               !lastname.isEmpty &&
               age > 0 &&
               !selectedGender.isEmpty &&
               agreedToTerms
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
        UserDefaults.standard.set(agreedToTerms, forKey: "agreedToTerms")
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView(navigateToMusicPreferences: .constant(false))
    }
}
