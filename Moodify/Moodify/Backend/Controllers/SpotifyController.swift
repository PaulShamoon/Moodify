//
//  SpotifyController.swift
//  Moodify
//
//  Created by Paul Shamoon on 09/16/24.

import Foundation
import SpotifyiOS

class SpotifyController: NSObject, ObservableObject, SPTAppRemotePlayerStateDelegate, SPTAppRemoteDelegate {
    
    var isFirstConnectionAttempt = true

    // Tracks if reconnect was attempted
    private var reconnectAttempted = false
    
    @Published private(set) var isConnected: Bool = false
    
    // Stores token expiration
    var tokenExpirationDate: Date? {
        get {
            if let timestamp = UserDefaults.standard.object(forKey: "SpotifyTokenExpiration") as? TimeInterval {
                return Date(timeIntervalSince1970: timestamp)
            }
            return nil
        }
        set {
            UserDefaults.standard.set(newValue?.timeIntervalSince1970, forKey: "SpotifyTokenExpiration")
        }
    }
    
    // Reset retry counter
    var retryCount = 0
    
    // Unique Spotify client ID
    private let spotifyClientID = "3dfaae404a2f4847a2ff7d707f7154f4"
    
    // Redirect URL after authorization
    private let spotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    
    // Initialize the MoodHandler
    private let moodQueueHandler = MoodQueueHandler()
    
    // Scopes for Spotify access
    private let spotifyScopes = "user-read-private user-read-email playlist-modify-public playlist-modify-private"
    
    // Published properties to hold info about the current track
    @Published var currentTrackName: String = "No track playing"
    @Published var currentTrackURI: String = ""
    @Published var currentAlbumName: String = ""
    @Published var currentArtistName: String = ""
    @Published var albumCover: UIImage? = nil
    
    // Access token for API requests
    @Published var accessToken: String? {
        didSet {
            appRemote.connectionParameters.accessToken = accessToken
        }
    }
    
    @Published var currentPlaylist: Playlist? = nil
    
    // Array of "Song" objects to hold the state of the queue
    @Published var currentQueue: [Song] = []
    
    // Stores all data for the current track, used to fetch album covers
    var currentTrackValue: SPTAppRemoteTrack? = nil
    
    // Variable to store the last known player state
    var isPaused: Bool = false
    
    @Published var currentMood: String = "Chill" // Default mood
    
