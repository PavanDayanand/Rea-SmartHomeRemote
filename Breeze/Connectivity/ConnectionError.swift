import Foundation

enum ConnectionError: LocalizedError {
    case notConfigured
    case noHome
    case missingDevice
    case invalidValue
    case requestFailed
    case credentialStorage

    var errorDescription: String? {
        switch self {
        case .notConfigured: "Breeze’s SDK credentials have not been configured yet."
        case .noHome: "Create or select a home before adding a fan."
        case .missingDevice: "This device is unavailable. Refresh your home and try again."
        case .invalidValue: "That value is not supported by this device."
        case .requestFailed: "The device service did not complete the request. Please try again."
        case .credentialStorage: "Breeze could not access its secure settings. Unlock your iPhone and try again."
        }
    }
}
