//
//  HomePageView.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 11/17/24.
//

import SwiftUI

struct HomePageView: View {
    @StateObject var viewModel: HomePageViewModel
    @StateObject var moodViewModel: MoodDetectionViewModel
    @Binding var navigateToHomePage: Bool
    @Binding var isCreatingNewProfile: Bool
    @Binding var navigateToMusicPreferences: Bool
    @Binding var isCreatingProfile: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: moodViewModel.backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                /* header */
                headerView
                
                /* Mood Detection View */
                MoodDetectionView(moodViewModel: moodViewModel)
                
                /* Player View */
                PlayerView(spotifyController: viewModel.spotifyController)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.2, green: 0.4, blue: 0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(red: 0.4, green: 0.3, blue: 0.2), lineWidth: 3.0)
                            )
                    )
                    .padding(.horizontal)
                
                /* Action Buttons */
                actionButtons
                
                Spacer()
            }
            .padding(.top, 60)
            .onAppear { viewModel.onAppear() }
            .onChange(of: viewModel.spotifyController.isConnected) { _ in
                viewModel.updateSpotifyButtons()
            }
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
            
            if viewModel.showMenu {
                MenuView(
                    showMenu: $viewModel.showMenu,
                    navigateToHomePage: $navigateToHomePage,
                    navigateToMusicPreferences: $navigateToMusicPreferences,
                    isCreatingNewProfile: $isCreatingProfile,
                    spotifyController: viewModel.spotifyController
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .sheet(isPresented: $viewModel.showingCamera) {
            CameraView(image: $moodViewModel.capturedImage, isCameraDismissed: Binding(
                get: { viewModel.isCameraDismissed },
                set: { viewModel.isCameraDismissed = $0 }
            ))
            .onDisappear {
                if viewModel.isCameraDismissed {
                    moodViewModel.onCameraDismissed()
                }
            }
        }
        
        .sheet(isPresented: $moodViewModel.showMoodPreferenceSheet) {
            MoodPreferenceView(
                spotifyController: viewModel.spotifyController,
                profile: viewModel.profile,
                detectedMood: moodViewModel.detectedMood,
                isPresented: $moodViewModel.showMoodPreferenceSheet
            )
        }
        .sheet(isPresented: $moodViewModel.showMoodSelector) {
            ManualMoodSelector(
                isPresented: $moodViewModel.showMoodSelector,
                spotifyController: viewModel.spotifyController,
                profile: viewModel.profile,
                currentMood: $moodViewModel.currentMood,
                currentMoodText: $moodViewModel.currentMoodText,
                updateBackgroundColors: moodViewModel.updateBackgroundColors
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.white.opacity(0.9))
                Text(viewModel.profile.name)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.leading, 35)
            
            Spacer()
            
            Button(action: { withAnimation { viewModel.showMenu.toggle() } }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.black.opacity(0.3)))
                    .shadow(radius: 10)
            }
        }
        .padding(.horizontal)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                viewModel.checkCameraPermission()
            }) {
                HStack {
                    Image(systemName: "camera")
                        .font(.system(size: 16))
                    Text(moodViewModel.isDetectingMood ? "Detecting..." : "Detect Mood")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.3))
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 0.2, green: 0.4, blue: 0.3), lineWidth: 1.5)
                        )
                )
            }
            
            if viewModel.showConnectToSpotifyButton {
                Button(action: {
                    viewModel.navigateToSpotify = true
                }) {
                    HStack {
                        Image(systemName: "music.note")
                            .font(.system(size: 16))
                        Text("Connect to Spotify")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 0.2, green: 0.4, blue: 0.3), lineWidth: 1.5)
                            )
                    )
                }
            }
            
            if viewModel.showResyncSpotifyButton {
                Button(action: {
                    viewModel.resyncSpotify()
                }) {
                    HStack {
                        Image(systemName: "music.note")
                            .font(.system(size: 16))
                        Text("Resync Spotify")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 0.2, green: 0.4, blue: 0.3), lineWidth: 1.5)
                            )
                    )
                }
            }
        }
        .padding(.top, 20)
    }
}

// Preview for HomePageView
struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(
            viewModel: HomePageViewModel(
                profile: Profile(
                    name: "Test User",
                    dateOfBirth: Date(),
                    favoriteGenres: ["Pop", "Rock"],
                    hasAgreedToTerms: true
                ),
                spotifyController: SpotifyController()
            ),
            moodViewModel: MoodDetectionViewModel(
                profile: Profile(
                    name: "Test User",
                    dateOfBirth: Date(),
                    favoriteGenres: ["Pop", "Rock"],
                    hasAgreedToTerms: true
                ),
                spotifyController: SpotifyController()
            ),
            navigateToHomePage: .constant(false),
            isCreatingNewProfile: .constant(false),
            navigateToMusicPreferences: .constant(false),
            isCreatingProfile: .constant(false)
        )
    }
}
