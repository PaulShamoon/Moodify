/*
 This is the onboarding mood view for the Moodify app.
 Created by: Nazanin Mahmoudi
 */

import SwiftUI

struct OnboardingMoodView: View {
    @StateObject private var viewModel = OnboardingMoodViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    let onCompletion: () -> Void
    
    var body: some View {
        ZStack {
            if viewModel.currentIndex < viewModel.moods.count {
                AnimatedGradientBackground(colors: viewModel.moods[viewModel.currentIndex].mood.colors,
                                           darkColors: viewModel.moods[viewModel.currentIndex].mood.darkColors)
            } else {
                AnimatedGradientBackground(
                    colors: [Color.black, Color.secondary],
                    darkColors: [Color.black.opacity(0.8), Color.secondary.opacity(0.7)]
                )
            }
            
            VStack(spacing: 20) {
                header
                
                Spacer()
                
                cardStack
                
                Spacer()
                
                skipButton
                    .padding(.bottom, 20)
            }
            .onAppear {
                if viewModel.currentIndex == viewModel.moods.count {
                    withAnimation { viewModel.showGetStarted = true }
                }
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 16) {
            Text("Let's Explore Your Moods")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#F5E6D3"))
                .padding(.top, 60)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding()
            
            Text("Swipe through the cards to explore different moods")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#F5E6D3").opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
    }
    
    private var cardStack: some View {
        ZStack {
            ForEach((0...viewModel.moods.count).reversed(), id: \.self) { index in
                if index == viewModel.currentIndex || index == viewModel.currentIndex - 1 || index == viewModel.currentIndex + 1 {
                    if index == viewModel.moods.count {
                        // Show GetStartedCard as the last card
                        GetStartedCard(action: onCompletion)
                            .offset(x: cardOffset(for: index))
                            .scaleEffect(index == viewModel.currentIndex ? 1 : 0.9)
                            .opacity(index == viewModel.currentIndex ? 1 : 0.5)
                            .gesture(dragGesture)
                            .animation(.spring(), value: viewModel.dragOffset)
                    } else {
                        MoodCardOnboardingView(moodOnboarding: viewModel.moods[index])
                            .offset(x: cardOffset(for: index))
                            .scaleEffect(index == viewModel.currentIndex ? 1 : 0.9)
                            .opacity(index == viewModel.currentIndex ? 1 : 0.5)
                            .gesture(dragGesture)
                            .animation(.spring(), value: viewModel.dragOffset)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in viewModel.dragOffset = gesture.translation }
            .onEnded { gesture in
                viewModel.handleDragEnd(gesture: gesture, maxIndex: viewModel.moods.count)
            }
    }
    
    private func cardOffset(for index: Int) -> CGFloat {
        index == viewModel.currentIndex ? viewModel.dragOffset.width : (index < viewModel.currentIndex ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width)
    }
    
    private var skipButton: some View {
        Button(action: {
            hasCompletedOnboarding = true
            onCompletion()
        }) {
            Text("Skip to Account Setup")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#F5E6D3").opacity(0.9))
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .overlay(
                            Capsule()
                                .strokeBorder(Color(hex: "#F5E6D3").opacity(0.4), lineWidth: 1)
                        )
                )
        }
        .opacity(viewModel.currentIndex == viewModel.moods.count ? 0 : 1)
        .animation(.easeInOut, value: viewModel.currentIndex)
    }
}

#Preview {
    OnboardingMoodView(onCompletion: {
        print("Navigate to account setup")
        // This is just a preview placeholder
    })
    .preferredColorScheme(.dark)
}
