////
////  MoodDetectionView.swift
////  Moodify
////
////  Created by Nazanin Mahmoudi on 11/17/24.
////
//
//import SwiftUI
//
//struct MoodDetectionView: View {
//    @ObservedObject var moodViewModel: MoodDetectionViewModel
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Text("Your Current Mood")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.white.opacity(0.9))
//                
//                Spacer()
//                
//                Button(action: {
//                    moodViewModel.showMoodSelector = true
//                }) {
//                    Image(systemName: "pencil.circle.fill")
//                        .font(.system(size: 30))
//                        .foregroundColor(.white)
//                }
//            }
//            .padding(.horizontal, 16)
//            
//            ZStack {
//                RoundedRectangle(cornerRadius: 30)
//                    .fill(.ultraThinMaterial)
//                    .frame(width: 150, height: 150)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 30)
//                            .stroke(.white.opacity(0.2), lineWidth: 1)
//                    )
//                
//                if moodViewModel.isDetectingMood {
//                    VStack(spacing: 15) {
//                        ProgressView()
//                            .scaleEffect(1.5)
//                            .tint(.white)
//                        
//                        Text("Detecting Mood...")
//                            .font(.system(size: 16))
//                            .foregroundColor(.white)
//                    }
//                } else {
//                    Text(moodViewModel.currentMood)
//                        .font(.system(size: 70))
//                }
//            }
//            .padding(.vertical, 8)
//            
//            Text(moodViewModel.currentMoodText)
//                .font(.system(size: 16, weight: .regular))
//                .foregroundColor(.white.opacity(0.8))
//                .multilineTextAlignment(.center)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 20)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color(red: 0.2, green: 0.4, blue: 0.3))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color(red: 0.4, green: 0.3, blue: 0.2), lineWidth: 3.0)
//                )
//        )
//        .padding(.horizontal)
//        .padding(.bottom, 20)
//    }
//}
//
//struct MoodDetectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        MoodDetectionView(
//            moodViewModel: MoodDetectionViewModel(
//                profile: Profile(
//                    name: "Test User",
//                    dateOfBirth: Date(),
//                    favoriteGenres: ["Pop", "Rock"],
//                    hasAgreedToTerms: true
//                ),
//                spotifyController: SpotifyController()
//            )
//        )
//    }
//}
