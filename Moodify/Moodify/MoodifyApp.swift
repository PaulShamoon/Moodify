import SwiftUI

@main
struct MoodifyApp: App {
    @StateObject var profileManager = ProfileManager()
    @AppStorage("hasCompletedQuestionnaire") var hasCompletedQuestionnaire: Bool = false
    @State private var navigateToMusicPreferences = false
    @State private var navigateToHomePage = false
    @State private var showSplash = true // State to control splash screen
    @State private var isCreatingNewProfile = false // Track if a new profile is being created

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if showSplash {
                    SplashPageView()
                        .onAppear {
                            // Display the splash screen for 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showSplash = false
                            }
                        }
                } else {
                    // Handle new profile creation or questionnaire only if necessary
                    if isCreatingNewProfile || !hasCompletedQuestionnaire {
                        if navigateToMusicPreferences {
                            // Automatically navigate to music preferences after completing the questionnaire
                            GeneralMusicPreferencesView(navigateToHomePage: $navigateToHomePage)
                                .onChange(of: navigateToHomePage) {
                                    if navigateToHomePage {
                                        hasCompletedQuestionnaire = true
                                        isCreatingNewProfile = false // Reset new profile creation state
                                    }
                                }
                                .environmentObject(profileManager)
                        } else {
                            // Show the questionnaire only for new profiles or first-time users
                            QuestionnaireView(navigateToMusicPreferences: $navigateToMusicPreferences)
                                .environmentObject(profileManager)
                        }
                    } else {
                        // For existing profiles, go to the home page or profile selection
                        if navigateToHomePage, let currentProfile = profileManager.currentProfile {
                            // Navigate to Home Page or main app content once the profile is selected
                            homePageView(profile: currentProfile, navigateToHomePage: $navigateToHomePage)  // Pass profile to home page
                                .environmentObject(profileManager)
                        } else {
                            ProfileSelectionView(navigateToHomePage: $navigateToHomePage, isCreatingNewProfile: $isCreatingNewProfile)
                                .environmentObject(profileManager)
                        }
                    }
                }
            }
        }
    }
}
