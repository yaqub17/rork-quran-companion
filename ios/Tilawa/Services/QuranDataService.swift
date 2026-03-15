import Foundation

@Observable
@MainActor
class QuranDataService {
    var surahs: [Surah] = []
    var isLoaded = false

    func loadSurahs() {
        guard !isLoaded else { return }
        surahs = Self.allSurahs
        isLoaded = true
    }

    func verses(for surah: Surah) -> [Verse] {
        (1...surah.versesCount).map { verseNum in
            let words = Self.sampleWords(for: surah.id, verse: verseNum)
            return Verse(
                id: "\(surah.id):\(verseNum)",
                surahNumber: surah.id,
                verseNumber: verseNum,
                arabicText: Self.sampleArabicText(surah: surah.id, verse: verseNum),
                transliteration: Self.sampleTransliteration(surah: surah.id, verse: verseNum),
                translation: Self.sampleTranslation(surah: surah.id, verse: verseNum),
                juzNumber: surah.juzNumbers.first ?? 1,
                pageNumber: 1,
                words: words
            )
        }
    }

    func surah(byNumber number: Int) -> Surah? {
        surahs.first { $0.id == number }
    }

    static func sampleWords(for surah: Int, verse: Int) -> [QuranWord] {
        let texts = sampleArabicWords(surah: surah, verse: verse)
        return texts.enumerated().map { index, text in
            QuranWord(
                id: "\(surah):\(verse):\(index)",
                position: index,
                arabicText: text,
                transliteration: "",
                translation: "",
                tajweedAnnotations: Self.tajweedAnnotations(for: text, surah: surah, verse: verse, position: index)
            )
        }
    }

    private static func tajweedAnnotations(for word: String, surah: Int, verse: Int, position: Int) -> [TajweedAnnotation] {
        var annotations: [TajweedAnnotation] = []

        let shaddah = "\u{0651}"
        let laam = "\u{0644}"
        let raa = "\u{0631}"
        let sheen = "\u{0634}"
        let saad = "\u{0635}"
        let dal = "\u{062F}"
        let noon = "\u{0646}"
        let meem = "\u{0645}"
        let alif = "\u{0627}"
        let tatweel = "\u{0640}"
        let superAlif = "\u{0670}"
        let fathah = "\u{064E}"
        let kasrah = "\u{0650}"
        let dammah = "\u{064F}"
        let sukun = "\u{0652}"
        let alefMadda = "\u{0622}"
        let tanweenFath = "\u{064B}"
        let tanweenDamm = "\u{064C}"
        let tanweenKasr = "\u{064D}"
        let qaf = "\u{0642}"
        let taa = "\u{0637}"
        let ba = "\u{0628}"
        let jeem = "\u{062C}"
        let yaa = "\u{064A}"
        let waw = "\u{0648}"
        let alefLam = alif + laam

        if word.contains(shaddah) {
            if word.hasPrefix(alefLam + raa + shaddah) || word.hasPrefix(alefLam + sheen + shaddah) || word.hasPrefix(alefLam + saad + shaddah) || word.hasPrefix(alefLam + dal + shaddah) || word.hasPrefix(alefLam + noon + shaddah) || word.contains(laam + raa + shaddah) || word.contains(laam + saad + shaddah) || word.contains(laam + sheen + shaddah) {
                if let range = word.range(of: laam) {
                    annotations.append(TajweedAnnotation(range: range, rule: .laamShamsiyyah))
                }
            }
        }

        for char in [qaf, taa, ba, jeem, dal] {
            if word.contains(char + sukun) {
                if let range = word.range(of: char + sukun) {
                    annotations.append(TajweedAnnotation(range: range, rule: .qalqalah))
                }
            }
        }

        if word.contains(noon + shaddah) {
            if let range = word.range(of: noon + shaddah) {
                annotations.append(TajweedAnnotation(range: range, rule: .ghunnah))
            }
        }
        if word.contains(meem + shaddah) {
            if let range = word.range(of: meem + shaddah) {
                annotations.append(TajweedAnnotation(range: range, rule: .ghunnah))
            }
        }

        if word.contains(tatweel + superAlif) {
            if let range = word.range(of: tatweel + superAlif) {
                annotations.append(TajweedAnnotation(range: range, rule: .maddNormal))
            }
        }
        if word.contains(fathah + alif) {
            if let range = word.range(of: fathah + alif) {
                annotations.append(TajweedAnnotation(range: range, rule: .maddNormal))
            }
        }

        if word.contains(alefMadda) {
            if let range = word.range(of: alefMadda) {
                annotations.append(TajweedAnnotation(range: range, rule: .maddMuttasil))
            }
        }

        if word.contains(tanweenFath) || word.contains(tanweenDamm) || word.contains(tanweenKasr) {
            if let range = word.range(of: tanweenFath) {
                annotations.append(TajweedAnnotation(range: range, rule: .ikhfa))
            } else if let range = word.range(of: tanweenDamm) {
                annotations.append(TajweedAnnotation(range: range, rule: .ikhfa))
            } else if let range = word.range(of: tanweenKasr) {
                annotations.append(TajweedAnnotation(range: range, rule: .ikhfa))
            }
        }

        let _ = [kasrah, dammah, yaa, waw]

        return annotations
    }

