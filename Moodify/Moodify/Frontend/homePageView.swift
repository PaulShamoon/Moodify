import SwiftUI
import AVFoundation

struct homePageView: View {
    var profile: Profile // Accept a profile as a parameter
    @StateObject private var model = EmotionDetection()
    @State private var showingCamera = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var capturedImage: UIImage?
    @State private var currentMood: String = "😶"
    @State private var currentMoodText: String = ""
    @State private var isDetectingMood: Bool = false
    @StateObject var spotifyController = SpotifyController()
    @State private var navigateToSpotify = false // State for navigation
    @State private var showMenu = false // State to show/hide the side menu
    @Binding var navigateToHomePage: Bool // This will be passed from outside


    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 30) {
                        // Header with menu button
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showMenu.toggle() // Toggle the menu
                                }
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }

                        // Display profile info
                        Text("Welcome, \(profile.name)")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()

                        // Title and Mood Display
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

                            // Subtitle
                            Text("Discover playlists that match your mood")
                                .font(.system(size: 18, weight: .light, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)

                            // Mood Display
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

                                Text(currentMoodText)
                                    .font(.system(size: 22, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }

                        // Detect Mood Button
                        Button(action: {
                            checkCameraPermission()
                        }) {
                            HStack {
                                Image(systemName: "camera")
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

                        // Connect to Spotify Button
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
                        Spacer()
                    }
                    .padding(.top, 60)
                    .navigationDestination(isPresented: $navigateToSpotify) {
                        ConnectToSpotifyDisplay(spotifyController: spotifyController)
                    }
                }
            }

            // Overlay the Menu if showMenu is true
            if showMenu {
                MenuView(showMenu: $showMenu, navigateToHomePage: $navigateToHomePage)
                    .transition(.move(edge: .trailing)) // Slide in from the right
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $capturedImage)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: capturedImage) { newImage in
            if let newImage = newImage {
                isDetectingMood = false
                if let result = model.detectEmotion(in: newImage) {
                    let emotion = result.target
                    let probability = result.targetProbability
                    currentMoodText = emotion.prefix(1).uppercased() + emotion.dropFirst()
                    currentMood = emotionToEmoji(emotion)
                    print(probability)
                }
            }
        }
        .onChange(of: model.error) { newError in
            if let error = newError {
                alertMessage = error
                showingAlert = true
                isDetectingMood = false
            }
        }
    }

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
            alertMessage = "Camera access is required to detect mood. Please enable it in Settings."
            showingAlert = true
        @unknown default:
            alertMessage = "Unexpected error occurred while accessing the camera."
            showingAlert = true
        }
    }

    private func emotionToEmoji(_ emotion: String) -> String {
        switch emotion.lowercased() {
        case "happy":
            return "😊"
        case "sad":
            return "😢"
        case "angry":
            return "😡"
        case "neutral":
            return "😐"
        default:
            return "🤔"
        }
    }

    // Placeholder: Spotify API Integration
    func connectSpotify() {
        spotifyController.connect()
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
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
