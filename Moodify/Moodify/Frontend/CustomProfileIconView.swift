//
//  CustomProfileIconView.swift
//  Moodify
//
//  Created by Mahdi Sulaiman on 11/28/24.
//


// CustomProfileIconView.swift
import SwiftUI

struct CustomProfileIconView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var isCropping: Bool
    @Binding var originalImage: UIImage?
    @Binding var croppedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    let icons = ["headphones", "guitars", "music.microphone", "bolt", 
                 "music.quarternote.3", "music.note", "music.mic", 
                 "music.note.list", "guitars.fill", "music.note.tv", 
                 "cloud.fill", "music.note.house", "film.fill", "globe"]
    
    let colors: [Color] = [.blue, .green, .red, .purple, .orange, 
                          .pink, .yellow, .indigo, .mint, .cyan]
    
    @State private var selectedIcon: String = "music.note"
    @State private var selectedColor: Color = .green
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Icon")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Preview
            ZStack {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 180, height: 180)
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                
                Image(systemName: selectedIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(40)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 20)
            
            // Icon Selection
            ScrollView {
                VStack(spacing: 20) {
                    Text("Select Icon")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Circle()
                                    .fill(selectedColor)
                                    .frame(height: 70)
                                    .overlay(
                                        Image(systemName: icon)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .padding(15)
                                            .foregroundColor(.white)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color.white : Color.clear, lineWidth: 3)
                                    )
                            }
                        }
                    }
                    
                    Text("Select Color")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 5), spacing: 15) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle()
                                    .fill(color)
                                    .frame(height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 3)
                                    )
                            }
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Save Button
            Button(action: saveCustomIcon) {
                HStack {
                    Text("Save Icon")
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
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func saveCustomIcon() {
        // Create UIImage from icon and color
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 400))
        let customImage = renderer.image { context in
            // Draw background
            let bounds = context.format.bounds
            selectedColor.toUIColor().setFill()
            UIBezierPath(ovalIn: bounds).fill()
            
            // Draw icon
            if let iconImage = UIImage(systemName: selectedIcon) {
                let padding: CGFloat = 100
                let iconRect = bounds.insetBy(dx: padding, dy: padding)
                iconImage.withTintColor(.white).draw(in: iconRect)
            }
        }
        
        // Clear original and set cropped image
        originalImage = nil
        croppedImage = customImage
        
        presentationMode.wrappedValue.dismiss()
    }
}

// Add this extension to Color for UIColor conversion
extension Color {
    func toUIColor() -> UIColor {
        UIColor(self)
    }
}
