//  MoodQueueHandler.swift
//  Moodify
//
//  Created by Mohammad Sulaiman on 11/03/24.

import Foundation

class MoodQueueHandler {
    
    func getRecommendations(mood: String, genres: [String], limit: Int = 20) -> [String] {
        let moodSongs: [String: [String]] = {
            switch mood.lowercased() {
            case "angry": return angrySongs
            case "happy": return happySongs
            case "sad": return sadSongs
            case "chill": return chillSongs
            default: return [:]
            }
        }()
        
        var selectedSongs = genres.flatMap { genre -> [String] in
            let songs = moodSongs[genre.lowercased()] ?? []
            // Add spotify:track: prefix here
            return songs.map { "spotify:track:" + $0 }
        }
        
        selectedSongs.shuffle()
        return Array(selectedSongs.prefix(limit))
    }
}
