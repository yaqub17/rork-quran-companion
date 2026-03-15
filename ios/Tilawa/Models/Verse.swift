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
    let tajweedAnnotations: [TajweedAnnotation]
}

nonisolated struct TajweedAnnotation: Hashable, Sendable {
    let range: Range<String.Index>
    let rule: TajweedColorRule
}

nonisolated enum TajweedColorRule: String, Sendable, Hashable, CaseIterable {
    case ghunnah
    case ikhfa
    case idgham
    case iqlab
    case qalqalah
    case maddNormal
    case maddMunfasil
    case maddMuttasil
    case maddLazim
    case laamShamsiyyah
    case izhar

    var displayName: String {
        switch self {
        case .ghunnah: "Ghunnah"
        case .ikhfa: "Ikhfa"
        case .idgham: "Idgham"
        case .iqlab: "Iqlab"
        case .qalqalah: "Qalqalah"
        case .maddNormal: "Madd Tabii"
        case .maddMunfasil: "Madd Munfasil"
        case .maddMuttasil: "Madd Muttasil"
        case .maddLazim: "Madd Lazim"
        case .laamShamsiyyah: "Laam Shamsiyyah"
        case .izhar: "Izhar"
        }
    }

    var arabicName: String {
        switch self {
        case .ghunnah: "غنة"
        case .ikhfa: "إخفاء"
        case .idgham: "إدغام"
        case .iqlab: "إقلاب"
        case .qalqalah: "قلقلة"
        case .maddNormal: "مد طبيعي"
        case .maddMunfasil: "مد منفصل"
        case .maddMuttasil: "مد متصل"
        case .maddLazim: "مد لازم"
        case .laamShamsiyyah: "لام شمسية"
        case .izhar: "إظهار"
        }
    }

    var colorHex: String {
        switch self {
        case .ghunnah: "#4CAF50"
        case .ikhfa: "#2196F3"
        case .idgham: "#9C27B0"
        case .iqlab: "#E91E63"
        case .qalqalah: "#F44336"
        case .maddNormal: "#FF9800"
        case .maddMunfasil: "#00BCD4"
        case .maddMuttasil: "#D32F2F"
        case .maddLazim: "#B71C1C"
        case .laamShamsiyyah: "#607D8B"
        case .izhar: "#795548"
        }
    }
}
