import SwiftUI

struct CropView: View {
    @Binding var originalImage: UIImage?
    @Binding var croppedImage: UIImage?
    @Binding var isCropping: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let minScale: CGFloat = 1.0
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
                        Color.black.opacity(0.8)
                        
                        if let image = originalImage{
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(scale)
                                .offset(offset)
                                .clipShape(Circle())
                                .gesture(
                                    SimultaneousGesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                let delta = value / lastScale
                                                lastScale = value
                                                
                                                // Limit scale within bounds
                                                let newScale = scale * delta
                                                scale = min(maxScale, max(minScale, newScale))
                                            }
                                            .onEnded { _ in
                                                lastScale = 1.0
                                            },
                                        DragGesture()
                                            .onChanged { value in
                                                let newOffset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                                
                                                // Limit movement based on scale
                                                let maxOffset = (size * (scale - 1)) / 2
                                                offset = CGSize(
                                                    width: max(-maxOffset, min(maxOffset, newOffset.width)),
                                                    height: max(-maxOffset, min(maxOffset, newOffset.height))
                                                )
                                            }
                                            .onEnded { _ in
                                                lastOffset = offset
                                            }
                                    )
                                )
                        }
                        
                        // Circular guide
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
        
        // Create a renderer with a square size based on the shorter dimension
        let size = min(inputImage.size.width, inputImage.size.height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: format)
        
        let croppedImg = renderer.image { context in
            // Create circular clipping path
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
            circlePath.addClip()
            
            // Calculate the drawing rect
            let drawRect = CGRect(
                x: (size - inputImage.size.width * scale) / 2 + offset.width,
                y: (size - inputImage.size.height * scale) / 2 + offset.height,
                width: inputImage.size.width * scale,
                height: inputImage.size.height * scale
            )
            
            // Draw the image
            inputImage.draw(in: drawRect)
        }
        
        croppedImage = croppedImg
        isCropping = false
    }
}
