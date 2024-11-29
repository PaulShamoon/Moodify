import SwiftUI
import AVFoundation

struct homePageView: View {
    let profile: Profile  // Profile passed from ProfileSelectionView
    @Binding var navigateToHomePage: Bool
    @Binding var isCreatingNewProfile: Bool
    @Binding var navigateToMusicPreferences: Bool
    @State private var navigateToSpotify = false // State for navigation
    @AppStorage("hasConnectedSpotify") private var hasConnectedSpotify = false
    @State private var showingCamera = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var capturedImage: UIImage?
    @State private var currentMood: String = "😶"
    @State private var currentMoodText: String = ""
    @State private var probabilities: [(emotion: String, probability: Double)] = []
    @State private var isDetectingMood: Bool = false
    @StateObject var spotifyController = SpotifyController()
    @Binding var isCreatingProfile: Bool // This will be passed from outside
    @State private var showMenu = false
    @State private var isCameraDismissed = false
    @State private var showConnectToSpotifyButton = false // New state variable
    @State private var showResyncSpotifyButton = false // New state variable
    @State private var isMoodButtonAnimating = false
    
    
    // NOTE - this URL is temporary and needs to be updated each time from the backend side to detect mood properly
    let backendURL = "https://2cd3-50-218-129-6.ngrok-free.app/analyze"
    
    // Add this property to manage background color
    @State private var backgroundColors: [Color] = [
        Color(red: 0.075, green: 0.075, blue: 0.075),  // Very dark gray, almost black
        Color(red: 0.1, green: 0.1, blue: 0.1)         // Slightly lighter dark gray
    ]
    
