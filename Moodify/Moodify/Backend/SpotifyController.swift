//
//  SpotifyController.swift
//  Moodify
//
//  Created by Paul Shamoon on 09/16/24.

import Foundation
import SpotifyiOS

class SpotifyController: NSObject, ObservableObject, SPTAppRemotePlayerStateDelegate, SPTAppRemoteDelegate {
    
    // Tracks if reconnect was attempted
    private var reconnectAttempted = false
    
    @Published private(set) var isConnected: Bool = false

    // Stores token expiration
    private var tokenExpirationDate: Date? {
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
    private let moodQueueHandler = MoodQueueHandler() // Initialize the MoodQueueHandler

    // Scopes for Spotify access
    private let spotifyScopes = "user-read-private user-read-email playlist-modify-public playlist-modify-private"
    
    // Unique Spotify Client secret
    private let spotifyClientSecret = "62247b1969084878b7f872abb42bbf8d"
    
    @Published private(set) var isRefreshing = false
    private var refreshTask: Task<Void, Never>?
    
    private let refreshQueue = DispatchQueue(label: "com.moodify.tokenRefresh")

    // Published property to hold the current track name
    @Published var currentTrackName: String = "No track playing"
    
    // Published property to hold the current track uri
    @Published var currentTrackURI: String = ""
    
    // Published property to hold the current track album
    @Published var currentAlbumName: String = ""
    
    // Stores all data for the current track, used to fetch album covers
    var currentTrackValue: SPTAppRemoteTrack? = nil
    
    // Variable to store the last known player state
    var isPaused: Bool = false
    
    // Access token for API requests
    @Published var accessToken: String? {
        didSet {
            appRemote.connectionParameters.accessToken = accessToken
        }
    }
    // Variable to hold album cover
    @Published var albumCover: UIImage? = nil
    
    // Stores the refresh token
    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "SpotifyRefreshToken") }
        set { UserDefaults.standard.set(newValue, forKey: "SpotifyRefreshToken") }
    }
    
    // Array of "Song" objects to hold the state of the queue
    @Published var currentQueue: [Song] = []
    
    // Spotify App Remote instance
    private lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
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
    
    private lazy var queueManager: QueueManager = {
        return QueueManager()
    }()
    
    override init() {
        super.init()
        retrieveAccessToken()
    }
    
    // Improved token refresh with proper error handling and retry logic
       func refreshAccessToken() async throws {
           return try await withCheckedThrowingContinuation { continuation in
               // Ensure we're not already refreshing
               guard !isRefreshing else {
                   continuation.resume(throwing: NSError(domain: "com.moodify", code: -1,
                       userInfo: [NSLocalizedDescriptionKey: "Token refresh already in progress"]))
                   return
               }
               
               guard let refreshToken = self.refreshToken else {
                   continuation.resume(throwing: NSError(domain: "com.moodify", code: -2,
                       userInfo: [NSLocalizedDescriptionKey: "No refresh token available"]))
                   return
               }
               
               isRefreshing = true
               
               // Create authorization header
               let authString = "\(spotifyClientID):\(spotifyClientSecret)".data(using: .utf8)!.base64EncodedString()
               
               // Prepare request
               var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
               request.httpMethod = "POST"
               request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
               request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
               
               let body = [
                   "grant_type": "refresh_token",
                   "refresh_token": refreshToken
               ].map { "\($0)=\($1)" }.joined(separator: "&")
               
               request.httpBody = body.data(using: .utf8)
               
               URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                   guard let self = self else { return }
                   
                   defer { self.isRefreshing = false }
                   
                   if let error = error {
                       continuation.resume(throwing: error)
                       return
                   }
                   
                   guard let data = data else {
                       continuation.resume(throwing: NSError(domain: "com.moodify", code: -3,
                           userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                       return
                   }
                   
                   do {
                       let decoder = JSONDecoder()
                       decoder.keyDecodingStrategy = .convertFromSnakeCase
                       
                       let response = try decoder.decode(TokenResponse.self, from: data)
                       
                       DispatchQueue.main.async {
                           self.accessToken = response.accessToken
                           self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(response.expiresIn))
                           
                           if let newRefreshToken = response.refreshToken {
                               self.refreshToken = newRefreshToken
                           }
                           
                           // Update app remote connection
                           self.appRemote.connectionParameters.accessToken = response.accessToken
                           
                           // Reconnect if needed
                           if !self.appRemote.isConnected {
                               self.connect()
                           }
                           
                           continuation.resume()
                       }
                   } catch {
                       continuation.resume(throwing: error)
                   }
               }.resume()
           }
       }
    
    // Helper method to handle token refresh
    private func handleTokenRefresh() async {
        guard refreshTask == nil else { return }
        
        refreshTask = Task {
            do {
                try await refreshAccessToken()
                print("Token refreshed successfully")
            } catch {
                print("Token refresh failed: \(error.localizedDescription)")
                // Handle failed refresh - maybe trigger reauthorization
                DispatchQueue.main.async {
                    self.disconnect()
                    self.connect() // This will trigger new authorization
                }
            }
            refreshTask = nil
        }
        
        await refreshTask?.value
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
            print("Already connected")
            return
        }
        
        // Check token status
        if let token = accessToken {
            if isAccessTokenExpired() {
                Task {
                    await handleTokenRefresh()
                }
            } else {
                appRemote.connectionParameters.accessToken = token
                appRemote.connect()
            }
        } else {
            // No token - need new authorization
            appRemote.authorizeAndPlayURI("")
        }
    }
    
    // Token response model
    private struct TokenResponse: Codable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let expiresIn: Int
        let refreshToken: String?
    }
    
    /*
     Method disconnects the application from Spotify if already connected.
     */
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
        // Reset track and album name and clear access token
        currentTrackName = "No track playing"
        currentAlbumName = ""
        accessToken = nil
    }
    
    //  Method to handle incoming URL after authorization and to set access token and expiration
    //
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
            
            if let refreshToken = parameters?["refresh_token"] as? String {
                self.refreshToken = refreshToken
                UserDefaults.standard.set(refreshToken, forKey: "SpotifyRefreshToken")
            }
            
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
        updatePlayerState()
        reconnectAttempted = false
        print("Spotify App Remote connected successfully.")
        
        DispatchQueue.main.async {
            self.isConnected = true  // Update connection status
        }
        
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
        
        // Attempt to reconnect immediately without retry logic
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
        
        DispatchQueue.main.async {
            self.isConnected = false  // Update connection status
            self.currentTrackName = "No track playing"  // Reset track info
            self.currentAlbumName = ""
        }
        
        // Attempt to reconnect after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.connect()
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
            self.currentTrackURI = playerState.track.uri
            self.currentAlbumName = playerState.track.album.name
            self.fetchAlbumCover()
        }
    }
    
    
    /*
     Method plays or pauses the player depending on its current status
     Created by Paul Shamoon on 10/17/2024.
     Updated by Mohammad on 11/03/2024
     */
    func togglePlayPause() {
        guard !isAccessTokenExpired() else {
            Task {
                await handleTokenRefresh()
                self.togglePlayPause() // Retry after refresh
            }
            return
        }
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
        guard !isAccessTokenExpired() else {
            Task {
                await handleTokenRefresh()
                self.skipToNext() // Retry after refresh
            }
            return
        }
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
        guard !isAccessTokenExpired() else {
            Task {
                await handleTokenRefresh()
                self.skipToPrevious() // Retry after refresh
            }
            return
        }
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
     Method Reconnects to spotify if connection is lost to perform the necessary action
     Created by Mohammad Sulaiman on 11/03/2024
     */
    private func reconnectAndExecute(_ action: @escaping () -> Void) {
        appRemote.authorizeAndPlayURI("") // Opens Spotify to establish a connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.appRemote.isConnected {
                action() // Execute the action once reconnected
            } else {
                print("Failed to reconnect to Spotify.")
            }
        }
        ensureSpotifyConnection()
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
     Method that retrieves the mood parameters, constructs the recommendation URL, and then fetches the recommendations
     
     @param mood: the users detected mood
     
     Created by: Paul Shamoon
     Updated by: Mohammad Sulaiman
     */
    func addSongsToQueue(mood: String, userGenres: [String]) {
        if appRemote.isConnected {
            // Use MoodQueueHandler to get mood parameters and build the recommendation URL
            let (minValence, maxValence, minEnergy, maxEnergy, minLoudness, maxLoudness, minAcousticness, maxAcousticness, minDanceability, maxDanceability) = moodQueueHandler.getMoodParameters(for: mood)
            
            guard let url = moodQueueHandler.buildRecommendationURL(userGenres: userGenres, limit: 20, minValence: minValence, maxValence: maxValence, minEnergy: minEnergy, maxEnergy: maxEnergy, minLoudness: minLoudness, maxLoudness: maxLoudness, minAcousticness: minAcousticness, maxAcousticness: maxAcousticness, minDanceability: minDanceability, maxDanceability: maxDanceability),
                  let accessToken = self.accessToken else {
                print("Invalid URL or missing access token")
                return
            }
            
            // Fetch recommendations and handle the response
            fetchRecommendations(url: url, accessToken: accessToken)
        } else {
            reconnectAndExecute {
                self.addSongsToQueue(mood: mood, userGenres: userGenres)
            }
        }
    }
    
    
    /*
     Function that sends the recommendation request to Spotify, handles the response, parses the track URIs, and then calls enqueueTracks with the list of track URIs.
     
     Created by: Mohammad Sulaiman
     */
    private func fetchRecommendations(url: URL, accessToken: String) {
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
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let tracks = json["tracks"] as? [[String: Any]] {
                    let uris = tracks.compactMap { $0["uri"] as? String }
                    
                    // Log the parsed URIs for better understanding of the data
                    print("Parsed URIs: \(uris)")
                    
                    self.enqueueTracks(tracks: tracks)
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
    private func enqueueTracks(tracks: [[String: Any]]) {
        // Clear the currentQueue before queueing new songs
        clearCurrentQueue()
        
        for (index, track) in tracks.enumerated() {
            // Extract the URI from each track dictionary
            guard let uri = track["uri"] as? String else {
                print("Failed to find URI in track at index \(index)")
                continue
            }


            // Add a small delay between requests to prevent rate limiting
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                self.appRemote.playerAPI?.enqueueTrackUri(uri, callback: { (result, error) in
                    if let error = error {
                        print("Failed to enqueue song URI \(uri): \(error.localizedDescription)")
                    } else {
                        print("Enqueued song URI: \(uri)")

                        // Only want to parse the track after succesfully queueing a song
                        self.currentQueue = self.queueManager.parseTrack(track: track)
                    }
                })
            }
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
    func updatePlayerState() {
        appRemote.playerAPI?.getPlayerState { [weak self] (result, error) in
            if let playerState = result as? SPTAppRemotePlayerState {
                self?.playerStateDidChange(playerState)
            }
        }
    }
}

extension SpotifyController {
    /// Checks connection state and token validity before attempting to connect
    func ensureSpotifyConnection() {
        guard !appRemote.isConnected else {
            print("Spotify already connected with valid token")
            return
        }
        
        // If we have a token, check if it's expired
        if let _ = accessToken {
            if isAccessTokenExpired() {
                Task {
                    do {
                        try await refreshAccessToken()
                        DispatchQueue.main.async {
                            self.connect()
                        }
                    } catch {
                        print("Token refresh failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.disconnect()
                            self.connect()  // This will trigger new authorization if needed
                        }
                    }
                }
            } else {
                connect()
            }
        } else {
            // No token, initiate fresh connection
            connect()
        }
    }
}
