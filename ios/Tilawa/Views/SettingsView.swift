import SwiftUI

struct SettingsView: View {
    @AppStorage("showTranslation") private var showTranslation = true
    @AppStorage("showTransliteration") private var showTransliteration = false
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 28
    @AppStorage("recitationSpeed") private var recitationSpeed: Double = 1.0
    @AppStorage("feedbackLanguage") private var feedbackLanguage = "English"
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("darkMode") private var darkMode = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Display") {
                    Toggle("Show Translation", isOn: $showTranslation)
                    Toggle("Show Transliteration", isOn: $showTransliteration)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Arabic Font Size")
                            Spacer()
                            Text("\(Int(arabicFontSize))")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $arabicFontSize, in: 20...44, step: 2)
                            .tint(.green)

                        Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ")
                            .font(.system(size: arabicFontSize))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 4)
                    }
                }

                Section("Recitation") {
                    Picker("Feedback Language", selection: $feedbackLanguage) {
                        Text("English").tag("English")
                        Text("Arabic").tag("Arabic")
                        Text("Both").tag("Both")
                    }

                    Toggle("Haptic Feedback", isOn: $hapticFeedback)
                }

                Section("Tajweed") {
                    NavigationLink {
                        TajweedRulesGuideView()
                    } label: {
                        Label("Tajweed Rules Guide", systemImage: "text.book.closed.fill")
                    }

                    NavigationLink {
                        TajweedColorReferenceView()
                    } label: {
                        Label("Tajweed Color Reference", systemImage: "paintpalette.fill")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About Tilawa", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct TajweedColorReferenceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("When reading Quran verses in Tilawa, words are color-coded to show Tajweed rules that apply.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)

                VStack(spacing: 0) {
                    ForEach(TajweedColorRule.allCases, id: \.self) { rule in
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: rule.colorHex))
                                .frame(width: 24, height: 24)

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(rule.displayName)
                                        .font(.subheadline.weight(.medium))
                                    Text("(\(rule.arabicName))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text(ruleDescription(rule))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineSpacing(2)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)

                        if rule != TajweedColorRule.allCases.last {
                            Divider().padding(.leading, 54)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Tajweed Colors")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func ruleDescription(_ rule: TajweedColorRule) -> String {
        switch rule {
        case .ghunnah: "Nasalization held for two counts on Noon/Meem Mushaddad"
        case .ikhfa: "Concealment of Noon Sakinah with nasalization"
        case .idgham: "Merging Noon Sakinah into the following letter"
        case .iqlab: "Converting Noon to Meem before Ba"
        case .qalqalah: "Echoing bounce on letters ق ط ب ج د when Sakin"
        case .maddNormal: "Natural prolongation of 2 counts"
        case .maddMunfasil: "Separated prolongation of 4-5 counts"
        case .maddMuttasil: "Connected prolongation of 4-5 counts"
        case .maddLazim: "Obligatory prolongation of 6 counts"
        case .laamShamsiyyah: "Assimilation of Laam into Sun letters"
        case .izhar: "Clear pronunciation before throat letters"
        }
    }
}

struct TajweedRulesGuideView: View {
    var body: some View {
        List {
            ForEach(TajweedRuleCategory.allCases, id: \.self) { category in
                Section(category.rawValue) {
                    ForEach(rulesForCategory(category)) { rule in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: rule.colorHex))
                                    .frame(width: 14, height: 14)

                                Text(rule.name)
                                    .font(.subheadline.weight(.medium))

                                Text("(\(rule.arabicName))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text(rule.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if !rule.example.isEmpty {
                                Text("Example: \(rule.example)")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Tajweed Rules")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rulesForCategory(_ category: TajweedRuleCategory) -> [TajweedRule] {
        switch category {
        case .noonSakinah:
            return [
                TajweedRule(id: "izhar", name: "Izhar", arabicName: "إظهار", category: category, description: "Clear pronunciation when followed by throat letters", example: "مَنْ أَعْطَى", colorHex: "#795548"),
                TajweedRule(id: "idgham", name: "Idgham", arabicName: "إدغام", category: category, description: "Merging Noon Sakinah into following letter", example: "مِن يَّعْمَلْ", colorHex: "#9C27B0"),
                TajweedRule(id: "iqlab", name: "Iqlab", arabicName: "إقلاب", category: category, description: "Converting Noon to Meem before Ba", example: "مِنۢ بَعْدِ", colorHex: "#E91E63"),
                TajweedRule(id: "ikhfa", name: "Ikhfa", arabicName: "إخفاء", category: category, description: "Concealment with nasalization", example: "مِنْ قَبْلِ", colorHex: "#2196F3"),
            ]
        case .ghunnah:
            return [
                TajweedRule(id: "ghunnah", name: "Ghunnah", arabicName: "غنة", category: category, description: "Nasalization held for two counts on Noon and Meem Mushaddad", example: "إِنَّ، ثُمَّ", colorHex: "#4CAF50"),
            ]
        case .madd:
            return [
                TajweedRule(id: "madd_tabii", name: "Madd Tabii", arabicName: "مد طبيعي", category: category, description: "Natural prolongation of 2 counts", example: "قَالَ", colorHex: "#FF9800"),
                TajweedRule(id: "madd_munfasil", name: "Madd Munfasil", arabicName: "مد منفصل", category: category, description: "Separated prolongation of 4-5 counts", example: "بِمَآ أُنزِلَ", colorHex: "#00BCD4"),
                TajweedRule(id: "madd_muttasil", name: "Madd Muttasil", arabicName: "مد متصل", category: category, description: "Connected prolongation of 4-5 counts", example: "جَآءَ", colorHex: "#D32F2F"),
            ]
        case .qalqalah:
            return [
                TajweedRule(id: "qalqalah", name: "Qalqalah", arabicName: "قلقلة", category: category, description: "Echoing bounce on letters ق ط ب ج د when sakin", example: "اقْرَأْ", colorHex: "#F44336"),
            ]
        default:
            return [
                TajweedRule(id: "\(category.rawValue)", name: category.rawValue, arabicName: "", category: category, description: "Rules for \(category.rawValue)", example: "", colorHex: "#607D8B"),
            ]
        }
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.15), .teal.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "waveform.and.mic")
                        .font(.system(size: 40))
                        .foregroundStyle(.green)
                }
                .padding(.top, 32)

                Text("Tilawa")
                    .font(.largeTitle.bold())

                Text("AI-Powered Quranic Recitation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Tilawa helps you perfect your Quran recitation through AI-powered pronunciation analysis and Tajweed rule detection.")
                        .font(.body)
                        .lineSpacing(4)

                    Text("Features include real-time audio analysis, word-by-word feedback, color-coded Tajweed highlighting, progress tracking, and personalized practice recommendations.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