    private lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )
    
    func refreshPlayerState() {
        if isFirstConnectionAttempt{
            // Call ensure connection if needed
            ensureSpotifyConnection()
        }
        // Fetch or update the current player state
        updatePlayerState()
        }
    
    // Spotify App Remote instance
    private lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    // Lazy initialization of the playbackController
    private lazy var playbackController: PlaybackController = {
        return PlaybackController(appRemote: appRemote)
    }()
    
    private lazy var queueManager: QueueManager = {
        return QueueManager()
    }()
    
    // Initialization of the playlistManager
    lazy var playlistManager: PlaylistManager = {
        return PlaylistManager(appRemote: appRemote, queueManager: queueManager, spotifyController: self)
    }()
    
    // Initialization of the profileManager
    private lazy var profileManager: ProfileManager = {
        return ProfileManager()
    }()
    
    override init() {
        super.init()
        retrieveAccessToken()
    }
    
    // Function to retrieve the access token from UserDefaults
    private func retrieveAccessToken() {
        if let storedAccessToken = UserDefaults.standard.string(forKey: "SpotifyAccessToken"),
           let expirationTimestamp = UserDefaults.standard.object(forKey: "SpotifyTokenExpiration") as? TimeInterval {
            self.accessToken = storedAccessToken
            self.tokenExpirationDate = Date(timeIntervalSince1970: expirationTimestamp)
            appRemote.connectionParameters.accessToken = storedAccessToken
        } else {
            print("No access token found in UserDefaults")
        }
    }
    
    func isAccessTokenExpired() -> Bool {
        guard let expirationDate = tokenExpirationDate else { return true }
        // Add 60-second buffer to prevent edge cases
        return Date().addingTimeInterval(60) >= expirationDate
    }
    
    /*
     Method connects the application to Spotify and or authorizes Moodify
     */
    func connect() {
        if appRemote.isConnected {
            ensureSpotifyConnection()
            print("Already connected")
            return
        }
        
        if let token = accessToken, !isAccessTokenExpired() {
            appRemote.connectionParameters.accessToken = token
            appRemote.connect()
        } else {
            // No valid token - need new authorization
            disconnect()
            appRemote.authorizeAndPlayURI("")
        }
    }
    
    /*
     Method disconnects the application from Spotify if already connected.
     */
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
            updatePlayerState()
        }
        // Reset track and album name and clear access token
        currentTrackName = "No track playing"
        currentAlbumName = "No album"
        albumCover = nil
        UserDefaults.standard.removeObject(forKey: "SpotifyAccessToken")
        UserDefaults.standard.removeObject(forKey: "SpotifyTokenExpiration")
    }
    
    // Handle incoming URL after authorization
    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey],
           let expiresIn = parameters?["expires_in"] as? String,
           let expirationInterval = TimeInterval(expiresIn) {
            self.accessToken = accessToken
            self.tokenExpirationDate = Date().addingTimeInterval(expirationInterval)
            
            appRemote.connectionParameters.accessToken = accessToken
            UserDefaults.standard.set(accessToken, forKey: "SpotifyAccessToken")
            UserDefaults.standard.set(self.tokenExpirationDate?.timeIntervalSince1970, forKey: "SpotifyTokenExpiration")
            
            // Connect and initialize player state
            appRemote.connect()
            
            // Add a slight delay to ensure connection is established before getting player state
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.updatePlayerState()
            }
        }
    }
    
    // Delegate method for successful connection
    @objc func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        reconnectAttempted = false
        print("Spotify App Remote connected successfully.")
        
        DispatchQueue.main.async {
            self.isConnected = true  // Update connection status
        }
        isPaused = false
        retryCount = 0 // Reset the retry counter on a successful connection
        
        // Set up the player API and subscribe to player state
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            } else {
                print("Subscribed to player state")
            }
        })
        
        // Fetch the current player state
        appRemote.playerAPI?.getPlayerState { (result, error) in
            if let playerState = result as? SPTAppRemotePlayerState {
                self.playerStateDidChange(playerState)
            } else if let error = error {
                print("Error fetching player state: \(error.localizedDescription)")
            }
        }
    }
    
    /*
     Called when the app remote fails to establish a connection.
     */
    @objc func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Failed to connect to Spotify App Remote: \(String(describing: error?.localizedDescription))")
        
        if !reconnectAttempted {
            reconnectAttempted = true  // Set the flag to prevent further retries
            reconnectAndExecute {
                print("Reattempted connection after failure.")
            }
        } else {
            print("Reconnect attempt already made, will not retry.")
        }
    }
    
    /*
     Called when the app remote is disconnected.
     */
    @objc func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Disconnected from Spotify App Remote: \(String(describing: error?.localizedDescription))")
        isFirstConnectionAttempt = false
        DispatchQueue.main.async {
            self.isConnected = false  // Update connection status
            self.currentTrackName = "No track playing"  // Reset track info
            self.currentAlbumName = "No album"
            self.currentArtistName = ""
            self.albumCover = nil
            self.isPaused = true
        }
    }
    
    /*
     Method fetches the changed state of the player and updates data
     Modified by Paul Shamoon on 10/16/2024.
     */
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        DispatchQueue.main.async {
            self.currentQueue = self.queueManager.removeSongsFromQueue(trackURI: self.currentTrackURI)
            self.currentTrackValue = playerState.track
            self.currentTrackName = playerState.track.name
            self.currentArtistName = playerState.track.artist.name
            self.currentTrackURI = playerState.track.uri
            self.currentAlbumName = playerState.track.album.name
            self.isPaused = playerState.isPaused
            self.fetchAlbumCover()
        }
    }
    
    
    /*
     Method plays or pauses the player depending on its current status
     Created by Paul Shamoon on 10/17/2024.
     Updated by Mohammad on 11/03/2024
     */
    func togglePlayPause() {
        if appRemote.isConnected {
            if isPaused {
                appRemote.playerAPI?.resume { [weak self] result, error in
                    if let error = error {
                        print("Error resuming playback: \(error.localizedDescription)")
                    } else {
                        self?.isPaused = false
                        print("Music resumed.")
                    }
                }
            } else {
                appRemote.playerAPI?.pause { [weak self] result, error in
                    if let error = error {
                        print("Error pausing playback: \(error.localizedDescription)")
                    } else {
                        self?.isPaused = true
                        print("Music paused.")
                    }
                }
            }
        } else {
            reconnectAndExecute {
                self.togglePlayPause()
            }
        }
    }
    
    
    /*
     Method skips to the next song in the queue
     Created by Paul Shamoon on 10/17/2024.
     Updated by Mohammad on 11/03/2024
     */
    func skipToNext() {
        if appRemote.isConnected {
            appRemote.playerAPI?.skip(toNext: { [weak self] result, error in
                if let error = error {
                    print("Error skipping to next track: \(error.localizedDescription)")
                    // Attempt to reconnect or handle the error
                    self?.handlePlayerAPIError()
                } else {
                    print("Successfully skipped to the next track.")
                }
            })
        } else {
            print("App Remote is not connected. Attempting to reconnect...")
            reconnectAndExecute {
                self.skipToNext()
            }
        }
    }
    
    /*
     Method skips to the previous song in the queue
     Created by Paul Shamoon on 10/17/2024.
     */
    func skipToPrevious() {
        if appRemote.isConnected {
            appRemote.playerAPI?.skip(toPrevious: { [weak self] result, error in
                if let error = error {
                    print("Error skipping to previous track: \(error.localizedDescription)")
                    // Attempt to reconnect or handle the error
                    self?.handlePlayerAPIError()
                } else {
                    print("Successfully skipped to the previous track.")
                }
            })
        } else {
            print("App Remote is not connected. Attempting to reconnect...")
            reconnectAndExecute {
                self.skipToPrevious()
            }
        }
    }

    /*
     Calls the `seekForwardOrBackward` method of the `playbackController`
     to skip forward or backward in the current track by 15 seconds.

     - Parameters:
        - forward: A Boolean that determines the direction to skip.
                   `true` for forward, `false` for backward.

     - Returns:
         Void
         
     - Created By: Paul Shamoon
     */
    func seekForwardOrBackward(forward: Bool) -> Void {
        playbackController.seekForwardOrBackward(forward: forward)
    }
    
    func reconnectAndExecute(_ action: @escaping () -> Void, delay: TimeInterval = 2.0) {
        // Check if already connected; if so, execute the action immediately
        guard !appRemote.isConnected else {
            print("Spotify is already connected.")
            action() // Execute the action immediately since we're already connected
            return
        }
        
        // If not connected, attempt to reconnect
        print("Spotify is not connected. Attempting to reconnect...")
        resetFirstConnectionAttempt()
        
        // Attempt to establish the connection and authorize
        appRemote.authorizeAndPlayURI("") // Opens Spotify to establish a connection
        
        // Delay to allow connection and then check if connected
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.appRemote.isConnected {
                // Refresh the player state to ensure everything is up-to-date
                self.refreshPlayerState()
                action() // Execute the provided action after refreshing player state
            } else {
                print("Failed to reconnect to Spotify.")
            }
        }
    }

     private func handlePlayerAPIError() {
         // Add error handleing
         print("Handling player API error. Make sure Spotify is open and playing.")
     }

    /*
     Method to clear the current queue
     
     NOTE: The Spotify Web API nor the Spotify iOS SDK provide an API endpoint to clear the current queue.
     Because of this, our only option is to skip through every song in the currentQueue to "clear" the queue.
     These "skip" requests happen almost instantanous and are barley noticable to the user, making it a effective loophole.
     
     Created By: Paul Shamoon
     */
    func clearCurrentQueue() {
        // Check if currentQueue is empty
        guard !currentQueue.isEmpty else {
            print("Queue was empty, no need to clear.")
            return
        }
        
        // Call skipToNext for every item in the currentQueue
        currentQueue.forEach { _ in
            skipToNext()
        }
    }
    
    
    /*
     Function that sends the recommendation request to Spotify, handles the response, parses the track URIs, and then calls enqueueTracks with the list of track URIs.

     Created by: Mohammad Sulaiman
     */
    func fetchRecommendations(mood: String, profile: Profile, userGenres: [String]) {
        guard appRemote.isConnected else {
            print("Spotify is not connected. Attempting to reconnect...")
            reconnectAndExecute({
                self.fetchRecommendations(mood: mood, profile: profile, userGenres: userGenres)
            }, delay: 3)
            return
        }
        
        // Reset currentPlaylist to nil when queueing songs based off mood
        self.currentPlaylist = nil
        self.currentMood = mood
        
        // Get feature parameters based on mood
        let (minValence, maxValence, minEnergy, maxEnergy, minLoudness, maxLoudness, minAcousticness, maxAcousticness, minDanceability, maxDanceability) = moodQueueHandler.getMoodParameters(for: mood)
        
        // Build the recommendation URL
        guard let url = moodQueueHandler.buildRecommendationURL(userGenres: userGenres, limit: 20, minValence: minValence, maxValence: maxValence, minEnergy: minEnergy, maxEnergy: maxEnergy, minLoudness: minLoudness, maxLoudness: maxLoudness, minAcousticness: minAcousticness, maxAcousticness: maxAcousticness, minDanceability: minDanceability, maxDanceability: maxDanceability),
              let accessToken = self.accessToken else {
            print("Invalid URL or missing access token")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching recommendations: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from Spotify")
                return
            }
            
            do {
                // Log the raw response data for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                
                // Try parsing the JSON
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let tracks = json["tracks"] as? [[String: Any]] {
                    
                    self.enqueueTracks(mood: mood, profile: profile, tracks: tracks)
                } else {
                    print("Unexpected JSON structure")
                }
            } catch {
                print("Error parsing recommendations response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    /*
     Method to enqueue a list of track URIs.
     
     @param tracks: Array of Spotify tracks.
     */
    private func enqueueTracks(mood: String, profile: Profile, tracks: [[String: Any]]) {
        // Clear the currentQueue before queueing new songs
        clearCurrentQueue()
        
        // This will store all song objects created after enqueuing the track
        var songs: [Song] = []
        
        // Create a DispatchGroup to track asynchronous tasks
        let dispatchGroup = DispatchGroup()
        
        for (index, track) in tracks.enumerated() {
            // Extract the URI from each track dictionary
            guard let uri = track["uri"] as? String else {
                print("Failed to find URI in track at index \(index)")
                continue
            }
            
            // Notify the group that a task is starting
            dispatchGroup.enter()
            
            // Add a small delay between requests to prevent rate limiting
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                // If it's the first song, play it immediately
                if index == 0 {
                    self.appRemote.playerAPI?.play(uri)
                    songs.append(self.parseTrack(track: track))
                    print("Started playing first song URI: \(uri)")
                    
                    // Leave the group immediately for the first track
                    dispatchGroup.leave()
                } else {
                    self.appRemote.playerAPI?.enqueueTrackUri(uri, callback: { (result, error) in
                        if let error = error {
                            print("Failed to enqueue song URI \(uri): \(error.localizedDescription)")
                        } else {
                            print("Enqueued song URI: \(uri)")
                            songs.append(self.parseTrack(track: track))
                        }
                        
                        // Notify the group that this task is finished
                        dispatchGroup.leave()
                    })
                }
            }
        }
        
        // This will run after all tracks have been enqueued
        dispatchGroup.notify(queue: .main) {
            // Now all tracks have been enqueued, and songs array is populated
            self.playlistManager.updateOrCreatePlaylist(mood: mood, profile: profile, songs: songs)
        }
    }
    
    /*
     Method fetches the current tracks album cover
     
     Created on 10/23/24 by: Paul Shamoon
     */
    func fetchAlbumCover() {
        // Fetch the current track image with specified size
        // Note to Naz: you can mess around with the cgsize and set it to whatever works best with our frontend. remove this comment in your UI pr
        appRemote.imageAPI?.fetchImage(forItem: currentTrackValue!, with: CGSize(width: 200, height: 200), callback: { (result, error) in
            if let error = error {
                print("Failed to fetch album cover: \(error.localizedDescription)")
                return
            }
            
            // Ensure that result is of type UIImage
            if let image = result as? UIImage {
                print("Successfully fetched album cover")
                DispatchQueue.main.async {
                    // Update the album cover on the main thread
                    self.albumCover = image
                }
            } else {
                print("Failed to cast result to UIImage")
            }
        })
    }
    /*
     Method to play the passed-in "Song" object from the currentQueue
     
     @param song: "Song" object from the queue to play
     
     Created By: Paul Shamoon
     */
    func playSongFromQueue(song: Song) {
        // Get the song to play's index in the currentQueue
        if let index = currentQueue.firstIndex(where: { $0.songURI == song.songURI }) {
            
            // This skips all songs in the queue leading up to the
            // one we intend to play, essentially "clearing" the queue
            for _ in 0..<(index + 1) {
                skipToNext()
            }
        }
        
        // Play the passed in song from the currentQueue
        appRemote.playerAPI?.play(song.songURI, callback: { result, error in
            if let error = error {
                print("Failed to play song: \(error.localizedDescription)")
            } else {
                print("Successfully started playing \(song.trackName) by \(song.artistName).")
            }
        })
    }
    
    /*
     Function to parse the current track and extract relevant data from it
     
     @param track: the track to extract data from
     
     Created By: Paul Shamoon
     */
    func parseTrack(track: [String: Any]) -> Song {
        // Extract track name
        let trackName = track["name"] as? String ?? "Unknown Track"
        
        // Extract album name from the album
        let album = track["album"] as? [String: Any]
        let albumName = album?["name"] as? String ?? "Unknown Album"
        
        // Extract artists name from the artist
        let artists = track["artists"] as? [[String: Any]] ?? []
        let artistNames = artists.compactMap { $0["name"] as? String }.joined(separator: ", ")
        
        // Extract song URI
        let songURI = track["uri"] as? String ?? "Unknown URI"
        
        // Create a "Song" object
        let song = Song(trackName: trackName, albumName: albumName, artistName: artistNames, songURI: songURI)
        
        // Add the "Song" object to the current queue
        currentQueue = queueManager.addSongToQueue(song: song)
        
        return song
    }
    
    func updatePlayerState() {
        appRemote.playerAPI?.getPlayerState { [weak self] (result, error) in
            if let playerState = result as? SPTAppRemotePlayerState {
                self?.playerStateDidChange(playerState)
            }
        }
    }


    func ensureSpotifyConnection(completion: (() -> Void)? = nil) {
        guard !appRemote.isConnected else {
            print("Spotify already connected.")
            completion?() // Trigger completion if already connected
            return
        }
        
        // Silent reconnect if token is valid but connection is lost
        if let token = accessToken, !isAccessTokenExpired() {
            print("Attempting silent reconnect with valid token.")
            appRemote.connectionParameters.accessToken = token
            appRemote.connect()
            
            // Listen for successful connection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.appRemote.isConnected {
                    completion?() // Trigger completion once reconnected
                }
            }
        } else {
            print("Token expired or missing; reconnect deferred.")
            completion?() // Call completion even if no reconnection occurs
        }
    }
    
    func initializeSpotifyConnection() {
        guard isFirstConnectionAttempt else {
            print("Initial connection attempt already completed.")
            return
        }
        guard !appRemote.isConnected else {
            print("Spotify already connected with valid token")
            return
        }
        
        if let token = accessToken, !isAccessTokenExpired() {
            connect()
        } else {
            disconnect()
            connect()
        }
        
        isFirstConnectionAttempt = false // Ensures this only runs once
    }
    
    func resetFirstConnectionAttempt() {
        isFirstConnectionAttempt = true
    }
    
}

