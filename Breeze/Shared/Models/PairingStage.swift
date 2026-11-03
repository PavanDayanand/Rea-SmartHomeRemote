import Foundation

enum PairingStage: String, Sendable {
    case idle, token, hotspot, connecting, found, registered, returnToWiFi
    case complete, failed, cancelled

    var title: String {
        switch self {
        case .idle: "Ready to connect"
        case .token: "Preparing a secure connection"
        case .hotspot: "Join the fan’s Wi-Fi"
        case .connecting: "Contacting your fan"
        case .found: "Fan found"
        case .registered: "Fan registered"
        case .returnToWiFi: "Return to your home Wi-Fi"
        case .complete: "Fan connected"
        case .failed: "Connection stopped"
        case .cancelled: "Connection cancelled"
        }
    }
}
