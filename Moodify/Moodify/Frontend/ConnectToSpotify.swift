import SwiftUI

/*
 A view that displays a button allowing the user to
 connect their Spotify account to the application
 
 Created by Paul Shamoon on 9/12/24.
 */
struct ConnectToSpotifyDisplay: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose your streaming provider to continue")
                .font(.title2)
                .multilineTextAlignment(.center) // Centers the text
                .padding(.bottom, 10)
            
            Button(action: {
                // This will be where we call some function to actually connect to spotify later
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
                .foregroundColor(Color.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}
