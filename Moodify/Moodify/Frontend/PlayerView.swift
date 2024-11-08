import SwiftUI

/*
 View to display the player
 
 Created By: Paul Shamoon
 */
struct PlayerView: View {
    @ObservedObject var spotifyController: SpotifyController
    @State private var navigateToQueue = false
    @AppStorage("hasConnectedSpotify") private var hasConnectedSpotify = false
    @State private var showResyncButton = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.96, green: 0.87, blue: 0.70))
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(spotifyController.currentTrackName)
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                        
                        Text(spotifyController.currentArtistName)
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                    }
                    Spacer()
                    
                    Button(action: { spotifyController.skipToPrevious() }) {
                        Image(systemName: "backward.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                            .foregroundColor(.black)
                    }
                    
                    Button(action: { spotifyController.togglePlayPause() }) {
                        Image(systemName: spotifyController.isPaused ? "play.fill" : "pause.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                            .foregroundColor(.black)
                    }
                    
                    Button(action: { spotifyController.skipToNext() }) {
                        Image(systemName: "forward.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                            .foregroundColor(.black)
                    }
                    
                    // Button to toggle queue visibility
                    Button(action: {
                        navigateToQueue = true
                    }) {
                        Image(systemName: "music.note.list")
                            .foregroundColor(.black)
                    }
                    .navigationDestination(isPresented: $navigateToQueue) {
                        QueueView(spotifyController: spotifyController)
                            .transition(.blurReplace)
                    }
                }
                
                // Resync button with dynamic visibility based on connection status
                if showResyncButton {
                    Button(action: {
                        // First call to ensureSpotifyConnection
                        spotifyController.ensureSpotifyConnection()
                        
                        // Second call to ensureSpotifyConnection after 4 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            spotifyController.ensureSpotifyConnection()
                        }
                        
                    }) {
                        Text("Resync")
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .padding()
        
        // Initial check on view appearance
        .onAppear {
            if !spotifyController.isConnected && hasConnectedSpotify {
                updateResyncButtonVisibility()
            }
        }
        
        // React to changes in connection status
        .onChange(of: spotifyController.isConnected) { _ in
            updateResyncButtonVisibility()

        }
        
        // React to changes in hasConnectedSpotify value
        .onChange(of: hasConnectedSpotify) { _ in
            updateResyncButtonVisibility()
        }
    }
    
    private func updateResyncButtonVisibility() {
        showResyncButton = !spotifyController.isConnected && hasConnectedSpotify
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(
            spotifyController: SpotifyController()
        )
    }
}
