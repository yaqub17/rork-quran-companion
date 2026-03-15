import SwiftUI

struct OnboardingView: View {
    @Binding var hasOnboarded: Bool
    @State private var currentPage: Int = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "waveform.and.mic",
            title: "Perfect Your Recitation",
            subtitle: "Tilawa listens to your Quran recitation and provides real-time AI-powered feedback on your pronunciation and Tajweed.",
            accentColor: .green
        ),
        OnboardingPage(
            icon: "paintpalette.fill",
            title: "Color-Coded Tajweed",
            subtitle: "See Tajweed rules highlighted in color as you read. Each color represents a specific rule — Ghunnah, Ikhfa, Qalqalah, Madd, and more.",
            accentColor: .teal
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            subtitle: "Monitor your improvement over time with detailed statistics, streaks, and personalized practice recommendations.",
            accentColor: .orange
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    onboardingPageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            bottomSection
        }
        .background(Color(.systemBackground))
    }

    private func onboardingPageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(page.accentColor.opacity(0.06))
                    .frame(width: 220, height: 220)

                Image(systemName: page.icon)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(page.accentColor)
                    .symbolEffect(.pulse, options: .repeating)
            }

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }

    private var bottomSection: some View {
        VStack(spacing: 24) {
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? pages[currentPage].accentColor : Color(.tertiaryLabel))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.snappy, value: currentPage)
                }
            }

            if currentPage == pages.count - 1 {
                Button {
                    withAnimation(.spring(duration: 0.4)) {
                        hasOnboarded = true
                    }
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation {
                        currentPage += 1
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }

            if currentPage < pages.count - 1 {
                Button("Skip") {
                    withAnimation(.spring(duration: 0.4)) {
                        hasOnboarded = true
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
}
