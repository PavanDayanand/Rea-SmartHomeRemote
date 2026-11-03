import Foundation

/// These names come from the controls in your Smart Life screenshots.
enum FanMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case normal = "Normal"
    case turbo = "Turbo"
    case sleep = "Sleep"
    case breeze = "Breeze"
    case reverse = "Reverse"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .normal: "fan"
        case .turbo: "wind"
        case .sleep: "moon"
        case .breeze: "leaf"
        case .reverse: "arrow.trianglehead.2.clockwise.rotate.90"
        }
    }
}