    // Add this method to determine background colors based on mood
    func updateBackgroundColors(for emotion: String) {
        withAnimation(.easeInOut(duration: 1.0)) {
            switch emotion.lowercased() {
            case "happy":
                backgroundColors = [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.2, green: 0.15, blue: 0.05)  // Subtle warm dark
                ]
            case "sad":
                backgroundColors = [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.05, green: 0.1, blue: 0.2)   // Subtle cool dark
                ]
            case "angry":
                backgroundColors = [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.2, green: 0.05, blue: 0.05)  // Subtle red dark
                ]
            case "chill":
                backgroundColors = [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.05, green: 0.15, blue: 0.15) // Subtle teal dark
                ]
            default:
                backgroundColors = [
                    Color(red: 0.075, green: 0.075, blue: 0.075),
                    Color(red: 0.1, green: 0.1, blue: 0.1)
                ]
            }
        }
    }
    
    // Add these new state variables
    @State private var showMoodPreferenceSheet = false
    @State private var detectedMood = ""
    
    // Add these state variables to homePageView
    @State private var showMoodSelector = false
    @State private var selectedManualMood = "chill"
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header with profile and settings
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(.white.opacity(0.9))
                        Text(profile.name)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    .padding(.leading, 35)
                    
                    Spacer()
                    
                    // Spotify Connection Button
                    if showConnectToSpotifyButton {
                        Button(action: {
                            navigateToSpotify = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "music.note") // Replace with Spotify logo from assets
                                    .font(.system(size: 16))
                                Text("Connect")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#1DB954")) // Spotify green
                                    .opacity(0.9)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    
                    if showResyncSpotifyButton {
                        Button(action: {
                            spotifyController.resetFirstConnectionAttempt()
                            spotifyController.refreshPlayerState()
                            showResyncSpotifyButton = false
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "music.note") // Replace with Spotify logo from assets
                                    .font(.system(size: 16))
                                Text("Resync")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#1DB954")) // Spotify green
                                    .opacity(0.7)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    
                    Button(action: {
                        withAnimation { showMenu.toggle() }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.3)))
                            .shadow(radius: 10)
                    }
                }
                .padding(.horizontal)
                
                // Mood Display
                VStack(spacing: 0) {
                    // Header with mood name
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Mood")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                            Text(currentMoodText.capitalized)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        
                        Button(action: {
                            showMoodSelector = true
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                    
                    // Gradient Blob - smaller size
                    ZStack {
                        // Main gradient blob
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: getMoodGradient(for: currentMoodText),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 160, height: 160)  // Reduced size
                            .blur(radius: 25)  // Slightly reduced blur
                            .offset(y: -15)
                        
                        // Secondary blob for layered effect
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: getMoodGradient(for: currentMoodText).reversed(),
                                    startPoint: .topTrailing,
                                    endPoint: .bottomLeading
                                )
                            )
                            .frame(width: 120, height: 120)  // Reduced size
                            .blur(radius: 20)  // Slightly reduced blur
                            .offset(x: 15, y: 15)  // Adjusted offset
                    }
                    .frame(height: 200)  // Reduced frame height
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // Detect Mood Button - Moved up
                Button(action: {
                    checkCameraPermission()
                }) {
                    HStack {
                        Image(systemName: "camera")
                            .font(.system(size: 24))
                        Text(isDetectingMood ? "Detecting..." : "Detect Mood")
                            .font(.system(size: 24, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(
                        ZStack {
                            // Gradient background
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.6),
                                    Color(red: 0.2, green: 0.4, blue: 0.3).opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // Subtle glow effect
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        }
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.2, green: 0.4, blue: 0.3),
                                                Color(red: 0.4, green: 0.3, blue: 0.2)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .opacity(isMoodButtonAnimating ? 0.8 : 0.4)
                            )
                            .shadow(
                                color: Color(red: 0.2, green: 0.4, blue: 0.3).opacity(0.5),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                    )
                    .padding(.vertical, 10)
                }
                
                // Player View - Moved up
                PlayerView(spotifyController: spotifyController)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.2, green: 0.4, blue: 0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(red: 0.4, green: 0.3, blue: 0.2), lineWidth: 3.0)
                            )
                    )
                    .padding(.horizontal)
            }
            .padding(.top, 60)
            
            .onAppear {
                // Check if the access token is available and not expired
                if spotifyController.accessToken != nil, !spotifyController.isAccessTokenExpired() {
                    if !spotifyController.isConnected {
                        spotifyController.initializeSpotifyConnection()
                    }
                    showConnectToSpotifyButton = false // Hide connect button if token is valid
                } else {
                    print("Access token is expired or missing. Please reconnect to Spotify.")
                    showConnectToSpotifyButton = true // Show connect button if not connected
                }
                updateResyncButtonVisibility() // Update resync button visibility on view load
            }
            
            // Observe spotifyController.isConnected changes to update resync button visibility
            .onChange(of: spotifyController.isConnected) { _ in
                updateResyncButtonVisibility()
                spotifyController.updatePlayerState() // Update player state if reconnected
            }
            
            
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
            // Add navigation handling
            .navigationDestination(isPresented: $navigateToSpotify) {
                ConnectToSpotifyView(spotifyController: spotifyController)
                    .onDisappear {
                        // Set flag when user completes Spotify connection
                        if spotifyController.accessToken != nil {
                            hasConnectedSpotify = true
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                navigateToSpotify = false
                            }) {
                                Image(systemName: "chevron.backward")
                                    .foregroundColor(.white)
                                Text("Back")
                                    .foregroundColor(.white)
                            }
                        }
                    }
            }
            
            // Slide-in menu
            if showMenu {
                MenuView(
                    showMenu: $showMenu,
                    navigateToHomePage: $navigateToHomePage,
                    navigateToMusicPreferences: $navigateToMusicPreferences,
                    isCreatingNewProfile: $isCreatingProfile,
                    spotifyController: spotifyController
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $capturedImage, isCameraDismissed: $isCameraDismissed)
                .onDisappear {
                    if let image = capturedImage {
                        analyzeImage(image: image)
                    } else {
                        alertMessage = "Image capture failed. Please try again."
                        showingAlert = true
                    }
                }
        }
        .sheet(isPresented: $showMoodPreferenceSheet) {
            MoodPreferenceView(
                spotifyController: spotifyController,
                profile: profile,
                detectedMood: detectedMood,
                isPresented: $showMoodPreferenceSheet,
                manualMoodSelectorPresented: $showMoodSelector
            )
        }
        .sheet(isPresented: $showMoodSelector) {
            ManualMoodSelector(
                isPresented: $showMoodSelector,
                spotifyController: spotifyController,
                profile: profile,
                currentMood: $currentMood,
                currentMoodText: $currentMoodText,
                updateBackgroundColors: updateBackgroundColors
            )
        }
    }
    
    // Function to update resync button visibility
    private func updateResyncButtonVisibility() {
        // Show Resync button only if Spotify was connected before (hasConnectedSpotify) but is now disconnected
        showResyncSpotifyButton = hasConnectedSpotify && !spotifyController.isConnected && !showConnectToSpotifyButton
    }
    
    // Check camera permissions
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    showingCamera = true
                } else {
                    alertMessage = "Camera access is required to detect mood."
                    showingAlert = true
                }
            }
        case .denied, .restricted:
            alertMessage = "Enable camera access in Settings."
            showingAlert = true
        @unknown default:
            alertMessage = "Unexpected error occurred."
            showingAlert = true
        }
    }
    
    // Analyze the captured image using the backend
    private func analyzeImage(image: UIImage) {
        // Set loading state to true when starting analysis
        DispatchQueue.main.async {
            isDetectingMood = true
            currentMoodText = ""  // Clear current mood text while detecting
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            alertMessage = "Failed to convert image to JPEG."
            showingAlert = true
            isDetectingMood = false  // Reset loading state on error
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
            // Set loading state to false when analysis completes
            DispatchQueue.main.async {
                isDetectingMood = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Failed to analyze image: \(error.localizedDescription)"
                    showingAlert = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "No data received from the server."
                    showingAlert = true
                }
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               var emotion = json["emotion"] as? String,
               let probabilitiesDict = json["probabilities"] as? [String: Double] {
                
                // Adjust emotion based on specified cases
                switch emotion.lowercased() {
                case "surprise":
                    emotion = "happy"
                case "disgust", "fear":
                    emotion = "sad"
                case "neutral":
                    emotion = "chill"
                default:
                    break
                }
                
                let sortedProbabilities = probabilitiesDict.sorted { $0.value > $1.value }
                DispatchQueue.main.async {
                    probabilities = sortedProbabilities.map { ($0.key, $0.value) }
                    currentMood = moodEmoji(for: emotion)
                    currentMoodText = "You seem to be \(emotion.capitalized)."
                    updateBackgroundColors(for: emotion)
                    
                    // Check if mood is sad and show preference sheet
                    if emotion.lowercased() == "sad" {
                        detectedMood = emotion
                        showMoodPreferenceSheet = true
                    } else {
                        // For non-sad moods, proceed as normal
                        spotifyController.fetchRecommendations(mood: emotion, profile: profile, userGenres: profile.favoriteGenres)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "Invalid response from server."
                    showingAlert = true
                }
            }
        }.resume()
    }
    
    /*
     Method to call the connect() method within the SpotifyController to reconnect to Spotify
     */
    private func reConnectToSpotify() {
        spotifyController.connect()
    }
    
    // Convert emotion string to emoji
    private func moodEmoji(for emotion: String) -> String {
        switch emotion.lowercased() {
        case "happy": return "😄"
        case "sad": return "😢"
        case "angry": return "😡"
        case "chill": return "😌"
        default: return "😶"
        }
    }
    
    // Helper functions for the modern mood display
    private func getMoodGradient(for mood: String) -> [Color] {
        switch mood.lowercased() {
        case "happy":
            return [
                Color(hex: "#FFD700"),  // Gold
                Color(hex: "#FFA500"),  // Orange
                Color(hex: "#FFFF00")   // Yellow
            ]
        case "sad":
            return [
                Color(hex: "#4F74FF"),  // Blue
                Color(hex: "#8270FF"),  // Purple-Blue
                Color(hex: "#B6B4FF")   // Light Purple
            ]
        case "angry":
            return [
                Color(hex: "#FF0000"),  // Pure Red
                Color(hex: "#FF4444"),  // Bright Red
                Color(hex: "#FF6666")   // Light Red
            ]
        case "chill":
            return [
                Color(hex: "#00CED1"),  // Turquoise
                Color(hex: "#40E0D0"),  // Light Turquoise
                Color(hex: "#48D1CC")   // Medium Turquoise
            ]
        default:
            return [
                Color(hex: "#808080"),
                Color(hex: "#A0A0A0"),
                Color(hex: "#C0C0C0")
            ]
        }
    }
    
    private func getMoodIcon(for mood: String) -> String {
        // Parse the mood text to extract the actual mood
        let moodText = mood.lowercased()
        if moodText.contains("happy") {
            return "sun.max.fill"
        } else if moodText.contains("sad") {
            return "cloud.rain.fill"
        } else if moodText.contains("angry") {
            return "flame.fill"
        } else if moodText.contains("chill") {
            return "leaf.fill"
        } else {
            return "circle.fill"
        }
    }
    
    private func getMoodDescription(for mood: String) -> String {
        switch mood.lowercased() {
        case "happy": return "High energy, upbeat vibes"
        case "sad": return "Reflective, melancholic state"
        case "angry": return "Intense, powerful energy"
        case "chill": return "Relaxed, peaceful mindset"
        default: return "Neutral state"
        }
    }
}

