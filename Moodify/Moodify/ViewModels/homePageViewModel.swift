////
////  HomePageViewModel.swift
////  Moodify
////
////  Created by Nazanin Mahmoudi on 11/17/24.
////
//
//import SwiftUI
//import AVFoundation
//
//class HomePageViewModel: ObservableObject {
//    @Published var showMenu = false
//    @Published var showingCamera = false
//    @Published var isCameraDismissed = false
//    @Published var showingAlert = false
//    @Published var alertMessage = ""
//    @Published var showConnectToSpotifyButton = false
//    @Published var showResyncSpotifyButton = false
//    @Published var navigateToSpotify = false
//    
//    let profile: Profile
//    let spotifyController: SpotifyController
//    
//    init(profile: Profile, spotifyController: SpotifyController) {
//        self.profile = profile
//        self.spotifyController = spotifyController
//    }
//    
//    // Called when the HomePageView appears
//    func onAppear() {
//        updateSpotifyButtons()
//        initializeSpotifyConnectionIfNeeded()
//    }
//    
//    // Updates the visibility of Spotify-related buttons
//    func updateSpotifyButtons() {
//        if let accessToken = spotifyController.accessToken, !spotifyController.isAccessTokenExpired() {
//            if !spotifyController.isConnected {
//                spotifyController.initializeSpotifyConnection()
//            }
//            showConnectToSpotifyButton = false
//        } else {
//            showConnectToSpotifyButton = true
//        }
//        
//        showResyncSpotifyButton = hasValidSpotifyConnection()
//    }
//    
//    // Initialize Spotify connection if conditions are met
//    private func initializeSpotifyConnectionIfNeeded() {
//        guard let accessToken = spotifyController.accessToken, !spotifyController.isAccessTokenExpired() else {
//            print("Access token is missing or expired. Prompting user to reconnect.")
//            return
//        }
//        
//        if !spotifyController.isConnected {
//            spotifyController.initializeSpotifyConnection()
//        }
//    }
//    
//    // Checks if Spotify has a valid connection
//    private func hasValidSpotifyConnection() -> Bool {
//        return spotifyController.isConnected && !showConnectToSpotifyButton
//    }
//    
//    // Trigger camera permission check
//    func checkCameraPermission() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            showingCamera = true
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    if granted {
//                        self.showingCamera = true
//                    } else {
//                        self.alertMessage = "Camera access is required to detect mood."
//                        self.showingAlert = true
//                    }
//                }
//            }
//        case .denied, .restricted:
//            alertMessage = "Enable camera access in Settings."
//            showingAlert = true
//        @unknown default:
//            alertMessage = "Unexpected error occurred."
//            showingAlert = true
//        }
//    }
//    
//    // Resync Spotify player state and refresh the button visibility
//    func resyncSpotify() {
//        spotifyController.resetFirstConnectionAttempt()
//        spotifyController.refreshPlayerState()
//        showResyncSpotifyButton = false
//    }
//}
