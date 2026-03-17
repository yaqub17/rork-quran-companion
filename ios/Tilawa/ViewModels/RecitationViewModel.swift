import Foundation

@Observable
@MainActor
class RecitationViewModel {
    var currentVerse: Verse?
    var currentVerseIndex: Int = 0
    var verses: [Verse] = []
    var surah: Surah?
    var isRecording = false
    var isAnalyzing = false
    var isLoadingVerses = false
    var feedback: RecitationFeedback?
    var showFeedback = false
    var audioLevel: Float = 0.0
    var recordingDuration: TimeInterval = 0
    var showTransliteration = true
    var showTranslation = true

    let audioService: AudioRecordingService
    let analysisService: RecitationAnalysisService
    let progressService: ProgressTrackingService

    private let quranService: QuranDataService

    init(
        quranService: QuranDataService,
        audioService: AudioRecordingService,
        analysisService: RecitationAnalysisService,
        progressService: ProgressTrackingService
    ) {
        self.quranService = quranService
        self.audioService = audioService
        self.analysisService = analysisService
        self.progressService = progressService
    }

    func load(surah: Surah) async {
        self.surah = surah
        isLoadingVerses = true

        let fetched = await quranService.fetchVerses(for: surah)
        self.verses = fetched
        self.currentVerseIndex = 0
        self.currentVerse = verses.first
        self.feedback = nil
        self.showFeedback = false
        isLoadingVerses = false
    }

    func startRecording() async {
        await audioService.requestPermission()
        guard audioService.hasPermission else { return }
        audioService.startRecording()
        isRecording = true
    }

    func stopRecording() async {
        guard let audioURL = audioService.stopRecording() else {
            isRecording = false
            return
        }
        isRecording = false
        isAnalyzing = true

        guard let verse = currentVerse else {
            isAnalyzing = false
            return
        }

        let result = await analysisService.analyzeRecitation(audioURL: audioURL, verse: verse)
        feedback = result
        isAnalyzing = false
        showFeedback = true

        let session = RecitationSession(
            id: UUID().uuidString,
            date: Date(),
            surahNumber: surah?.id ?? 0,
            surahName: surah?.englishName ?? "",
            startVerse: verse.verseNumber,
            endVerse: verse.verseNumber,
            overallScore: result.overallScore,
            tajweedScore: result.tajweedScore,
            pronunciationScore: result.pronunciationScore,
            fluencyScore: result.fluencyScore,
            duration: recordingDuration,
            violations: result.violations,
            versesRecited: 1
        )
        progressService.addSession(session)
    }

    func nextVerse() {
        guard currentVerseIndex < verses.count - 1 else { return }
        currentVerseIndex += 1
        currentVerse = verses[currentVerseIndex]
        feedback = nil
        showFeedback = false
    }

    func previousVerse() {
        guard currentVerseIndex > 0 else { return }
        currentVerseIndex -= 1
        currentVerse = verses[currentVerseIndex]
        feedback = nil
        showFeedback = false
    }

    func selectVerse(at index: Int) {
        guard index >= 0, index < verses.count else { return }
        currentVerseIndex = index
        currentVerse = verses[index]
        feedback = nil
        showFeedback = false
    }

    func dismissFeedback() {
        showFeedback = false
    }
}
