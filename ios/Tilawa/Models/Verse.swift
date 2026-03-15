import Foundation

nonisolated struct Verse: Identifiable, Hashable, Sendable {
    let id: String
    let surahNumber: Int
    let verseNumber: Int
    let arabicText: String
    let transliteration: String
    let translation: String
    let juzNumber: Int
    let pageNumber: Int
    let words: [QuranWord]
}

nonisolated struct QuranWord: Identifiable, Hashable, Sendable {
    let id: String
    let position: Int
    let arabicText: String
    let transliteration: String
    let translation: String
}
