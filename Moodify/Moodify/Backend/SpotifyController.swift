//
//  SpotifyController.swift
//  Moodify
//
//  Created by Paul Shamoon on 09/16/24.

import Foundation
import SpotifyiOS

class SpotifyController: NSObject, ObservableObject, SPTAppRemotePlayerStateDelegate, SPTAppRemoteDelegate {
    
    // Stores token expiration
    private var tokenExpirationDate: Date?
    
    // Reset retry counter
    var retryCount = 0

    // Unique Spotify client ID
    private let spotifyClientID = "3dfaae404a2f4847a2ff7d707f7154f4"
    
    // Redirect URL after authorization
    private let spotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    
    // Scopes for Spotify access
    private let spotifyScopes = "user-read-private user-read-email playlist-modify-public playlist-modify-private"
    
    // Published property to hold the current track name
    @Published var currentTrackName: String = "No track playing"
    
    // Published property to hold the current track album
    @Published var currentAlbumName: String = ""
    
    // Stores all data for the current track, used to fetch album covers
    var currentTrackValue: SPTAppRemoteTrack? = nil
    
    // Variable to store the last known player state
    var isPaused: Bool = false
    
    // Access token for API requests
    @Published var accessToken: String? = nil
    
    // Variable to hold album cover
    @Published var albumCover: UIImage? = nil
    
