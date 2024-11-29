import SwiftUI
struct CropView: View {
    @Binding var originalImage: UIImage?
    @Binding var croppedImage: UIImage?
    @Binding var isCropping: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    // Adjust scale limits
    private let minScale: CGFloat = 0.5  // Allow zoom out like WhatsApp
    private let maxScale: CGFloat = 4.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Adjust Your Photo")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                GeometryReader { geo in
                    let size = min(geo.size.width, geo.size.height) - 40
                    
                    ZStack {
                        Color.black
                        
                        if let image = originalImage {
                            // Background dimmed image
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(scale)
                                .offset(offset)
                                .opacity(0.3)  // Dimmed version
                            
                            // Main image
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(scale)
                                .offset(offset)
                                .clipShape(Circle())
                                .frame(width: size, height: size)
                                .gesture(
                                    SimultaneousGesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                let delta = value / lastScale
                                                lastScale = value
                                                scale = min(maxScale, max(minScale, scale * delta))
                                            }
                                            .onEnded { _ in
                                                lastScale = 1.0
                                                // Snap back if needed
                                                if scale < minScale {
                                                    withAnimation { scale = minScale }
                                                } else if scale > maxScale {
                                                    withAnimation { scale = maxScale }
                                                }
                                            },
                                        DragGesture()
                                            .onChanged { value in
                                                let newOffset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                                offset = newOffset
                                            }
                                            .onEnded { _ in
                                                lastOffset = offset
                                                // Here you could add bounds checking if needed
                                            }
                                    )
                                )
                        }
                        
                        // Circle outline
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 1)
                            .frame(width: size, height: size)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: { isCropping = false }) {
                        Text("Cancel")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(white: 0.2))
                            .cornerRadius(15)
                    }
                    
                    Button(action: cropAndSave) {
                        Text("Done")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func cropAndSave() {
        guard let inputImage = originalImage else { return }
        
        let outputSize = CGSize(width: 800, height: 800) // Fixed output size
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        
        let croppedImg = renderer.image { context in
            // Create circular clipping path
            context.cgContext.addEllipse(in: CGRect(origin: .zero, size: outputSize))
            context.cgContext.clip()
            
            // Calculate the drawing rect based on scale and offset
            let aspectRatio = inputImage.size.width / inputImage.size.height
            let drawWidth: CGFloat
            let drawHeight: CGFloat
            
            if aspectRatio > 1 {
                drawHeight = outputSize.height * scale
                drawWidth = drawHeight * aspectRatio
            } else {
                drawWidth = outputSize.width * scale
                drawHeight = drawWidth / aspectRatio
            }
            
            let x = (outputSize.width - drawWidth) / 2 + offset.width * scale
            let y = (outputSize.height - drawHeight) / 2 + offset.height * scale
            
            inputImage.draw(in: CGRect(x: x, y: y, width: drawWidth, height: drawHeight))
        }
        
        croppedImage = croppedImg
        isCropping = false
    }
}
