////
////  MoodPrefrenceView.swift
////  Moodify
////
////  Created by Nazanin Mahmoudi on 11/17/24.
////
//
//import SwiftUI
//
//struct MoodPreferenceView: View {
//    let spotifyController: SpotifyController
//    let profile: Profile
//    let detectedMood: String
//    @Binding var isPresented: Bool
//    
//    var body: some View {
//        VStack(spacing: 30) {
//            // Emoji and Title
//            VStack(spacing: 15) {
//                Text("😢")
//                    .font(.system(size: 60))
//                Text("We noticed you're feeling down")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//            }
//            .padding(.top, 40)
//            
//            Text("How would you like to feel better?")
//                .font(.body)
//                .foregroundColor(.secondary)
//                .padding(.bottom, 10)
//            
//            VStack(spacing: 16) {
//                Button(action: {
//                    spotifyController.fetchRecommendations(mood: detectedMood, profile: profile, userGenres: profile.favoriteGenres)
//                    isPresented = false
//                }) {
//                    HStack {
//                        Image(systemName: "cloud.rain")
//                            .font(.title3)
//                        Text("Lean into the feeling\nwith sad melodies")
//                            .multilineTextAlignment(.center)
//                            .lineLimit(2)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 70)
//                    .background(
//                        RoundedRectangle(cornerRadius: 15)
//                            .fill(Color.blue.opacity(0.15))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 15)
//                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
//                            )
//                    )
//                }
//                .foregroundColor(.primary)
//                
//                Button(action: {
//                    spotifyController.fetchRecommendations(mood: "happy", profile: profile, userGenres: profile.favoriteGenres)
//                    isPresented = false
//                }) {
//                    HStack {
//                        Image(systemName: "sun.max.fill")
//                            .font(.title3)
//                        Text("Lift my spirits\nwith upbeat tunes")
//                            .multilineTextAlignment(.center)
//                            .lineLimit(2)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 70)
//                    .background(
//                        RoundedRectangle(cornerRadius: 15)
//                            .fill(Color.green.opacity(0.15))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 15)
//                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
//                            )
//                    )
//                }
//                .foregroundColor(.primary)
//            }
//            .padding(.horizontal)
//        }
//        .padding(.horizontal, 20)
//        .padding(.bottom, 40)
//        .frame(maxWidth: 340)
//        .background(
//            RoundedRectangle(cornerRadius: 25)
//                .fill(Color(UIColor.systemBackground))
//                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
//        )
//    }
//}
//
//struct MoodPreferenceView_Previews: PreviewProvider {
//    static var previews: some View {
//        MoodPreferenceView(
//            spotifyController: SpotifyController(),
//            profile: Profile(name: "Test User", dateOfBirth: Date(), favoriteGenres: ["Pop", "Rock"], hasAgreedToTerms: true),
//            detectedMood: "sad",
//            isPresented: .constant(true)
//        )
//    }
//}
