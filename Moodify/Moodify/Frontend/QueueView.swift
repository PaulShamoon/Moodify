//
//  QueueView.swift
//  Moodify
//
//  Created by Paul Shamoon on 10/30/24.
//

import SwiftUI

/*
 View to display the currentQueue
 
 Created By: Paul Shamoon
 */
struct QueueView: View {
    @ObservedObject var spotifyController: SpotifyController

    // Environment property to handle view dismissal
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: {
                    // Dismiss the view to return back to the home page
                    dismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.leading)
                }
                
                // Pushes the text and remaining space to the center
                Spacer()
                
                Text("Queue")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                Spacer()
            }
            Divider()
                .background(Color.gray)

            Text("Now Playing:")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack {                
                VStack(alignment: .leading) {
                    Text(spotifyController.currentTrackName)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                    Text(spotifyController.currentAlbumName)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.leading, 10)

                }
                .padding(.leading, 10)
            }
            
            Divider()
                .background(Color.gray)
            
            HStack {
                Text("Next in Queue:")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Spacer to push the "Clear Queue" button to the right
                Spacer()
                
                Button(action: {
                    spotifyController.clearCurrentQueue()
                }) {
                    Text("Clear queue")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
            }

            // Check if currentQueue is empty
            if spotifyController.currentQueue.isEmpty {
                Text("No songs queued")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(spotifyController.currentQueue) { song in
                    VStack(alignment: .leading) {
                        Button(action: {
                            spotifyController.playSongFromQueue(song: song)
                        }) {
                        Text(song.trackName)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(song.artistName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                                            }
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        
        // Hides the default back button
        .navigationBarBackButtonHidden(true)
    }
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView(spotifyController: SpotifyController())
    }
}
