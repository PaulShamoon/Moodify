/*
 TipSheetView.swift
 Moodify
 
 Created by Nazanin Mahmoudi on 12/2/24.
 An onboarding view that provides users with helpful tips
 for getting the best mood detection results.
 */

import SwiftUI

/* Displays a modal sheet with camera usage tips to help users
 capture better quality selfies for mood detection */
struct MoodDetectionTipsView: View {
    @Binding var isPresented: Bool
    let onContinue: () -> Void
    
    /* Core tips for optimal mood detection results */
    private let tips = [
        (icon: "sun.max.fill", title: "Good Lighting", description: "Face a well-lit area or natural light source"),
        (icon: "face.smiling", title: "Center Your Face", description: "Keep your face in the center of the frame"),
        (icon: "camera.filters", title: "Clear View", description: "Ensure your face is fully visible")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Quick Tips")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#F5E6D3"))
                .padding(.top, 20)
            
            VStack(spacing: 20) {
                ForEach(tips, id: \.title) { tip in
                    HStack(spacing: 16) {
                        Image(systemName: tip.icon)
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#F5E6D3"))
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tip.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#F5E6D3"))
                            
                            Text(tip.description)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#F5E6D3").opacity(0.8))
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                isPresented = false
                onContinue()
            }) {
                Text("Got it!")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A2F2A"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#F5E6D3"))
                    )
                    .padding(.horizontal)
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 20)
        .background(Color(hex: "#1A2F2A"))
    }
}
