import SwiftUI

struct AccountInfoView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var isEditingProfile = false
    @State private var navigateToProfilePictureView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Spacer()
                
                Text("Account Information")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#F5E6D3"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                if let profile = profileManager.currentProfile {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            if let profilePictureData = profile.profilePicture,
                               let uiImage = UIImage(data: profilePictureData) {
                                // Display the profile picture
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.green, lineWidth: 4)
                                    )
                            } else {
                                // Fallback to default placeholder
                                Circle()
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.green)
                                            .padding(12)
                                    )
                            }
                            
                            // Edit Button Overlay
                            Button(action: {
                                navigateToProfilePictureView = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 25))
                                    .foregroundColor(Color(hex: "#F5E6D3"))
                                    .background(Circle().fill(Color.green))
                                    .frame(width: 30, height: 30)
                                    .contentShape(Circle())
                            }
                            .offset(x: -25, y: -25)
                            
                            Text(profile.name)
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#F5E6D3"))
                                .offset(x: -25)
                        }
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 16) {
                            InfoRow(
                                icon: "calendar",
                                title: "Age",
                                value: "\(calculateAge(from: profile.dateOfBirth)) years old"
                            )
                            
                            InfoRow(
                                icon: "music.note.list",
                                title: "Genres",
                                value: profile.favoriteGenres.isEmpty ?
                                    "Not Set" :
                                    profile.favoriteGenres.joined(separator: ", ")
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(white: 0.15))
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    NavigationLink {
                        QuestionnaireView(
                            isEditingProfile: .constant(true),
                            navigateToMusicPreferences: .constant(true),
                            isCreatingNewProfile: .constant(false),
                            isCreatingProfile: .constant(false)
                        )
                        .environmentObject(profileManager)
                        .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                            Text("Edit Profile")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .lineLimit(1)
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
                        .shadow(
                            color: Color(hex: "#243B35").opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    .padding(.top, 10)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.red.opacity(0.8))
                        
                        Text("No Profile Selected")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(white: 0.15))
                    )
                }
                
                Spacer()
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $navigateToProfilePictureView) {
                ProfilePictureView(navigateToHomePage: .constant(false))
                    .environmentObject(profileManager)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                navigateToProfilePictureView = false
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "chevron.backward")
                                        .foregroundColor(Color(hex: "#F5E6D3"))
                                    Text("Back")
                                        .foregroundColor(Color(hex: "#F5E6D3"))
                                }
                            }
                        }
                    }
            }
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year ?? 0
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.green)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "#F5E6D3"))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}
