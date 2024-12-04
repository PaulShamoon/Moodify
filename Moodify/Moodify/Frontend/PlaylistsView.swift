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
            ScrollView {
                VStack(spacing: 20) {
                    if !groupedPlaylists.isEmpty {
                        // Mood Filter Section
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                MoodFilterButton(title: "All", isSelected: selectedMood == nil) {
                                    selectedMood = nil
                                }
                                
                                ForEach(uniqueMoods, id: \.self) { mood in
                                    MoodFilterButton(title: mood.capitalized, isSelected: selectedMood == mood) {
                                        selectedMood = mood
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 10)
                        
                        // Playlists Section
                        ForEach(groupedPlaylists.keys.sorted(), id: \.self) { mood in
                            VStack(alignment: .leading, spacing: 15) {
                                Text(mood.capitalized)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#F5E6D3"))
                                    .padding(.horizontal)
                                
                                ForEach(groupedPlaylists[mood]!, id: \.id) { playlist in
                                    NavigationLink(
                                        destination: DetailedPlaylistView(
                                            playlist: playlist,
                                            spotifyController: spotifyController
                                        )
                                    ) {
                                        PlaylistCard(playlist: playlist)
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    } else {
                        EmptyPlaylistView()
                    }
                }
                .padding(.vertical)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#1A2F2A"), Color(hex: "#243B35")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationTitle("My Playlists")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshPlaylists"))) { _ in
            refreshID = UUID()
        }
        .id(refreshID)
    }
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
}


struct DetailedPlaylistView: View {
    @State private var playlist: Playlist
    @State private var songs: [Song]
    var spotifyController: SpotifyController
    @EnvironmentObject var profileManager: ProfileManager
    @ObservedObject var playlistManager: PlaylistManager
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0
    private let songsPerPage = 10
    
    init(playlist: Playlist, spotifyController: SpotifyController) {
        self.playlist = playlist
        self._songs = State(initialValue: playlist.songs)
        self.spotifyController = spotifyController
        self.playlistManager = spotifyController.playlistManager
    }
    private var totalPages: Int {
        Int(ceil(Double(songs.count) / Double(songsPerPage)))
    }
    
    private var paginatedSongs: [Song] {
        let startIndex = currentPage * songsPerPage
        let endIndex = min(startIndex + songsPerPage, songs.count)
        return Array(songs[startIndex..<endIndex])
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                PlaylistHeaderCard(
                    playlist: playlist,
                    songsCount: songs.count,
                    onPlay: {
                        spotifyController.playlistManager.playPlaylist(playlist: playlist)
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                
                // Pagination Indicator
                if totalPages > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { page in
                            Circle()
                                .fill(currentPage == page ?
                                    Color(hex: "4ADE80") :
                                    Color(hex: "#F5E6D3").opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Songs List
                VStack(spacing: 12) {
                    ForEach(paginatedSongs) { song in
                        SongRow(
                            song: song,
                            playlist: $playlist,
                            songs: $songs,
                            spotifyController: spotifyController
                        )
                    }
                }
                
                // Pagination Controls
                if totalPages > 1 {
                    HStack {
                        if currentPage > 0 {
                            PaginationButton(direction: .previous) {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if currentPage < totalPages - 1 {
                            PaginationButton(direction: .next) {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#1A2F2A"), Color(hex: "#243B35")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("Playlist Details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: songs) { newSongs in
            playlist.songs = newSongs
            if let index = playlistManager.playlists.firstIndex(where: { $0.id == playlist.id }) {
                playlistManager.playlists[index].songs = newSongs
                NotificationCenter.default.post(name: NSNotification.Name("RefreshPlaylists"), object: nil)
            }
        }
    }
    
    
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mood")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text(playlist.mood.capitalized)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Genres")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text(playlist.genres.joined(separator: ", "))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Text("\(songs.count) Songs")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var playButton: some View {
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
    
}


// Playlist Card Component
struct PlaylistCard: View {
    let playlist: Playlist
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(playlist.mood.capitalized)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E6D3"))
                    
                    Text("\(playlist.songs.count) songs")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Created")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                    Text(formatDate(playlist.dateCreated))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E6D3"))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(white: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#F5E6D3").opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}
// Empty State View
struct EmptyPlaylistView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text("No playlists created yet")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#F5E6D3"))
            
            Text("Detect your mood to generate your playlists")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#F5E6D3").opacity(0.1), lineWidth: 1)
                )
        )
        .padding()
    }
}

// Playlist Header Card
struct PlaylistHeaderCard: View {
    let playlist: Playlist
    let songsCount: Int
    let onPlay: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mood")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                    Text(playlist.mood.capitalized)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#F5E6D3"))
                }
                
                Spacer()
                
                Button(action: onPlay) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Genres")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                Text(playlist.genres.joined(separator: ", "))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3"))
            }
            
            Text("\(songsCount) Songs")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(white: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#F5E6D3").opacity(0.1), lineWidth: 1)
                )
        )
    }
}
struct SongRow: View {
    let song: Song
    @Binding var playlist: Playlist
    @Binding var songs: [Song]
    var spotifyController: SpotifyController
    
    @State private var isPressed = false
    @State private var showingOptions = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(song.trackName)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3"))
                Text(song.artistName)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
            }
            
            Spacer()
            
            if song.isFavorited {
                Image(systemName: "star.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isPressed ?
                    Color(hex: "243B35") : // Darker when pressed
                    Color(white: 0.15)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isPressed ?
                        LinearGradient(
                            colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) : LinearGradient(
                            colors: [Color.clear, Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isPressed ? 2.5 : 1.5 // Thicker border when pressed
                       )
        )
        .scaleEffect(scale)
        .gesture(
            LongPressGesture(minimumDuration: 0.2) // Made slightly faster
                .onChanged { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { // Faster animation
                        isPressed = true
                        scale = 0.97 // Less scale to keep content more readable
                    }
                    hapticFeedback()
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isPressed = false
                        scale = 1.0
                    }
                    showingOptions = true
                }
        )

        .confirmationDialog("Song Options", isPresented: $showingOptions) {
            Button(song.isFavorited ? "Remove from Favorites" : "Add to Favorites") {
                var mutablePlaylist = playlist
                _ = spotifyController.playlistManager.toggleFavorite(playlist: &mutablePlaylist, song: song)
                playlist = mutablePlaylist
                songs = mutablePlaylist.songs
            }
            
            Button("Remove from Playlist", role: .destructive) {
                var mutablePlaylist = playlist
                _ = spotifyController.playlistManager.removeSongFromPlaylist(playlist: &mutablePlaylist, song: song)
                playlist = mutablePlaylist
                songs = mutablePlaylist.songs
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
// Pagination Control Button
struct PaginationButton: View {
    enum Direction {
        case previous
        case next
    }
    
    let direction: Direction
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if direction == .previous {
                    Image(systemName: "chevron.left")
                }
                
                Text(direction == .previous ? "Previous" : "Next")
                
                if direction == .next {
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}
struct MoodFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .black : Color(hex: "#F5E6D3"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            // For MoodFilterButton
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ?
                              LinearGradient(
                                colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                                startPoint: .leading,
                                endPoint: .trailing
                              ) : LinearGradient(
                                colors: [Color(white: 0.15), Color(white: 0.15)],
                                startPoint: .leading,
                                endPoint: .trailing
                              )
                             )
                )
        }
    }
}
