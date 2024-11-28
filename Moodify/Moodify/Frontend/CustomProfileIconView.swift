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
                          .pink, .yellow, .indigo, .mint, .cyan, .black, .white]
    
    @State private var selectedIcon: String = "music.note"
    @State private var selectedColor: Color = .green
    @State private var iconColor: Color = .white
    
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
                    .overlay(Circle().stroke(Color.green, lineWidth: 4))
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
                                            .foregroundColor(iconColor)
                                    .overlay(Circle().stroke(Color.green, lineWidth: 4))

                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color.white : Color.gray, lineWidth: 5)
                                    )
                            }
                        }
                    }
                    
                    Text("Select Background Color")
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
                                            .stroke(selectedColor == color ? Color.white : Color.gray, lineWidth: 5)
                                    )
                            }
                        }
                    }
                    
                    // Icon Color Selection
                    VStack(spacing: 10) {
                        Text("Icon Color")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                        
                        HStack(spacing: 20) {
                            Button(action: { iconColor = .white }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(iconColor == .white ? Color.white : Color.gray, lineWidth: 5)
                                    )
                            }
                            
                            Button(action: { iconColor = .black }) {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(iconColor == .black ? Color.green : Color.gray, lineWidth: 5)
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
