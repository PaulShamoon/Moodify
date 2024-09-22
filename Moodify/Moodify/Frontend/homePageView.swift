// homePage.swift
// Naz M

import SwiftUI

struct homePageView: View {
    // using emoji holders for now to represent what AI would show
    @State private var currentMood: String = "😊"
    @State private var isDetectingMood: Bool = false
    @StateObject var spotifyController = SpotifyController()

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                HStack(spacing: 0) {
                    Text("M")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.2))
                    Text("oodify")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.96, green: 0.87, blue: 0.70))
                }
                .padding(.top, 20)
                
                Text("Discover playlists that match your mood")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // Current Mood Display is subject to change
                VStack(spacing: 10) {
                    Text("Your Current Mood")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(currentMood)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.gray.opacity(0.4)))
                        .shadow(radius: 10)
                }
                
                // Detect Mood Button is subject to change!
                Button(action: {
                    isDetectingMood.toggle()
                    detectMood()
                }) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .font(.title2)
                            .foregroundColor(.black)
                        Text(isDetectingMood ? "Detecting..." : "Detect Mood")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Capsule().fill(Color.green))
                    .shadow(radius: 10)
                }
                
                // Trying the Connect to Spotify on the homepage
                Button(action: {
                    connectSpotify()
                }) {
                    HStack {
                        Image(systemName: "music.note")
                            .font(.title2)
                            .foregroundColor(.black)
                        Text("Connect to Spotify")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Capsule().fill(Color.green))
                    .shadow(radius: 10)
                }
                
                Spacer()
            }
            .padding(.top, 60)
        }
    }
    
    func detectMood() {
        let moods = ["😊", "😢", "😡", "😴", "😍", "😎", "🤔"]
        currentMood = moods.randomElement() ?? "😊"
        isDetectingMood = false
    }
    
    // Placeholder: Spotify API Integration
    func connectSpotify() {
        spotifyController.connect()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        homePageView()
    }
}
