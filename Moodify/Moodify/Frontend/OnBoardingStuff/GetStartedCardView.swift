/*
    This is the get started card view for the Moodify app.
    Created by: Nazanin Mahmoudi
*/

import SwiftUI

struct GetStartedCard: View {
    var action: () -> Void
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.green.opacity(0.3))
                .frame(width: 300, height: 395)
                .shadow(radius: 10)
            
            VStack(spacing: 20) {
                Text("Ready to Begin?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Tap the button to get started")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                actionButton
            }
        }
        .padding()
    }
    
    private var actionButton: some View {
        ZStack {
            // Outer ring with rotating animation
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 6)
                .frame(width: 60, height: 60)
            
            // Animated circle that rotates
            Circle()
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 60, height: 60)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Center button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 0.8
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scale = 1.0
                        action()
                    }
                }
            }) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                    )
                    .scaleEffect(scale)
                    .shadow(radius: 4)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    GetStartedCard {
        /* Preview action closure */
        print("Card action triggered")
    }
}
