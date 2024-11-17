/*
 This is the main entry point for the Moodify app.
 */

import SwiftUI

@main
struct MoodifyApp: App {
    @StateObject var profileManager = ProfileManager()
    @AppStorage("hasCompletedQuestionnaire") var hasCompletedQuestionnaire: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var navigateToMusicPreferences = false
    @State private var navigateToHomePage = false
    @State private var showSplash = true
    @State private var isCreatingNewProfile = false
    @State private var isCreatingProfile = false
    @State private var isEditingProfile = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if showSplash {
                    SplashPageView(showSplash: $showSplash)
                } else if !hasCompletedOnboarding {
                    OnboardingView {
                        hasCompletedOnboarding = true
                        hasCompletedQuestionnaire = false
                    }
                } else {
                    if isCreatingNewProfile || !hasCompletedQuestionnaire {
                        if navigateToMusicPreferences {
                            GeneralMusicPreferencesView(navigateToHomePage: $navigateToHomePage)
                                .onChange(of: navigateToHomePage) { _ in
                                    if navigateToHomePage {
                                        hasCompletedQuestionnaire = true
                                        isCreatingNewProfile = false
                                    }
                                }
                                .environmentObject(profileManager)
                        } else {
                            QuestionnaireView(
                                isEditingProfile: $isEditingProfile,
                                navigateToMusicPreferences: $navigateToMusicPreferences,
                                isCreatingNewProfile: $isCreatingNewProfile
                            )
                            .environmentObject(profileManager)
                        }
                    } else {
                        if navigateToHomePage, let currentProfile = profileManager.currentProfile {
                            HomePageView(
                                viewModel: HomePageViewModel(
                                    profile: currentProfile,
                                    spotifyController: SpotifyController()
                                ),
                                moodViewModel: MoodDetectionViewModel(
                                    profile: currentProfile,
                                    spotifyController: SpotifyController()
                                ),
                                navigateToHomePage: $navigateToHomePage,
                                isCreatingNewProfile: $isCreatingNewProfile,
                                navigateToMusicPreferences: $navigateToMusicPreferences,
                                isCreatingProfile: $isCreatingProfile
                            )
                            .environmentObject(profileManager)
                        } else {
                            ProfileSelectionView(
                                navigateToHomePage: $navigateToHomePage,
                                isCreatingNewProfile: $isCreatingNewProfile,
                                navigateToMusicPreferences: $navigateToMusicPreferences
                            )
                            .environmentObject(profileManager)
                        }
                    }
                }
            }
        }
    }
}
