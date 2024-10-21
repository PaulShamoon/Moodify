import Foundation

struct Profile: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var dateOfBirth: Date
    var favoriteGenres: [String]
    var hasAgreedToTerms: Bool
}

