import SwiftUI

nonisolated enum TajweedRuleCategory: String, CaseIterable, Sendable, Hashable {
    case noonSakinah = "Noon Sakinah & Tanween"
    case meemSakinah = "Meem Sakinah"
    case qalqalah = "Qalqalah"
    case madd = "Madd (Elongation)"
    case ghunnah = "Ghunnah"
    case laamShamsiyyah = "Laam Shamsiyyah & Qamariyyah"
    case stopping = "Waqf (Stopping)"
    case heavyLight = "Heavy & Light Letters"
}

nonisolated struct TajweedRule: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let arabicName: String
    let category: TajweedRuleCategory
    let description: String
    let example: String
    let colorHex: String
}

nonisolated struct TajweedViolation: Identifiable, Hashable, Sendable {
    let id: String
    let rule: TajweedRule
    let wordIndex: Int
    let wordText: String
    let explanation: String
    let severity: Severity

    nonisolated enum Severity: String, Sendable, Hashable {
        case minor
        case moderate
        case major
    }
}
