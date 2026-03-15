import SwiftUI

struct ProgressView: View {
    @State private var viewModel: ProgressViewModel

    init(progressService: ProgressTrackingService) {
        self._viewModel = State(initialValue: ProgressViewModel(progressService: progressService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    overviewCards
                    weeklyChart
                    weakAreasSection
                    recentSessionsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Progress")
            .task { viewModel.load() }
        }
    }

    private var overviewCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ProgressStatCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    value: "\(viewModel.stats?.currentStreak ?? 0)",
                    label: "Day Streak"
                )

                ProgressStatCard(
                    icon: "book.fill",
                    iconColor: .green,
                    value: "\(viewModel.stats?.totalVersesRecited ?? 0)",
                    label: "Verses Recited"
                )
            }

            HStack(spacing: 12) {
                ProgressStatCard(
                    icon: "clock.fill",
                    iconColor: .blue,
                    value: viewModel.formattedTotalTime,
                    label: "Total Time"
                )

                ProgressStatCard(
                    icon: "star.fill",
                    iconColor: .purple,
                    value: viewModel.scoreGrade,
                    label: "Avg Grade"
                )
            }
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.headline)

            if let progress = viewModel.stats?.weeklyProgress {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(progress.reversed()) { day in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.green.opacity(0.6), .green],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(height: max(8, CGFloat(day.versesRecited) * 6))

                            Text(dayLabel(day.date))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 140)
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    @ViewBuilder
    private var weakAreasSection: some View {
        if let weakRules = viewModel.stats?.weakRules, !weakRules.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label("Areas to Improve", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)

                ForEach(weakRules) { rule in
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.subheadline)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(rule.name)
                                    .font(.subheadline.weight(.medium))
                                Text("(\(rule.arabicName))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text(rule.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
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

    @ViewBuilder
    private var recentSessionsSection: some View {
        if let sessions = viewModel.stats?.recentSessions, !sessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Sessions")
                    .font(.headline)

                ForEach(sessions) { session in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(scoreColor(session.overallScore).opacity(0.15))
                                .frame(width: 44, height: 44)

                            Text("\(Int(session.overallScore * 100))")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .foregroundStyle(scoreColor(session.overallScore))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(session.surahName)
                                .font(.subheadline.weight(.medium))

                            Text("Verses \(session.startVerse)-\(session.endVerse)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 3) {
                            Text(session.date.formatted(.dateTime.day().month(.abbreviated)))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(formatDuration(session.duration))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    if session.id != sessions.last?.id {
                        Divider()
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 0.8...: .green
        case 0.6..<0.8: .orange
        default: .red
        }
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(2))
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        return "\(minutes)m"
    }
}

struct ProgressStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.12), in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.headline, design: .rounded, weight: .bold))

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}
