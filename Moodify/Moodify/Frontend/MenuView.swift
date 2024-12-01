import SwiftUI

struct MenuView: View {
    @Binding var showMenu: Bool
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var navigateToHomePage: Bool
    @Binding var navigateToMusicPreferences: Bool
    @Binding var isCreatingNewProfile: Bool
    @State private var showingAccountInformation = false
    @State private var showingMusicPreferences = false
    @State private var showingPlaylists = false
    @State private var showingDeleteAlert = false
    @State private var showingPinSetup = false
    @State private var showingPinManagement = false
    @State private var showingChangePinView = false
    @State private var showingDeletePinAlert = false
    @State private var showingTOS = false
    @State private var selectedTab: MenuTab? = nil
    @State private var isInPinManagement = false
    @State private var activeAlert: ActiveAlert?
    @State private var showingAlert = false
    @ObservedObject var spotifyController: SpotifyController
    
    @Namespace private var menuAnimation

    private var hasPin: Bool {
        profileManager.currentProfile?.userPin != nil
    }
    
    enum ActiveAlert {
        case deleteProfile
        case deletePin
    }
    
    enum MenuTab: String, CaseIterable {
        case account = "Account Information"
        case music = "Music Preferences"
        case playlists = "Playlists"
        case user = "Switch User"
        case addPin = "Add PIN"
        case managePin = "Manage PIN"
        case changePin = "Change PIN"
        case deletePin = "Delete PIN"
        case tos = "Terms of Service"
        case delete = "Delete Profile"
        
        var icon: String {
            switch self {
            case .account: return "person.circle"
            case .music: return "music.note"
            case .playlists: return "music.note.list"
            case .user: return "arrow.triangle.2.circlepath"
            case .addPin: return "lock.circle"
            case .managePin: return "person.badge.key"
            case .changePin: return "lock.rotation"
            case .deletePin: return "lock.slash"
            case .tos: return "doc.text"
            case .delete: return "trash.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .account: return .blue
            case .music: return .purple
            case .playlists: return .yellow
            case .user: return .green
            case .addPin, .managePin, .changePin: return .orange
            case .deletePin: return .red
            case .tos: return .gray
            case .delete: return .red
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(showMenu ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showMenu)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showMenu = false
                                isInPinManagement = false
                            }
                        }
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            if isInPinManagement {
                                PinManagementHeader(showMenu: $showMenu, isInPinManagement: $isInPinManagement)
                            } else {
                                MenuHeader(showMenu: $showMenu)
                            }
                            
