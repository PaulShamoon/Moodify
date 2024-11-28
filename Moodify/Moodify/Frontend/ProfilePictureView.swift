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
    @Binding var navigateToHomePage: Bool
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isCropping: Bool = false
    @State private var originalImage: UIImage? = nil // Preserve the original image
    @State private var croppedImage: UIImage? = nil // Reflect cropping adjustments
    @State private var scale: CGFloat = 1.0 // Cropping scale adjustment
    @State private var offset: CGSize = .zero // Cropping offset adjustment

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set a Profile Picture")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
            
            ZStack {
                // Show cropped image if available, otherwise fallback to selected or saved image
                if let image = croppedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.green, lineWidth: 4))
                        .shadow(radius: 10)
                } else if let image = originalImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.green, lineWidth: 4))
                        .shadow(radius: 10)
                } else if let profile = profileManager.currentProfile,
                          let profilePictureData = profile.profilePicture,
                          let profileImage = UIImage(data: profilePictureData) {
                    // Load and display saved profile picture
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.green, lineWidth: 4))
                        .shadow(radius: 10)
                } else {
                    // Placeholder for when no image is selected
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
                
                // Crop Icon Button
                if croppedImage != nil || originalImage != nil {
                    Button(action: {
                        isCropping = true
                    }) {
                        Image(systemName: "crop")
                            .font(.system(size: 20))
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .offset(x: 60, y: 60)
                }
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
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $originalImage)
        }
        .sheet(isPresented: $isCropping) {
            CropView(
                originalImage: $originalImage,
                croppedImage: $croppedImage,
                isCropping: $isCropping,
                scale: $scale,
                offset: $offset
            )
        }
    }
    
    func saveProfilePicture() {
        guard let currentProfile = profileManager.currentProfile else { return }
        guard let imageToSave = croppedImage ?? originalImage else { return } // Use cropped or original image

        // Convert the image to Data
        if let imageData = imageToSave.jpegData(compressionQuality: 0.8) {
            // Update the profile using ProfileManager's updateProfile method
            profileManager.updateProfile(
                profile: currentProfile,
                name: currentProfile.name,
                dateOfBirth: currentProfile.dateOfBirth,
                favoriteGenres: currentProfile.favoriteGenres,
                hasAgreedToTerms: currentProfile.hasAgreedToTerms,
                userPin: currentProfile.userPin,
                personalSecurityQuestion: currentProfile.personalSecurityQuestion,
                securityQuestionAnswer: currentProfile.securityQuestionAnswer,
                profilePicture: imageData // Pass the updated profile picture data
            )
            navigateToHomePage = true
        }
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
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Dynamically update sourceType to handle changes
        if uiViewController.sourceType != sourceType {
            uiViewController.sourceType = sourceType
        }
    }
    
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
