//
//  PlaylistView.swift
//  Moodify
//
//  Created by Paul Shamoon on 11/6/24.
//

import SwiftUI

/*
 View to display the users saved playlists
 
 Created By: Paul Shamoon
 */
struct PlaylistsView: View {
    @ObservedObject var spotifyController: SpotifyController
    @EnvironmentObject var profileManager: ProfileManager
    
    var body: some View {
        VStack {
            let userPlaylists = spotifyController.playlistManager.getUsersPlaylists(profile: profileManager.currentProfile!)
            
            if userPlaylists.isEmpty {
                Text("No playlists created")
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            } else {
                // Swipeable Playlist Cards using TabView
                SwipeablePlaylistView(playlists: userPlaylists, spotifyController: spotifyController)
            }
        }
        .padding()
    }
}

/*
 SwipeablePlaylistView displays a horizontally swipeable collection of playlist cards.
 
 
 @param playlist: An array of Playlist objects to display.
 @param spotifyController: The SpotifyController used to handle interactions with Spotify.
 
 Created By: Paul Shamoon
 */
struct SwipeablePlaylistView: View {
    // Current index of what playlist card the user is on
    @State private var selectedIndex: Int = 0
    
    // Array to store the users playlists
    var playlists: [Playlist]
    
    var spotifyController: SpotifyController
    
    var body: some View {
        // TabView with PageTabViewStyle for swipeable cards
        TabView(selection: $selectedIndex) {
            ForEach(self.playlists.indices, id: \.self) { index in
                PlaylistCard(playlist: self.playlists[index], spotifyController: self.spotifyController)
                    // Ensure each card is tagged for proper page index
                    .tag(index)
            }
        }
        
        // Defines the style for the TabView
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        
        // Padding to define the size of the card
        .padding(.horizontal, 20)
    }
}

/*
 View to contruct each individual playlist card
 
 @param playlist: A single Playlist object to display in a card.
 @param spotifyController: The SpotifyController used to handle interactions with Spotify.
 
 Created By: Paul Shamoon
 */
struct PlaylistCard: View {
    // The playlist to display in the card
    var playlist: Playlist
    
    var spotifyController: SpotifyController
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(playlist.mood.prefix(1).capitalized + playlist.mood.dropFirst())
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(hex: "#F5E6D3"))
                
                Spacer()
                
                Button(action: {
                    spotifyController.playlistManager.playPlaylist(playlist: playlist)
                    // After selecting a playlist to play, return to the homePageView
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "play.fill")
                        .font(.title)
                        // Set the play icon to be black
                        .foregroundColor(.black)
                        // Padding to increase size of circle
                        .padding(16)
                        // Add a green background to the circle
                        .background(Circle().fill(Color.green))
                }
            }
            
            Divider().background(Color(hex: "#F5E6D3"))
            
            // ScrollView enables songs to be scrolled through
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(playlist.songs) { song in
                        VStack(alignment: .leading) {
                            Text(song.trackName)
                                .font(.body)
                                .foregroundColor(.black)
                            
                            Text(song.artistName)
                                .font(.footnote)
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 3)
                    }
                }
                // Ensures that the song list is aligned to the left
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            // Increases the verticle length of the song list
            .frame(maxHeight: 400)
            // Adds a bit of space between the song list and end of card
            .padding(.bottom, 10)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}
