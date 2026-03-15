import Foundation

@Observable
@MainActor
class ProgressTrackingService {
    var sessions: [RecitationSession] = []
    var dailyProgress: [DailyProgress] = []
    var currentStreak: Int = 0

    init() {
        loadSampleData()
    }

    var stats: UserStats {
        let totalDuration = sessions.reduce(0.0) { $0 + $1.duration }
        let avgScore = sessions.isEmpty ? 0 : sessions.reduce(0.0) { $0 + $1.overallScore } / Double(sessions.count)
        let totalVerses = sessions.reduce(0) { $0 + $1.versesRecited }

        return UserStats(
            totalSessions: sessions.count,
            totalVersesRecited: totalVerses,
            totalDuration: totalDuration,
            averageScore: avgScore,
            currentStreak: currentStreak,
            longestStreak: max(currentStreak, 7),
            topTajweedScores: [:],
            weakRules: sampleWeakRules,
            recentSessions: Array(sessions.prefix(5)),
            weeklyProgress: dailyProgress
        )
    }

    func addSession(_ session: RecitationSession) {
        sessions.insert(session, at: 0)
        updateStreak()
    }

    private func updateStreak() {
        currentStreak = min(sessions.count, 12)
    }

    private func loadSampleData() {
        let calendar = Calendar.current
        let today = Date()

        sessions = (0..<8).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
            return RecitationSession(
                id: UUID().uuidString,
                date: date,
                surahNumber: [1, 112, 36, 67, 55, 78, 93, 114][dayOffset],
                surahName: ["Al-Fatihah", "Al-Ikhlas", "Ya-Sin", "Al-Mulk", "Ar-Rahman", "An-Naba", "Ad-Duhaa", "An-Nas"][dayOffset],
                startVerse: 1,
                endVerse: [7, 4, 10, 5, 8, 6, 11, 6][dayOffset],
                overallScore: Double.random(in: 0.65...0.95),
                tajweedScore: Double.random(in: 0.6...0.9),
                pronunciationScore: Double.random(in: 0.7...0.95),
                fluencyScore: Double.random(in: 0.6...0.85),
                duration: Double.random(in: 120...600),
                violations: [],
                versesRecited: [7, 4, 10, 5, 8, 6, 11, 6][dayOffset]
            )
        }

        dailyProgress = (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
            return DailyProgress(
                id: UUID().uuidString,
                date: date,
                sessionsCount: Int.random(in: 1...3),
                totalDuration: Double.random(in: 300...1200),
                averageScore: Double.random(in: 0.65...0.9),
                versesRecited: Int.random(in: 5...20),
                streak: max(1, 7 - dayOffset)
            )
        }

        currentStreak = 7
    }

    private var sampleWeakRules: [TajweedRule] {
        [
            TajweedRule(id: "ikhfa", name: "Ikhfa", arabicName: "إخفاء", category: .noonSakinah, description: "Concealment of Noon Sakinah", example: "مِنْ قَبْلِ", colorHex: "#FF9800"),
            TajweedRule(id: "ghunnah", name: "Ghunnah", arabicName: "غنة", category: .ghunnah, description: "Nasalization", example: "إِنَّ", colorHex: "#4CAF50"),
            TajweedRule(id: "madd_lazim", name: "Madd Lazim", arabicName: "مد لازم", category: .madd, description: "Obligatory prolongation", example: "الضَّآلِّينَ", colorHex: "#2196F3"),
        ]
    }
}
