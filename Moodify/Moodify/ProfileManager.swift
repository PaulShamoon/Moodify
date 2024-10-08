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
    }

    func startNewProfile() {
        tempName = ""
        tempDateOfBirth = Date()
        tempSelectedGenres = []
        tempHasAgreedToTerms = false
        currentProfile = nil
    }

    func editProfile(_ profile: Profile) {
        tempName = profile.name
        tempDateOfBirth = profile.dateOfBirth
        tempSelectedGenres = profile.favoriteGenres
        tempHasAgreedToTerms = profile.hasAgreedToTerms
        currentProfile = profile
    }

    func saveProfile() {
        if let existingProfile = currentProfile {
            if let index = profiles.firstIndex(where: { $0.id == existingProfile.id }) {
                profiles[index].name = tempName
                profiles[index].dateOfBirth = tempDateOfBirth
                profiles[index].favoriteGenres = tempSelectedGenres
                profiles[index].hasAgreedToTerms = tempHasAgreedToTerms
            }
        } else {
            let newProfile = Profile(name: tempName, dateOfBirth: tempDateOfBirth, favoriteGenres: tempSelectedGenres, hasAgreedToTerms: tempHasAgreedToTerms)
            profiles.append(newProfile)
            currentProfile = newProfile
        }
        saveProfiles()
    }

    func loadProfiles() {
        if let data = UserDefaults.standard.data(forKey: profilesKey),
           let decodedProfiles = try? JSONDecoder().decode([Profile].self, from: data) {
            profiles = decodedProfiles
        }
    }

    func saveProfiles() {
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: profilesKey)
        }
    }

    func selectProfile(_ profile: Profile) {
        currentProfile = profile
    }

    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        saveProfiles()
        if currentProfile?.id == profile.id {
            currentProfile = nil
        }
    }

    // Check if profiles are available
    func hasProfiles() -> Bool {
        return !profiles.isEmpty
    }
}