    private static func sampleArabicWords(surah: Int, verse: Int) -> [String] {
        if surah == 1 {
            switch verse {
            case 1: return ["بِسْمِ", "ٱللَّهِ", "ٱلرَّحْمَـٰنِ", "ٱلرَّحِيمِ"]
            case 2: return ["ٱلْحَمْدُ", "لِلَّهِ", "رَبِّ", "ٱلْعَـٰلَمِينَ"]
            case 3: return ["ٱلرَّحْمَـٰنِ", "ٱلرَّحِيمِ"]
            case 4: return ["مَـٰلِكِ", "يَوْمِ", "ٱلدِّينِ"]
            case 5: return ["إِيَّاكَ", "نَعْبُدُ", "وَإِيَّاكَ", "نَسْتَعِينُ"]
            case 6: return ["ٱهْدِنَا", "ٱلصِّرَٰطَ", "ٱلْمُسْتَقِيمَ"]
            case 7: return ["صِرَٰطَ", "ٱلَّذِينَ", "أَنْعَمْتَ", "عَلَيْهِمْ", "غَيْرِ", "ٱلْمَغْضُوبِ", "عَلَيْهِمْ", "وَلَا", "ٱلضَّآلِّينَ"]
            default: return ["بِسْمِ", "ٱللَّهِ"]
            }
        }
        if surah == 112 {
            switch verse {
            case 1: return ["قُلْ", "هُوَ", "ٱللَّهُ", "أَحَدٌ"]
            case 2: return ["ٱللَّهُ", "ٱلصَّمَدُ"]
            case 3: return ["لَمْ", "يَلِدْ", "وَلَمْ", "يُولَدْ"]
            case 4: return ["وَلَمْ", "يَكُن", "لَّهُۥ", "كُفُوًا", "أَحَدٌۢ"]
            default: return ["بِسْمِ", "ٱللَّهِ"]
            }
        }
        return ["بِسْمِ", "ٱللَّهِ", "ٱلرَّحْمَـٰنِ", "ٱلرَّحِيمِ"]
    }

    private static func sampleArabicText(surah: Int, verse: Int) -> String {
        sampleArabicWords(surah: surah, verse: verse).joined(separator: " ")
    }

    private static func sampleTransliteration(surah: Int, verse: Int) -> String {
        if surah == 1 {
            switch verse {
            case 1: return "Bismillahir Rahmanir Raheem"
            case 2: return "Alhamdu lillahi Rabbil 'aalameen"
            case 3: return "Ar-Rahmanir-Raheem"
            case 4: return "Maaliki Yawmid-Deen"
            case 5: return "Iyyaaka na'budu wa iyyaaka nasta'een"
            case 6: return "Ihdinas-Siraatal-Mustaqeem"
            case 7: return "Siraatal-lazeena an'amta 'alaihim ghairil-maghdoobi 'alaihim wa lad-daaalleen"
            default: return ""
            }
        }
        if surah == 112 {
            switch verse {
            case 1: return "Qul huwal laahu ahad"
            case 2: return "Allahus-samad"
            case 3: return "Lam yalid wa lam yoolad"
            case 4: return "Wa lam yakul-lahu kufuwan ahad"
            default: return ""
            }
        }
        return "Bismillahir Rahmanir Raheem"
    }

    private static func sampleTranslation(surah: Int, verse: Int) -> String {
        if surah == 1 {
            switch verse {
            case 1: return "In the name of Allah, the Most Gracious, the Most Merciful"
            case 2: return "All praise is due to Allah, Lord of all the worlds"
            case 3: return "The Most Gracious, the Most Merciful"
            case 4: return "Master of the Day of Judgment"
            case 5: return "You alone we worship, and You alone we ask for help"
            case 6: return "Guide us along the Straight Path"
            case 7: return "The path of those You have blessed—not those You are displeased with, or those who are astray"
            default: return ""
            }
        }
        if surah == 112 {
            switch verse {
            case 1: return "Say, 'He is Allah, the One'"
            case 2: return "Allah, the Eternal Refuge"
            case 3: return "He neither begets nor is born"
            case 4: return "Nor is there to Him any equivalent"
            default: return ""
            }
        }
        return "In the name of Allah, the Most Gracious, the Most Merciful"
    }

