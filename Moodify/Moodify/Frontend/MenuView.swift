import SwiftUI

struct MenuView: View {
    @Binding var showMenu: Bool
    @EnvironmentObject var profileManager: ProfileManager
    @Binding var navigateToHomePage: Bool
    @Binding var isCreatingNewProfile: Bool
    @Binding var navigateToMusicPreferences: Bool
    @State private var showingAccountInformation = false
    @State private var showingMusicPreferences = false
    @State private var showingPlaylists = false
    @State private var showingDeleteAlert = false
    @State private var showingPinSetup = false
    @State private var showingTOS = false  // New state for TOS navigation
    @State private var selectedTab: MenuTab? = nil
    @ObservedObject var spotifyController: SpotifyController

    @Namespace private var menuAnimation
    
    enum MenuTab: String, CaseIterable {
        case account = "Account Information"
        case music = "Music Preferences"
        case playlists = "Playlists"
        case user = "Switch User"
        case pin = "Set/Change PIN"
        case delete = "Delete Profile"
        case tos = "Terms of Service"  // New case for TOS
        
        var icon: String {
            switch self {
            case .account: return "person.circle"
            case .music: return "music.note"
            case .playlists: return "music.note.list"
            case .user: return "arrow.triangle.2.circlepath"
            case .pin: return "lock.circle"
            case .delete: return "trash.circle"
            case .tos: return "doc.text"  // Icon for TOS
            }
        }
        
        var color: Color {
            switch self {
            case .account: return .blue
            case .music: return .purple
            case .playlists: return .yellow
            case .user: return .green
            case .pin: return .orange
            case .delete: return .red
            case .tos: return .gray  // Color for TOS
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
                            }
                        }
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            MenuHeader(showMenu: $showMenu)
                            
                            if let profile = profileManager.currentProfile {
                                ProfileSection(profile: profile)
                            }
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(MenuTab.allCases, id: \.self) { tab in
                                        MenuButton(
                                            tab: tab,
                                            isSelected: selectedTab == tab,
                                            action: {
                                                handleTabSelection(tab)
                                            }
                                        )
                                    }
                                }
                                .padding(.vertical)
                            }
                            
                            Spacer()
                            
                            Text("Prototype 2.0")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom)
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
                    
                    .navigationDestination(isPresented: $showingAccountInformation) {
                            AccountInfoView()
                                .environmentObject(profileManager)
                    }

                    .navigationDestination(isPresented: $showingMusicPreferences) {
                        GeneralMusicPreferencesView(navigateToHomePage: .constant(false))
                                .environmentObject(profileManager)
                    }
                    
                    .navigationDestination(isPresented: $showingPlaylists) {
                        PlaylistsView(spotifyController: spotifyController)
                            .environmentObject(profileManager)
                    }
                    
                    .navigationDestination(isPresented: $showingPinSetup) {
                        PinSetupView(profile: profileManager.currentProfile)
                            .environmentObject(profileManager)
                    }
                    
                    .navigationDestination(isPresented: $showingTOS) {
                        TermsOfServiceView(
                            agreedToTerms: Binding(
                                get: { profileManager.currentProfile?.hasAgreedToTerms ?? false },
                                set: { profileManager.currentProfile?.hasAgreedToTerms = $0 }
                            )
                        ).environmentObject(profileManager)
                    }
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete Profile"),
                        message: Text("Are you sure you want to delete the current profile? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteProfile()
                        },
                        secondaryButton: .cancel()
                    )
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
        case .pin:
            showingPinSetup = true
        case .delete:
            showingDeleteAlert = true
        case .tos:
            showingTOS = true  // Handle TOS tab selection
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
    
    private func deleteProfile() {
        if let currentProfile = profileManager.currentProfile {
            withAnimation {
                profileManager.deleteProfile(profile: currentProfile)
                profileManager.currentProfile = nil
                isCreatingNewProfile = false
                navigateToHomePage = false
                navigateToMusicPreferences = false
                showMenu = false
            }
        }
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
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(profile.name)
                .font(.title3.bold())
            
            Divider()
        }
        .padding()
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