                            if let profile = profileManager.currentProfile {
                                ProfileSection(profile: profile)
                            }
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    if isInPinManagement {
                                        // PIN Management Options
                                        MenuButton(
                                            tab: .changePin,
                                            isSelected: selectedTab == .changePin,
                                            action: { handleTabSelection(.changePin) }
                                        )
                                        
                                        MenuButton(
                                            tab: .deletePin,
                                            isSelected: selectedTab == .deletePin,
                                            action: { handleTabSelection(.deletePin) }
                                        )
                                    } else {
                                        // Regular Menu Options
                                        ForEach(MenuTab.allCases.filter { tab in
                                            switch tab {
                                            case .addPin:
                                                return !hasPin
                                            case .managePin:
                                                return hasPin
                                            case .changePin, .deletePin:
                                                return false
                                            default:
                                                return true
                                            }
                                        }, id: \.self) { tab in
                                            MenuButton(
                                                tab: tab,
                                                isSelected: selectedTab == tab,
                                                action: {
                                                    handleTabSelection(tab)
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                        .frame(width: min(geometry.size.width * 0.85, 320))
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 20/255, green: 20/255, blue: 20/255))
                                .shadow(radius: 10)
                        )
                        .offset(x: showMenu ? 0 : geometry.size.width)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showMenu)
                    }
                    // For AccountInfoView
                    .navigationDestination(isPresented: $showingAccountInformation) {
                        AccountInfoView()
                            .environmentObject(profileManager)
                            .navigationBarBackButtonHidden(true)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        showingAccountInformation = false
                                    }) {
                                        Image(systemName: "chevron.backward")
                                            .foregroundColor(.white)
                                        Text("Back")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                    }

                    // For GeneralMusicPreferencesView
                    .navigationDestination(isPresented: $showingMusicPreferences) {
                        GeneralMusicPreferencesView(navigateToHomePage: .constant(false), navigateToProfilePicture: .constant(false), navigateToMusicPreferences: .constant(false))
                            .environmentObject(profileManager)
                            .navigationBarBackButtonHidden(true)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        showingMusicPreferences = false
                                    }) {
                                        Image(systemName: "chevron.backward")
                                            .foregroundColor(.white)
                                        Text("Back")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                    }

                    // For PlaylistsView
                    .navigationDestination(isPresented: $showingPlaylists) {
                        PlaylistsView(spotifyController: spotifyController)
                            .environmentObject(profileManager)
                            .navigationBarBackButtonHidden(true)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        showingPlaylists = false
                                    }) {
                                        Image(systemName: "chevron.backward")
                                            .foregroundColor(.white)
                                        Text("Back")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                    }

                    // For PinSetupView (used twice)
                    .navigationDestination(isPresented: $showingPinSetup) {
                        PinSetupView(profile: profileManager.currentProfile)
                            .environmentObject(profileManager)
                            .navigationBarBackButtonHidden(true)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        showingPinSetup = false
                                    }) {
                                        Image(systemName: "chevron.backward")
                                            .foregroundColor(.white)
                                        Text("Back")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                    }
                    .navigationDestination(isPresented: $showingChangePinView) {
                        PinSetupView(profile: profileManager.currentProfile)
                            .environmentObject(profileManager)
                            .navigationBarBackButtonHidden(true)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        showingChangePinView = false
                                    }) {
                                        Image(systemName: "chevron.backward")
                                            .foregroundColor(.white)
                                        Text("Back")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                    }

                    // For TermsOfServiceView
                    .navigationDestination(isPresented: $showingTOS) {
                        TermsOfServiceView(
                            agreedToTerms: Binding(
                                get: { profileManager.currentProfile?.hasAgreedToTerms ?? false },
                                set: { profileManager.currentProfile?.hasAgreedToTerms = $0 }
                            )
                        )
                        .environmentObject(profileManager)
                        .navigationBarBackButtonHidden(true)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    showingTOS = false
                                }) {
                                    Image(systemName: "chevron.backward")
                                        .foregroundColor(.white)
                                    Text("Back")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }

                }
                .alert(isPresented: $showingAlert) {
                    switch activeAlert {
                    case .deletePin:
                        return Alert(
                            title: Text("Delete PIN"),
                            message: Text("Are you sure you want to delete your PIN? This will remove PIN protection from your profile."),
                            primaryButton: .destructive(Text("Delete")) {
                                deletePin()
                                isInPinManagement = false
                            },
                            secondaryButton: .cancel()
                        )
                    case .deleteProfile:
                        return Alert(
                            title: Text("Delete Profile"),
                            message: Text("Are you sure you want to delete the current profile? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteProfile()
                            },
                            secondaryButton: .cancel()
                        )
                    case .none:
                        return Alert(title: Text("Error"))
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func handleTabSelection(_ tab: MenuTab) {
        withAnimation(.spring()) {
            selectedTab = tab
        }
        
        switch tab {
        case .account:
            showingAccountInformation = true
        case .music:
            showingMusicPreferences = true
        case .playlists:
            showingPlaylists = true
        case .user:
            switchUser()
        case .addPin:
            showingPinSetup = true
        case .managePin:
            isInPinManagement = true
        case .changePin:
            showingChangePinView = true
        case .deletePin:
            activeAlert = .deletePin
            showingAlert = true
        case .tos:
            showingTOS = true
        case .delete:
            activeAlert = .deleteProfile
            showingAlert = true
        }
    }
    
    private func switchUser() {
        withAnimation {
            profileManager.currentProfile = nil
            isCreatingNewProfile = false
            navigateToHomePage = false
            navigateToMusicPreferences = false
            showMenu = false
        }
    }
    
    private func deletePin() {
        if let currentProfile = profileManager.currentProfile {
            withAnimation {
                profileManager.deletePin(profile: currentProfile)
                profileManager.updateProfile(
                    profile: currentProfile,
                    name: currentProfile.name,
                    dateOfBirth: currentProfile.dateOfBirth,
                    favoriteGenres: currentProfile.favoriteGenres,
                    hasAgreedToTerms: currentProfile.hasAgreedToTerms,
                    userPin: nil,
                    personalSecurityQuestion: currentProfile.personalSecurityQuestion,
                    securityQuestionAnswer: currentProfile.securityQuestionAnswer
                )
            }
        }
    }
    
    private func deleteProfile() {
        if let currentProfile = profileManager.currentProfile {
            withAnimation {
                profileManager.deleteProfile(profile: currentProfile)
                switchUser()
            }
        }
    }
}

struct PinManagementHeader: View {
    @Binding var showMenu: Bool
    @Binding var isInPinManagement: Bool
    
    var body: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isInPinManagement = false
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            Text("Pin Management")
                .font(.title.bold())
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showMenu = false
                    isInPinManagement = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

// MARK: - Supporting Views
struct MenuHeader: View {
    @Binding var showMenu: Bool
    
    var body: some View {
        HStack {
            Text("Menu")
                .font(.title.bold())
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showMenu = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct ProfileSection: View {
    let profile: Profile
    
    var body: some View {
        VStack(spacing: 12) {
            if let profilePictureData = profile.profilePicture,
               let uiImage = UIImage(data: profilePictureData) {
                // Display the saved profile picture
                Image(uiImage: uiImage)
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
            } else {
                // Fallback to default image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(hex: "94A3BB"))
            }
        }
        .padding()
    }
    private var fallbackImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(Color(hex: "94A3B8"))
    }
}

struct MenuButton: View {
    let tab: MenuView.MenuTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: tab.icon)
                    .font(.title3)
                    .foregroundColor(tab.color)
                    .frame(width: 24)
                
                Text(tab.rawValue)
                    .font(.body)
                
                Spacer()
                
                if tab != .delete {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? tab.color.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}
