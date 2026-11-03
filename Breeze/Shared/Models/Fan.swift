import Foundation

/// A struct is a value: one fan and the settings we want to show for it.
struct Fan: Codable, Identifiable, Equatable, Sendable {
    let id: String
    var name: String
    var room: String
    var isOn = false
    var speed = 1
    var mode = FanMode.normal
    var lightLevel = 0
    var turnsOffAt: Date?

    // Six speeds are a demo assumption, not a verified Aeroslim specification.
    let speedCount: Int

    var summary: String {
        isOn ? "On · Speed \(speed)" : "Off"
    }

    var lightDescription: String {
        lightLevel == 0 ? "Off" : "Level \(lightLevel)"
    }

    static let examples = [
        Fan(id: "bedroom", name: "My fan", room: "Bedroom", isOn: true, speed: 2, speedCount: 6),
        Fan(id: "living-room", name: "Living room fan", room: "Living room", speedCount: 6)
    ]
}
