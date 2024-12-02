/*
 This is the view that appears when the user confirms their mood.
 It shows a gradient circle with the mood icon and the mood name.
 It also has two buttons: "Yes, that's right" and "No, retake mood".
 created by Nazanin Mahmoudi
 */

import SwiftUI

struct MoodConfirmationSheet: View {
    let detectedMood: String
    let confidence: Double
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    let onRetake: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    /* Haptic feedback for button interactions */
    let impact = UIImpactFeedbackGenerator(style: .medium)
    
    /* Returns a gradient array based on the emotional context of each mood */
    private func getMoodGradient(for mood: String) -> [Color] {
        switch mood.lowercased() {
        case "happy":
            return [
                Color(hex: "#DAA520"),
                Color(hex: "#B8860B"),
                Color(hex: "#CD853F")
            ]
        case "sad":
            return [
                Color(hex: "#4B0082"),
                Color(hex: "#483D8B"),
                Color(hex: "#6A5ACD")
            ]
        case "angry":
            return [
                Color(hex: "#800000"),
                Color(hex: "#8B0000"),
                Color(hex: "#A52A2A")
            ]
        case "chill":
            return [
                Color(hex: "#008B8B"),
                Color(hex: "#20B2AA"),
                Color(hex: "#5F9EA0")
            ]
        default:
            return [
                Color(hex: "#696969"),
                Color(hex: "#808080"),
                Color(hex: "#A9A9A9")
            ]
        }
    }
    
    /* Maps each mood to a relevant SF Symbol */
    private func getMoodIcon(for mood: String) -> String {
        switch mood.lowercased() {
        case "happy": return "sun.max.fill"
        case "sad": return "cloud.rain.fill"
        case "angry": return "flame.fill"
        case "chill": return "leaf.fill"
        default: return "circle.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            /* Sheet drag indicator */
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            Spacer()
                .frame(height: 50)
            
            /* Mood visualization section */
            VStack(spacing: 30) {
                ZStack {
                    /* Blurred gradient background for mood icon */
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: getMoodGradient(for: detectedMood),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                    
                    Image(systemName: getMoodIcon(for: detectedMood))
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                /* Mood detection result text */
                VStack(spacing: 8) {
                    Text("I detect that you're feeling")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(detectedMood.capitalized)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            /* Action buttons container */
            VStack(spacing: 12) {
                /* Confirm mood button */
                Button(action: {
                    impact.impactOccurred()
                    withAnimation(.spring()) {
                        isPresented = false
                        onConfirm()
                    }
                }) {
                    Text("Yes, that's right")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(
                                    colors: getMoodGradient(for: detectedMood),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .opacity(0.8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                /* Retake mood button */
                Button(action: {
                    impact.impactOccurred()
                    withAnimation(.spring()) {
                        isPresented = false
                        onRetake()
                    }
                }) {
                    Text("No, retake mood")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(hex: "#1A1A1A"))
                .ignoresSafeArea()
        )
        .transition(.move(edge: .bottom))
    }
}
