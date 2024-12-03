/*
 CameraView.swift
 Moodify
 
 Created by Nazanin Mahmoudi and Kidd Chang
 This is a custom camera implementation for capturing selfies with quality checks
 for the mood detection feature.
 */

import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isCameraDismissed: Bool
    @Binding var shouldRetakePhoto: Bool
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
                
                /* Handles face detection errors by showing an alert and allowing users
                 to retake their photo if no face is detected */
                if !hasFace(in: fixedImage) {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "Face Not Fully Visible",
                            message: "Please ensure your entire face (including eyes and mouth) is clearly visible in the frame.",
                            preferredStyle: .alert
                        )
                        
                        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                            alert.dismiss(animated: true) {
                                picker.dismiss(animated: true) {
                                    self?.parent.image = nil
                                    self?.parent.shouldRetakePhoto = true
                                    self?.parent.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        })
                        
                        picker.present(alert, animated: true)
                    }
                    return
                }
                
                /* Handles image quality issues like poor lighting or low resolution
                 by showing an alert with specific feedback */
                if let qualityError = checkImageQuality(fixedImage) {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "Image Quality Issue",
                            message: qualityError,
                            preferredStyle: .alert
                        )
                        
                        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                            picker.dismiss(animated: true) {
                                self?.parent.image = nil
                                self?.parent.shouldRetakePhoto = true
                                self?.parent.presentationMode.wrappedValue.dismiss()
                            }
                        })
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                            self?.parent.presentationMode.wrappedValue.dismiss()
                        })
                        
                        picker.present(alert, animated: true)
                    }
                    return
                }
                
                parent.image = fixedImage
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isCameraDismissed = true
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        private func fixOrientation(image: UIImage, cameraDevice: UIImagePickerController.CameraDevice) -> UIImage {
            guard cameraDevice == .front else { return image }
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: image.size.width / 2, y: image.size.height / 2)
            context.scaleBy(x: -1.0, y: 1.0)
            context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return flippedImage ?? image
        }
        
        private func hasFace(in image: UIImage) -> Bool {
            guard let ciImage = CIImage(image: image) else { return false }
            
            let detector = CIDetector(ofType: CIDetectorTypeFace,
                                      context: nil,
                                      options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            
            let features = detector?.features(in: ciImage) as? [CIFaceFeature] ?? []
            
            guard features.count == 1,
                  let face = features.first else {
                return false
            }
            
            guard face.hasLeftEyePosition &&
                    face.hasRightEyePosition &&
                    face.hasMouthPosition else {
                return false
            }
            
            let imageHeight = ciImage.extent.height
            
            let eyesY = max(face.leftEyePosition.y, face.rightEyePosition.y)
            let mouthY = face.mouthPosition.y
            let eyeMouthDistance = eyesY - mouthY
            
            let minEyeMouthRatio: CGFloat = 0.15
            let minTopSpaceRatio: CGFloat = 0.2
            let minBottomSpaceRatio: CGFloat = 0.2
            
            let hasValidLayout = eyeMouthDistance / imageHeight >= minEyeMouthRatio &&
            eyesY / imageHeight <= (1.0 - minTopSpaceRatio) &&
            mouthY / imageHeight >= minBottomSpaceRatio
            
            return hasValidLayout
        }
        
        private func checkImageQuality(_ image: UIImage) -> String? {
            guard let cgImage = image.cgImage else { return "Invalid image format" }
            
            let brightness = calculateAverageBrightness(cgImage)
            if brightness < 0.2 {
                return "Image is too dark. Please try again with better lighting."
            }
            if brightness > 0.8 {
                return "Image is too bright. Please try again with less intense lighting."
            }
            
            if cgImage.width < 480 || cgImage.height < 480 {
                return "Image resolution is too low. Please try again."
            }
            
            return nil
        }
        
        private func calculateAverageBrightness(_ cgImage: CGImage) -> Double {
            let width = cgImage.width
            let height = cgImage.height
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width
            let bitsPerComponent = 8
            
            var totalBrightness: Double = 0
            
            guard let context = CGContext(data: nil,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: bitsPerComponent,
                                          bytesPerRow: bytesPerRow,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
                  let data = context.data else {
                return 0
            }
            
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            let buffer = data.assumingMemoryBound(to: UInt8.self)
            let totalPixels = width * height
            
            for i in stride(from: 0, to: totalPixels * 4, by: 4) {
                let r = Double(buffer[i])
                let g = Double(buffer[i + 1])
                let b = Double(buffer[i + 2])
                totalBrightness += (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            }
            
            return totalBrightness / Double(totalPixels)
        }
    }
}
