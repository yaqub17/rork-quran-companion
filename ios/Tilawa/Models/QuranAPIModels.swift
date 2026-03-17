import Foundation

nonisolated struct QuranAPIResponse: Codable, Sendable {
    let code: Int
    let status: String
    let data: [QuranAPISurahData]
}

nonisolated struct QuranAPISingleResponse: Codable, Sendable {
    let code: Int
    let status: String
    let data: QuranAPISurahData
}

nonisolated struct QuranAPISurahData: Codable, Sendable {
    let number: Int
    let name: String
    let englishName: String
    let englishNameTranslation: String
    let revelationType: String
    let numberOfAyahs: Int
    let ayahs: [QuranAPIAyah]
    let edition: QuranAPIEdition
}

nonisolated struct QuranAPIAyah: Codable, Sendable {
    let number: Int
    let text: String
    let numberInSurah: Int
    let juz: Int
    let page: Int
}

nonisolated struct QuranAPIEdition: Codable, Sendable {
    let identifier: String
    let language: String
    let name: String
    let englishName: String
}
