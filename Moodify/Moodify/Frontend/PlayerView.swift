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
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.15, green: 0.25, blue: 0.20))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack {
                HStack(spacing: 15) {
                    // Album Cover
                    if let image = spotifyController.albumCover {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .cornerRadius(12)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 24))
                            )
                    }
                    
                    // Track and Artist info with nude background
                    VStack(alignment: .leading) {
                        Text(spotifyController.currentTrackName)
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                            .lineLimit(1)
                        
                        Text(spotifyController.currentArtistName)
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.93, green: 0.87, blue: 0.83))  // Nude color
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
                    
                    Spacer()
                    
                    Button(action: { spotifyController.skipToPrevious() }) {
                        Image(systemName: "backward.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { spotifyController.togglePlayPause() }) {
                        Image(systemName: spotifyController.isPaused ? "play.fill" : "pause.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { spotifyController.skipToNext() }) {
                        Image(systemName: "forward.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        navigateToQueue = true
                    }) {
                        Image(systemName: "music.note.list")
                            .foregroundColor(.white)
                    }
                    .navigationDestination(isPresented: $navigateToQueue) {
                        QueueView(spotifyController: spotifyController)
                            .transition(.blurReplace)
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}


struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(
            spotifyController: SpotifyController()
        )
    }
}
