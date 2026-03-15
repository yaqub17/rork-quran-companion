import Foundation

@Observable
@MainActor
class ProgressViewModel {
    var stats: UserStats?
    var selectedTimeRange: TimeRange = .week

    private let progressService: ProgressTrackingService

    init(progressService: ProgressTrackingService) {
        self.progressService = progressService
    }

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case allTime = "All Time"
    }

    func load() {
        stats = progressService.stats
    }

    var formattedTotalTime: String {
        guard let stats else { return "0m" }
        let minutes = Int(stats.totalDuration / 60)
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
        return "\(minutes)m"
    }

    var scoreGrade: String {
        guard let stats else { return "—" }
        switch stats.averageScore {
        case 0.9...: return "Excellent"
        case 0.8..<0.9: return "Very Good"
        case 0.7..<0.8: return "Good"
        case 0.6..<0.7: return "Fair"
        default: return "Needs Practice"
        }
    }
}
