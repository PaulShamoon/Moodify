//
//  generalMusicPrefrences.swift
//  Moodify
//
//  Created by Mahdi Sulaiman on 9/13/24.
//

import Foundation
import SwiftUI
struct generalMusicPreferencesView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Thank you for completing the questionnaire!")
                .font(.headline)
                .padding()
            Spacer()
        }
        .navigationBarTitle("MusicPreferences", displayMode: .inline)
    }
}

#Preview {
    generalMusicPreferencesView()
}
