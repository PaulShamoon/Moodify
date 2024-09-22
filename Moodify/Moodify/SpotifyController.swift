//
//  SpotifyController.swift
//  Moodify
//
//  Created by Paul Shamoon on 09/16/24.


import SwiftUI
import SpotifyiOS
import Combine

class SpotifyController: NSObject, ObservableObject, SPTAppRemotePlayerStateDelegate, SPTAppRemoteDelegate {
    // This is our unique spotify client ID used to establish a connection
    let spotifyClientID = "3dfaae404a2f4847a2ff7d707f7154f4"
    
    // Used to send users back to the application
    let spotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!

    // Published property to hold current track name
    @Published var currentTrackName: String = "Not playing"
    
    // Needed to make API requests, will be set later on
    var accessToken: String? = nil

    // Spotify App Remote instance
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        print("AppRemote created with access token: \(String(describing: self.accessToken))")
        return appRemote
    }()

    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )

    override init() {
        super.init()
        
        print("Initializing SpotifyController...")

        // Retrieve access token from persistent storage if available
        if let storedAccessToken = UserDefaults.standard.string(forKey: "SpotifyAccessToken") {
            self.accessToken = storedAccessToken
            print("Access token retrieved from UserDefaults: \(storedAccessToken)")
        } else {
            print("No access token found in UserDefaults")
        }
    }

    func connect() {
        guard appRemote.connectionParameters.accessToken != nil else {
            print("Access token is nil, starting authorization")
            appRemote.authorizeAndPlayURI("")
            return
        }
        print("Connecting to Spotify App Remote with access token: \(appRemote.connectionParameters.accessToken!)")
        appRemote.connect()
    }

    func disconnect() {
        if appRemote.isConnected {
            print("Disconnecting from Spotify App Remote...")
            appRemote.disconnect()
        } else {
            print("AppRemote is not connected, no need to disconnect")
        }
    }

    func setAccessToken(from url: URL) {
        print("Attempting to set access token from URL: \(url)")
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            print("Access token successfully set: \(accessToken)")
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
            UserDefaults.standard.set(accessToken, forKey: "SpotifyAccessToken")
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("Error setting access token: \(errorDescription)")
        }
    }

    @objc func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Successfully connected to Spotify App Remote")
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            } else {
                print("Subscribed to player state")
            }
        })
        
        // Fetch the current player state as soon as connected
        self.appRemote.playerAPI?.getPlayerState { (result, error) in
            if let playerState = result as? SPTAppRemotePlayerState {
                self.playerStateDidChange(playerState)
                print("Fetched initial player state: \(playerState.track.name)")
            } else if let error = error {
                print("Error fetching player state: \(error.localizedDescription)")
            }
        }
    }

    @objc func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Failed to connect to Spotify App Remote: \(String(describing: error?.localizedDescription))")
    }

    @objc func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Disconnected from Spotify App Remote: \(String(describing: error?.localizedDescription))")
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        DispatchQueue.main.async {
            print("Player state changed: \(playerState.track.name)")
            self.currentTrackName = playerState.track.name
        }
    }
}
