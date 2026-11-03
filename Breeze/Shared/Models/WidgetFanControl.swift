import Foundation

struct WidgetFanControl: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let symbol: String
    let value: String
    let choices: [String]
}
