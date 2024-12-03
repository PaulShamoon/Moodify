import SwiftUI

struct PinInputView: View {
    let profile: Profile
    @EnvironmentObject var profileManager: ProfileManager
    @State private var enteredPin: String = ""
    @State private var showError: Bool = false
    @State private var showingForgotPin: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateBackToSelection: Bool = false
    var onPinEntered: (String) -> Void
    
    private let backgroundColor = Color.black
    private let accentColor = Color.green
    private let secondaryColor = Color(white: 0.2)
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 10)
                
                if showError {
                    Text("Incorrect PIN. Please try again.")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .transition(.opacity)
                        .padding(.top, 155)
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 12) {
                    Text("Enter your PIN")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                // PIN Display
                HStack(spacing: 20) {
                    ForEach(0..<4) { index in
                        Circle()
                            .stroke(accentColor, lineWidth: 2)
                            .background(
                                Circle()
                                    .fill(enteredPin.count > index ? accentColor : .clear)
                            )
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.vertical, 32)
                
                // Custom Number Pad
                VStack(spacing: 16) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 24) {
                            ForEach(1...3, id: \.self) { col in
                                let number = row * 3 + col
                                NumberButton(number: "\(number)") {
                                    appendPin(number: "\(number)")
                                }
                            }
                        }
                    }
                    
                    HStack(spacing: 24) {
                        // Empty space for alignment
                        Color.clear
                            .frame(width: 72, height: 72)
                        
                        NumberButton(number: "0") {
                            appendPin(number: "0")
                        }
                        
                        // Delete button
                        NumberButton(number: "DEL", isSpecial: true) {
                            if !enteredPin.isEmpty {
                                enteredPin.removeLast()
                                showError = false
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Forgot PIN Button
                Button(action: {
                    showingForgotPin = true
                }) {
                    Text("Forgot PIN?")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E6D3"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "1A2F2A"), Color(hex: "243B35")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(35)
                        .shadow(
                            color: Color.black.opacity(0.2),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .padding()
        }
        .sheet(isPresented: $showingForgotPin) {
            ForgotPinView(navigateBackToSelection: $navigateBackToSelection, profile: profile)
                .environmentObject(profileManager)
        }
        .onChange(of: navigateBackToSelection) { value in
            if value {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            profileManager.loadProfiles()
        }
    }
    
    // Helper function to handle PIN input and auto-submit
    private func appendPin(number: String) {
        if enteredPin.count < 4 {
            enteredPin += number
            showError = false
            
            // Auto-submit when 4 digits are entered
            if enteredPin.count == 4 {
                onPinEntered(enteredPin)
                enteredPin = ""
                showError = true
            }
        }
    }
}

struct NumberButton: View {
    let number: String
    var isSpecial: Bool = false
    let action: () -> Void
    
    private let buttonSize: CGFloat = 72
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1A2F2A"), Color(hex: "243B35")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(
                        color: Color.black.opacity(0.2),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
                
                Text(number)
                    .font(.system(size: isSpecial ? 20 : 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3"))
            }
        }
        .buttonStyle(NumberButtonStyle())
    }
}

struct NumberButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

