import SwiftUI

struct CropView: View {
    @Binding var originalImage: UIImage? // The original image
    @Binding var croppedImage: UIImage? // The final cropped image
    @Binding var isCropping: Bool

    @Binding var scale: CGFloat
    @Binding var offset: CGSize

    var body: some View {
        VStack {
            if let image = originalImage {
                GeometryReader { geometry in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                DragGesture().onChanged { value in
                                    offset = value.translation
                                }
                            )
                            .gesture(
                                MagnificationGesture().onChanged { value in
                                    scale = value
                                }
                            )

                        // Circular Overlay
                        Circle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            .frame(width: geometry.size.width - 40, height: geometry.size.width - 40)

                        // Grid Overlay (Optional)
                        GridOverlay()
                    }
                }
                .frame(height: UIScreen.main.bounds.width) // Square cropping frame

                Spacer()

                HStack {
                    Button(action: {
                        isCropping = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                    }

                    Button(action: saveCroppedImage) {
                        Text("Save")
                            .foregroundColor(.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            } else {
                Text("No Image Selected")
            }
        }
    }

    func saveCroppedImage() {
        croppedImage = generateCroppedImage(from: originalImage, scale: scale, offset: offset)
        isCropping = false
    }

    func generateCroppedImage(from image: UIImage?, scale: CGFloat, offset: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        return image // Simply return the same image as this app relies on adjustments, not actual cropping.
    }
}

struct GridOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let step = geometry.size.width / 3
                for i in 1..<3 {
                    // Vertical lines
                    let x = step * CGFloat(i)
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    
                    // Horizontal lines
                    let y = step * CGFloat(i)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
    }
}
