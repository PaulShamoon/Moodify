//
//  PlaylistView.swift
//  Moodify
//
//  Created by Paul Shamoon & Kidd Chang on 11/6/24.
//

import SwiftUI

/*
 View to display the users saved playlists
 
 Created By: Paul Shamoon
 */
struct PlaylistsView: View {
    @ObservedObject var spotifyController: SpotifyController
    @EnvironmentObject var profileManager: ProfileManager
    @State private var searchText = ""
    @State private var selectedMood: String? = nil
    
    private var groupedPlaylists: [String: [Playlist]] {
        let allPlaylists = spotifyController.playlistManager.getMockUsersPlaylists()
    
        let filteredPlaylists = allPlaylists.filter { playlist in
            let matchesMood = selectedMood == nil || playlist.mood == selectedMood
            let matchesSearch = searchText.isEmpty ||
                playlist.mood.localizedCaseInsensitiveContains(searchText) ||
                playlist.songs.contains { song in
                    song.trackName.localizedCaseInsensitiveContains(searchText) ||
                    song.artistName.localizedCaseInsensitiveContains(searchText)
                }
            
            return matchesMood && matchesSearch
        }
        return Dictionary(grouping: filteredPlaylists) { $0.mood }
    }
    
    private var uniqueMoods: [String] {
        Array(Set(spotifyController.playlistManager.getMockUsersPlaylists().map { $0.mood })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if !groupedPlaylists.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button(action: {
                                selectedMood = nil
                            }) {
                                Text("All")
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(selectedMood == nil ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedMood == nil ? .black : .white)
                                    .cornerRadius(20)
                            }
                            
                            ForEach(uniqueMoods, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = mood
                                }) {
                                    Text(mood.capitalized)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(selectedMood == mood ? Color.green : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedMood == mood ? .black : .white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                }
                
                if groupedPlaylists.isEmpty {
                    VStack {
                        Image(systemName: "music.note.list")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No playlists found")
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(groupedPlaylists.keys.sorted(), id: \.self) { mood in
                            VStack() {
                                ForEach(groupedPlaylists[mood]!, id: \.id) { playlist in
                                    NavigationLink(destination: DetailedPlaylistView(playlist: playlist, spotifyController: spotifyController)) {
                                        PlaylistRowView(playlist: playlist)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Playlists")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
}

struct PlaylistRowView: View {
    var playlist: Playlist
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(playlist.mood.capitalized)
                    .font(.headline)
                Text("\(playlist.songs.count) songs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Date Created")
                    .font(.headline)
                Text(formatDate(playlist.dateCreated))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct DetailedPlaylistView: View {
    @State private var playlist: Playlist
    var spotifyController: SpotifyController
    
    @Environment(\.presentationMode) var presentationMode
    
    init(playlist: Playlist, spotifyController: SpotifyController) {
        self.playlist = playlist
        self.spotifyController = spotifyController
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(playlist.mood.capitalized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("\(playlist.songs.count) Songs")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        spotifyController.playlistManager.playPlaylist(playlist: playlist)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green)
                    }
                }
                .padding()
        
                LazyVStack(spacing: 15) {
                    ForEach(playlist.songs) { song in
                        SongRowWithSwipeActions(
                            song: song,
                            playlist: playlist,
                            spotifyController: spotifyController
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Playlist Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SongRowWithSwipeActions: View {
    let song: Song
    @State var playlist: Playlist
    var spotifyController: SpotifyController
    
    @State private var offset: CGFloat = 0
    @State private var showMessage = false
    @State private var messageText = ""
    @State private var messageColor = Color.green
    @State private var messageAlignment: Alignment = .trailing
    
    var body: some View {
        ZStack(alignment: .center) {
            // Main content
            HStack {
                VStack(alignment: .leading) {
                    Text(song.trackName)
                        .font(.headline)
                    Text(song.artistName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .offset(x: offset)
            .zIndex(1)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        if value.translation.width < -100 {
                            // Swipe right to left (favorite)
                            withAnimation(.spring()) {
                                offset = -300
                                messageAlignment = .trailing
                                performAction(type: .favorite)
                            }
                        } else if value.translation.width > 100 {
                            // Swipe left to right (remove)
                            withAnimation(.spring()) {
                                offset = 300
                                messageAlignment = .leading
                                performAction(type: .remove)
                            }
                        } else {
                            // Snap back if not swiped far enough
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
            
            // Message overlay
            if showMessage {
                GeometryReader { geometry in
                    HStack {
                        if messageAlignment == .leading {
                            Text(messageText)
                                .foregroundColor(.white)
                                .padding()
                                .background(messageColor)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        if messageAlignment == .trailing {
                            Text(messageText)
                                .foregroundColor(.white)
                                .padding()
                                .background(messageColor)
                                .cornerRadius(10)
                        }
                    }
                    .frame(width: geometry.size.width)
                }
                .transition(.move(edge: messageAlignment == .leading ? .leading : .trailing))
                .zIndex(0)
            }
        }
        .animation(.default, value: showMessage)
    }
    
    enum ActionType {
        case favorite
        case remove
    }
    
    private func performAction(type: ActionType) {
        switch type {
        case .favorite:
            let success = spotifyController.playlistManager.toggleFavorite(playlist: &playlist, song: song)
            messageText = "Song Favorited!"
            messageColor = .green
        case .remove:
            let success = spotifyController.playlistManager.removeSongFromPlaylist(playlist: &playlist, song: song)
            messageText = "Song Removed"
            messageColor = .red
        }
        
        // Show message
        withAnimation {
            showMessage = true
        }
        
        // Hide message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showMessage = false
                offset = 0
            }
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        return PlaylistsView(spotifyController: SpotifyController())
            .environmentObject(ProfileManager())
    }
}
