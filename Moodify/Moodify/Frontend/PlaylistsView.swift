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
                            Section() {
                                ForEach(groupedPlaylists[mood]!, id: \.id) { playlist in
                                    NavigationLink(destination: DetailedPlaylistView(playlist: playlist, spotifyController: spotifyController)) {
                                        PlaylistRowView(playlist: playlist)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("My Playlists")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy, HH:mm:ss" // Customize the format as needed
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
    var playlist: Playlist
    var spotifyController: SpotifyController
    
    @Environment(\.presentationMode) var presentationMode
    
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
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Playlist Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        return PlaylistsView(spotifyController: SpotifyController())
            .environmentObject(ProfileManager())
    }
}
