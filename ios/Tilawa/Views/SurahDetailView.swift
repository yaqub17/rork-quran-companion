import SwiftUI

struct SurahDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var verses: [Verse] = []
    @State private var isLoading = true
    @State private var showTranslation = true
    @State private var showTransliteration = false
    @State private var showTajweedColors = true
    @State private var selectedVerse: Verse?
    @State private var showRecitation = false
    @State private var showTajweedLegend = false

    let surah: Surah
    let quranService: QuranDataService
    let audioService: AudioRecordingService
    let analysisService: RecitationAnalysisService
    let progressService: ProgressTrackingService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    surahHeader

                    if surah.id != 1 && surah.id != 9 {
                        bismillah
                    }

                    if showTajweedLegend {
                        tajweedLegendSection
                    }

                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .controlSize(.large)
                            Text("Loading verses...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }

                    LazyVStack(spacing: 0) {
                        ForEach(verses) { verse in
                            TajweedVerseRowView(
                                verse: verse,
                                showTranslation: showTranslation,
                                showTransliteration: showTransliteration,
                                showTajweedColors: showTajweedColors,
                                onPractice: {
                                    selectedVerse = verse
                                    showRecitation = true
                                }
                            )

                            if verse.id != verses.last?.id {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .navigationTitle(surah.englishName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("Translation", isOn: $showTranslation)
                        Toggle("Transliteration", isOn: $showTransliteration)
                        Divider()
                        Toggle("Tajweed Colors", isOn: $showTajweedColors)
                        Button {
                            withAnimation(.snappy) {
                                showTajweedLegend.toggle()
                            }
                        } label: {
                            Label("Tajweed Legend", systemImage: showTajweedLegend ? "checkmark" : "")
                        }
                    } label: {
                        Image(systemName: "textformat.size")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Practice All", systemImage: "mic.fill") {
                        showRecitation = true
                    }
                    .tint(.green)
                }
            }
            .task {
                isLoading = true
                verses = await quranService.fetchVerses(for: surah)
                isLoading = false
            }
            .fullScreenCover(isPresented: $showRecitation) {
                RecitationView(
                    surah: surah,
                    initialVerse: selectedVerse,
                    quranService: quranService,
                    audioService: audioService,
                    analysisService: analysisService,
                    progressService: progressService
                )
            }
        }
    }

    private var surahHeader: some View {
        ZStack {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    .teal.opacity(0.3), .green.opacity(0.2), .mint.opacity(0.25),
                    .green.opacity(0.25), .teal.opacity(0.35), .cyan.opacity(0.2),
                    .mint.opacity(0.2), .green.opacity(0.3), .teal.opacity(0.25)
                ]
            )

            VStack(spacing: 12) {
                Text(surah.arabicName)
                    .font(.system(size: 36, weight: .bold))

                Text(surah.englishTranslation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    Label(surah.revelationType.rawValue, systemImage: "mappin.circle.fill")
                    Label("\(surah.versesCount) Verses", systemImage: "text.alignleft")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 24)
        }
    }

    private var bismillah: some View {
        Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ")
            .font(.system(size: 24))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.secondarySystemBackground).opacity(0.5))
    }

    private var tajweedLegendSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Tajweed Color Guide", systemImage: "paintpalette.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
                Spacer()
                Button {
                    withAnimation(.snappy) { showTajweedLegend = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            TajweedLegendView()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .transition(.scale.combined(with: .opacity))
    }
}

struct TajweedVerseRowView: View {
    let verse: Verse
    let showTranslation: Bool
    let showTransliteration: Bool
    let showTajweedColors: Bool
    let onPractice: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                verseNumberBadge

                Spacer()

                Button {
                    onPractice()
                } label: {
                    Image(systemName: "mic.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
            }

            if showTajweedColors {
                TajweedTextView(words: verse.words, fontSize: 26, showLegend: false)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Text(verse.arabicText)
                    .font(.system(size: 26))
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(12)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            if showTransliteration && !verse.transliteration.isEmpty {
                Text(verse.transliteration)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if showTranslation && !verse.translation.isEmpty {
                Text(verse.translation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(4)
            }
        }
        .padding(16)
    }

    private var verseNumberBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.green.opacity(0.12), .teal.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)

            Text("\(verse.verseNumber)")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.green)
        }
    }
}
