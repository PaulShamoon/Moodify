//
//  PinInputView.swift
//  Moodify
//
//  Created by Mahdi Sulaiman on 10/23/24.
//
import SwiftUI

struct PinInputView: View {
    let profile: Profile
    @EnvironmentObject var profileManager: ProfileManager
    @State private var enteredPin: String = ""
    @State private var showError: Bool = false
    @State private var showingForgotPin = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateBackToSelection = false
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
                ForgotPinView(navigateBackToSelection: $navigateBackToSelection, profile: profile)
                    .environmentObject(profileManager)
            }

            Spacer()
        }
        .padding()
        .onChange(of: navigateBackToSelection) { value in
            if value {
                presentationMode.wrappedValue.dismiss() // Dismiss the view when navigation flag is set
            }
        }
    }
}
