import Foundation

nonisolated struct RecitationFeedback: Identifiable, Sendable {
    let id: String
    let verseId: String
    let overallScore: Double
    let tajweedScore: Double
    let pronunciationScore: Double
    let fluencyScore: Double
    let wordResults: [WordResult]
    let violations: [TajweedViolation]
    let feedbackText: String
    let arabicFeedback: String
}

nonisolated struct WordResult: Identifiable, Hashable, Sendable {
    let id: String
    let position: Int
    let arabicText: String
    let status: WordStatus
    let score: Double

    nonisolated enum WordStatus: String, Sendable, Hashable {
        case correct
        case minor
        case incorrect
        case missed
    }
}
