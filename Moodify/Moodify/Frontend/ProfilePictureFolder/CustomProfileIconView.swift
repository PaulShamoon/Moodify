import SwiftUI

struct CustomProfileIconView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var isCropping: Bool
    @Binding var originalImage: UIImage?
    @Binding var croppedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    let icons = ["headphones", "guitars", "music.microphone", "bolt",
                 "music.quarternote.3", "music.note", "music.mic",
                 "music.note.list", "guitars.fill", "music.note.tv",
                 "cloud.fill", "music.note.house", "film.fill", "globe"]
    
    let colors: [Color] = [
        Color(hex: "779885"),  // Medium sage
        Color(hex: "4A6670"),  // Muted teal
        Color(hex: "C85C37"),  // Terracotta
        Color(hex: "796878"),  // Mauve
        Color(hex: "D4B570"),  // Warm gold
        Color(hex: "9B6B5D"),  // Warm brown
        Color(hex: "A39B8B"),  // Warm gray
        Color(hex: "687864"),  // Forest green
        Color(hex: "8B4744"),  // Deep burgundy
        .black,
        .white
    ]
    
    @State private var selectedIcon: String = "music.note"
    @State private var selectedColor: Color = Color(hex: "779885")  // Default to medium sage
    @State private var iconColor: Color = Color(hex: "#F5E6D3")
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                // Back button
                Button(action: { dismiss() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3"))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.top, 15)
                    Spacer()
                }
            }
            Text("Choose Your Icon")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(Color(hex: "#F5E6D3"))
            
            // Preview
            ZStack {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 180, height: 180)
                    .overlay(Circle().stroke(Color(hex: "4ADE80"), lineWidth: 4))
                    .shadow(radius: 10)
                
                Image(systemName: selectedIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(iconColor)
            }
            .padding(.vertical, 20)
            
            // Icon Selection
            ScrollView {
                VStack(spacing: 20) {
                    Text("Select Icon")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#F5E6D3"))
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
                                            .foregroundColor(iconColor)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color(hex: "#F5E6D3") : Color.gray, lineWidth: 5)
                                    )
                            }
                        }
                    }
                    
                    Text("Select Background Color")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#F5E6D3"))
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
                                            .stroke(selectedColor == color ? Color(hex: "#F5E6D3") : Color.gray, lineWidth: 5)
                                    )
                            }
                        }
                    }
                    
                    // Icon Color Selection
                    VStack(spacing: 10) {
                        Text("Icon Color")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#F5E6D3"))
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                        
                        HStack(spacing: 20) {
                            Button(action: { iconColor = Color(hex: "#F5E6D3") }) {
                                Circle()
                                    .fill(Color(hex: "#F5E6D3"))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(iconColor == Color(hex: "#F5E6D3") ? Color(hex: "4ADE80") : Color.gray, lineWidth: 5)
                                    )
                            }
                            
                            Button(action: { iconColor = .black }) {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(iconColor == .black ? Color(hex: "4ADE80") : Color.gray, lineWidth: 5)
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
                .foregroundColor(Color(hex: "#F5E6D3"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#1A2F2A"), Color(hex: "#243B35")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func saveCustomIcon() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 400))
        let customImage = renderer.image { context in
            // Draw background
            let bounds = context.format.bounds
            selectedColor.toUIColor().setFill()
            UIBezierPath(ovalIn: bounds).fill()
            
            // Draw icon with selected color
            if let iconImage = UIImage(systemName: selectedIcon) {
                let iconSize: CGFloat = bounds.width * 0.4
                let x = (bounds.width - iconSize) / 2
                let y = (bounds.height - iconSize) / 2
                let iconRect = CGRect(x: x, y: y, width: iconSize, height: iconSize)
                iconImage.withTintColor(iconColor.toUIColor()).draw(in: iconRect)
            }
        }
        
        originalImage = nil
        croppedImage = customImage
        
        presentationMode.wrappedValue.dismiss()
    }
}

// Extension for Color to UIColor conversion
extension Color {
    func toUIColor() -> UIColor {
        UIColor(self)
    }
}

struct CustomProfileIconView_Previews: PreviewProvider {
    static var previews: some View {
        let mockProfileManager = ProfileManager()
        let mockImage = UIImage(systemName: "person.circle")
        
        return CustomProfileIconView(
            isCropping: .constant(false),
            originalImage: .constant(mockImage),
            croppedImage: .constant(nil)
        )
        .environmentObject(mockProfileManager)
    }
}
