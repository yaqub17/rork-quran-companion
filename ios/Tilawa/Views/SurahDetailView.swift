import SwiftUI

struct SurahDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var verses: [Verse] = []
    @State private var showTranslation = true
    @State private var showTransliteration = false
    @State private var selectedVerse: Verse?
    @State private var showRecitation = false

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

                    LazyVStack(spacing: 0) {
                        ForEach(verses) { verse in
                            VerseRowView(
                                verse: verse,
                                showTranslation: showTranslation,
                                showTransliteration: showTransliteration,
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
                verses = quranService.verses(for: surah)
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [.green.opacity(0.08), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var bismillah: some View {
        Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ")
            .font(.system(size: 24))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.secondarySystemBackground).opacity(0.5))
    }
}

struct VerseRowView: View {
    let verse: Verse
    let showTranslation: Bool
    let showTransliteration: Bool
    let onPractice: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 32, height: 32)

                    Text("\(verse.verseNumber)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.green)
                }

                Spacer()

                Button {
                    onPractice()
                } label: {
                    Image(systemName: "mic.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
            }

            Text(verse.arabicText)
                .font(.system(size: 26))
                .multilineTextAlignment(.trailing)
                .lineSpacing(12)
                .frame(maxWidth: .infinity, alignment: .trailing)

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
}
