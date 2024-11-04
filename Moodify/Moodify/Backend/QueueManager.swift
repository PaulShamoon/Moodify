//
//  QueueManager.swift
//  Moodify
//
//  Created by Paul Shamoon on 10/29/24.
//


/*
 Class to handle managing the queue
 
 Created By: Paul Shamoon
 */
class QueueManager: ObservableObject {
    @Published var currentQueue: [Song] = []
    init() {}
    
    /*
     Function to parse the current track and extract relevant data from it
     
     @param track: the track to extract data from
     @returns: an array of "Song" objects
     
     Created By: Paul Shamoon
     */
    func parseTrack(track: [String: Any]) -> [Song] {
        // Extract track name
        let trackName = track["name"] as? String ?? "Unknown Track"
        
        // Extract album name from the album
        let album = track["album"] as? [String: Any]
        let albumName = album?["name"] as? String ?? "Unknown Album"
        
        // Extract artists name from the artist
        let artists = track["artists"] as? [[String: Any]] ?? []
        let artistNames = artists.compactMap { $0["name"] as? String }.joined(separator: ", ")
        
        // Extract song URI
        let songURI = track["uri"] as? String ?? "Unknown URI"
        
        // Create a "Song" object
        let song = Song(trackName: trackName, albumName: albumName, artistName: artistNames, songURI: songURI)
        
        // Append the "Song" object to the currentQueue
        currentQueue.append(song)
        print("Current Queue Contains: \(currentQueue)")
        
        // Return the updated state of currentQueue
        return currentQueue
    }

    /*
     Function to remove a specified track URI and
     everything that appears before it from the queue
     
     @param trackURI: the tracks URI to remove from the queue
     @returns: an array of "Song" objects
     
     Created By: Paul Shamoon
     */
    func removeSongsFromQueue(trackURI: String) -> [Song] {
        // Check if currentQueue is already empty
        guard !currentQueue.isEmpty else {
            print("Queue is empty")
            return currentQueue
        }
        
        // Find the index of the song to be removed by matching the songURI
        if let index = currentQueue.firstIndex(where: { $0.songURI == trackURI }) {
            
            // Remove songs from the start of the queue up to and including the specified index
            currentQueue.removeSubrange(0...index)
            print("Removed song with URI \(trackURI) and all songs before it from the queue.")
        } else {
            print("Song with URI \(trackURI) not found in the queue.")
        }
        
        // Return the updated state of currentQueue
        return currentQueue
    }
}
