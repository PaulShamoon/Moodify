//
//  TermsOfServicePage.swift
//  Moodify
//
//  Created by Mahdi Sulaiman on 11/6/24.
//

import SwiftUI
// TermsOfServicePage: Separate Page for TOS
struct TermsOfServicePage: View {
    @Binding var agreedToTerms: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Moodify Terms and Conditions")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 5)
                    
                    Text("Last Updated: 09/25/2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    Text("Welcome to Moodify! By using our app, you agree to these Terms and Conditions. Please read them carefully as they outline your rights and obligations as a user of Moodify. If you do not agree to these terms, please do not use our app.")
                        .padding(.bottom, 20)
                    
                    Section(header: Text("1. Acceptance of Terms").font(.headline)) {
                        Text("By accessing or using the Moodify app, you agree to be bound by these Terms and Conditions. Moodify reserves the right to modify these terms at any time. Any changes will be posted, and continued use of the app after such changes constitutes your acceptance of the updated terms.")
                    }
                    .padding(.bottom, 15)
                    
                    Section(header: Text("2. User Information").font(.headline)) {
                        Text("By using Moodify, you agree to provide accurate and up-to-date personal information including but not limited to:")
                            .padding(.bottom, 5)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("• First and last name")
                            Text("• Age")
                            Text("• Gender")
                            Text("• Music preferences")
                        }
                        .padding(.bottom, 5)
                        
                        Text("You grant Moodify permission to store and use this information to enhance your app experience.")
                    }
                    .padding(.bottom, 15)
                    
                    Section(header: Text("3. Access to Streaming Data").font(.headline)) {
                        Text("Moodify connects with third-party music providers to personalize your experience. By using the app, you authorize Moodify to:")
                            .padding(.bottom, 5)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("• Connect with your Spotify account to access your streaming data (e.g., listening history, playlists, preferences).")
                            Text("• Use this information to create personalized playlists and recommendations based on your mood and listening habits.")
                        }
                        .padding(.bottom, 5)
                        
                        Text("In the future, Moodify may integrate with other music providers such as Apple Music. By continuing to use the app after such integrations, you agree to allow access to streaming data from those providers as well.")
                    }
                    .padding(.bottom, 15)
                    
                    Section(header: Text("4. Mood Scans and Emotional Detection").font(.headline)) {
                        Text("Moodify allows you to upload photos for mood scanning. By using this feature, you agree to the following:")
                            .padding(.bottom, 5)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("• Moodify will store and process your mood scan photos using machine learning models to detect your emotions.")
                            Text("• Moodify may use the results from the mood scans to further personalize your playlists and app experience.")
                        }
                        .padding(.bottom, 5)
                        
                        Text("Moodify ensures that these photos are stored securely and used only for the purposes of enhancing your app experience.")
                    }
                    .padding(.bottom, 15)
                    
                    Section(header: Text("5. Personalized Experiences").font(.headline)) {
                        Text("Moodify uses data about your music listening habits to personalize your experience. This may include:")
                            .padding(.bottom, 5)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("• Song duration")
                            Text("• Number of skips")
                            Text("• Frequency of listening to certain genres or artists")
                        }
                        .padding(.bottom, 5)
                        
                        Text("By using the app, you agree to allow Moodify to analyze this data to provide you with customized playlists and recommendations that reflect your preferences and emotional states.")
                    }
                    .padding(.bottom, 15)
                    
                    Section(header: Text("6. Data Security and Privacy").font(.headline)) {
                        Text("Your privacy and data security are important to us. Moodify will take reasonable steps to protect your personal data and streaming information. However, you acknowledge that no method of transmission or storage is completely secure, and Moodify cannot guarantee absolute security. For more details on how we handle your information, please review our Privacy Policy.")
                    }
                    .padding(.bottom, 15)
                    
                    Section(header: Text("7. Changes to the App").font(.headline)) {
                        Text("Moodify may make changes to the app, add or remove features, or update services at any time without prior notice. We will notify users of any significant changes that impact their experience.")
                    }
                    .padding(.bottom, 15)
                    
                    Section(header: Text("8. Termination").font(.headline)) {
                        Text("Moodify reserves the right to suspend or terminate your access to the app at any time, without prior notice, for any reason, including breach of these Terms and Conditions.")
                    }
                    .padding(.bottom, 15)
                    
                    Section(header: Text("9. Contact Information").font(.headline)) {
                        Text("If you have any questions or concerns about these Terms and Conditions, please contact us at hg5146@wayne.edu.")
                    }
                    .padding(.bottom, 15)
                    
                    Text("By continuing to use Moodify, you acknowledge that you have read and understood these Terms and Conditions and agree to be bound by them.")
                        .padding(.bottom, 20)
                }
                .padding()
                .font(.body)
            }
            
            Button(action: {
                agreedToTerms = true
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Agree and Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}
