import SwiftUI

struct MenuView: View {
    @Binding var showMenu: Bool

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all) // Dim background when menu is shown
            
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        withAnimation {
                            showMenu = false // Close menu on button click
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40) // Lower the X button
                    .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Account Information Link
                    NavigationLink(destination: AccountInfoView()) {
                        
                        Text("Account Information")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                            .padding(.top, 100)
                    }
                    
                    NavigationLink(destination: GeneralMusicPreferencesView(navigateToHomePage: .constant(false))) {
                        Text("Music Preferences")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                    }

                    Spacer()
                }
                .padding(.top, 40) // Adjust the spacing below the X button
            }
            .frame(maxWidth: 250) // Set the width of the side menu
            .background(Color.black.opacity(0.8))
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarHidden(true) // Hide the navigation bar in the menu view
    }
}
