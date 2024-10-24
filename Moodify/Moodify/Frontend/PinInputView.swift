//
//  PinInputView.swift
//  Moodify
//
//  Created by Mahdi Sulaiman on 10/23/24.
//
import SwiftUI

struct PinInputView: View {
    let profile: Profile
    @EnvironmentObject var profileManager: ProfileManager // Add this line
    @State private var enteredPin: String = ""
    @State private var showError: Bool = false
    @State private var showingForgotPin = false
    var onPinEntered: (String) -> Void

    var body: some View {
        VStack {
            Text("Enter PIN for \(profile.name)")
                .font(.headline)
                .padding()

            SecureField("Enter PIN", text: $enteredPin)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .frame(width: 200)

            if showError {
                Text("Incorrect PIN. Please try again.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }

            Button(action: {
                if enteredPin.count == 4 {
                    onPinEntered(enteredPin)
                } else {
                    showError = true
                }
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()

            Button(action: {
                showingForgotPin = true
            }) {
                Text("Forgot PIN?")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .underline()
            }
            .padding(.top, 10)
            .sheet(isPresented: $showingForgotPin) {
                ForgotPinView(profile: profile)
                    .environmentObject(profileManager) // Ensure profileManager is passed here
            }

            Spacer()
        }
        .padding()
    }
}
