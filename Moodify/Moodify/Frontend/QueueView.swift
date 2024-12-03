//
//  QueueView.swift
//  Moodify
//
//  Created by Paul Shamoon on 10/30/24.
//

import SwiftUI

/*
 View to display the currentQueue
 
 Created By: Paul Shamoon
 */
struct QueueView: View {
    @ObservedObject var spotifyController: SpotifyController
    @Environment(\.dismiss) var dismiss
    @State private var animateGradient = false
    @State private var draggedItem: Song?
    
    // Dynamic gradient colors based on mood
    private var backgroundColors: [Color] {
        switch spotifyController.currentMood.lowercased() {
        case "happy":
            return [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)]
        case "sad":
            return [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]
        case "angry":
            return [Color.red.opacity(0.3), Color.orange.opacity(0.3)]
        case "chill":
            return [Color.green.opacity(0.3), Color.blue.opacity(0.3)]
        default:
            return [Color(red: 0.1, green: 0.3, blue: 0.4), Color(red: 0.2, green: 0.4, blue: 0.3)]
        }
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(colors: backgroundColors,
                           startPoint: animateGradient ? .topLeading : .bottomTrailing,
                           endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed header section
                VStack(spacing: 16) {
                    CustomHeader(dismiss: dismiss, spotifyController: spotifyController)
                    MoodSection(spotifyController: spotifyController)
                    NowPlayingCard(spotifyController: spotifyController)
                }
                .padding(.bottom)
                
                // Scrollable queue section
                VStack(alignment: .leading) {
                    Text("COMING UP NEXT")
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    
                    if spotifyController.currentQueue.isEmpty {
                        EmptyQueueView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(spotifyController.currentQueue) { song in
                                    QueueItemView(song: song, spotifyController: spotifyController)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
                // Extra padding for the top of the background section
                .padding(.top, 12)
                // Extra padding for the bottom of the background section
                .padding(.bottom, 16)
                // Setting a maxWidth so it can be the same size as the CustomHeader and EmptyQueueView
                .frame(maxWidth: 400)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                )
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

// Current Mood Section
struct MoodSection: View {
    let spotifyController: SpotifyController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CURRENT MOOD")
                .font(.caption.bold())
                .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
            
            HStack {
                Image(systemName: getMoodIcon())
                    .font(.title)
                    .foregroundColor(Color(hex: "#F5E6D3"))
                
                Text(spotifyController.currentMood)
                    .font(.title2.bold())
                    .foregroundColor(Color(hex: "#F5E6D3"))
                
                Spacer()
                // Mood indicator pill
                Text(
                    spotifyController.currentPlaylist == nil
                    ? "Playing \(spotifyController.currentMood.lowercased()) music"
                    : "Playing \(spotifyController.currentPlaylist!.mood) playlist"
                )
                .font(.caption)
                .foregroundColor(Color(hex: "#F5E6D3"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    // Helper function to get mood icon
    private func getMoodIcon() -> String {
        switch spotifyController.currentMood.lowercased() {
        case "happy":
            return "face.smiling"
        case "sad":
            return "cloud.rain"
        case "angry":
            return "bolt.fill"
        case "chill":
            return "leaf.fill"
        default:
            return "music.note"
        }
    }
}

// Custom Header
struct CustomHeader: View {
    let dismiss: DismissAction
    let spotifyController: SpotifyController
    
    var body: some View {
        HStack {
            // Back button
            Button(action: { dismiss() }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#F5E6D3"))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            
            // Center text with fixed width
            Text("Mood Queue")
                .font(.title3.bold())
                .foregroundColor(Color(hex: "#F5E6D3"))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            // Trash button with fixed width to match back button
            Button(action: { spotifyController.clearCurrentQueue() }) {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(Color(hex: "C85C37"))
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "C85C37").opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: Color(hex: "C85C37").opacity(0.5), radius: 4, x: 0, y: 0)
            }
            .frame(width: 85)  // Match the approximate width of back button
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// Now Playing Card
struct NowPlayingCard: View {
    @ObservedObject var spotifyController: SpotifyController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("NOW PLAYING")
                .font(.caption.bold())
                .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
            
            HStack(spacing: 16) {
                // Album art
                if let albumCover = spotifyController.albumCover {
                    Image(uiImage: albumCover)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(spotifyController.currentTrackName)
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#F5E6D3"))
                    Text(spotifyController.currentAlbumName)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                }
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        
        .onChange(of: spotifyController.currentTrackName) { _ in
            spotifyController.updatePlayerState()
        }
    }
}

// Queue Section
struct QueueSection: View {
    let spotifyController: SpotifyController
    @State private var draggedItem: Song?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("COMING UP NEXT")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal)
            
            if spotifyController.currentQueue.isEmpty {
                EmptyQueueView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(spotifyController.currentQueue) { song in
                        QueueItemView(song: song, spotifyController: spotifyController)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

// Empty Queue View
struct EmptyQueueView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            Text("Your queue is empty")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            Text("Add some songs to get the party started!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
}

// Queue Item View
struct QueueItemView: View {
    let song: Song
    let spotifyController: SpotifyController
    @State private var isHovered = false
    
    var body: some View {
        Button(action: { spotifyController.playSongFromQueue(song: song) }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.trackName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#F5E6D3"))
                    Text(song.artistName)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                }
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(isHovered ? 0.15 : 0.1))
            )
            .padding(.horizontal)
        }
    }
}

// Drop Delegate
struct DropViewDelegate: DropDelegate {
    let item: Song
    let items: [Song]
    @Binding var draggedItem: Song?
    let reorderAction: (Int, Int) -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else { return }
        
        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            reorderAction(from, to)
        }
    }
}

// Animation modifier
extension View {
    func animate(withDuration duration: Double, autoreverses: Bool = false, repeatForever: Bool = false, completion: (() -> Void)? = nil) -> some View {
        return self.onAppear {
            withAnimation(Animation.easeInOut(duration: duration)
                .repeatForever(autoreverses: autoreverses)) {
                    completion?()
                }
        }
    }
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView(spotifyController: SpotifyController())
    }
}
