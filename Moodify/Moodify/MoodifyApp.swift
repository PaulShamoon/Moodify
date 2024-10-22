import SwiftUI

@main
struct MoodifyApp: App {
    @StateObject var spotifyController = SpotifyController()
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
                        } else {
                            QuestionnaireView(navigateToMusicPreferences: $navigateToMusicPreferences)
                        }
                    } else {
                        homePageView()
                    }
                }
            }
        }
    }
}
