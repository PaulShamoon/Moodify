//
//  SpotifyOnboardingView.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 11/30/24.
//

// import SwiftUI

// struct SpotifyOnboardingView: View {
//     @StateObject var spotifyController: SpotifyController
//     @Environment(\.dismiss) private var dismiss
//     let onCompletion: () -> Void
    
//     @State private var isConnecting = false
//     @State private var showError = false
//     @State private var errorMessage = ""
//     @State private var showSuccessMessage = false
    
//     init(spotifyController: SpotifyController = SpotifyController(), onCompletion: @escaping () -> Void) {
//         _spotifyController = StateObject(wrappedValue: spotifyController)
//         self.onCompletion = onCompletion
//     }
    
//     var body: some View {
//         ZStack {
//             // Background gradient
//             LinearGradient(
//                 gradient: Gradient(colors: [
//                     Color(hex: "#1A1A2E"),
//                     Color(hex: "#16213E")
//                 ]),
//                 startPoint: .topLeading,
//                 endPoint: .bottomTrailing
//             )
//             .ignoresSafeArea()
            
//             // Floating circles background animation
//             ForEach(0..<15) { _ in
//                 Circle()
//                     .fill(Color.white.opacity(0.05))
//                     .frame(width: CGFloat.random(in: 50...120))
//                     .position(
//                         x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
//                         y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
//                     )
//             }
            
//             VStack(spacing: 40) {
//                 Spacer()
                
//                 // Spotify Logo
//                 Image(systemName: "music.note.list")
//                     .font(.system(size: 80))
//                     .foregroundColor(.white)
                
//                 VStack(spacing: 16) {
//                     Text("One Last Step")
//                         .font(.system(size: 34, weight: .bold))
//                         .foregroundColor(.white)
                    
//                     Text("Connect your Spotify account\nto start your personalized experience")
//                         .font(.system(size: 18))
//                         .foregroundColor(.white.opacity(0.8))
//                         .multilineTextAlignment(.center)
//                 }
                
//                 Spacer()
                
//                 // Connect button
//                 Button(action: {
//                     connectToSpotify()
//                 }) {
//                     HStack(spacing: 12) {
//                         if isConnecting {
//                             ProgressView()
//                                 .tint(.black)
//                         } else {
//                             Image(systemName: "music.note")
//                         }
//                         Text(isConnecting ? "Connecting..." : "Connect with Spotify")
//                             .font(.headline)
//                     }
//                     .foregroundColor(.black)
//                     .frame(maxWidth: .infinity)
//                     .padding(.vertical, 16)
//                     .background(Color(hex: "#1DB954").opacity(isConnecting ? 0.7 : 1))
//                     .cornerRadius(12)
//                 }
//                 .disabled(isConnecting)
//                 .padding(.horizontal, 40)
                
//                 // Skip button
//                 Button(action: {
//                     dismiss()
//                     onCompletion()
//                 }) {
//                     Text("Skip for now")
//                         .font(.system(size: 16))
//                         .foregroundColor(.white.opacity(0.6))
//                 }
//                 .padding(.bottom, 50)
//             }
//         }
//         .alert("Connection Error", isPresented: $showError) {
//             Button("Try Again") {
//                 connectToSpotify()
//             }
//             Button("Cancel", role: .cancel) { }
//         } message: {
//             Text(errorMessage)
//         }
//         .alert("Successfully Connected", isPresented: $showSuccessMessage) {
//             Button("Continue") {
//                 dismiss()
//                 onCompletion()
//             }
//         } message: {
//             Text("Your Spotify account has been connected successfully!")
//         }
//     }
    
//     private func connectToSpotify() {
//         isConnecting = true
        
