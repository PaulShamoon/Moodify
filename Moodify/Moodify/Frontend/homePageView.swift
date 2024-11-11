import SwiftUI
import AVFoundation

struct homePageView: View {
    let profile: Profile  // Profile passed from ProfileSelectionView
    @Binding var navigateToHomePage: Bool
    @Binding var isCreatingNewProfile: Bool
    @Binding var navigateToMusicPreferences: Bool
    @State private var navigateToSpotify = false // State for navigation
    
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
    
    // NOTE - this URL is temporary and needs to be updated each time from the backend side to detect mood properly
    let backendURL = "https://25f7-2601-406-4d00-7af0-b905-2ee2-ba90-3017.ngrok-free.app/analyze"
    
    // Add this property to manage background color
    @State private var backgroundColors: [Color] = [
        Color(red: 0.15, green: 0.25, blue: 0.20).opacity(0.3),  // Initial faint dark green
        Color(red: 0.15, green: 0.25, blue: 0.20).opacity(0.1)   // Lighter shade for gradient
    ]
    
    // Add this method to determine background colors based on mood
    private func updateBackgroundColors(for emotion: String) {
        withAnimation(.easeInOut(duration: 1.0)) {
            switch emotion.lowercased() {
            case "happy":
                backgroundColors = [
                    Color.yellow.opacity(0.3),
                    Color.orange.opacity(0.2)
                ]
            case "sad":
                backgroundColors = [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2)
                ]
            case "angry":
                backgroundColors = [
                    Color.red.opacity(0.3),
                    Color.orange.opacity(0.2)
                ]
            case "surprise":
                backgroundColors = [
                    Color.purple.opacity(0.3),
                    Color.pink.opacity(0.2)
                ]
            case "neutral":
                backgroundColors = [
                    Color(red: 0.5, green: 0.5, blue: 0.5).opacity(0.3),
                    Color(red: 0.6, green: 0.6, blue: 0.6).opacity(0.2)
                ]
            default:
                backgroundColors = [
                    Color(red: 0.15, green: 0.25, blue: 0.20).opacity(0.3),
                    Color(red: 0.15, green: 0.25, blue: 0.20).opacity(0.1)
                ]
            }
        }
    }
    
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
                    Text("Welcome, \(profile.name)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.leading, 35)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation { showMenu.toggle() }
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.3)))
                            .shadow(radius: 10)
                    }
                }
                .padding(.horizontal)
                
                // Mood Display
                VStack{
                    Text("Your Current Mood")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    
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
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.1), lineWidth: 0.5)
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
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                    }
                    
                    Button(action: {
                        if spotifyController.accessToken == nil {
                            navigateToSpotify = true
                        } else {
                            reConnectToSpotify()
                        }
                    }) {
                        HStack {
                            Image(systemName: "music.note")
                                .font(.system(size: 16))
                            Text(spotifyController.accessToken == nil ? "Connect to Spotify" : "Resume Playback")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Player View
                PlayerView(spotifyController: spotifyController)
                    .padding(.horizontal)
            }
            .padding(.top, 60)
            
            // Add navigation handling
            .navigationDestination(isPresented: $navigateToSpotify) {
                ConnectToSpotifyView(spotifyController: spotifyController)
            }
            
            // Slide-in menu
            if showMenu {
                MenuView(
                    showMenu: $showMenu,
                    navigateToHomePage: $navigateToHomePage,
                    isCreatingNewProfile: $isCreatingProfile,
                    navigateToMusicPreferences: $navigateToMusicPreferences,
                    spotifyController: spotifyController
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $capturedImage)
                .onDisappear {
                    if let image = capturedImage {
                        analyzeImage(image: image)
                    } else {
                        alertMessage = "Image capture failed. Please try again."
                        showingAlert = true
                    }
                }
        }
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
               let emotion = json["emotion"] as? String,
               let probabilitiesDict = json["probabilities"] as? [String: Double] {
                
                let sortedProbabilities = probabilitiesDict.sorted { $0.value > $1.value }
                DispatchQueue.main.async {
                    probabilities = sortedProbabilities.map { ($0.key, $0.value) }
                    currentMood = moodEmoji(for: emotion)
                    currentMoodText = "You seem to be \(emotion.capitalized)."
                    updateBackgroundColors(for: emotion)
                    spotifyController.fetchRecommendations(mood: emotion, profile: profile, userGenres: profile.favoriteGenres)
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
        case "surprise": return "😲"
        case "neutral": return "😐"
        default: return "😶"
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                let fixedImage = fixOrientation(image: image, cameraDevice: picker.cameraDevice)
                parent.image = fixedImage  // Save the corrected image!!!
            } else {
                print("Failed to capture image.")
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        //I decided to add this to not have the image be captured inverted
        private func fixOrientation(image: UIImage, cameraDevice: UIImagePickerController.CameraDevice) -> UIImage {
            guard cameraDevice == .front else { return image }
            // Apply horizontal flip to the image
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: image.size.width / 2, y: image.size.height / 2)
            context.scaleBy(x: -1.0, y: 1.0)  // Flip horizontally
            context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return flippedImage ?? image
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        homePageView(
            profile: Profile(name: "Test User", dateOfBirth: Date(), favoriteGenres: ["Pop", "Rock"], hasAgreedToTerms: true),
            navigateToHomePage: .constant(false),
            isCreatingNewProfile: .constant(false),
            navigateToMusicPreferences: .constant(false), isCreatingProfile: .constant(false)
        )
    }
}
