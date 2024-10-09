import Foundation

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var currentProfile: Profile? = nil

    var tempName: String = ""
    var tempDateOfBirth: Date = Date()
    var tempSelectedGenres: [String] = []
    var tempHasAgreedToTerms: Bool = false // Track the agreement to terms

    private let profilesKey = "savedProfiles"

    init() {
        loadProfiles() // Load profiles on initialization
        print("Profiles loaded: \(profiles)")
    }

    // Start onboarding for a new profile
    func startNewProfile() {
        tempName = ""
        tempDateOfBirth = Date()
        tempSelectedGenres = []
        tempHasAgreedToTerms = false
        currentProfile = nil
        print("Started new profile creation")
    }

    // Start editing an existing profile
    func editProfile(_ profile: Profile) {
        tempName = profile.name
        tempDateOfBirth = profile.dateOfBirth
        tempSelectedGenres = profile.favoriteGenres
        tempHasAgreedToTerms = profile.hasAgreedToTerms
        currentProfile = profile
        print("Editing profile: \(profile)")
    }

    // Save the profile after onboarding (for both new and edit)
    func saveProfile() {
        print("Saving profile. Current Profile: \(String(describing: currentProfile))")
        if let existingProfile = currentProfile {
            if let index = profiles.firstIndex(where: { $0.id == existingProfile.id }) {
                print("Updating existing profile at index \(index)")
                profiles[index].name = tempName
                profiles[index].dateOfBirth = tempDateOfBirth
                profiles[index].favoriteGenres = tempSelectedGenres
                profiles[index].hasAgreedToTerms = tempHasAgreedToTerms
            }
        } else {
            // Creating a new profile
            let newProfile = Profile(name: tempName, dateOfBirth: tempDateOfBirth, favoriteGenres: tempSelectedGenres, hasAgreedToTerms: tempHasAgreedToTerms)
            profiles.append(newProfile)
            currentProfile = newProfile
            print("Created new profile: \(newProfile)")

        }
        saveProfiles()
        print("Profiles saved: \(profiles)")

    }

    func loadProfiles() {
        if let data = UserDefaults.standard.data(forKey: profilesKey),
           let decodedProfiles = try? JSONDecoder().decode([Profile].self, from: data) {
            profiles = decodedProfiles
        }
        print("Loaded profiles from UserDefaults: \(profiles)")
    }

    func saveProfiles() {
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: profilesKey)
            print("Saved profiles to UserDefaults: \(profiles)")
        } else {
            print("Error saving profiles to UserDefaults")
        }
    }

    func selectProfile(_ profile: Profile) {
        currentProfile = profile
        print("Selected profile: \(profile)")
    }

    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        saveProfiles()
        if currentProfile?.id == profile.id {
            currentProfile = nil
        }
        print("Deleted profile: \(profile)")
    }
}
