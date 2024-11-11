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
        case "happy", "surprise":
            return [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)]
        case "sad", "disgust", "fear":
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
            .animate(withDuration: 5, autoreverses: true, repeatForever: true) {
                animateGradient.toggle()
            }
            
            VStack(spacing: 0) {
                // Fixed header section
                VStack(spacing: 16) {
                    CustomHeader(dismiss: dismiss, spotifyController: spotifyController)
                    MoodSection(currentMood: spotifyController.currentMood)
                    NowPlayingCard(spotifyController: spotifyController)
                }
                .padding(.bottom)
                
                // Scrollable queue section
                VStack(alignment: .leading) {
                    Text("COMING UP NEXT")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    if spotifyController.currentQueue.isEmpty {
                        EmptyQueueView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(spotifyController.currentQueue) { song in
                                    QueueItemView(song: song, spotifyController: spotifyController)
                                        .onDrag {
                                            self.draggedItem = song
                                            return NSItemProvider(object: song.songURI as NSString)
                                        }
                                        .onDrop(of: [.text], delegate: DropViewDelegate(item: song, items: spotifyController.currentQueue, draggedItem: $draggedItem) { from, to in
                                            withAnimation {
                                                spotifyController.reorderQueue(from: from, to: to)
                                            }
                                        })
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                )
            }
        }
        .navigationBarHidden(true)
    }
}

// Current Mood Section
struct MoodSection: View {
    let currentMood: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CURRENT MOOD")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.7))
            
            HStack {
                Image(systemName: getMoodIcon())
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(currentMood)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                // Mood indicator pill
                Text("Playing \(currentMood.lowercased()) music")
                    .font(.caption)
                    .foregroundColor(.white)
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
        switch currentMood.lowercased() {
        case "happy", "surprise":
            return "face.smiling"
        case "sad", "disgust", "fear":
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
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Mood Queue")
                .font(.title3.bold())
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { spotifyController.clearCurrentQueue() }) {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// Now Playing Card
struct NowPlayingCard: View {
    let spotifyController: SpotifyController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("NOW PLAYING")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.7))
            
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
                        .foregroundColor(.white)
                    Text(spotifyController.currentAlbumName)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                
                // Updated Play/Pause button
                Button(action: {
                    spotifyController.togglePlayPause()
                }) {
                    Image(systemName: spotifyController.isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
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
                            .onDrag {
                                self.draggedItem = song
                                return NSItemProvider(object: song.songURI as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(item: song, items: spotifyController.currentQueue, draggedItem: $draggedItem) { from, to in
                                withAnimation {
                                    spotifyController.reorderQueue(from: from, to: to)
                                }
                            })
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
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.subheadline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.trackName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text(song.artistName)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .font(.caption)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(.white.opacity(0.2)))
                    .opacity(isHovered ? 1 : 0.6)
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
