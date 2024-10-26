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
            appRemote.connectionParameters.accessToken = storedAccessToken
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
     Method disconnects the application from Spotify if already connected.
     */
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
            // Reset track and album name
            currentTrackName = "No track playing"
            currentAlbumName = ""
            accessToken = nil
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
    
    /*
     Called when the app remote fails to establish a connection.
     */
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Failed to connect to Spotify App Remote: \(String(describing: error?.localizedDescription))")
    }
    
    /*
     Called when the app remote is disconnected.
     */
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Disconnected from Spotify App Remote: \(String(describing: error?.localizedDescription))")
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
    func addSongsToQueue(mood: String, userGenres: [String]) {
        clearQueue() //clears the queue before adding other songs based on another mood.
        // Define mood-based valence, energy, and additional features ranges
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
        case "happy":
            minValence = 0.7
            maxValence = 1.0
            minEnergy = 0.6
            maxEnergy = 0.9
            minDanceability = 0.7
            maxDanceability = 1.0 // Danceable, upbeat tracks

        case "sad":
            minValence = 0.0
            maxValence = 0.3
            minEnergy = 0.3
            maxEnergy = 0.5
            minAcousticness = 0.6
            maxAcousticness = 1.0 // Softer, acoustic-style tracks

        case "angry":
            minValence = 0.0
            maxValence = 0.3
            minEnergy = 0.8
            maxEnergy = 1.0
            minLoudness = -5.0 // Louder tracks for intensity

        case "neutral":
            minValence = 0.4
            maxValence = 0.6
            minEnergy = 0.4
            maxEnergy = 0.6
            minAcousticness = 0.3
            maxAcousticness = 0.6 // Balanced range for neutrality

        default:
            break
        }

        // Limit the number of user-selected genres (Spotify allows up to 5 seeds)
        let limitedGenres = userGenres.prefix(5).map { $0.lowercased() }
        let seedGenres = limitedGenres.joined(separator: ",")

        let limit = 20  // Number of recommendations to retrieve

        var urlString = """
        https://api.spotify.com/v1/recommendations?seed_genres=\(seedGenres)&limit=\(limit)\
        &min_valence=\(minValence)&max_valence=\(maxValence)\
        &min_energy=\(minEnergy)&max_energy=\(maxEnergy)
        """

        // Append additional parameters if set
        if let minLoudness = minLoudness { urlString += "&min_loudness=\(minLoudness)" }
        if let maxLoudness = maxLoudness { urlString += "&max_loudness=\(maxLoudness)" }
        if let minAcousticness = minAcousticness { urlString += "&min_acousticness=\(minAcousticness)" }
        if let maxAcousticness = maxAcousticness { urlString += "&max_acousticness=\(maxAcousticness)" }
        if let minDanceability = minDanceability { urlString += "&min_danceability=\(minDanceability)" }
        if let maxDanceability = maxDanceability { urlString += "&max_danceability=\(maxDanceability)" }

        guard let url = URL(string: urlString), let accessToken = self.accessToken else {
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
    /*
     Method to clear the current Spotify playback queue.
     */
    private func clearQueue() {
        guard let accessToken = self.accessToken else {
            print("Missing access token")
            return
        }
        
        let urlString = "https://api.spotify.com/v1/me/player/pause"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error clearing the queue: \(error.localizedDescription)")
                return
            }
            print("Playback paused, effectively clearing the queue")
        }.resume()
    }
}
