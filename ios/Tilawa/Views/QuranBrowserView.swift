import SwiftUI

struct QuranBrowserView: View {
    @State private var viewModel: QuranViewModel
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
        self._viewModel = State(initialValue: QuranViewModel(quranService: quranService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterChips

                List(viewModel.filteredSurahs) { surah in
                    Button {
                        selectedSurah = surah
                    } label: {
                        SurahRowView(
                            surah: surah,
                            isBookmarked: viewModel.isBookmarked(surah)
                        )
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button {
                            viewModel.toggleBookmark(for: surah)
                        } label: {
                            Label(
                                viewModel.isBookmarked(surah) ? "Unbookmark" : "Bookmark",
                                systemImage: viewModel.isBookmarked(surah) ? "bookmark.slash" : "bookmark"
                            )
                        }
                        .tint(.orange)
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if viewModel.filteredSurahs.isEmpty {
                        ContentUnavailableView("No Surahs Found", systemImage: "magnifyingglass", description: Text("Try adjusting your search or filter."))
                    }
                }
            }
            .navigationTitle("Quran")
            .searchable(text: Bindable(viewModel).searchText, prompt: "Search surahs...")
            .task { viewModel.load() }
            .fullScreenCover(item: $selectedSurah) { surah in
                SurahDetailView(
                    surah: surah,
                    quranService: quranService,
                    audioService: audioService,
                    analysisService: analysisService,
                    progressService: progressService
                )
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(QuranViewModel.SurahFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.snappy) {
                            viewModel.selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedFilter == filter
                                ? AnyShapeStyle(LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing))
                                : AnyShapeStyle(Color(.tertiarySystemFill))
                            )
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

struct SurahRowView: View {
    let surah: Surah
    let isBookmarked: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green.opacity(0.2), .teal.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("\(surah.id)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.green)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(surah.englishName)
                        .font(.headline)

                    if isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }

                HStack(spacing: 8) {
                    Text(surah.revelationType.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(surah.revelationType == .meccan ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1))
                        .foregroundStyle(surah.revelationType == .meccan ? .blue : .purple)
                        .clipShape(Capsule())

                    Text("\(surah.versesCount) verses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(surah.arabicName)
                .font(.system(size: 20))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}
