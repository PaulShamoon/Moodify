/**************************
Filename: Questionnaire.swift
Author: Mohammad Sulaiman
Date: September 12, 2024
Purpose: Questionnaire for the application's initial setup.

*******************************************/
import Foundation
import SwiftUI

struct QuestionnaireView: View {
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var age: Int = 18
    @State private var selectedGender: String = "Male"
    @State private var agreedToTerms: Bool = false
    @State private var navigateToNextPage: Bool = false // State to control navigation
    
    let genders = ["Male", "Female", "Prefer not to say"]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                // First name input
                Text("First Name:")
                    .font(.headline)
                
                TextField("Enter your first name", text: $firstname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
                
                // Last name input
                Text("Last Name")
                    .font(.headline)
                
                TextField("Enter your last name", text: $lastname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
                
                // Age scroll selection
                Text("Age:")
                    .font(.headline)
                
                Picker("Select Age", selection: $age) {
                    ForEach(8..<100) { age in
                        Text("\(age)").tag(age)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                
                // Gender selection
                Text("Gender:")
                    .font(.headline)
                
                Picker("Select Gender", selection: $selectedGender) {
                    ForEach(genders, id: \.self) { gender in
                        Text(gender).tag(gender)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Link to the Terms of Service
                Link("Read Terms of Service", destination: URL(string: "//")!)
                    .foregroundColor(.blue)
                    .padding(.top)
                
                // Terms of Service
                Toggle(isOn: $agreedToTerms) {
                    Text("I agree to the Terms of Service")
                }
                .padding(.bottom)
                
                // Submit button
                Button(action: {
                    if validateForm() {
                        submitForm()
                        navigateToNextPage = true
                    }
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(validateForm() ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!validateForm()) // Disable button if form is not valid
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Questionnaire")
            .navigationDestination(isPresented: $navigateToNextPage) {
                GeneralMusicPreferencesView() // Navigates to GeneralMusicPreferencesView when form is submitted
            }
        }
    }
    
    // Validate form inputs
    func validateForm() -> Bool {
        return !firstname.isEmpty &&
               !lastname.isEmpty &&
               age > 0 && // Assuming age must be greater than 0
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
        // Backend logic here
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView()
    }
}
