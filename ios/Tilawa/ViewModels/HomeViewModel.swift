import Foundation

@Observable
@MainActor
class HomeViewModel {
    var greeting: String = ""
    var todaysSessions: Int = 0
    var todaysVersesRecited: Int = 0
    var todaysDuration: TimeInterval = 0
    var currentStreak: Int = 0
    var lastRecitedSurah: Surah?
    var suggestedSurahs: [Surah] = []

    private let quranService: QuranDataService
    private let progressService: ProgressTrackingService

    init(quranService: QuranDataService, progressService: ProgressTrackingService) {
        self.quranService = quranService
        self.progressService = progressService
    }

    func load() {
        updateGreeting()
        quranService.loadSurahs()

        let stats = progressService.stats
        currentStreak = stats.currentStreak
        todaysSessions = stats.weeklyProgress.first?.sessionsCount ?? 0
        todaysVersesRecited = stats.weeklyProgress.first?.versesRecited ?? 0
        todaysDuration = stats.weeklyProgress.first?.totalDuration ?? 0

        if let lastSession = stats.recentSessions.first {
            lastRecitedSurah = quranService.surah(byNumber: lastSession.surahNumber)
        }

        suggestedSurahs = Array(quranService.surahs.filter { [1, 36, 55, 67, 112].contains($0.id) }.prefix(5))
    }

    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: greeting = "Good Morning"
        case 12..<17: greeting = "Good Afternoon"
        case 17..<21: greeting = "Good Evening"
        default: greeting = "Assalamu Alaikum"
        }
    }
}
