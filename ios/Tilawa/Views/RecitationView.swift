import SwiftUI

struct RecitationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecitationViewModel

    let surah: Surah
    let initialVerse: Verse?

    init(surah: Surah, initialVerse: Verse? = nil, quranService: QuranDataService, audioService: AudioRecordingService, analysisService: RecitationAnalysisService, progressService: ProgressTrackingService) {
        self.surah = surah
        self.initialVerse = initialVerse
        self._viewModel = State(initialValue: RecitationViewModel(
            quranService: quranService,
            audioService: audioService,
            analysisService: analysisService,
            progressService: progressService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    verseNavigationBar
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            verseDisplay
                            
                            if viewModel.showTransliteration, let verse = viewModel.currentVerse, !verse.transliteration.isEmpty {
                                Text(verse.transliteration)
                                    .font(.subheadline)
                                    .italic()
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            if viewModel.showTranslation, let verse = viewModel.currentVerse, !verse.translation.isEmpty {
                                Text(verse.translation)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 200)
                    }

                    Spacer()

                    recordingControls
                }
            }
            .navigationTitle(surah.englishName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("Transliteration", isOn: Bindable(viewModel).showTransliteration)
                        Toggle("Translation", isOn: Bindable(viewModel).showTranslation)
                    } label: {
                        Image(systemName: "textformat.size")
                    }
                }
            }
            .task {
                viewModel.load(surah: surah)
                if let initialVerse {
                    let index = viewModel.verses.firstIndex(where: { $0.id == initialVerse.id }) ?? 0
                    viewModel.selectVerse(at: index)
                }
            }
            .sheet(isPresented: Bindable(viewModel).showFeedback) {
                if let feedback = viewModel.feedback, let verse = viewModel.currentVerse {
                    TajweedFeedbackView(feedback: feedback, verse: verse)
                }
            }
        }
    }

    private var verseNavigationBar: some View {
        HStack {
            Button {
                withAnimation(.snappy) { viewModel.previousVerse() }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            .disabled(viewModel.currentVerseIndex == 0)
            .opacity(viewModel.currentVerseIndex == 0 ? 0.3 : 1)

            Spacer()

            VStack(spacing: 2) {
                Text("Verse \(viewModel.currentVerseIndex + 1) of \(viewModel.verses.count)")
                    .font(.subheadline.weight(.medium))
                
                Text(surah.arabicName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.snappy) { viewModel.nextVerse() }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            .disabled(viewModel.currentVerseIndex >= viewModel.verses.count - 1)
            .opacity(viewModel.currentVerseIndex >= viewModel.verses.count - 1 ? 0.3 : 1)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground).opacity(0.5))
    }

    private var verseDisplay: some View {
        VStack(spacing: 16) {
            if let verse = viewModel.currentVerse {
                if let feedback = viewModel.feedback {
                    wordByWordDisplay(verse: verse, feedback: feedback)
                } else {
                    Text(verse.arabicText)
                        .font(.system(size: 32))
                        .multilineTextAlignment(.center)
                        .lineSpacing(16)
                        .padding(.horizontal)
                }
            }
        }
    }

    private func wordByWordDisplay(verse: Verse, feedback: RecitationFeedback) -> some View {
        let layout = FlowLayout(spacing: 12)
        return layout.callAsFunction {
            ForEach(feedback.wordResults) { wordResult in
                Text(wordResult.arabicText)
                    .font(.system(size: 28))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colorForStatus(wordResult.status).opacity(0.15))
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorForStatus(wordResult.status), lineWidth: 1.5)
                    )
            }
        }
        .padding(.horizontal)
    }

    private func colorForStatus(_ status: WordResult.WordStatus) -> Color {
        switch status {
        case .correct: .green
        case .minor: .orange
        case .incorrect: .red
        case .missed: .gray
        }
    }

    private var recordingControls: some View {
        VStack(spacing: 16) {
            if viewModel.audioService.isRecording {
                audioWaveform
            }

            if viewModel.isAnalyzing {
                VStack(spacing: 12) {
                    SwiftUI.ProgressView()
                        .controlSize(.large)
                    Text("Analyzing your recitation...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
            }

            HStack(spacing: 32) {
                if viewModel.feedback != nil {
                    Button {
                        viewModel.showFeedback = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.title3)
                            Text("Results")
                                .font(.caption2)
                        }
                        .foregroundStyle(.green)
                    }
                }

                Button {
                    Task {
                        if viewModel.audioService.isRecording {
                            await viewModel.stopRecording()
                        } else {
                            await viewModel.startRecording()
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(viewModel.audioService.isRecording ? Color.red : Color.green)
                            .frame(width: 72, height: 72)
                            .shadow(color: (viewModel.audioService.isRecording ? Color.red : Color.green).opacity(0.4), radius: 12, y: 4)

                        Image(systemName: viewModel.audioService.isRecording ? "stop.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .disabled(viewModel.isAnalyzing)
                .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.audioService.isRecording)

                if viewModel.feedback != nil {
                    Button {
                        withAnimation(.snappy) { viewModel.nextVerse() }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "forward.fill")
                                .font(.title3)
                            Text("Next")
                                .font(.caption2)
                        }
                        .foregroundStyle(.green)
                    }
                    .disabled(viewModel.currentVerseIndex >= viewModel.verses.count - 1)
                }
            }
        }
        .padding(24)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var audioWaveform: some View {
        HStack(spacing: 3) {
            ForEach(0..<20, id: \.self) { index in
                let height = waveHeight(for: index, level: viewModel.audioService.audioLevel)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.green)
                    .frame(width: 3, height: height)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.audioService.audioLevel)
            }
        }
        .frame(height: 40)
    }

    private func waveHeight(for index: Int, level: Float) -> CGFloat {
        let base: CGFloat = 4
        let maxAdditional: CGFloat = 36
        let centerDistance = abs(CGFloat(index) - 10) / 10.0
        let levelFactor = CGFloat(level) * (1.0 - centerDistance * 0.5)
        let randomVariation = CGFloat.random(in: 0.7...1.0)
        return base + maxAdditional * levelFactor * randomVariation
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> ArrangementResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews.reversed() {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX)
        }

        positions.reverse()
        return ArrangementResult(positions: positions, size: CGSize(width: totalWidth, height: currentY + lineHeight))
    }

    private struct ArrangementResult {
        let positions: [CGPoint]
        let size: CGSize
    }
}
