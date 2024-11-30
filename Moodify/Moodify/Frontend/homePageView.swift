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
    let backendURL = "/analyze"
    
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
                    Color(hex: "#2C2620"),  // Deep warm brown
                    Color(hex: "#1C1915")   // Rich dark brown
                ]
            case "sad":
                backgroundColors = [
                    Color(hex: "#1A1B2E"),  // Deep midnight blue
                    Color(hex: "#15162B")   // Dark navy
                ]
            case "angry":
                backgroundColors = [
                    Color(hex: "#2A1517"),  // Deep maroon
                    Color(hex: "#1C1314")   // Dark burgundy
                ]
            case "chill":
                backgroundColors = [
                    Color(hex: "#162226"),  // Deep teal
                    Color(hex: "#131B1D")   // Dark aqua
                ]
            default:
                backgroundColors = [
                    Color(hex: "#1A1A1A"),
                    Color(hex: "#141414")
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
    
    // Add these state variables
    @State private var showMoodConfirmation = false
    @State private var detectedEmotion = ""
    @State private var detectedConfidence: Double = 0.0
    
    // Define a constant for the milky beige color at the top of the struct
    let milkyBeige = Color(hex: "#F5E6D3")
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Inside your main ZStack, right after the background gradient
            // Add particle overlay for the current mood
            particleEffect(for: currentMoodText)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false) // Ensures particles don't interfere with UI interaction
            
            VStack {
                // Header with profile and settings
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(milkyBeige.opacity(0.9))
                        Text(profile.name)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(milkyBeige)
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
                                Image("spotify-logo")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22)
                                    .clipShape(Circle())
                                Text("Connect")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(milkyBeige)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#1DB954")) // Spotify green
                                    .opacity(0.9)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(milkyBeige.opacity(0.2), lineWidth: 1)
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
                            .foregroundColor(milkyBeige)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#1DB954")) // Spotify green
                                    .opacity(0.7)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(milkyBeige.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    
                    Button(action: {
                        withAnimation { showMenu.toggle() }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .foregroundColor(milkyBeige)
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
                            Text("You're Feeling")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(milkyBeige.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            Text(currentMoodText.capitalized)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(milkyBeige)
                        }
                        Spacer()
                        
                        // More prominent mood selector button with dark green
                        Button(action: {
                            showMoodSelector = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "paintpalette.fill")
                                    .font(.system(size: 16))
                                Text("Select Mood")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(milkyBeige)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(hex: "#1A2F2A")) // Dark green background
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
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
                
                // Detect Mood Button
                Button(action: {
                    checkCameraPermission()
                }) {
                    HStack {
                        Image(systemName: "camera")
                            .font(.system(size: 24))
                        Text(isDetectingMood ? "Detecting..." : "Detect Mood")
                            .font(.system(size: 24, weight: .medium))
                    }
                    .foregroundColor(milkyBeige)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(
                        ZStack {
                            // Main background
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(
                                    colors: [
                                        Color(hex: "#2C2C2C"),
                                        Color(hex: "#1A1A1A")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                            
                            // Shimmering border
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            milkyBeige.opacity(0.2),
                                            milkyBeige.opacity(0.5),
                                            milkyBeige.opacity(0.2)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "#FF6B6B").opacity(0.3),
                                                    Color(hex: "#4ECDC4").opacity(0.3),
                                                    Color(hex: "#FF6B6B").opacity(0.3)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        }
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .onAppear {
                    isMoodButtonAnimating = true
                }
                
                // Player View - Moved up
                PlayerView(spotifyController: spotifyController)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Group {
                            // Main background
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "#1A2F2A"))  // Darker green
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 5, y: 5) // Dark shadow
                                .shadow(color: Color(hex: "#243B35").opacity(0.3), radius: 10, x: -5, y: -5) // Light shadow
                            
                            // Inner highlight
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),  // Subtle highlight
                                            Color.clear,
                                            Color.black.opacity(0.1)   // Subtle shadow
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                            
                            // Subtle inner glow
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    Color(hex: "#243B35").opacity(0.2),
                                    lineWidth: 1
                                )
                                .blur(radius: 1)
                                .padding(1)
                        }
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
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
                                    .foregroundColor(milkyBeige)
                                Text("Back")
                                    .foregroundColor(milkyBeige)
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
        .sheet(isPresented: $showMoodConfirmation) {
            MoodConfirmationSheet(
                detectedMood: detectedEmotion,
                confidence: detectedConfidence,
                isPresented: $showMoodConfirmation,
                onConfirm: {
                    currentMood = moodEmoji(for: detectedEmotion)
                    currentMoodText = detectedEmotion.capitalized
                    updateBackgroundColors(for: detectedEmotion)
                    
                    if detectedEmotion.lowercased() == "sad" {
                        detectedMood = detectedEmotion
                        showMoodPreferenceSheet = true
                    } else {
                        spotifyController.fetchRecommendations(
                            mood: detectedEmotion,
                            profile: profile,
                            userGenres: profile.favoriteGenres
                        )
                    }
                },
                onRetake: {
                    checkCameraPermission()
                }
            )
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.clear)
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
                    if let emotion = probabilitiesDict.max(by: { $0.value < $1.value })?.key {
                        DispatchQueue.main.async {
                            let mappedEmotion = mapDetectedEmotion(emotion)
                            detectedEmotion = mappedEmotion
                            detectedConfidence = probabilitiesDict[emotion] ?? 0.0
                            showMoodConfirmation = true
                            
                            // Update UI elements
                            currentMood = getMoodIcon(for: mappedEmotion)
                            currentMoodText = mappedEmotion.capitalized
                            updateBackgroundColors(for: mappedEmotion)
                        }
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
                Color(hex: "#DAA520"),  // Golden rod
                Color(hex: "#B8860B"),  // Dark golden rod
                Color(hex: "#CD853F")   // Peru gold
            ]
        case "sad":
            return [
                Color(hex: "#4B0082"),  // Indigo
                Color(hex: "#483D8B"),  // Dark slate blue
                Color(hex: "#6A5ACD")   // Slate blue
            ]
        case "angry":
            return [
                Color(hex: "#800000"),  // Maroon
                Color(hex: "#8B0000"),  // Dark red
                Color(hex: "#A52A2A")   // Brown red
            ]
        case "chill":
            return [
                Color(hex: "#008B8B"),  // Dark cyan
                Color(hex: "#20B2AA"),  // Light sea green
                Color(hex: "#5F9EA0")   // Cadet blue
            ]
        default:
            return [
                Color(hex: "#696969"),  // Dim gray
                Color(hex: "#808080"),  // Gray
                Color(hex: "#A9A9A9")   // Dark gray
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
    
    // Add these methods to your homePageView struct
    @ViewBuilder
    private func particleEffect(for mood: String) -> some View {
        switch mood.lowercased() {
        case let m where m.contains("happy"):
            ParticleEmitterView(
                particleImage: UIImage(systemName: "sparkle")?.withTintColor(.yellow) ?? UIImage(),
                birthRate: 4,
                lifetime: 8,
                velocity: 100,
                scale: 0.15,
                color: UIColor(Color(hex: "#FFD700").opacity(0.8))
            )
        case let m where m.contains("sad"):
            ParticleEmitterView(
                particleImage: UIImage(systemName: "drop.fill")?.withTintColor(.blue) ?? UIImage(),
                birthRate: 6,
                lifetime: 10,
                velocity: 150,
                scale: 0.12,
                color: UIColor(Color(hex: "#4F74FF").opacity(0.6))
            )
        case let m where m.contains("chill"):
            ParticleEmitterView(
                particleImage: UIImage(systemName: "leaf.fill")?.withTintColor(.green) ?? UIImage(),
                birthRate: 3,
                lifetime: 12,
                velocity: 80,
                scale: 0.18,
                color: UIColor(Color(hex: "#40E0D0").opacity(0.7))
            )
        case let m where m.contains("angry"):
            ParticleEmitterView(
                particleImage: UIImage(systemName: "flame.fill")?.withTintColor(.red) ?? UIImage(),
                birthRate: 8,
                lifetime: 6,
                velocity: 120,
                scale: 0.15,
                color: UIColor(Color(hex: "#FF4444").opacity(0.7))
            )
        default:
            EmptyView()
        }
    }
    
    // Add this function to map detected emotions to our 4 moods
    private func mapDetectedEmotion(_ emotion: String) -> String {
        switch emotion.lowercased() {
        case "happy", "joy", "excited", "content":
            return "happy"
        case "sad", "depressed", "melancholy":
            return "sad"
        case "angry", "rage", "frustrated":
            return "angry"
        case "chill", "calm", "relaxed", "neutral", "peaceful":
            return "chill"
        default:
            return "chill"  // Default to chill if unknown emotion detected
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

// Add this new struct above ManualMoodSelector
struct MoodButton: View {
    let mood: (name: String, description: String, gradient: [Color])
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                
                Spacer()
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mood.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#F5E6D3"))
                    
                    Text(mood.description)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#F5E6D3").opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#F5E6D3"))
                        .font(.system(size: 22))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? mood.gradient : [Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isSelected ? 2 : 0
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
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
                    // Replace the navigation title with a custom title
                    Text("How are you feeling?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "#F5E6D3")) // Same green as player
                        .shadow(color: Color(hex: "#243B35").opacity(0.3), radius: 8, x: 0, y: 0) // Subtle glow
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                        .padding(.bottom, 10)
                    
                    Text("Select Your Mood")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#F5E6D3"))
                        .padding(.top, 10)
                    
                    ForEach(moods, id: \.name) { mood in
                        MoodButton(
                            mood: mood,
                            isSelected: selectedMood == mood.name,
                            action: {
                                selectedMood = mood.name
                                updateMood(mood: mood.name.lowercased())
                            }
                        )
                    }
                }
                .padding()
            }
            .background(
                Color(hex: "#2C2620")  // Dark brown color
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarHidden(true)
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

// Add this extension to modify the navigation title color
extension View {
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(color)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(color)]
        return self
    }
}
