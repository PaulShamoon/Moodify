//
//  Player.swift
//  Moodify
//
//  Created by Paul Shamoon on 10/29/24.
//

import SwiftUI

/*
 View to display the player
 
 Created By: Paul Shamoon
 */
struct PlayerView: View {
    @ObservedObject var spotifyController: SpotifyController
    @State private var navigateToQueue = false
    
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
                HStack(spacing: 32) {
                    Button(action: { spotifyController.skipToPrevious() }) {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { spotifyController.togglePlayPause() }) {
                        Image(systemName: spotifyController.isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { spotifyController.skipToNext() }) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: { navigateToQueue = true }) {
                        Image(systemName: "music.note.list")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .frame(height: 160)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationDestination(isPresented: $navigateToQueue) {
            QueueView(spotifyController: spotifyController)
                .transition(.blurReplace)
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(
            spotifyController: SpotifyController()
        )
    }
}
