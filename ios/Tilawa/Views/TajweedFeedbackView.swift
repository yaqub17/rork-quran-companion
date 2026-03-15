import SwiftUI

struct TajweedFeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    let feedback: RecitationFeedback
    let verse: Verse

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    scoreOverview
                    scoreBreakdown
                    wordResultsSection
                    violationsSection
                    feedbackSection
                }
                .padding()
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recitation Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var scoreOverview: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemFill), lineWidth: 10)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: feedback.overallScore)
                    .stroke(
                        scoreColor(feedback.overallScore),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120, height: 120)

                VStack(spacing: 2) {
                    Text("\(Int(feedback.overallScore * 100))")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(scoreColor(feedback.overallScore))

                    Text("Score")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(gradeText(feedback.overallScore))
                .font(.title3.weight(.semibold))
                .foregroundStyle(scoreColor(feedback.overallScore))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var scoreBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score Breakdown")
                .font(.headline)

            HStack(spacing: 12) {
                ScoreDetailCard(title: "Tajweed", score: feedback.tajweedScore, icon: "text.book.closed.fill", color: .blue)
                ScoreDetailCard(title: "Pronunciation", score: feedback.pronunciationScore, icon: "waveform", color: .green)
                ScoreDetailCard(title: "Fluency", score: feedback.fluencyScore, icon: "water.waves", color: .purple)
            }
        }
    }

    private var wordResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Word-by-Word Results")
                .font(.headline)

            let layout = FlowLayout(spacing: 8)
            layout {
                ForEach(feedback.wordResults) { result in
                    VStack(spacing: 4) {
                        Text(result.arabicText)
                            .font(.system(size: 22))

                        Image(systemName: iconForStatus(result.status))
                            .font(.caption)
                            .foregroundStyle(colorForStatus(result.status))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(colorForStatus(result.status).opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorForStatus(result.status).opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    @ViewBuilder
    private var violationsSection: some View {
        if !feedback.violations.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label("Tajweed Notes", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)

                ForEach(feedback.violations) { violation in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(violation.rule.name)
                                .font(.subheadline.weight(.semibold))

                            Text("(\(violation.rule.arabicName))")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            severityBadge(violation.severity)
                        }

                        HStack(spacing: 8) {
                            Text("Word:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(violation.wordText)
                                .font(.system(size: 18))
                        }

                        Text(violation.explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AI Feedback", systemImage: "sparkles")
                .font(.headline)

            Text(feedback.feedbackText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)

            if !feedback.arabicFeedback.isEmpty {
                Text(feedback.arabicFeedback)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 0.8...: .green
        case 0.6..<0.8: .orange
        default: .red
        }
    }

    private func gradeText(_ score: Double) -> String {
        switch score {
        case 0.9...: "Excellent!"
        case 0.8..<0.9: "Very Good"
        case 0.7..<0.8: "Good"
        case 0.6..<0.7: "Fair"
        default: "Keep Practicing"
        }
    }

    private func colorForStatus(_ status: WordResult.WordStatus) -> Color {
        switch status {
        case .correct: .green
        case .minor: .orange
        case .incorrect: .red
        case .missed: .gray
        }
    }

    private func iconForStatus(_ status: WordResult.WordStatus) -> String {
        switch status {
        case .correct: "checkmark.circle.fill"
        case .minor: "exclamationmark.circle.fill"
        case .incorrect: "xmark.circle.fill"
        case .missed: "minus.circle.fill"
        }
    }

    private func severityBadge(_ severity: TajweedViolation.Severity) -> some View {
        Text(severity.rawValue.capitalized)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                severity == .major ? Color.red.opacity(0.15) :
                severity == .moderate ? Color.orange.opacity(0.15) :
                Color.yellow.opacity(0.15)
            )
            .foregroundStyle(
                severity == .major ? .red :
                severity == .moderate ? .orange :
                .yellow
            )
            .clipShape(Capsule())
    }
}

struct ScoreDetailCard: View {
    let title: String
    let score: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text("\(Int(score * 100))%")
                .font(.system(.headline, design: .rounded, weight: .bold))

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}
