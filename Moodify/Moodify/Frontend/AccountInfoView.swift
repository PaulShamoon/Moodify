import SwiftUI

struct AccountInfoView: View {
    @State private var name: String = ""
    @State private var dateOfBirth = Date() // Store the date of birth
    @State private var calculatedAge: Int = 0 // Calculated age from dateOfBirth

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account Information")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 20)

            Text("Name: \(name)")
                .font(.title2)
                .foregroundColor(.white)

            Text("Age: \(calculatedAge)")
                .font(.title2)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 20) {
                // Links to Questionnaire and Preferences
                NavigationLink(destination: QuestionnaireView(navigateToMusicPreferences: .constant(false))) {
                    Text("Edit User Information")
                        .font(.title2.italic())
                        .foregroundColor(.green)
                        .padding(.leading, 50)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            loadUserData() // Load saved user data
        }
    }

    // Function to load data from UserDefaults
    func loadUserData() {
        name = UserDefaults.standard.string(forKey: "name") ?? "Unknown"
        dateOfBirth = UserDefaults.standard.object(forKey: "dateOfBirth") as? Date ?? Date()
        calculatedAge = calculateAge(from: dateOfBirth) // Calculate age based on dateOfBirth
    }

    // Function to calculate age from date of birth
    func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year ?? 0
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInfoView()
    }
}
