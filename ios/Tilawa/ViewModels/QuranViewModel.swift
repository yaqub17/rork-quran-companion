import Foundation

@Observable
@MainActor
class QuranViewModel {
    var surahs: [Surah] = []
    var searchText: String = ""
    var selectedFilter: SurahFilter = .all
    var bookmarkedSurahIds: Set<Int> = [1, 36, 55, 67, 112]

    private let quranService: QuranDataService

    init(quranService: QuranDataService) {
        self.quranService = quranService
    }

    enum SurahFilter: String, CaseIterable {
        case all = "All"
        case meccan = "Meccan"
        case medinan = "Medinan"
        case bookmarked = "Bookmarked"
        case juz30 = "Juz 30"
    }

    var filteredSurahs: [Surah] {
        var result = quranService.surahs

        switch selectedFilter {
        case .all: break
        case .meccan: result = result.filter { $0.revelationType == .meccan }
        case .medinan: result = result.filter { $0.revelationType == .medinan }
        case .bookmarked: result = result.filter { bookmarkedSurahIds.contains($0.id) }
        case .juz30: result = result.filter { $0.juzNumbers.contains(30) }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.englishName.localizedStandardContains(searchText) ||
                $0.arabicName.localizedStandardContains(searchText) ||
                $0.englishTranslation.localizedStandardContains(searchText) ||
                "\($0.id)".contains(searchText)
            }
        }

        return result
    }

    func load() {
        quranService.loadSurahs()
        surahs = quranService.surahs
    }

    func toggleBookmark(for surah: Surah) {
        if bookmarkedSurahIds.contains(surah.id) {
            bookmarkedSurahIds.remove(surah.id)
        } else {
            bookmarkedSurahIds.insert(surah.id)
        }
    }

    func isBookmarked(_ surah: Surah) -> Bool {
        bookmarkedSurahIds.contains(surah.id)
    }

    func verses(for surah: Surah) -> [Verse] {
        quranService.verses(for: surah)
    }
}
