import Foundation

struct Profile: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var dateOfBirth: Date
    var favoriteGenres: [String]
    var hasAgreedToTerms: Bool
    var userPin: String?
    var personalSecurityQuestion: String?
    var securityQuestionAnswer: String?
}

