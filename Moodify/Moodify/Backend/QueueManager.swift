//
//  QueueManager.swift
//  Moodify
//
//  Created by Paul Shamoon on 10/29/24.
//

class QueueManager {
    let spotifyController = SpotifyController()
    
    // Define the function to parse the response
    func parseTrack(data: [String: Any]) {
        // Extract track name
        let trackName = data["name"] as? String ?? "Unknown Track"
        
        // Extract album name
        let album = data["album"] as? [String: Any]
        let albumName = album?["name"] as? String ?? "Unknown Album"
        
        // Extract artist names
        let artists = data["artists"] as? [[String: Any]] ?? []
        let artistNames = artists.compactMap { $0["name"] as? String }.joined(separator: ", ")
        
        // Extract song URI (id)
        let songURI = data["uri"] as? String ?? "Unknown URI"
        
        // Create and return a Song instance
        let song = Song(trackName: trackName, albumName: albumName, artistName: artistNames, songURI: songURI)
        
        spotifyController.currentQueue.append(song)
        print("Current Queue Contains: \(spotifyController.currentQueue)")
    }

    /*
     Function to remove the passed in song and everything before it from the queue
     */
    func removeSongsFromQueue(trackURI: String) {
        // Ensure queue is not empty
        guard !spotifyController.currentQueue.isEmpty else {
            print("Queue is empty")
            return
        }
        
        // Find the index of the song to be removed by matching the songURI
        if let index = spotifyController.currentQueue.firstIndex(where: { $0.songURI == trackURI }) {
            // Remove songs from the start of the queue up to and including the specified track
            spotifyController.currentQueue.removeSubrange(0...index)
            print("Removed song with URI \(trackURI) and all songs before it from the queue.")
            print("Current Queue is: \(spotifyController.currentQueue)")
        } else {
            print("Song with URI \(trackURI) not found in the queue.")
        }
    }
}
