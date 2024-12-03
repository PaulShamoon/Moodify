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
    @State private var refreshID = UUID()
    
    private var groupedPlaylists: [String: [Playlist]] {
        let allPlaylists = spotifyController.playlistManager.getUsersPlaylists(profile: profileManager.currentProfile!)
    
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
        Array(Set(spotifyController.playlistManager.getUsersPlaylists(profile: profileManager.currentProfile!).map { $0.mood })).sorted()
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshPlaylists"))) { _ in
            refreshID = UUID()
        }
        .id(refreshID) // Force refresh when this changes
        .onAppear {
            // Force a refresh of the playlists
            refreshID = UUID()
        }
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
    @State private var songs: [Song]
    var spotifyController: SpotifyController
    @EnvironmentObject var profileManager: ProfileManager
    @ObservedObject var playlistManager: PlaylistManager

    @Environment(\.presentationMode) var presentationMode
    
    init(playlist: Playlist, spotifyController: SpotifyController) {
        self.playlist = playlist
        self._songs = State(initialValue: playlist.songs)
        self.spotifyController = spotifyController
        self.playlistManager = spotifyController.playlistManager
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(playlist.mood.capitalized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("\(songs.count) Songs")
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
                    ForEach(songs) { song in
                        SongRowWithSwipeActions(
                            song: song,
                            playlist: $playlist,
                            songs: $songs,
                            spotifyController: spotifyController
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing),
                                                removal: .slide))
                    }
                }
                .padding(.horizontal)
                .animation(.spring(), value: songs)
            }
        }
        .navigationTitle("Playlist Details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: songs) { newSongs in
            // Sync changes back to the original playlist
            playlist.songs = newSongs
            if let index = playlistManager.playlists.firstIndex(where: { $0.id == playlist.id }) {
                playlistManager.playlists[index].songs = newSongs
                // Force parent view to update when dismissing
                NotificationCenter.default.post(name: NSNotification.Name("RefreshPlaylists"), object: nil)
            }
        }
    }
}

struct SongRowWithSwipeActions: View {
    let song: Song
    @Binding var playlist: Playlist
    @Binding var songs: [Song]
    var spotifyController: SpotifyController
    
    @State private var offset: CGFloat = 0
    @State private var showMessage = false
    @State private var messageText = ""
    @State private var messageColor = Color.green
    @State private var messageAlignment: Alignment = .trailing
    @State private var actionType: ActionType = .remove
    
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Action View
                HStack {
                    VStack {
                        HStack {
                            if actionType == .remove {
                                Spacer()
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.white)
                                    .padding()
                            } else {
                                Image(systemName: song.isFavorited ? "star.slash.fill" : "star.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: 60)
                    .background(actionType == .remove ? Color.red : Color.green)
                }
                
                // Foreground Content with Gesture
                HStack {
                    VStack(alignment: .leading) {
                        Text(song.trackName)
                            .font(.headline)
                        Text(song.artistName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Favorite indicator
                    if song.isFavorited {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.leading, 10)
                .frame(width: geometry.size.width, height: 60)
                .background(Color.black)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let translation = gesture.translation.width
                            
                            // Determine action type based on swipe direction
                            actionType = translation < 0 ? .remove : .favorite
                            
                            // Limit horizontal movement
                            if abs(translation) <= swipeThreshold {
                                offset = translation
                            }
                        }
                        .onEnded { gesture in
                            let translation = gesture.translation.width
                            
                            // Trigger action if swiped past threshold
                            if abs(translation) >= swipeThreshold {
                                performAction(type: actionType)
                            }
                            
                            // Always reset offset
                            withAnimation {
                                offset = 0
                            }
                        }
                )
            }
        }
        .frame(height: 60)
        .animation(.default, value: showMessage)
    }
    
    enum ActionType {
        case favorite
        case remove
    }
    
    private func performAction(type: ActionType) {
        withAnimation(.spring()) {
            switch type {
            case .favorite:
                // Toggle favorite status using PlaylistManager's method
                var mutablePlaylist = playlist
                let success = spotifyController.playlistManager.toggleFavorite(playlist: &mutablePlaylist, song: song)
                
                // Update the local playlist and songs
                playlist = mutablePlaylist
                songs = mutablePlaylist.songs
                
                // Optionally show a message
                showFavoriteMessage(isFavorite: song.isFavorited)

            case .remove:
                var mutablePlaylist = playlist
                let success = spotifyController.playlistManager.removeSongFromPlaylist(playlist: &mutablePlaylist, song: song)
                
                // Update the local playlist and songs
                playlist = mutablePlaylist
                songs = mutablePlaylist.songs
                
                // Show removal message
                showRemovalMessage()
            }
        }
    }
    
    private func showFavoriteMessage(isFavorite: Bool) {
        messageText = isFavorite ? "star.fill" : "star.slash.fill"
        messageColor = .green
        messageAlignment = .trailing
        showMessage = true
        
        // Hide message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showMessage = false
            }
        }
    }
    
    private func showRemovalMessage() {
        messageText = "trash.fill"
        messageColor = .red
        messageAlignment = .trailing
        showMessage = true
        
        // Hide message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showMessage = false
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
