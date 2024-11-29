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
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isCropping = false
    @State private var originalImage: UIImage?
    @State private var croppedImage: UIImage?
    @State private var showIconPicker = false
    @Environment(\.presentationMode) var presentationMode
    
    var currentImage: UIImage? {
        if let image = croppedImage { return image }
        if let image = originalImage { return image }
        if let profile = profileManager.currentProfile,
           let imageData = profile.profilePicture {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Set a Profile Picture")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            ZStack {
                if let image = currentImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.green, lineWidth: 4))
                        .shadow(radius: 10)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 180, height: 180)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
                
                if currentImage != nil {
                    Button(action: {
                        // Load the current image into originalImage before cropping
                        if originalImage == nil {
                            originalImage = currentImage
                        }
                        isCropping = true
                    }) {
                        Image(systemName: "crop")
                            .font(.system(size: 20))
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .offset(x: 70, y: 70)
                }
            }
            .padding(.vertical, 20)
            HStack(spacing: 16) {
                Button(action: {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose from Library")
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    showIconPicker = true  // Add this state variable
                }) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("Choose an Icon Instead")
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
            
            .padding(.horizontal)
            
            Spacer()
            
            if currentImage != nil {
                Button(action: saveAndDismiss) {
                    HStack{
                        Text("Save Profile Picture")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            } else {
                Button(action:{
                    navigateToHomePage = true
                    presentationMode.wrappedValue.dismiss()
                }
                ) {
                    HStack{
                        Text("Skip")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: Binding(
                get: { originalImage },
                set: { newImage in
                    originalImage = newImage
                    croppedImage = nil  // Clear the cropped image when selecting a new photo
                }
            ))
        }
        .sheet(isPresented: $isCropping) {
            CropView(
                originalImage: $originalImage,
                croppedImage: $croppedImage,
                isCropping: $isCropping
            )
            .interactiveDismissDisabled()
        }
        .onAppear {
            // Load saved profile picture if it exists
            if originalImage == nil,
               let profile = profileManager.currentProfile,
               let imageData = profile.profilePicture,
               let savedImage = UIImage(data: imageData) {
                originalImage = savedImage
            }
        }
        .sheet(isPresented: $showIconPicker) {
            CustomProfileIconView(
                isCropping: $isCropping,
                originalImage: $originalImage,
                croppedImage: $croppedImage
            )
        }
    }
    
    private func saveAndDismiss() {
        if let profile = profileManager.currentProfile,
           let imageToSave = currentImage,
           let imageData = imageToSave.jpegData(compressionQuality: 0.8) {
            
            profileManager.updateProfile(
                profile: profile,
                name: profile.name,
                dateOfBirth: profile.dateOfBirth,
                favoriteGenres: profile.favoriteGenres,
                hasAgreedToTerms: profile.hasAgreedToTerms,
                userPin: profile.userPin,
                personalSecurityQuestion: profile.personalSecurityQuestion,
                securityQuestionAnswer: profile.securityQuestionAnswer,
                profilePicture: imageData
            )
            
            navigateToHomePage = true
            presentationMode.wrappedValue.dismiss()
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
