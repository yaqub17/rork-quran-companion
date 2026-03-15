import SwiftUI

struct QuickPracticeView: View {
    @State private var selectedSurah: Surah?

    let quranService: QuranDataService
    let audioService: AudioRecordingService
    let analysisService: RecitationAnalysisService
    let progressService: ProgressTrackingService

    private let beginnerSurahs = [1, 112, 113, 114, 108, 103, 110, 105, 106, 107]
    private let popularSurahs = [36, 55, 56, 67, 78, 18]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    quickStartSection
                    beginnerSection
                    popularSection
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Practice")
            .task { quranService.loadSurahs() }
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

    private var quickStartSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.2), .teal.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)

                    Image(systemName: "mic.badge.plus")
                        .font(.system(size: 24))
                        .foregroundStyle(.green)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Practice")
                        .font(.title3.bold())
                    Text("Start reciting Al-Fatihah")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Button {
                selectedSurah = quranService.surahs.first { $0.id == 1 }
            } label: {
                Label("Start Reciting", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(colors: [.green.opacity(0.3), .teal.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
        )
    }

    private var beginnerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Beginner Surahs", systemImage: "star.fill")
                    .font(.headline)
                Spacer()
            }

            Text("Short surahs perfect for learning Tajweed")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(filteredSurahs(ids: beginnerSurahs)) { surah in
                    Button {
                        selectedSurah = surah
                    } label: {
                        PracticeSurahCard(surah: surah, color: .green)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Popular Surahs", systemImage: "heart.fill")
                    .font(.headline)
                Spacer()
            }

            Text("Frequently recited surahs")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(filteredSurahs(ids: popularSurahs)) { surah in
                    Button {
                        selectedSurah = surah
                    } label: {
                        PracticeSurahCard(surah: surah, color: .teal)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func filteredSurahs(ids: [Int]) -> [Surah] {
        ids.compactMap { id in quranService.surahs.first { $0.id == id } }
    }
}

struct PracticeSurahCard: View {
    let surah: Surah
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(surah.id)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(color)
                    .padding(6)
                    .background(color.opacity(0.12), in: Circle())

                Spacer()

                Text(surah.arabicName)
                    .font(.system(size: 16))
            }

            Text(surah.englishName)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)

            Text("\(surah.versesCount) verses")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}
