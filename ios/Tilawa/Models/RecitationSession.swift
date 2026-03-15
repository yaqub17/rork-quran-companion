import Foundation

nonisolated struct RecitationSession: Identifiable, Hashable, Sendable {
    let id: String
    let date: Date
    let surahNumber: Int
    let surahName: String
    let startVerse: Int
    let endVerse: Int
    let overallScore: Double
    let tajweedScore: Double
    let pronunciationScore: Double
    let fluencyScore: Double
    let duration: TimeInterval
    let violations: [TajweedViolation]
    let versesRecited: Int
}

nonisolated struct DailyProgress: Identifiable, Hashable, Sendable {
    let id: String
    let date: Date
    let sessionsCount: Int
    let totalDuration: TimeInterval
    let averageScore: Double
    let versesRecited: Int
    let streak: Int
}

nonisolated struct UserStats: Sendable {
    let totalSessions: Int
    let totalVersesRecited: Int
    let totalDuration: TimeInterval
    let averageScore: Double
    let currentStreak: Int
    let longestStreak: Int
    let topTajweedScores: [String: Double]
    let weakRules: [TajweedRule]
    let recentSessions: [RecitationSession]
    let weeklyProgress: [DailyProgress]
}
