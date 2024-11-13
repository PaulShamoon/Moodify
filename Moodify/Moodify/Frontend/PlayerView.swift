import SwiftUI

/*
 View to display the player
 
 Created By: Paul Shamoon
 */
struct PlayerView: View {
    @ObservedObject var spotifyController: SpotifyController
    @State private var navigateToQueue = false
    @AppStorage("hasConnectedSpotify") private var hasConnectedSpotify = false

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    // Album Cover
                    if let image = spotifyController.albumCover {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 24))
                            )
                    }
                    
                    // Track and Artist info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(spotifyController.currentTrackName)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(spotifyController.currentArtistName)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                        
                        Text(spotifyController.currentAlbumName)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                
                // Playback Controls
                HStack(spacing: 25) {
                    Button(action: { spotifyController.skipToPrevious() }) {
                        Image(systemName: "backward.end.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { spotifyController.seekForwardOrBackward(forward: false) }) {
                        Image(systemName: "gobackward.15")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { spotifyController.togglePlayPause() }) {
                        Image(systemName: spotifyController.isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { spotifyController.seekForwardOrBackward(forward: true) }) {
                        Image(systemName: "goforward.15")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Button(action: { spotifyController.skipToNext() }) {
                        Image(systemName: "forward.end.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: { navigateToQueue = true }) {
                        Image(systemName: "music.note.list")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $navigateToQueue) {
                        QueueView(spotifyController: spotifyController)
                            .presentationDetents([.large]) // Optional: Allows you to control sheet sizes
                    }
                }
                
            }
            .padding()
        }
        .padding()
        
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIScene.didActivateNotification,
                object: nil,
                queue: .main
            ) { _ in
                if hasConnectedSpotify && !spotifyController.isConnected {
                    spotifyController.initializeSpotifyConnection()
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
        }
        .onChange(of: spotifyController.isConnected) { _ in
            spotifyController.updatePlayerState()
        }/*
        */
    }
    
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(
            spotifyController: SpotifyController()
        )
    }
}
