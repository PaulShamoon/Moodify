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
            Text("Thank you for completing the questionnaire!")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Next Page", displayMode: .inline)
    }
}

#Preview {
    generalMusicPreferencesView()
}
