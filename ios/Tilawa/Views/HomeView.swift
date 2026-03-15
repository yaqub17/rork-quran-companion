import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var selectedSurah: Surah?
    @State private var appeared = false

    let quranService: QuranDataService
    let audioService: AudioRecordingService
    let analysisService: RecitationAnalysisService
    let progressService: ProgressTrackingService

    init(quranService: QuranDataService, audioService: AudioRecordingService, analysisService: RecitationAnalysisService, progressService: ProgressTrackingService) {
        self.quranService = quranService
        self.audioService = audioService
        self.analysisService = analysisService
        self.progressService = progressService
        self._viewModel = State(initialValue: HomeViewModel(quranService: quranService, progressService: progressService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    heroSection
                        .padding(.bottom, 24)

                    VStack(spacing: 24) {
                        dailyStatsRow
                        continueReadingSection
                        suggestedSurahsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Tilawa")
                        .font(.headline)
                }
            }
            .task {
                viewModel.load()
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                    appeared = true
                }
            }
            .fullScreenCover(item: $selectedSurah) { surah in
                RecitationView(
                    surah: surah,
                    quranService: quranService,
                    audioService: audioService,
                    analysisService: analysisService,
                    progressService: progressService
                )
            }
        }
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    .teal.opacity(0.8), .green.opacity(0.6), .mint.opacity(0.7),
                    .green.opacity(0.7), .teal, .cyan.opacity(0.6),
                    .mint.opacity(0.6), .green.opacity(0.8), .teal.opacity(0.9)
                ]
            )
            .frame(height: 260)
            .overlay {
                VStack(spacing: 16) {
                    Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)

                    Text(viewModel.greeting)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .opacity(appeared ? 1 : 0)
                }
                .padding(.bottom, 40)
            }

            HStack(spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(viewModel.currentStreak) day streak")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    private var dailyStatsRow: some View {
        HStack(spacing: 10) {
            HomeStatPill(
                icon: "book.fill",
                value: "\(viewModel.todaysVersesRecited)",
                label: "Verses",
                tint: .green
            )

            HomeStatPill(
                icon: "clock.fill",
                value: formatDuration(viewModel.todaysDuration),
                label: "Time",
                tint: .blue
            )

            HomeStatPill(
                icon: "star.fill",
                value: "\(viewModel.todaysSessions)",
                label: "Sessions",
                tint: .purple
            )
        }
    }

    @ViewBuilder
    private var continueReadingSection: some View {
        if let surah = viewModel.lastRecitedSurah {
            VStack(alignment: .leading, spacing: 12) {
                Text("Continue Reciting")
                    .font(.headline)

                Button {
                    selectedSurah = surah
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [.green.opacity(0.2), .teal.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 52, height: 52)

                            Text("\(surah.id)")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(.green)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(surah.englishName)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(surah.englishTranslation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(surah.arabicName)
                            .font(.system(size: 22))
                            .foregroundStyle(.primary)

                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.green)
                            .symbolEffect(.pulse, options: .repeating.speed(0.5))
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var suggestedSurahsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggested Surahs")
                .font(.headline)

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(viewModel.suggestedSurahs) { surah in
                        Button {
                            selectedSurah = surah
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.green.opacity(0.15), .teal.opacity(0.1)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: 48, height: 48)

                                    Text("\(surah.id)")
                                        .font(.system(.callout, design: .rounded, weight: .bold))
                                        .foregroundStyle(.green)
                                }

                                Text(surah.arabicName)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.primary)

                                Text(surah.englishName)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .frame(width: 90)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
            .scrollIndicators(.hidden)
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(minutes)m"
    }
}

struct HomeStatPill: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(tint)

            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}
