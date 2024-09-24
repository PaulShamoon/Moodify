import Foundation
import SwiftUI

struct QuestionnaireView: View {
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var age: Int = 18
    @State private var selectedGender: String = "Male"
    @State private var agreedToTerms: Bool = false
    @State private var navigateToNextPage: Bool = false
    
    let genders = ["Male", "Female", "Prefer not to say"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title similar to homePageView
                    HStack(spacing: 0) {
                        Text("M")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.2))
                        Text("oodify")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.96, green: 0.87, blue: 0.70))
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    
                    Text("Complete the following to customize your experience")
                        .font(.system(size: 12, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    // First Name Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("First Name:")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        TextField("Enter your first name", text: $firstname)
                            .padding()
                            .background(Color(red: 0.96, green: 0.87, blue: 0.70))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                    }
                    
                    // Last Name Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Last Name:")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        TextField("Enter your last name", text: $lastname)
                            .padding()
                            .background(Color(red: 0.96, green: 0.87, blue: 0.70))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                    }
                    
                    // Age Scroll Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Age:")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Picker("Select Age", selection: $age) {
                            ForEach(8..<100) { age in
                                Text("\(age)")
                                    .tag(age)
                                    .foregroundColor(.gray)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)
                        .background(Color(red: 0.96, green: 0.87, blue: 0.70).cornerRadius(10))
                    }
                    
                    // Gender Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Gender:")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Picker("Select Gender", selection: $selectedGender) {
                            ForEach(genders, id: \.self) { gender in
                                Text(gender)
                                    .foregroundColor(.white)
                                    .tag(gender)
                            }
                        }
                        .background(Color(red: 0.96, green: 0.87, blue: 0.70))
                        .pickerStyle(SegmentedPickerStyle())
                        .cornerRadius(7)
                    }
                    
                    // Link to the Terms of Service
                    Link("Read Terms of Service", destination: URL(string: "//")!)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.2))
                        .padding(.top)
                    
                    // Terms of Service Agreement
                    Toggle(isOn: $agreedToTerms) {
                        Text("I agree to the Terms of Service")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                    }
                    
                    Spacer()

                    Button(action: {
                        if validateForm() {
                            submitForm()
                            navigateToNextPage = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(.black)
                            Text("Submit")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(validateForm() ?  Color(red: 0.0, green: 0.5, blue: 0.2) : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!validateForm())
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .navigationDestination(isPresented: $navigateToNextPage) {
                    GeneralMusicPreferencesView() // Navigate to GeneralMusicPreferencesView when form is submitted
                }
            }
        }
    }
    
    // Validate form inputs
    func validateForm() -> Bool {
        return !firstname.isEmpty &&
               !lastname.isEmpty &&
               age > 0 &&
               !selectedGender.isEmpty &&
               agreedToTerms
    }
    
    // Handle form submission
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
        QuestionnaireView()
    }
}
