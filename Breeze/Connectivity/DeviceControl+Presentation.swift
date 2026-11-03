import Foundation

extension DeviceControl {
    var displayName: String {
        name.lowercased().contains("wind") ? "Wind speed" : name
    }

    var symbol: String {
        let title = name.lowercased()
        if title.contains("power") { return "power" }
        if title.contains("light") { return "lightbulb" }
        if title.contains("timer") || title.contains("countdown") { return "timer" }
        if title.contains("speed") { return "wind" }
        return "fan.ceiling"
    }

    func label(for choice: String) -> String {
        choice.replacingOccurrences(of: "_", with: " ").capitalized
    }

    func symbol(for choice: String) -> String {
        let value = choice.lowercased()
        if name.lowercased().contains("light") {
            if value == "off" || value == "0" { return "lightbulb.slash" }
            if value.contains("1") { return "lightbulb.min" }
            if value.contains("3") { return "lightbulb.max" }
            return "lightbulb.fill"
        }
        if value.contains("sleep") { return "moon.zzz" }
        if value.contains("breeze") { return "wind" }
        if value.contains("turbo") { return "bolt.fill" }
        if value.contains("rever") { return "arrow.trianglehead.2.clockwise.rotate.90" }
        return symbol
    }
}
