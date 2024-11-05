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
    
    // Published property to hold the current track uri
    @Published var currentTrackURI: String = ""
    
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
    
    // Array of "Song" objects to hold the state of the queue
    @Published var currentQueue: [Song] = []
    
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
    
    private lazy var queueManager: QueueManager = {
        return QueueManager()
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
    @objc func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Failed to connect to Spotify App Remote: \(String(describing: error?.localizedDescription))")
    }
    
    /*
     Called when the app remote is disconnected.
     */
    @objc func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Disconnected from Spotify App Remote: \(String(describing: error?.localizedDescription))")
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
            https://api.spotify.com/v1/recommendations?seed_genres=\(seedGenres)&limit=\(limit)\
            &min_valence=\(minValence)&max_valence=\(maxValence)\
            &min_energy=\(minEnergy)&max_energy=\(maxEnergy)
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
                // Log the raw response data for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                
                // Try parsing the JSON
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let tracks = json["tracks"] as? [[String: Any]] {
                    
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
    
    // Function to convert user-facing genre names to API-compatible genre names
    private func apiGenre(from genre: String) -> String {
        switch genre {
        case "R&B": return "r-n-b"
        case "World Music": return "world-music"
        case "Film Scores": return "movie"
        default: return genre.lowercased()
        }
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
}
