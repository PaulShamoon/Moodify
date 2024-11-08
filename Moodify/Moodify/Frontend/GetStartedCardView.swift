/*
    This is the get started card view for the Moodify app.
    Created by: Nazanin Mahmoudi
*/

import SwiftUI

struct GetStartedCard: View {
    var action: () -> Void
    @GestureState private var isHolding = false
    @State private var holdProgress: CGFloat = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.green.opacity(0.3))
                .frame(width: 300, height: 400)
                .shadow(radius: 10)
            
            VStack(spacing: 20) {
                Text("Ready to Begin?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Tap and hold to get started")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                progressCircle
            }
        }
        .padding()
    }
    
    private var progressCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 6)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: holdProgress)
                .stroke(Color.green, lineWidth: 6)
                .rotationEffect(.degrees(-90))
                .frame(width: 60, height: 60)
                .animation(.easeInOut(duration: 1.5), value: holdProgress)
            
            Circle()
                .fill(Color.green)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                )
                .scaleEffect(isHolding ? 1.2 : 1.0)
                .shadow(radius: isHolding ? 8 : 4)
                .animation(.easeInOut(duration: 0.2), value: isHolding)
                .gesture(
                    LongPressGesture(minimumDuration: 1.5)
                        .updating($isHolding) { currentState, gestureState, _ in
                            gestureState = currentState
                        }
                        .onChanged { _ in
                            withAnimation(.linear(duration: 1.5)) {
                                holdProgress = 1.0
                            }
                        }
                        .onEnded { _ in
                            if holdProgress >= 1.0 {
                                action()
                            }
                            holdProgress = 0.0
                        }
                )
        }
    }
}

#Preview {
    GetStartedCard {
        /* Preview action closure */
        print("Card action triggered")
    }
}
