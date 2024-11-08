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
    
    // NOTE - this URL is temporary and needs to be updated each time from the backend side to detect mood properly
    let backendURL = "https://6e9f-143-59-31-134.ngrok-free.app/analyze"
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 30) {
                        // Header with menu button
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation { showMenu.toggle() }
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        // Welcome and mood display
                        VStack(spacing: 30) {
                            Text("Welcome, \(profile.name)")
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Text("Your Current Mood")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(currentMood)
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.gray.opacity(0.4)))
                                .shadow(radius: 10)
                            
                            Text(currentMoodText)
                                .font(.body)
                                .foregroundColor(.white)
                            
                            // Probabilities display
                            if !probabilities.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Probabilities")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    ForEach(probabilities, id: \.emotion) { prob in
                                        HStack {
                                            Text("\(prob.emotion.capitalized):")
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text("\(String(format: "%.2f", prob.probability * 100))%")
                                                .foregroundColor(.green)
                                        }
                                        .padding(.vertical, 5)
                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3)))
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Detect Mood button
                        Button(action: {
                            checkCameraPermission()
                        }) {
                            HStack {
                                Image(systemName: "camera")
                                Text(isDetectingMood ? "Detecting..." : "Detect Mood")
                            }
                            .padding()
                            .background(Capsule().fill(Color.green))
                            .shadow(radius: 10)
                        }
                        
                         // Connect to Spotify/Resume Playback button
                        if !hasConnectedSpotify || spotifyController.accessToken == nil {
                            Button(action: {
                                navigateToSpotify = true
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
                        }
                        if hasConnectedSpotify && spotifyController.accessToken != nil {
                            // Player to control Spotify
                            PlayerView(spotifyController: spotifyController)
                            .padding(.horizontal)
                        }
                            // Padding on the outside for better spacing
                        
                        
                        
                        Spacer()

                    }
                    .padding(.top, 60)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .navigationDestination(isPresented: $navigateToSpotify) {
                    ConnectToSpotifyView(spotifyController: spotifyController)
                        .onDisappear {
                            // Set flag when user completes Spotify connection
                            if spotifyController.accessToken != nil {
                                hasConnectedSpotify = true
                            }
                        }
                }
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
                    .transition(.move(edge: .trailing)) // Slide in from the right
                    .zIndex(1) // Ensure the menu is above the main content
            }
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
