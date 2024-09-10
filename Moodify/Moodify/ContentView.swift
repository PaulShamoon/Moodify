//
//  homePage.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 9/9/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Moodify")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.darkGreen)
        
    }
}

extension Color {
    static let darkGreen = Color(red: 0/255, green: 100/255, blue: 0/255)
}

#Preview {
    ContentView()
}
