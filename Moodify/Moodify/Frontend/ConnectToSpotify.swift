import SwiftUI

/*
 A view that displays a button allowing the user to
 connect their Spotify account to the application
 
 Created by Paul Shamoon on 9/12/24.
 */
struct ConnectToSpotifyDisplay: View {
    @ObservedObject var spotifyController: SpotifyController
    @Environment(\.dismiss) var dismiss // Environment property to handle view dismissal

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
        
         // We can access the url when spotift redirects us to Moodify
        .onOpenURL { url in
            // We call setAccessToken passing in the url so it can retrieve the access token from it
            spotifyController.setAccessToken(from: url)
            // This navigates us back to the homepage
            dismiss()
        }
    }
}
