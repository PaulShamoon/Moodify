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
    
    
    /*
     Fetches the current playback position (in milliseconds) of the track
     in the Spotify player and returns via the completion handler.

     - Parameters:
         - completion: A closure that takes an integer (the playback position in milliseconds) as an argument.
                       This closure is called once the player state is fetched, or -1 if an error occurs.

     - Returns:
         This method does not return a value directly. Instead, it asynchronously
         provides the playback position via the completion handler.
     
     - Created By: Paul Shamoon
     */
    func getPlaybackPosition(completion: @escaping (Int) -> Void) {
        appRemote.playerAPI?.getPlayerState { playerState, error in
            if let error = error {
                print("Failed to retrieve player state: \(error.localizedDescription)")
                
                // Return -1 if there’s an error (since -1 is an invalid position)
                completion(-1)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                // Access and print the playback position
                let playbackPosition = playerState.playbackPosition
                
                print("Current playback position: \(playbackPosition) milliseconds")
                completion(playbackPosition)
            }
        }
    }
    
    
    /*
     Skips 15 seconds forward or backward in the current track based on the `forward` parameter.

     - Parameters:
         - forward: A Boolean that determines the direction to skip. `true` for forward, `false` for backward.

     - Returns:
         Void

     - Created By: Paul Shamoon
     */
    func seekForwardOrBackward(forward: Bool) -> Void {
        getPlaybackPosition { position in
            // Check for error condition (position == -1)
            if position == -1 {
                print("Error: Could not retrieve playback position since getPlaybackPosition method failed to retrieve the player state.")
                return
            }
            
            // Determine seek amount based on 'forward' flag
            let seekAmount = forward ? 15000 : -15000
            
            // Add or subtract 15000 milliseconds to the current position
            let newPosition = position + seekAmount

            self.appRemote.playerAPI?.seek(toPosition: newPosition) { result, error in
                let direction = forward ? "forward" : "backward"
                
                if let error = error {
                    print("Failed to seek 15 seconds \(direction): \(error.localizedDescription)")
                } else {
                    print("Successfully skipped \(direction) 15 seconds.")
                }
            }
        }
    }
}
