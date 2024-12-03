//
//  TermsOfServicePage.swift
//  Moodify
//
//  Created by Mahdi Sulaiman on 11/6/24.
//

import SwiftUI
// TermsOfServicePage: Separate Page for TOS
struct TermsOfServiceView: View {
    @Binding var agreedToTerms: Bool
    @Environment(\.presentationMode) var presentationMode
    let showBackButton: Bool
    
    // Default initializer with back button
    init(agreedToTerms: Binding<Bool>) {
        self._agreedToTerms = agreedToTerms
        self.showBackButton = true
    }
    
    // Additional initializer for menu navigation
    init(agreedToTerms: Binding<Bool>, showBackButton: Bool) {
        self._agreedToTerms = agreedToTerms
        self.showBackButton = showBackButton
    }
    
    var body: some View {
        VStack(spacing: 1) {
            // Only show back button if showBackButton is true
            if showBackButton {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "#F5E6D3"))
                        .font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 10)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Moodify Terms and Conditions")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 5)
                    
                    Text("Last Updated: 12/03/2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    Text("Welcome to Moodify! By using our app, you agree to these Terms and Conditions. Please read them carefully as they outline your rights and obligations as a user of Moodify. If you do not agree to these terms, please do not use our app.")
                        .padding(.bottom, 20)
                    
                    // Section 1
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    Text("By accessing or using the Moodify app, you agree to be bound by these Terms and Conditions. Moodify reserves the right to modify these terms at any time. Changes will be posted, and continued use of the app after such changes constitutes acceptance of the updated terms.")
                        .padding(.bottom, 15)
                    
                    // Section 2
                    Text("2. User Information")
                        .font(.headline)
                    Text("By using Moodify, you agree to provide accurate and up-to-date personal information, including:")
                        .padding(.bottom, 5)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("• Preferred name")
                        Text("• Date of birth")
                        Text("• Preferred genres")
                    }
                    .padding(.bottom, 5)
                    Text("You grant Moodify permission to store and use this information to enhance your app experience.")
                        .padding(.bottom, 15)
                    
                    // Section 3
                    Text("3. Access to Streaming Data")
                        .font(.headline)
                    Text("Moodify connects with third-party music providers to personalize your experience. By using the app, you authorize Moodify to:")
                        .padding(.bottom, 5)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("• Connect with your Spotify account to access your streaming data, such as listening history and playlists.")
                        Text("• Use this information to create personalized playlists and recommendations based on your mood and listening habits.")
                    }
                    .padding(.bottom, 5)
                    Text("In the future, Moodify may integrate with other music providers. Continuing to use the app after such integrations constitutes agreement to allow access to streaming data from those providers as well.")
                        .padding(.bottom, 15)
                    
                    // Section 4
                    Text("4. Mood Scans and Emotional Detection")
                        .font(.headline)
                    Text("Moodify allows you to upload photos for mood scanning. By using this feature, you agree to:")
                        .padding(.bottom, 5)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("• Allow Moodify to store and process your mood scan photos using machine learning models to detect emotions.")
                        Text("• Permit the use of mood scan results to personalize playlists and app experiences.")
                    }
                    .padding(.bottom, 5)
                    Text("Moodify ensures these photos are stored securely and used only for app enhancement.")
                        .padding(.bottom, 15)
                    

                    .padding(.bottom, 5)
                    Text("By using the app, you allow Moodify to analyze this data to provide customized playlists and recommendations that reflect your preferences and emotional states.")
                        .padding(.bottom, 15)
                    
                    // Section 5
                    Text("5. Data Security and Privacy")
                        .font(.headline)
                    Text("Your privacy and data security are important to us. Moodify takes reasonable steps to protect your personal data and streaming information. However, you acknowledge that no method of transmission or storage is completely secure, and Moodify cannot guarantee absolute security. Please review our Privacy Policy for more information on how we handle your information.")
                        .padding(.bottom, 15)
                    
                    // Section 6
                    Text("6. Changes to the App")
                        .font(.headline)
                    Text("Moodify may make changes to the app, add or remove features, or update services at any time without prior notice. We will notify users of any significant changes that impact their experience.")
                        .padding(.bottom, 15)
                    
                    // Section 7
                    Text("7. Termination")
                        .font(.headline)
                    Text("Moodify reserves the right to suspend or terminate your access to the app at any time, without prior notice, for any reason, including breach of these Terms and Conditions.")
                        .padding(.bottom, 15)
                    
                    // Section 8
                    Text("8. Minimum Age Requirement")
                        .font(.headline)
                    Text("You must be at least 13 years old to use the Moodify app. By using the app, you confirm that you meet this minimum age requirement. Moodify reserves the right to restrict access if this requirement is not met.")
                        .padding(.bottom, 15)
                    
                    // Section 9
                    Text("9. Contact Information")
                        .font(.headline)
                    Text("If you have any questions or concerns about these Terms and Conditions, please contact us at hg5146@wayne.edu.")
                        .padding(.bottom, 15)
                    
                    Text("By agreeing, you acknowledge that you have read and understood these Terms and Conditions and agree to be bounded by them.")
                        .padding(.bottom, 20)
                        .fontWeight(.bold)
                }
                .padding()
                .font(.body)
            }
            Button(action: {
                agreedToTerms = true
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 12) {
                    Text(agreedToTerms ? "Done" : "Agree and Continue")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .lineLimit(1)
                }
                .foregroundColor(Color(hex: "#F5E6D3"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#1A2F2A"), Color(hex: "#243B35")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(
                    color: Color(hex: "#243B35").opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView(agreedToTerms: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