    static let allSurahs: [Surah] = [
        Surah(id: 1, arabicName: "الفاتحة", englishName: "Al-Fatihah", englishTranslation: "The Opening", versesCount: 7, revelationType: .meccan, juzNumbers: [1]),
        Surah(id: 2, arabicName: "البقرة", englishName: "Al-Baqarah", englishTranslation: "The Cow", versesCount: 286, revelationType: .medinan, juzNumbers: [1, 2, 3]),
        Surah(id: 3, arabicName: "آل عمران", englishName: "Ali 'Imran", englishTranslation: "Family of Imran", versesCount: 200, revelationType: .medinan, juzNumbers: [3, 4]),
        Surah(id: 4, arabicName: "النساء", englishName: "An-Nisa", englishTranslation: "The Women", versesCount: 176, revelationType: .medinan, juzNumbers: [4, 5, 6]),
        Surah(id: 5, arabicName: "المائدة", englishName: "Al-Ma'idah", englishTranslation: "The Table Spread", versesCount: 120, revelationType: .medinan, juzNumbers: [6, 7]),
        Surah(id: 6, arabicName: "الأنعام", englishName: "Al-An'am", englishTranslation: "The Cattle", versesCount: 165, revelationType: .meccan, juzNumbers: [7, 8]),
        Surah(id: 7, arabicName: "الأعراف", englishName: "Al-A'raf", englishTranslation: "The Heights", versesCount: 206, revelationType: .meccan, juzNumbers: [8, 9]),
        Surah(id: 8, arabicName: "الأنفال", englishName: "Al-Anfal", englishTranslation: "The Spoils of War", versesCount: 75, revelationType: .medinan, juzNumbers: [9, 10]),
        Surah(id: 9, arabicName: "التوبة", englishName: "At-Tawbah", englishTranslation: "The Repentance", versesCount: 129, revelationType: .medinan, juzNumbers: [10, 11]),
        Surah(id: 10, arabicName: "يونس", englishName: "Yunus", englishTranslation: "Jonah", versesCount: 109, revelationType: .meccan, juzNumbers: [11]),
        Surah(id: 11, arabicName: "هود", englishName: "Hud", englishTranslation: "Hud", versesCount: 123, revelationType: .meccan, juzNumbers: [11, 12]),
        Surah(id: 12, arabicName: "يوسف", englishName: "Yusuf", englishTranslation: "Joseph", versesCount: 111, revelationType: .meccan, juzNumbers: [12, 13]),
        Surah(id: 13, arabicName: "الرعد", englishName: "Ar-Ra'd", englishTranslation: "The Thunder", versesCount: 43, revelationType: .medinan, juzNumbers: [13]),
        Surah(id: 14, arabicName: "إبراهيم", englishName: "Ibrahim", englishTranslation: "Abraham", versesCount: 52, revelationType: .meccan, juzNumbers: [13]),
        Surah(id: 15, arabicName: "الحجر", englishName: "Al-Hijr", englishTranslation: "The Rocky Tract", versesCount: 99, revelationType: .meccan, juzNumbers: [14]),
        Surah(id: 16, arabicName: "النحل", englishName: "An-Nahl", englishTranslation: "The Bee", versesCount: 128, revelationType: .meccan, juzNumbers: [14]),
        Surah(id: 17, arabicName: "الإسراء", englishName: "Al-Isra", englishTranslation: "The Night Journey", versesCount: 111, revelationType: .meccan, juzNumbers: [15]),
        Surah(id: 18, arabicName: "الكهف", englishName: "Al-Kahf", englishTranslation: "The Cave", versesCount: 110, revelationType: .meccan, juzNumbers: [15, 16]),
        Surah(id: 19, arabicName: "مريم", englishName: "Maryam", englishTranslation: "Mary", versesCount: 98, revelationType: .meccan, juzNumbers: [16]),
        Surah(id: 20, arabicName: "طه", englishName: "Taha", englishTranslation: "Ta-Ha", versesCount: 135, revelationType: .meccan, juzNumbers: [16]),
        Surah(id: 21, arabicName: "الأنبياء", englishName: "Al-Anbiya", englishTranslation: "The Prophets", versesCount: 112, revelationType: .meccan, juzNumbers: [17]),
        Surah(id: 22, arabicName: "الحج", englishName: "Al-Hajj", englishTranslation: "The Pilgrimage", versesCount: 78, revelationType: .medinan, juzNumbers: [17]),
        Surah(id: 23, arabicName: "المؤمنون", englishName: "Al-Mu'minun", englishTranslation: "The Believers", versesCount: 118, revelationType: .meccan, juzNumbers: [18]),
        Surah(id: 24, arabicName: "النور", englishName: "An-Nur", englishTranslation: "The Light", versesCount: 64, revelationType: .medinan, juzNumbers: [18]),
        Surah(id: 25, arabicName: "الفرقان", englishName: "Al-Furqan", englishTranslation: "The Criterion", versesCount: 77, revelationType: .meccan, juzNumbers: [18, 19]),
        Surah(id: 36, arabicName: "يس", englishName: "Ya-Sin", englishTranslation: "Ya-Sin", versesCount: 83, revelationType: .meccan, juzNumbers: [22, 23]),
        Surah(id: 55, arabicName: "الرحمن", englishName: "Ar-Rahman", englishTranslation: "The Most Merciful", versesCount: 78, revelationType: .medinan, juzNumbers: [27]),
        Surah(id: 56, arabicName: "الواقعة", englishName: "Al-Waqi'ah", englishTranslation: "The Inevitable", versesCount: 96, revelationType: .meccan, juzNumbers: [27]),
        Surah(id: 67, arabicName: "الملك", englishName: "Al-Mulk", englishTranslation: "The Sovereignty", versesCount: 30, revelationType: .meccan, juzNumbers: [29]),
        Surah(id: 72, arabicName: "الجن", englishName: "Al-Jinn", englishTranslation: "The Jinn", versesCount: 28, revelationType: .meccan, juzNumbers: [29]),
        Surah(id: 73, arabicName: "المزمل", englishName: "Al-Muzzammil", englishTranslation: "The Enshrouded One", versesCount: 20, revelationType: .meccan, juzNumbers: [29]),
        Surah(id: 78, arabicName: "النبأ", englishName: "An-Naba", englishTranslation: "The Tidings", versesCount: 40, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 87, arabicName: "الأعلى", englishName: "Al-A'la", englishTranslation: "The Most High", versesCount: 19, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 93, arabicName: "الضحى", englishName: "Ad-Duhaa", englishTranslation: "The Morning Hours", versesCount: 11, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 94, arabicName: "الشرح", englishName: "Ash-Sharh", englishTranslation: "The Relief", versesCount: 8, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 95, arabicName: "التين", englishName: "At-Tin", englishTranslation: "The Fig", versesCount: 8, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 96, arabicName: "العلق", englishName: "Al-Alaq", englishTranslation: "The Clot", versesCount: 19, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 97, arabicName: "القدر", englishName: "Al-Qadr", englishTranslation: "The Power", versesCount: 5, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 99, arabicName: "الزلزلة", englishName: "Az-Zalzalah", englishTranslation: "The Earthquake", versesCount: 8, revelationType: .medinan, juzNumbers: [30]),
        Surah(id: 100, arabicName: "العاديات", englishName: "Al-Adiyat", englishTranslation: "The Chargers", versesCount: 11, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 101, arabicName: "القارعة", englishName: "Al-Qari'ah", englishTranslation: "The Calamity", versesCount: 11, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 102, arabicName: "التكاثر", englishName: "At-Takathur", englishTranslation: "The Rivalry", versesCount: 8, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 103, arabicName: "العصر", englishName: "Al-Asr", englishTranslation: "The Declining Day", versesCount: 3, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 104, arabicName: "الهمزة", englishName: "Al-Humazah", englishTranslation: "The Traducer", versesCount: 9, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 105, arabicName: "الفيل", englishName: "Al-Fil", englishTranslation: "The Elephant", versesCount: 5, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 106, arabicName: "قريش", englishName: "Quraysh", englishTranslation: "Quraysh", versesCount: 4, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 107, arabicName: "الماعون", englishName: "Al-Ma'un", englishTranslation: "The Small Kindnesses", versesCount: 7, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 108, arabicName: "الكوثر", englishName: "Al-Kawthar", englishTranslation: "The Abundance", versesCount: 3, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 109, arabicName: "الكافرون", englishName: "Al-Kafirun", englishTranslation: "The Disbelievers", versesCount: 6, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 110, arabicName: "النصر", englishName: "An-Nasr", englishTranslation: "The Victory", versesCount: 3, revelationType: .medinan, juzNumbers: [30]),
        Surah(id: 111, arabicName: "المسد", englishName: "Al-Masad", englishTranslation: "The Palm Fiber", versesCount: 5, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 112, arabicName: "الإخلاص", englishName: "Al-Ikhlas", englishTranslation: "The Sincerity", versesCount: 4, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 113, arabicName: "الفلق", englishName: "Al-Falaq", englishTranslation: "The Daybreak", versesCount: 5, revelationType: .meccan, juzNumbers: [30]),
        Surah(id: 114, arabicName: "الناس", englishName: "An-Nas", englishTranslation: "Mankind", versesCount: 6, revelationType: .meccan, juzNumbers: [30]),
    ]
}