//         Task {
//             do {
//                 try await spotifyController.connect()
//                 await MainActor.run {
//                     isConnecting = false
//                     showSuccessMessage = true
//                 }
//             } catch {
//                 await MainActor.run {
//                     isConnecting = false
//                     errorMessage = error.localizedDescription
//                     showError = true
//                 }
//             }
//         }
//     }
// }
// struct SpotifyConnectSheet: View {
//     @StateObject var spotifyController: SpotifyController
//     @Binding var isPresented: Bool
//     @State private var isConnecting = false
//     @State private var showError = false
//     @State private var errorMessage = ""
//     @State private var showSuccessMessage = false
    
//     var body: some View {
//         VStack(spacing: 0) {
//             // Pull indicator
//             RoundedRectangle(cornerRadius: 2.5)
//                 .fill(Color.white.opacity(0.3))
//                 .frame(width: 36, height: 5)
//                 .padding(.top, 8)
//                 .padding(.bottom, 20)
            
//             VStack(spacing: 40) {
//                 // Spotify Logo and text
//                 VStack(spacing: 16) {
//                     Image(systemName: "music.note.list")
//                         .font(.system(size: 60))
//                         .foregroundColor(.white)
                    
//                     VStack(spacing: 8) {
//                         Text("Connect to Spotify")
//                             .font(.system(size: 24, weight: .bold))
//                             .foregroundColor(.white)
                        
//                         Text("Enhance your experience with\npersonalized music recommendations")
//                             .font(.system(size: 16))
//                             .foregroundColor(.white.opacity(0.8))
//                             .multilineTextAlignment(.center)
//                     }
//                 }
                
//                 // Connect button
//                 Button(action: {
//                     connectToSpotify()
//                 }) {
//                     HStack(spacing: 12) {
//                         if isConnecting {
//                             ProgressView()
//                                 .tint(.black)
//                         } else {
//                             Image(systemName: "music.note")
//                                 .font(.system(size: 16))
//                         }
//                         Text(isConnecting ? "Connecting..." : "Connect with Spotify")
//                             .font(.system(size: 16, weight: .medium))
//                     }
//                     .foregroundColor(.black)
//                     .frame(maxWidth: .infinity)
//                     .padding(.vertical, 16)
//                     .background(
//                         RoundedRectangle(cornerRadius: 12)
//                             .fill(Color(hex: "#1A2F2A"))
//                             .overlay(
//                                 RoundedRectangle(cornerRadius: 12)
//                                     .stroke(Color.white.opacity(0.1), lineWidth: 1)
//                             )
//                     )
//                 }
//                 .disabled(isConnecting)
//                 .padding(.horizontal, 24)
                
//                 // Maybe later button
//                 Button(action: {
//                     withAnimation {
//                         isPresented = false
//                     }
//                 }) {
//                     Text("Maybe Later")
//                         .font(.system(size: 16))
//                         .foregroundColor(.white.opacity(0.6))
//                 }
//                 .padding(.bottom, 30)
//             }
//         }
//         .padding(.top, 8)
//         .background(
//             RoundedRectangle(cornerRadius: 24)
//                 .fill(Color(hex: "#1A1A2E"))
//                 .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
//         )
//         .alert("Connection Error", isPresented: $showError) {
//             Button("Try Again") {
//                 connectToSpotify()
//             }
//             Button("Cancel", role: .cancel) { 
//                 withAnimation {
//                     isPresented = false
//                 }
//             }
//         } message: {
//             Text(errorMessage)
//         }
//         .alert("Successfully Connected", isPresented: $showSuccessMessage) {
//             Button("Great!") {
//                 withAnimation {
//                     isPresented = false
//                 }
//             }
//         } message: {
//             Text("Your Spotify account has been connected successfully!")
//         }
//     }
    
//     private func connectToSpotify() {
//         isConnecting = true
        
//         Task {
//             do {
//                 try await spotifyController.connect()
//                 await MainActor.run {
//                     isConnecting = false
//                     showSuccessMessage = true
//                 }
//             } catch {
//                 await MainActor.run {
//                     isConnecting = false
//                     errorMessage = error.localizedDescription
//                     showError = true
//                 }
//             }
//         }
//     }
// }