//  MoodQueueHandler.swift
//  Moodify
//
//  Created by Mohammad Sulaiman on 11/03/24.

import Foundation

class MoodQueueHandler {
    
    // Function to get mood parameters
    func getMoodParameters(for mood: String, genresSelected: [String]) -> (Double, Double, Double, Double, Double?, Double?, Double?, Double?, Double?, Double?) {
        // Default values for broad coverage
        var minValence: Double = 0.4
        var maxValence: Double = 0.7
        var minEnergy: Double = 0.4
        var maxEnergy: Double = 0.7
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
            maxAcousticness = 1.0
        case "angry":
            minValence = 0.1
            maxValence = 0.4
            minEnergy = 0.8
            maxEnergy = 1.0
            minLoudness = -6.0
            maxLoudness = nil
            
        case "chill":
            minValence = 0.3
            maxValence = 0.6
            minEnergy = 0.4
            maxEnergy = 0.6
            minAcousticness = 0.3
            maxAcousticness = 0.7
        
        default:
            minValence = 0.4
            maxValence = 0.7
            minEnergy = 0.4
            maxEnergy = 0.7
        }
        
        // Adjust ranges dynamically based on selected genres
        if genresSelected.count <= 2 {
            // Relax constraints if user has selected few genres
            minValence -= 0.1
            maxValence += 0.1
            minEnergy -= 0.1
            maxEnergy += 0.1
        }
        
        // Ensure values stay within valid bounds
        minValence = max(0.0, minValence)
        maxValence = min(1.0, maxValence)
        minEnergy = max(0.0, minEnergy)
        maxEnergy = min(1.0, maxEnergy)
        
        return (minValence, maxValence, minEnergy, maxEnergy, minLoudness, maxLoudness, minAcousticness, maxAcousticness, minDanceability, maxDanceability)
    }

    /*
     Function that constructs the Spotify API recommendation URL using the provided genres and audio feature ranges. It dynamically includes each feature parameter in the URL if it’s not nil.
     
     Created by: Mohammad Sulaiman
     */
    func buildRecommendationURL(userGenres: [String], limit: Int, minValence: Double, maxValence: Double, minEnergy: Double, maxEnergy: Double, minLoudness: Double?, maxLoudness: Double?, minAcousticness: Double?, maxAcousticness: Double?, minDanceability: Double?, maxDanceability: Double?) -> URL? {
        // Shuffle the genres if more than 5 are selected
        let shuffledGenres = userGenres.count > 5 ? userGenres.shuffled() : userGenres
        // Convert user selected genres to compatible genres and limit to 5 for the API
        let seedGenres = shuffledGenres.prefix(5).map { apiGenre(from: $0) }.joined(separator: ",")
        var urlString = """
            https://api.spotify.com/v1/recommendations?seed_genres=\(seedGenres)&limit=\(limit)&min_valence=\(minValence)&max_valence=\(maxValence)&min_energy=\(minEnergy)&max_energy=\(maxEnergy)
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
        print("Shuffled Genres: ", shuffledGenres)
        return URL(string: urlString)
    }
    
    // Function to convert user-facing genre names to API-compatible genre names
    private func apiGenre(from genre: String) -> String {
        switch genre {
        case "R&B": return "r-n-b"
        case "World Music": return "world-music"
        case "Film Scores": return "movies"
        default: return genre.lowercased()
        }
    }
}
