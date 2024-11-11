//
//  PlaylistManager.swift
//  Moodify
//
//  Created by Paul Shamoon on 11/5/24.
//

import Foundation

class PlaylistManager: ObservableObject {
    @Published var playlists: [Playlist] = []
    private var appRemote: SPTAppRemote?
    private var queueManager: QueueManager
    private var spotifyController: SpotifyController // Reference to the spotifyController


    init(appRemote: SPTAppRemote? = nil, queueManager: QueueManager, spotifyController: SpotifyController) {
        self.appRemote = appRemote // Initialize appRemote
        self.queueManager = queueManager
        self.spotifyController =  spotifyController
        loadPlaylists() // Call the method after all properties are initialized
    }
    
    /*
     Method to update or create a playlist for the specified profile
     
     @param mood: The mood the playlist is being created for
     @param profile: The profile who the playlist will belong to
     @param songs: An array of "Song" objects that make up the playlist
     
     Created By: Paul Shamoon
     */
    func updateOrCreatePlaylist(mood: String, profile: Profile, songs: [Song]) {
        guard !songs.isEmpty else {
            print("Songs were empty, not creating a playlist.")
            return
        }
        
        var combined_mood: String
        switch mood {
        case "happy", "surprise":
            combined_mood = "happy"
        case "sad", "disgust", "fear":
            combined_mood = "sad"
        default:
            combined_mood = mood
        }
        
        if let index = playlists.firstIndex(where: { $0.profileId == profile.id && $0.mood == combined_mood }) {
            playlists[index].songs = songs
            playlists[index].dateCreated = Date()
            print("Playlist updated for \(profile.name) with mood: \(combined_mood).")
        } else {
            let newPlaylist = Playlist(mood: combined_mood, profileId: profile.id, songs: songs)
            playlists.append(newPlaylist)
            print("New playlist created for \(profile.name) with mood: \(combined_mood).")
        }
        savePlaylists()
    }
    
    
    /*
     Method to get all playlists belonging to the passed in profile
     
     @param profile: The profile of the user who's playlists to get
     @return: All playlists belonging to the user
     
     Created By: Paul Shamoon
     */
    func getUsersPlaylists(profile: Profile) -> [Playlist] {
        // Filter playlists by the profile's ID to get all playlists for the given profile
        return playlists.filter { $0.profileId == profile.id }
    }
    
    
    /*
     Method to queue all songs in the passed in playlist
     
     @param playlist: The playlist to be played
     
     Created By: Paul Shamoon
     */
    func playPlaylist(playlist: Playlist) {
        spotifyController.reconnectAndExecute({
            // Clear currentQueue before queueing the playlist's songs
            self.spotifyController.clearCurrentQueue()
            
            for (index, track) in playlist.songs.enumerated() {
                let uri = track.songURI
                
                // Add a small delay between requests to prevent rate limiting
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                    // If it's the first song, play it immediately to prevent Spotify from playing a random song
                    if index == 0 {
                        self.appRemote?.playerAPI?.play(uri)
                    } else {
                        // Add the song to the queue
                        self.appRemote?.playerAPI?.enqueueTrackUri(uri, callback: { (result, error) in
                            if let error = error {
                                print("Failed to enqueue song URI \(uri): \(error.localizedDescription)")
                            } else {
                                print("Enqueued song URI: \(uri)")
                            }
                            // Update the currentQueue with the songs from the playlist that we enqueue
                            self.spotifyController.currentQueue = self.queueManager.addSongToQueue(song: track)
                        })
                    }
                }
            }
        })  // Using a 10-second delay for reconnect if needed
    }

    
    
    /*
     Method to save all users playlists
     
     Created By: Paul Shamoon
     */
    private func savePlaylists() {
        do {
            let encoded = try JSONEncoder().encode(playlists)
            UserDefaults.standard.set(encoded, forKey: "savedPlaylists")
        } catch {
            print("Failed to save playlists: \(error.localizedDescription)")
        }
    }

    
    /*
     Method to load all the users playlists
     
     Created By: Paul Shamoon
     */
    private func loadPlaylists() {
        guard let data = UserDefaults.standard.data(forKey: "savedPlaylists") else { return }
        
        do {
            playlists = try JSONDecoder().decode([Playlist].self, from: data)
        } catch {
            print("Failed to load playlists: \(error.localizedDescription)")
        }
    }
}
