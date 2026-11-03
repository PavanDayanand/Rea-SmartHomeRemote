import Foundation

/// A control described by the fan itself, rather than a guessed data-point ID.
struct DeviceControl: Identifiable, Sendable {
    let id: String
    let name: String
    let kind: String
    let isWritable: Bool
    var boolValue: Bool
    var numberValue: Int
    var textValue: String
    let minimum: Int
    let maximum: Int
    let step: Int
    let choices: [String]
}
