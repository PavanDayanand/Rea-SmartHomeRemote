import Foundation

struct ConnectedDevice: Identifiable, Sendable {
    let id: String
    let name: String
    let isOnline: Bool
    let controls: [DeviceControl]
}
