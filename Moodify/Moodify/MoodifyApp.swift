//
//  MoodifyApp.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 9/9/24.
//

import SwiftUI

@main
struct MoodifyApp: App {
    @StateObject var spotifyController = SpotifyController()

    var body: some Scene {
        WindowGroup {
            // Comment the below out to demonstrate spotify connection
            // ConnectToSpotifyDisplay(spotifyController: spotifyController)
            homePageView()
        }
    }
}
