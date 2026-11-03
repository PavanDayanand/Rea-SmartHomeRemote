import Foundation

enum WidgetCommandError: LocalizedError {
    case appProcessRequired
    var errorDescription: String? { "The fan session is unavailable. Open Breeze once to reconnect, then retry the widget." }
}
