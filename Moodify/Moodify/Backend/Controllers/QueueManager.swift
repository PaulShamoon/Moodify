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
     Method to add song to the queue
     
     @param song: a "Song" object to be added to the queue
     @return: an array of "Song" objects
     
     Created By: Paul Shamoon
     */
    func addSongToQueue(song: Song) -> [Song] {
        currentQueue.append(song)
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
