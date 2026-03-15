import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var showRecitation = false
    @State private var selectedSurah: Surah?

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
                VStack(spacing: 24) {
                    headerSection
                    streakCard
                    dailyStatsSection
                    continueReadingSection
                    suggestedSurahsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tilawa")
            .navigationBarTitleDisplayMode(.large)
            .task { viewModel.load() }
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

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greeting)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.primary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var streakCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.title3)
                    Text("\(viewModel.currentStreak) Day Streak")
                        .font(.headline)
                }

                Text("Keep going! Your consistency is building strong recitation habits.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.orange.opacity(0.2), lineWidth: 6)
                    .frame(width: 56, height: 56)

                Circle()
                    .trim(from: 0, to: min(Double(viewModel.currentStreak) / 30.0, 1.0))
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 56, height: 56)

                Text("\(viewModel.currentStreak)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.orange)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var dailyStatsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "book.fill",
                value: "\(viewModel.todaysVersesRecited)",
                label: "Verses",
                color: .green
            )

            StatCard(
                icon: "clock.fill",
                value: formatDuration(viewModel.todaysDuration),
                label: "Time",
                color: .blue
            )

            StatCard(
                icon: "star.fill",
                value: "\(viewModel.todaysSessions)",
                label: "Sessions",
                color: .purple
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
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 52, height: 52)

                            Text("\(surah.id)")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(.green)
                        }

                        VStack(alignment: .leading, spacing: 4) {
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
                            .font(.title2)
                            .foregroundStyle(.green)
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
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.1))
                                        .frame(width: 48, height: 48)

                                    Text("\(surah.id)")
                                        .font(.system(.callout, design: .rounded, weight: .semibold))
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

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))

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
