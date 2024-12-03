import SwiftUI

/*
 A view that displays a button allowing the user to
 connect their Spotify account to the application
 
 Created by Paul Shamoon on 9/12/24.
 Updated by Nazanin on 12/03/24
 */
struct ConnectToSpotifyView: View {
    @ObservedObject var spotifyController: SpotifyController
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasConnectedSpotify") private var hasConnectedSpotify = false
    
    // Add animation state
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(hex: "0A2F23"),
                    Color(hex: "0A2F23")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 20)
                .offset(x: -50, y: -100)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
            
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 20)
                .offset(x: 50, y: 100)
                .scaleEffect(isAnimating ? 0.8 : 1.2)
            
            // Main content
            VStack(spacing: 30) {
                Spacer()
                
                Image("SpotifyLogo")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .aspectRatio(contentMode: .fit)
                    .shadow(color: Color(hex: "22C55E").opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 20)
                
                Button(action: {
                    print("button pressed")
                    spotifyController.initializeSpotifyConnection()
                }) {
                    HStack(spacing: 12) {
                        Text("Connect with Spotify")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .lineLimit(1)
                    }
                    .foregroundColor(Color(hex: "#F5E6D3"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#1A2F2A"), Color(hex: "#243B35")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(
                        color: Color(hex: "#243B35").opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
        // We can access the url when spotify redirects us to Moodify
        .onOpenURL { url in
            print("Received Spotify redirect URL")
            spotifyController.setAccessToken(from: url)
            
            // Only set hasConnectedSpotify and dismiss if we got a valid token
            if spotifyController.accessToken != nil {
                print("Successfully connected to Spotify")
                hasConnectedSpotify = true
                dismiss()
            } else {
                print("Failed to get valid token from Spotify")
            }
        }
        .onChange(of: spotifyController.accessToken) { newToken in
            if newToken != nil {
                print("Access token updated, dismissing view")
                hasConnectedSpotify = true
                dismiss()
            }
        }
    }
}

#Preview("Connect to Spotify View") {
    ConnectToSpotifyView(spotifyController: SpotifyController())
        .preferredColorScheme(.dark)
}
