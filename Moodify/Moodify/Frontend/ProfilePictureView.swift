//
//  ProfilePictureView.swift
//  Moodify
//
//  Created by Mahdi Sulaiman on 11/25/24.
//


import SwiftUI
import PhotosUI

struct ProfilePictureView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var selectedImage: UIImage? = nil
    @Binding var navigateToHomePage: Bool // Add this to handle navigation
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Set a Profile Picture")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
            
            if let image = selectedImage {
                // If a new image is selected, show it
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.green, lineWidth: 4)
                    )
                    .shadow(radius: 10)
            } else if let profile = profileManager.currentProfile,
                      let imagePath = String(data: profile.profilePicture ?? Data(), encoding: .utf8),
                      let savedImage = UIImage(contentsOfFile: imagePath) {
                // Load and display the saved profile picture if it exists
                Image(uiImage: savedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.green, lineWidth: 4)
                    )
                    .shadow(radius: 10)
            } else {
                // Display placeholder if no image is set or saved
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
            
            
            HStack {
                Button(action: {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }) {
                    Text("Choose from Library")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    sourceType = .camera
                    showImagePicker = true
                }) {
                    Text("Take a Photo")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            if selectedImage != nil {
                Button(action: {
                    saveProfilePicture()
                    navigateToHomePage = true
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Profile Picture")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $selectedImage)
        }
    }
    
    func saveProfilePicture() {
        guard let profile = profileManager.currentProfile else { return }
        guard let selectedImage = selectedImage else { return }
        
        // Convert the UIImage to Data
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }
        
        // Create a unique file name for the image using the profile ID
        let fileName = "\(profile.id.uuidString).jpg"
        
        // Get the file URL for saving the image in the app's documents directory
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            // Save the image data to the file
            try imageData.write(to: fileURL)
            
            // Update the profile using ProfileManager's updateProfile method
            profileManager.updateProfile(
                profile: profile,
                name: profile.name,
                dateOfBirth: profile.dateOfBirth,
                favoriteGenres: profile.favoriteGenres,
                hasAgreedToTerms: profile.hasAgreedToTerms,
                userPin: profile.userPin,
                personalSecurityQuestion: profile.personalSecurityQuestion,
                securityQuestionAnswer: profile.securityQuestionAnswer
            )
            
            // Add the file path as the profile picture
            if let index = profileManager.profiles.firstIndex(where: { $0.id == profile.id }) {
                profileManager.profiles[index].profilePicture = fileURL.path.data(using: .utf8)
            }
            navigateToHomePage = true
            print("Profile picture saved for \(profile.name) at \(fileURL.path)")
        } catch {
            print("Failed to save profile picture: \(error.localizedDescription)")
        }
    }
    
    // Helper function to get the app's documents directory
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProfilePictureView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock profile for testing
        let mockProfile = Profile(
            id: UUID(),
            name: "Test User",
            dateOfBirth: Date(),
            favoriteGenres: ["Rock", "Jazz"],
            hasAgreedToTerms: true,
            userPin: nil,
            personalSecurityQuestion: nil,
            securityQuestionAnswer: nil,
            profilePicture: nil
        )
        
        // Mock ProfileManager
        let mockProfileManager = ProfileManager()
        mockProfileManager.currentProfile = mockProfile
        mockProfileManager.profiles.append(mockProfile)
        
        return ProfilePictureView(navigateToHomePage: .constant(false))
            .environmentObject(mockProfileManager)
    }
}
