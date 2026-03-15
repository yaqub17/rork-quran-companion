import Foundation

@Observable
@MainActor
class RecitationAnalysisService {
    var isAnalyzing = false

    func analyzeRecitation(audioURL: URL, verse: Verse) async -> RecitationFeedback {
        isAnalyzing = true
        defer { isAnalyzing = false }

        try? await Task.sleep(for: .seconds(1.5))

        let wordResults = verse.words.enumerated().map { index, word in
            let statuses: [WordResult.WordStatus] = [.correct, .correct, .correct, .minor, .correct, .incorrect]
            let status = statuses[index % statuses.count]
            let score: Double = switch status {
            case .correct: Double.random(in: 0.85...1.0)
            case .minor: Double.random(in: 0.6...0.84)
            case .incorrect: Double.random(in: 0.2...0.59)
            case .missed: 0.0
            }
            return WordResult(
                id: UUID().uuidString,
                position: index,
                arabicText: word.arabicText,
                status: status,
                score: score
            )
        }

        let overallScore = wordResults.reduce(0.0) { $0 + $1.score } / Double(max(wordResults.count, 1))

        let violations = generateSampleViolations(for: verse, wordResults: wordResults)

        return RecitationFeedback(
            id: UUID().uuidString,
            verseId: verse.id,
            overallScore: overallScore,
            tajweedScore: Double.random(in: 0.65...0.95),
            pronunciationScore: Double.random(in: 0.7...0.95),
            fluencyScore: Double.random(in: 0.6...0.9),
            wordResults: wordResults,
            violations: violations,
            feedbackText: "Good effort! Focus on the elongation of the Madd letters and the nasalization (Ghunnah) in your recitation.",
            arabicFeedback: "جهد جيد! ركز على مد الحروف والغنة في تلاوتك."
        )
    }

    private func generateSampleViolations(for verse: Verse, wordResults: [WordResult]) -> [TajweedViolation] {
        let incorrectWords = wordResults.filter { $0.status == .minor || $0.status == .incorrect }
        return incorrectWords.prefix(2).map { word in
            TajweedViolation(
                id: UUID().uuidString,
                rule: TajweedRule(
                    id: "ghunnah",
                    name: "Ghunnah",
                    arabicName: "غنة",
                    category: .ghunnah,
                    description: "Nasalization held for two counts",
                    example: "مِنْ + ب = مِمْبَ",
                    colorHex: "#4CAF50"
                ),
                wordIndex: word.position,
                wordText: word.arabicText,
                explanation: "The Ghunnah (nasalization) should be held for approximately two counts when Noon Sakinah or Tanween is followed by certain letters.",
                severity: word.status == .incorrect ? .major : .minor
            )
        }
    }
}