    // Stores the refresh token
    private var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "SpotifyRefreshToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SpotifyRefreshToken")
        }
    }
    
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
        return Date() >= expirationDate
    }
    
    
    /*
     Method connects the application to Spotify and or authorizes Moodify
     */
    func connect() {
        if appRemote.isConnected {
            print("AppRemote is already connected.")
            return
        }

        // Check if we have a valid access token
        if let token = accessToken {
            if isAccessTokenExpired() {
                refreshAccessToken() // Attempt to refresh the token
            } else {
                // Force reinitialize the App Remote to ensure it's fresh
                appRemote.connectionParameters.accessToken = token
                appRemote.connect() // Connect using the existing token
            }
        } else {
            // Start the authorization process if no token is available
            appRemote.authorizeAndPlayURI("")
        }
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
            } else {
                print("No refresh token found in URL parameters.")
            }
            
            appRemote.connect()
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("Error setting access token: \(errorDescription)")
        }
    }
    
    func refreshAccessToken() {
        guard let refreshToken = refreshToken else {
            print("No refresh token available.")
            return
        }
        
        // Construct the request to Spotify's token endpoint
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        
        // Set up the request body
        let bodyComponents = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": spotifyClientID
        ]
        request.httpBody = bodyComponents
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return } // Safely capture `self`
            
            if let error = error {
                print("Error refreshing token: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received when refreshing token.")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let newAccessToken = json["access_token"] as? String,
                   let expiresIn = json["expires_in"] as? Double {
                    self.accessToken = newAccessToken
                    self.tokenExpirationDate = Date().addingTimeInterval(expiresIn)
                    self.appRemote.connectionParameters.accessToken = newAccessToken
                    UserDefaults.standard.set(newAccessToken, forKey: "SpotifyAccessToken")
                    UserDefaults.standard.set(self.tokenExpirationDate?.timeIntervalSince1970, forKey: "SpotifyTokenExpiration")
                    print("Token refreshed successfully.")
                } else {
                    print("Failed to parse refresh token response.")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Delegate method for successful connection
    @objc func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Spotify App Remote connected successfully.")
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

        // Retry logic
        guard retryCount < 3 else {
            print("Maximum retry attempts reached. Connection failed.")
            return
        }

        retryCount += 1
        print("Retrying connection attempt \(retryCount)...")

        // Reinitialize the App Remote before retrying
        self.appRemote.disconnect()
        self.appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        self.appRemote.delegate = self

        // Attempt to reconnect after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.connect()
        }
    }
    
    /*
     Called when the app remote is disconnected.
     */
    @objc func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Disconnected from Spotify App Remote: \(String(describing: error?.localizedDescription))")

        // Cleanly disconnect to reset the state
        appRemote.disconnect()
        
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
            self.currentTrackValue = playerState.track
            self.currentTrackName = playerState.track.name
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
        if appRemote.isConnected {
            if isPaused {
                appRemote.playerAPI?.resume { [weak self] result, error in
                    if let error = error {
                        print("Error resuming playback: \(error.localizedDescription)")
                        // Attempt to handle the error
                        self?.handlePlayerAPIError()
                    } else {
                        self?.isPaused = false
                        print("Music resumed.")
                    }
                }
            } else {
                appRemote.playerAPI?.pause { [weak self] result, error in
                    if let error = error {
                        print("Error pausing playback: \(error.localizedDescription)")
                        // Attempt to handle the error
                        self?.handlePlayerAPIError()
                    } else {
                        self?.isPaused = true
                        print("Music paused.")
                    }
                }
            }
        } else {
            print("App Remote is not connected. Attempting to reconnect...")
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
    }

    private func handlePlayerAPIError() {
        // Add error handleing
        print("Handling player API error. Make sure Spotify is open and playing.")
    }

    
    /*
     Method that retrieves the mood parameters, constructs the recommendation URL, and then fetches the recommendations
     
     @param mood: the users detected mood
     
     Created by: Paul Shamoon
     Updated by: Mohammad Sulaiman
     */
    func addSongsToQueue(mood: String, userGenres: [String]) {
        if appRemote.isConnected {
            // Get feature parameters based on mood
            let (minValence, maxValence, minEnergy, maxEnergy, minLoudness, maxLoudness, minAcousticness, maxAcousticness, minDanceability, maxDanceability) = getMoodParameters(for: mood)
            
            // Build the recommendation URL
            guard let url = buildRecommendationURL(userGenres: userGenres, limit: 20, minValence: minValence, maxValence: maxValence, minEnergy: minEnergy, maxEnergy: maxEnergy, minLoudness: minLoudness, maxLoudness: maxLoudness, minAcousticness: minAcousticness, maxAcousticness: maxAcousticness, minDanceability: minDanceability, maxDanceability: maxDanceability),
                  let accessToken = self.accessToken else {
                print("Invalid URL or missing access token")
                return
            }
            
            // Fetch recommendations and handle the response
            fetchRecommendations(url: url, accessToken: accessToken)
        } else {
            print("App Remote is not connected. Attempting to reconnect...")
            reconnectAndExecute {
                self.addSongsToQueue(mood: mood, userGenres: userGenres)
            }
        }
    }
    
    /*
     Function that determines the mood-based audio feature ranges (e.g., valence, energy) based on the provided mood. It returns a tuple with the appropriate values for each feature.
     
     Created by: Mohammad Sulaiman
     */
    private func getMoodParameters(for mood: String) -> (Double, Double, Double, Double, Double?, Double?, Double?, Double?, Double?, Double?) {
        var minValence: Double = 0.5
        var maxValence: Double = 0.5
        var minEnergy: Double = 0.5
        var maxEnergy: Double = 0.5
        var minLoudness: Double? = nil
        var maxLoudness: Double? = nil
        var minAcousticness: Double? = nil
        var maxAcousticness: Double? = nil
        var minDanceability: Double? = nil
        var maxDanceability: Double? = nil
        
        switch mood.lowercased() {
        case "happy", "surprise":
            minValence = 0.7
            maxValence = 1.0
            minEnergy = 0.6
            maxEnergy = 0.9
            /*
             minDanceability = 0.7
             maxDanceability = 1.0 // Danceable, upbeat tracks
             */
            
        case "sad", "disgust", "fear":
            minValence = 0.0
            maxValence = 0.3
            minEnergy = 0.3
            maxEnergy = 0.5
            minAcousticness = 0.6
            maxAcousticness = 1.0
        case "angry":
            minValence = 0.0
            maxValence = 0.3
            minEnergy = 0.8
            maxEnergy = 1.0
            minLoudness = -5.0
            
        case "neutral":
            minValence = 0.4
            maxValence = 0.6
            minEnergy = 0.4
            maxEnergy = 0.6
            minAcousticness = 0.3
            maxAcousticness = 0.6
        default:
            break
        }
        
        return (minValence, maxValence, minEnergy, maxEnergy, minLoudness, maxLoudness, minAcousticness, maxAcousticness, minDanceability, maxDanceability)
    }
    
    /*
     Function that constructs the Spotify API recommendation URL using the provided genres and audio feature ranges. It dynamically includes each feature parameter in the URL if it’s not nil.
     
     Created by: Mohammad Sulaiman
     */
    private func buildRecommendationURL(userGenres: [String], limit: Int, minValence: Double, maxValence: Double, minEnergy: Double, maxEnergy: Double, minLoudness: Double?, maxLoudness: Double?, minAcousticness: Double?, maxAcousticness: Double?, minDanceability: Double?, maxDanceability: Double?) -> URL? {
        // TODO: Shuffle the usergenres if more than 5 moods are selected.
        // Convert user-selected genres to API-compatible genres
        let seedGenres = userGenres.prefix(5).map { apiGenre(from: $0) }.joined(separator: ",")
        
        var urlString = """
            https://api.spotify.com/v1/recommendations?seed_genres=\(seedGenres)&limit=\(limit)&min_valence=\(minValence)&max_valence=\(maxValence)&min_energy=\(minEnergy)&max_energy=\(maxEnergy)
            """
        // Organize optional parameters in a dictionary
        let optionalParameters: [String: Double?] = [
            "min_loudness": minLoudness,
            "max_loudness": maxLoudness,
            "min_acousticness": minAcousticness,
            "max_acousticness": maxAcousticness,
            "min_danceability": minDanceability,
            "max_danceability": maxDanceability
        ]
        
        // Iterate over optional parameters and append if non-nil
        for (key, value) in optionalParameters {
            if let value = value {
                urlString += "&\(key)=\(value)"
            }
        }
        
        return URL(string: urlString)
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
                    
                    self.enqueueTracks(uris: uris)
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
     @param uris: Array of Spotify track URIs.
     */
    private func enqueueTracks(uris: [String]) {
        for (index, uri) in uris.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                // Need to add a small delay between requests to prevent rate limiting errors
                self.appRemote.playerAPI?.enqueueTrackUri(uri, callback: { (result, error) in
                    if let error = error {
                        print("Failed to enqueue song URI \(uri): \(error.localizedDescription)")
                    } else {
                        print("Enqueued song URI: \(uri)")
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
    
    // Function to convert user-facing genre names to API-compatible genre names
    private func apiGenre(from genre: String) -> String {
        switch genre {
        case "R&B": return "r-n-b"
        case "World Music": return "world-music"
        case "Film Scores": return "movie"
        default: return genre.lowercased()
        }
    }
}
