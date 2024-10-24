import SwiftUI

struct ProfileSelectionView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var navigateToHomePage: Bool
    @Binding var isCreatingNewProfile: Bool
    @State private var showingQuestionnaire = false
    @Binding var navigateToMusicPreferences: Bool
    let defaultProfileImage = URL(string: "https://cdn.pixabay.com/photo/2016/11/08/15/21/user-1808597_1280.png")!
    let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 24)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(hex: "0A2F23"),
                    Color(hex: "0A2F23")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Who's Listening?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "4ADE80"),
                                    Color(hex: "22C55E")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Select or create your profile")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "94A3B8"))
                }
                .padding(.top, 40)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(profileManager.profiles, id: \.id) { profile in
                            ProfileCard(
                                profile: profile,
                                defaultProfileImage: defaultProfileImage,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        profileManager.selectProfile(profile)
                                        navigateToHomePage = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        resetProfileCreationState()
                        showingQuestionnaire = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Add New Profile")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(width: 220, height: 50)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "4ADE80"),
                                Color(hex: "22C55E")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "4ADE80").opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: navigateToMusicPreferences) { value in
            handleMusicPreferenceNavigation(value)
        }
    }
    
    private func resetProfileCreationState() {
        isCreatingNewProfile = true
        navigateToHomePage = false
        navigateToMusicPreferences = false
    }

    private func handleMusicPreferenceNavigation(_ isNavigating: Bool) {
        if isNavigating {
            navigateToHomePage = false
            showingQuestionnaire = false
        }
    }

    // Preview provider for development
    struct ProfileSelectionView_Previews: PreviewProvider {
        static var previews: some View {
            ProfileSelectionView(
                navigateToHomePage: .constant(false),
                isCreatingNewProfile: .constant(false),
                navigateToMusicPreferences: .constant(false)
            )
            .environmentObject(ProfileManager())
        }
    }
}

struct ProfileCard: View {
    let profile: Profile
    let defaultProfileImage: URL
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Profile Image
                AsyncImage(url: defaultProfileImage) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "4ADE80"),
                                                Color(hex: "22C55E")
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: Color(hex: "4ADE80").opacity(0.2), radius: 8, x: 0, y: 4)
                    case .failure:
                        fallbackImage
                    @unknown default:
                        fallbackImage
                    }
                }
                
                Text(profile.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(width: 160, height: 180)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "1C1C1E")) // Dark card background
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "22C55E").opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: "4ADE80").opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = pressing
            }
        }, perform: { })
    }
    
    private var fallbackImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(Color(hex: "94A3B8"))
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
