// MoodifyApp.swift

import SwiftUI

@main
struct MoodifyApp: App {
    @StateObject var profileManager = ProfileManager()
    @AppStorage("hasCompletedQuestionnaire") var hasCompletedQuestionnaire: Bool = false
    @State private var navigateToMusicPreferences = false
    @State private var navigateToHomePage = false
    @State private var showSplash = true  // Control splash screen visibility
    @State private var isCreatingNewProfile = false  // Track if a new profile is being created
    @State private var isCreatingProfile = false  // Initialize with a default value

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if showSplash {
                    SplashPageView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showSplash = false
                            }
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
                            QuestionnaireView(navigateToMusicPreferences: $navigateToMusicPreferences)
                                .environmentObject(profileManager)
                        }
                    } else {
                        if navigateToHomePage, let currentProfile = profileManager.currentProfile {
                            homePageView(
                                profile: currentProfile,
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
