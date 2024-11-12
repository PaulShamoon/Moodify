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


    // NOTE - this URL is temporary and needs to be updated each time from the backend side to detect mood properly
    let backendURL = "https://5c39-50-4-216-192.ngrok-free.app/analyze"
    
    // Add this property to manage background color
    @State private var backgroundColors: [Color] = [
        Color(red: 0.075, green: 0.075, blue: 0.075),  // Very dark gray, almost black
        Color(red: 0.1, green: 0.1, blue: 0.1)         // Slightly lighter dark gray
    ]
    
    // Add this method to determine background colors based on mood
    private func updateBackgroundColors(for emotion: String) {
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
                VStack {
                    HStack {
                        Text("Your Current Mood")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        Button(action: {
                            showMoodSelector = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    ZStack {
                        // Frosted glass effect background
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                            .frame(width: 150, height: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        Text(currentMood)
                            .font(.system(size: 70))
                    }
                    .padding(.vertical, 8)
                    
                    Text(currentMoodText)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.2, green: 0.4, blue: 0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 0.4, green: 0.3, blue: 0.2), lineWidth: 3.0)
                        )
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Player View
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
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        checkCameraPermission()
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.system(size: 16))
                            Text(isDetectingMood ? "Detecting..." : "Detect Mood")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.3))
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 0.2, green: 0.4, blue: 0.3), lineWidth: 1.5)
                                )
                        )
                    }
                    
                    // Connect to Spotify Button
                    if showConnectToSpotifyButton {
                        Button(action: {
                            navigateToSpotify = true
                        }) {
                            HStack {
                                Image(systemName: "music.note")
                                    .font(.system(size: 16))
                                Text("Connect to Spotify")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.3))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(red: 0.2, green: 0.4, blue: 0.3), lineWidth: 1.5)
                                    )
                            )
                        }
                    }

                    // Resync Spotify Button
                    if showResyncSpotifyButton {
                        Button(action: {
                            spotifyController.resetFirstConnectionAttempt()
                            spotifyController.refreshPlayerState()
                            showResyncSpotifyButton = false // Hide the button after resync
                        }) {
                            HStack {
                                Image(systemName: "music.note")
                                    .font(.system(size: 16))
                                Text("Resync Spotify")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.3))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(red: 0.2, green: 0.4, blue: 0.3), lineWidth: 1.5)
                                    )
                            )
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 60)
            /*
            .onAppear {
                // Check if the access token is available and not expired
                if spotifyController.accessToken != nil, !spotifyController.isAccessTokenExpired() {
                    if !spotifyController.isConnected {
                        spotifyController.initializeSpotifyConnection()
                        showResyncSpotifyButton = true // Show resync button if disconnected
                    } else {
                        showResyncSpotifyButton = false // Hide resync if already connected
                    }
                    showConnectToSpotifyButton = false
                } else {
                    print("Access token is expired or missing. Please reconnect to Spotify.")
                    showConnectToSpotifyButton = true // Show connect button if not connected
                }
            }*/
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
                isPresented: $showMoodPreferenceSheet
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
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            alertMessage = "Failed to convert image to JPEG."
            showingAlert = true
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
}

struct MoodPreferenceView: View {
    let spotifyController: SpotifyController
    let profile: Profile
    let detectedMood: String
    @Binding var isPresented: Bool
    
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
    
    private let moods: [(name: String, emoji: String, color: Color, icon: String)] = [
        ("Happy", "😄", .yellow, "sun.max.fill"),
        ("Sad", "😢", .blue, "cloud.rain"),
        ("Angry", "😡", .red, "flame.fill"),
        ("Chill", "😌", .mint, "leaf.fill")
    ]
    
    @State private var selectedMood: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showMoodPreferenceSheet = false
    @State private var detectedMood = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    Text("How are you feeling?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // First row - 2 items
                    HStack(spacing: 15) {
                        MoodCard(
                            mood: moods[0], // Happy
                            isSelected: selectedMood == moods[0].name,
                            action: { selectedMood = moods[0].name; updateMood(mood: moods[0].name.lowercased()) }
                        )
                        MoodCard(
                            mood: moods[1], // Sad
                            isSelected: selectedMood == moods[1].name,
                            action: { selectedMood = moods[1].name; updateMood(mood: moods[1].name.lowercased()) }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Second row - 2 items
                    HStack(spacing: 15) {
                        MoodCard(
                            mood: moods[2], // Angry
                            isSelected: selectedMood == moods[2].name,
                            action: { selectedMood = moods[2].name; updateMood(mood: moods[2].name.lowercased()) }
                        )
                        MoodCard(
                            mood: moods[3], // Chill
                            isSelected: selectedMood == moods[3].name,
                            action: { selectedMood = moods[3].name; updateMood(mood: moods[3].name.lowercased()) }
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
        .sheet(isPresented: $showMoodPreferenceSheet) {
            MoodPreferenceView(
                spotifyController: spotifyController,
                profile: profile,
                detectedMood: detectedMood,
                isPresented: $showMoodPreferenceSheet
            )
            /**
             Closes manual selector after preference selection
             Created by: Nazanin Mahmoudi
             */
            .onDisappear {
                isPresented = false
            }
        }
    }
    
    /**
     Updates UI and handles music recommendations based on selected mood.
     Displays preference options if user selects 'sad'.
     
     @param mood: String representing the selected mood
     Created by: Nazanin Mahmoudi
     */
    private func updateMood(mood: String) {
        // Update UI
        currentMood = moods.first(where: { $0.name.lowercased() == mood.lowercased() })?.emoji ?? "😶"
        currentMoodText = "You're feeling \(mood.capitalized)"
        updateBackgroundColors(mood)
        
        if mood.lowercased() == "sad" {
            /** Show preference options for sad mood */
            detectedMood = mood
            showMoodPreferenceSheet = true
        } else {
            /** Direct music recommendations for other moods */
            let recommendationMood = mapMoodToRecommendation(mood)
            spotifyController.fetchRecommendations(
                mood: recommendationMood,
                profile: profile,
                userGenres: profile.favoriteGenres
            )
            isPresented = false
        }
    }
    
    /**
     Maps mood selections to appropriate music categories
     Created by: Nazanin Mahmoudi
     */
    private func mapMoodToRecommendation(_ mood: String) -> String {
        switch mood.lowercased() {
        case "anxious": return "chill"
        default: return mood
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
