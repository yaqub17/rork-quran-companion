import Foundation

nonisolated struct Surah: Identifiable, Hashable, Sendable {
    let id: Int
    let arabicName: String
    let englishName: String
    let englishTranslation: String
    let versesCount: Int
    let revelationType: RevelationType
    let juzNumbers: [Int]

    nonisolated enum RevelationType: String, Sendable, Hashable {
        case meccan = "Meccan"
        case medinan = "Medinan"
    }
}
