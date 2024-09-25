//
//  MoodifyApp.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 9/9/24.
//
import SwiftUI

@main
struct MoodifyApp: App {
    @StateObject var spotifyController = SpotifyController()
    @AppStorage("hasCompletedQuestionnaire") var hasCompletedQuestionnaire: Bool = false
    @State private var navigateToMusicPreferences = false
    @State private var navigateToHomePage = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if !hasCompletedQuestionnaire {
                    // Show Questionnaire if not completed
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
                    homePageView() // Default page after completion
                }
            }
        }
    }
}
