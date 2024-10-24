//
//  PlayBackController.swift
//  Moodify
//
//  Created by Paul Shamoon on 10/17/24.
//

import Foundation
import SpotifyiOS

/*
 Class to handle playback controlls
 */
class PlaybackController {
    private let appRemote: SPTAppRemote

    // Initialize with appRemote dependency
    init(appRemote: SPTAppRemote) {
        self.appRemote = appRemote
    }

    /*
     Method skips to the previous song in the queue
     Created by Paul Shamoon on 10/17/2024.
    */
    func skipToPrevious() {
        appRemote.playerAPI?.skip(toPrevious: { (result, error) in
            if let error = error {
                print("Error skipping to previous track: \(error.localizedDescription)")
            } else {
                print("Successfully skipped to the previous track")
            }
        })
    }
    
    /*
     Method skips to the next song in the queue
     Created by Paul Shamoon on 10/17/2024.
    */
    func skipToNext() {
        appRemote.playerAPI?.skip(toNext: { (result, error) in
            if let error = error {
                print("Error skipping to next track: \(error.localizedDescription)")
            } else {
                print("Successfully skipped to the next track")
            }
        })
    }
    
}
