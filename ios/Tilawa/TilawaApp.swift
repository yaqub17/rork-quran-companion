import SwiftUI

@main
struct TilawaApp: App {
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    @State private var quranService = QuranDataService()
    @State private var audioService = AudioRecordingService()
    @State private var analysisService = RecitationAnalysisService()
    @State private var progressService = ProgressTrackingService()

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                MainTabView(
                    quranService: quranService,
                    audioService: audioService,
                    analysisService: analysisService,
                    progressService: progressService
                )
            } else {
                OnboardingView(hasOnboarded: $hasOnboarded)
            }
        }
    }
}