struct MoodPreferenceView: View {
    let spotifyController: SpotifyController
    let profile: Profile
    let detectedMood: String
    @Binding var isPresented: Bool
    @Binding var manualMoodSelectorPresented: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // Emoji and Title
            VStack(spacing: 15) {
                Text("😢")
                    .font(.system(size: 60))
                
                Text("We noticed you're feeling down")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Text("How would you like to feel better?")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            // Buttons Stack
            VStack(spacing: 16) {
                Button(action: {
                    spotifyController.fetchRecommendations(mood: detectedMood, profile: profile, userGenres: profile.favoriteGenres)
                    isPresented = false
                    manualMoodSelectorPresented = false
                }) {
                    HStack {
                        Image(systemName: "cloud.rain")
                            .font(.title3)
                        Text("Lean into the feeling\nwith sad melodies")
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .foregroundColor(.primary)
                
                Button(action: {
                    spotifyController.fetchRecommendations(mood: "happy", profile: profile, userGenres: profile.favoriteGenres)
                    isPresented = false
                    manualMoodSelectorPresented = false
                }) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .font(.title3)
                        Text("Lift my spirits\nwith upbeat tunes")
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .frame(maxWidth: 340)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct ManualMoodSelector: View {
    @Binding var isPresented: Bool
    let spotifyController: SpotifyController
    let profile: Profile
    @Binding var currentMood: String
    @Binding var currentMoodText: String
    let updateBackgroundColors: (String) -> Void
    
    private let moods: [(name: String, description: String, gradient: [Color])] = [
        ("Happy", "Energetic & Upbeat", [
            Color(hex: "#FFD700"),
            Color(hex: "#FFA500"),
            Color(hex: "#FFFF00")
        ]),
        ("Sad", "Melancholic & Reflective", [
            Color(hex: "#4F74FF"),
            Color(hex: "#8270FF"),
            Color(hex: "#B6B4FF")
        ]),
        ("Angry", "Intense & Powerful", [
            Color(hex: "#FF0000"),
            Color(hex: "#FF4444"),
            Color(hex: "#FF6666")
        ]),
        ("Chill", "Calm & Peaceful", [
            Color(hex: "#00CED1"),
            Color(hex: "#40E0D0"),
            Color(hex: "#48D1CC")
        ])
    ]
    
    @State private var selectedMood: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showMoodPreferenceSheet = false
    @State private var detectedMood = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(moods, id: \.name) { mood in
                        Button(action: {
                            selectedMood = mood.name
                            updateMood(mood: mood.name.lowercased())
                        }) {
                            HStack {
                                // Gradient blob indicator
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: mood.gradient,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 60, height: 60)
                                        .blur(radius: 15)
                                }
                                .frame(width: 60, height: 60)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mood.name)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(mood.description)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                if selectedMood == mood.name {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 22))
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: mood.gradient,
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: selectedMood == mood.name ? 2 : 0
                                            )
                                    )
                            )
                        }
                        .scaleEffect(selectedMood == mood.name ? 1.02 : 1.0)
                        .animation(.spring(response: 0.3), value: selectedMood == mood.name)
                    }
                }
                .padding()
            }
            .background(Color.black.opacity(0.9))
            .navigationTitle("How are you feeling?")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showMoodPreferenceSheet) {
            MoodPreferenceView(
                spotifyController: spotifyController,
                profile: profile,
                detectedMood: detectedMood,
                isPresented: $showMoodPreferenceSheet,
                manualMoodSelectorPresented: $isPresented
            )
        }
    }
    
    private func updateMood(mood: String) {
        currentMood = getMoodIcon(for: mood)
        currentMoodText = mood.capitalized
        updateBackgroundColors(mood)
        
        if mood.lowercased() == "sad" {
            detectedMood = mood
            showMoodPreferenceSheet = true
        } else {
            let recommendationMood = mapMoodToRecommendation(mood)
            spotifyController.fetchRecommendations(
                mood: recommendationMood,
                profile: profile,
                userGenres: profile.favoriteGenres
            )
            isPresented = false
        }
    }
    
    private func mapMoodToRecommendation(_ mood: String) -> String {
        switch mood.lowercased() {
        case "anxious": return "chill"
        default: return mood
        }
    }
    
    private func getMoodIcon(for mood: String) -> String {
        switch mood.lowercased() {
        case "happy": return "sun.max.fill"
        case "sad": return "cloud.rain.fill"
        case "angry": return "flame.fill"
        case "chill": return "leaf.fill"
        default: return "circle.fill"
        }
    }
}

struct MoodCard: View {
    let mood: (name: String, emoji: String, color: Color, icon: String)
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(mood.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.system(size: 30))
                        
                        Image(systemName: mood.icon)
                            .font(.system(size: 12))
                            .foregroundColor(mood.color)
                            .opacity(0.8)
                    }
                }
                
                Text(mood.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: isSelected ? mood.color.opacity(0.3) : Color.black.opacity(0.1),
                            radius: isSelected ? 10 : 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        homePageView(
            profile: Profile(name: "Naz", dateOfBirth: Date(), favoriteGenres: ["Pop", "Rock"], hasAgreedToTerms: true),
            navigateToHomePage: .constant(false),
            isCreatingNewProfile: .constant(false),
            navigateToMusicPreferences: .constant(false), isCreatingProfile: .constant(false)
        )
    }
}
