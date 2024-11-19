//
//  MoodDetectionViewModel.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 11/17/24.
//

import SwiftUI
import AVFoundation

class MoodDetectionViewModel: ObservableObject {
    @Published var backgroundColors: [Color] = [
        Color(red: 0.075, green: 0.075, blue: 0.075),
        Color(red: 0.1, green: 0.1, blue: 0.1)
    ]
    @Published var currentMood = "😶"
    @Published var isCameraDismissed = false
    @Published var currentMoodText = ""
    @Published var isDetectingMood = false
    @Published var showMoodPreferenceSheet = false
    @Published var showMoodSelector = false
    @Published var detectedMood = ""
    @Published var capturedImage: UIImage?
    @Published var alertMessage = ""
    @Published var showingAlert = false
    
    let profile: Profile
    let spotifyController: SpotifyController
    private let backendURL = "/analyze"  // NOTE - this URL is temporary and needs to be updated each time from the backend side to detect mood properly
    
    init(profile: Profile, spotifyController: SpotifyController) {
        self.profile = profile
        self.spotifyController = spotifyController
    }
    
    func updateBackgroundColors(for emotion: String) {
        withAnimation(.easeInOut(duration: 1.0)) {
            switch emotion.lowercased() {
            case "happy":
                backgroundColors = [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.2, green: 0.15, blue: 0.05)
                ]
            case "sad":
                backgroundColors = [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.05, green: 0.1, blue: 0.2)
                ]
            case "angry":
                backgroundColors = [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.2, green: 0.05, blue: 0.05)
                ]
            case "chill":
                backgroundColors = [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.05, green: 0.15, blue: 0.15)
                ]
            default:
                backgroundColors = [
                    Color(red: 0.075, green: 0.075, blue: 0.075),
                    Color(red: 0.1, green: 0.1, blue: 0.1)
                ]
            }
        }
    }
    
    func onCameraDismissed() {
        guard let image = capturedImage else {
            alertMessage = "Image capture failed. Please try again."
            showingAlert = true
            return
        }
        analyzeImage(image: image)
    }
    
    func analyzeImage(image: UIImage) {
        isDetectingMood = true
        currentMoodText = ""  // Clear current mood text while detecting
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            alertMessage = "Failed to convert image to JPEG."
            showingAlert = true
            isDetectingMood = false
            return
        }
        
        var request = URLRequest(url: URL(string: backendURL)!)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"mood.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isDetectingMood = false }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to analyze image: \(error.localizedDescription)"
                    self.showingAlert = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = "No data received from the server."
                    self.showingAlert = true
                }
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               var emotion = json["emotion"] as? String,
               let probabilitiesDict = json["probabilities"] as? [String: Double] {
                
                // Adjust emotion for specific cases
                switch emotion.lowercased() {
                case "surprise": emotion = "happy"
                case "disgust", "fear": emotion = "sad"
                case "neutral": emotion = "chill"
                default: break
                }
                
                DispatchQueue.main.async {
                    self.currentMood = self.moodEmoji(for: emotion)
                    self.currentMoodText = "You seem to be \(emotion.capitalized)."
                    self.updateBackgroundColors(for: emotion)
                    
                    if emotion.lowercased() == "sad" {
                        self.detectedMood = emotion
                        self.showMoodPreferenceSheet = true
                    } else {
                        self.spotifyController.fetchRecommendations(
                            mood: emotion,
                            profile: self.profile,
                            userGenres: self.profile.favoriteGenres
                        )
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = "Invalid response from server."
                    self.showingAlert = true
                }
            }
        }.resume()
    }
    
    private func moodEmoji(for emotion: String) -> String {
        switch emotion.lowercased() {
        case "happy": return "😄"
        case "sad": return "😢"
        case "angry": return "😡"
        case "chill": return "😌"
        default: return "😶"
        }
    }
}
