import SwiftUI

/*
 A view that displays a button allowing the user to
 connect their Spotify account to the application
 
 Created by Paul Shamoon on 9/12/24.
 Updated by [Assistant] on 11/04/24
 */
struct ConnectToSpotifyView: View {
    @ObservedObject var spotifyController: SpotifyController
    @Environment(\.dismiss) var dismiss // Environment property to handle view dismissal
    @AppStorage("hasConnectedSpotify") private var hasConnectedSpotify = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose your streaming provider to continue")
                .font(.title2)
                .multilineTextAlignment(.center) // Centers the text
                .padding(.bottom, 10)
            
            Button(action: {
                print("button pressed")
                spotifyController.connect()
            }) {
                HStack(spacing: 0) {
                    Text("Connect with")
                        .font(.headline)
                    
                    Image("SpotifyLogo")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .aspectRatio(contentMode: .fit)
                    
                    Text("Spotify")
                        .font(.headline)
                }
                .padding()
                .background(Color.green)
                .foregroundColor(Color.black)
                .cornerRadius(10)
            }
        }
        .padding()
        
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
