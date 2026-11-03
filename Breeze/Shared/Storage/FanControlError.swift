import Foundation

enum FanControlError: LocalizedError {
    case fanNotFound
    case invalidSpeed
    case invalidLightLevel
    case invalidCountdown

    var errorDescription: String? {
        switch self {
        case .fanNotFound: "This demo fan could not be found."
        case .invalidSpeed: "Choose a speed supported by this fan."
        case .invalidLightLevel: "Choose a light level from 0 to 3."
        case .invalidCountdown: "Choose 0, 2, 4, 6, or 8 hours."
        }
    }
}
