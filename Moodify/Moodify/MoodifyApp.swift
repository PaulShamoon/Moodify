import SwiftUI

@main
struct MoodifyApp: App {
    @StateObject var profileManager = ProfileManager()
    @AppStorage("hasCompletedQuestionnaire") var hasCompletedQuestionnaire: Bool = false
    @State private var navigateToMusicPreferences = false
    @State private var navigateToHomePage = false
    @State private var showSplash = true // State to control splash screen

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if showSplash {
                    SplashPageView()
                        .onAppear {
                            // Display the splash screen for 3 seconds, as defined in your SplashPageView
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showSplash = false
                            }
                        }
                } else {
                    if !hasCompletedQuestionnaire {
                        // Show the Questionnaire if not completed
                        if navigateToMusicPreferences {
                            GeneralMusicPreferencesView(navigateToHomePage: $navigateToHomePage)
                                .onChange(of: navigateToHomePage) {
                                    if navigateToHomePage {
                                        hasCompletedQuestionnaire = true
                                    }
                                }
                                .environmentObject(profileManager)
                        } else {
                            QuestionnaireView(navigateToMusicPreferences: $navigateToMusicPreferences)
                                .environmentObject(profileManager)
                        }
                    } else {
                        if navigateToHomePage, let currentProfile = profileManager.currentProfile {
                            // Navigate to Home Page or main app content once the profile is selected
                            homePageView(profile: currentProfile)  // Pass profile to home page
                                .environmentObject(profileManager)
                        } else {
                            // Show profile selection screen if a profile is not selected
                            ProfileSelectionView(navigateToHomePage: $navigateToHomePage)
                                .environmentObject(profileManager)
                        }
                    }
                }
            }
        }
    }
}
