import SwiftUI

struct TajweedTextView: View {
    let words: [QuranWord]
    let fontSize: CGFloat
    let showLegend: Bool

    init(words: [QuranWord], fontSize: CGFloat = 28, showLegend: Bool = false) {
        self.words = words
        self.fontSize = fontSize
        self.showLegend = showLegend
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(buildAttributedString())
                .multilineTextAlignment(.center)
                .lineSpacing(fontSize * 0.5)

            if showLegend {
                tajweedLegend
            }
        }
    }

    private func buildAttributedString() -> AttributedString {
        var fullString = AttributedString()
        let reversedWords = words.reversed()

        for (index, word) in reversedWords.enumerated() {
            if word.tajweedAnnotations.isEmpty {
                var attr = AttributedString(word.arabicText)
                attr.font = .system(size: fontSize)
                attr.foregroundColor = .primary
                fullString.append(attr)
            } else {
                let annotated = buildAnnotatedWord(word)
                fullString.append(annotated)
            }

            if index < reversedWords.count - 1 {
                var space = AttributedString(" ")
                space.font = .system(size: fontSize)
                fullString.append(space)
            }
        }

        return fullString
    }

    private func buildAnnotatedWord(_ word: QuranWord) -> AttributedString {
        let text = word.arabicText
        var result = AttributedString(text)
        result.font = .system(size: fontSize)
        result.foregroundColor = .primary

        for annotation in word.tajweedAnnotations {
            let startOffset = text.distance(from: text.startIndex, to: annotation.range.lowerBound)
            let endOffset = text.distance(from: text.startIndex, to: annotation.range.upperBound)

            let attrStart = result.index(result.startIndex, offsetByCharacters: startOffset)
            let attrEnd = result.index(result.startIndex, offsetByCharacters: endOffset)

            if attrStart < attrEnd {
                result[attrStart..<attrEnd].foregroundColor = Color(hex: annotation.rule.colorHex)
            }
        }

        return result
    }

    private var tajweedLegend: some View {
        let activeRules = Set(words.flatMap { $0.tajweedAnnotations.map(\.rule) })
        return Group {
            if !activeRules.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(Array(activeRules).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { rule in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: rule.colorHex))
                                    .frame(width: 8, height: 8)
                                Text(rule.displayName)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 16)
                .scrollIndicators(.hidden)
            }
        }
    }
}

struct TajweedLegendView: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(TajweedColorRule.allCases, id: \.self) { rule in
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: rule.colorHex))
                        .frame(width: 14, height: 14)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(rule.displayName)
                            .font(.caption2.weight(.medium))
                        Text(rule.arabicName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
