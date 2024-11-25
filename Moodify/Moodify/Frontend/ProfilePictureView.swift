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
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set a Profile Picture")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
            
            if let image = selectedImage {
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
            } else {
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
        if let selectedImage = selectedImage {
            print("Profile picture saved for \(profile.name)")
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
