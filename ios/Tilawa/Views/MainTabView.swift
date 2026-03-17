import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    let quranService: QuranDataService
    let audioService: AudioRecordingService
    let analysisService: RecitationAnalysisService
    let progressService: ProgressTrackingService

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView(
                    quranService: quranService,
                    audioService: audioService,
                    analysisService: analysisService,
                    progressService: progressService
                )
            }

            Tab("Quran", systemImage: "book.fill", value: 1) {
                QuranBrowserView(
                    quranService: quranService,
                    audioService: audioService,
                    analysisService: analysisService,
                    progressService: progressService
                )
            }

            Tab("Practice", systemImage: "mic.fill", value: 2) {
                QuickPracticeView(
                    quranService: quranService,
                    audioService: audioService,
                    analysisService: analysisService,
                    progressService: progressService
                )
            }

            Tab("Progress", systemImage: "chart.bar.fill", value: 3) {
                ProgressTrackerView(progressService: progressService)
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                SettingsView()
            }
        }
        .tint(.green)
    }
}
