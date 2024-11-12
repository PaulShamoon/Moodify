import SwiftUI

/*
A view that displays a splash screen which will
be rendered upon every launch of the application
 
 Created by Paul Shamoon on 9/24/24.
 */
struct SplashPageView: View {
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // Splash screen content
            VStack {
                HStack(spacing: 0) {
                    Text("M")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.2))
                    Text("oodify")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.96, green: 0.87, blue: 0.70))
                }
            }
            .onAppear {
                // Display for 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
