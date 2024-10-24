//
//  SpotifyController.swift
//  Moodify
//
//  Created by Paul Shamoon on 09/16/24.

import Foundation
import SpotifyiOS

class SpotifyController: NSObject, ObservableObject, SPTAppRemotePlayerStateDelegate, SPTAppRemoteDelegate {
    
    // Unique Spotify client ID
    private let spotifyClientID = "3dfaae404a2f4847a2ff7d707f7154f4"
    
    // Redirect URL after authorization
    private let spotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    
    // Published property to hold the current track name
    @Published var currentTrackName: String = "No track playing"
    @Published var currentAlbumName: String = ""
    // Variable to store the last known player state
    var isPaused: Bool = false

    // Access token for API requests
    @Published var accessToken: String? = nil
    
    // Spotify App Remote instance
    private lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    private lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )
    
    // Lazy initialization of the playbackController
    private lazy var playbackController: PlaybackController = {
        return PlaybackController(appRemote: appRemote)
    }()
    
    override init() {
        super.init()
        retrieveAccessToken()
    }
    
    // Function to retrieve the access token from UserDefaults
    private func retrieveAccessToken() {
        if let storedAccessToken = UserDefaults.standard.string(forKey: "SpotifyAccessToken") {
            self.accessToken = storedAccessToken
            // Initializes playbackController
            _ = playbackController
            appRemote.connectionParameters.accessToken = storedAccessToken
            playbackController = PlaybackController(appRemote: appRemote)
        } else {
            print("No access token found in UserDefaults")
        }
    }
    
    /*
     Method connects the application to Spotify and or authorizes Moodify
     */
    func connect() {
        if accessToken == nil {
            // Authorizes user and plays passed in URI
            appRemote.authorizeAndPlayURI("")
        } else {
            appRemote.connect()
        }
    }
    
    /*
     Method disconnects the application from Spotify if already connected
     */
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
            // Reset track and album name
            currentTrackName = "No track playing"
            currentAlbumName = ""
        } else {
            print("AppRemote is not connected, no need to disconnect")
        }
    }
    
    // Handle incoming URL after authorization
    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            self.accessToken = accessToken
            appRemote.connectionParameters.accessToken = accessToken
            UserDefaults.standard.set(accessToken, forKey: "SpotifyAccessToken")
            // Connect after setting access token
            appRemote.connect()
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("Error setting access token: \(errorDescription)")
        }
    }
    
    // Delegate method for successful connection
    @objc func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            } else {
                print("Subscribed to player state")
            }
        })
        
        // Fetch the current player state
        self.appRemote.playerAPI?.getPlayerState { (result, error) in
            if let playerState = result as? SPTAppRemotePlayerState {
                self.playerStateDidChange(playerState)
            } else if let error = error {
                print("Error fetching player state: \(error.localizedDescription)")
            }
        }
    }
    
    // Handle connection failure
    @objc func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Failed to connect to Spotify App Remote: \(String(describing: error?.localizedDescription))")
    }
    
    // Handle disconnection
    @objc func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Disconnected from Spotify App Remote: \(String(describing: error?.localizedDescription))")
    }
    
    /*
     Method fetches the changed state of the player and updates data
     Modified by Paul Shamoon on 10/16/2024.
    */
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        DispatchQueue.main.async {
            self.currentTrackName = playerState.track.name
            self.currentAlbumName = playerState.track.album.name
        }
    }
    
    
    /*
     Method plays or pauses the player depending on its current status
     Created by Paul Shamoon on 10/17/2024.
    */
    func togglePlayPause() {
        if isPaused {
            // If isPaused is true, then resume player
            appRemote.playerAPI?.resume()
            isPaused = false
        } else {
            // If isPaused is false, then pause player
            appRemote.playerAPI?.pause()
            isPaused = true
        }
    }
    
    
    /*
     Method skips to the next song in the queue
     Created by Paul Shamoon on 10/17/2024.
    */
    func skipToNext() {
        playbackController.skipToNext()
    }
    
    /*
     Method skips to the previous song in the queue
     Created by Paul Shamoon on 10/17/2024.
    */
    func skipToPrevious() {
        playbackController.skipToPrevious()
    }
    
    /*
     Method to add songs to the queue relating to users detected mood
     
     @param mood: the users detected mood
     
     Created by: Paul Shamoon
     */
    func addSongsToQueue(mood: String) {
        let songs: [String]
        
        switch mood.lowercased() {
            case "happy":
                songs = happy_songs
            case "sad":
                songs = sad_songs
            case "angry":
                songs = angry_songs
            default:
                songs = neutral_songs
        }
        
        // Shuffle the set of songs to maintain a random order
        let shuffledSongs = songs.shuffled()
        
        for (index, uri) in shuffledSongs.enumerated() {
            // Need to add a small delay between requests to prevent rate limiting errors
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                self.appRemote.playerAPI?.enqueueTrackUri("spotify:track:\(uri)", callback: { (result, error) in
                    if let error = error {
                        print("Failed to enqueue song URI \(uri): \(error.localizedDescription)")
                    } else {
                        print("Enqueued song URI: \(uri)")
                    }
                })
            }
        }
    }
}
