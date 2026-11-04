import AppIntents

/// Background commands reuse the SDK session in the app process, not widget storage.
struct ControlConnectedFanIntent: AppIntent {
    static var isDiscoverable: Bool { false }
    static let title: LocalizedStringResource = "Control connected fan"
    static var openAppWhenRun: Bool { false }
    static var supportedModes: IntentModes { [.background, .foreground(.dynamic)] }
    @Parameter(title: "Device ID") var deviceID: String
    @Parameter(title: "Control") var action: String
    @Parameter(title: "Value") var value: String

    init() {}
    init(deviceID: String, action: String, value: String) {
        self.deviceID = deviceID; self.action = action; self.value = value
    }
    @MainActor
    func perform() async throws -> some IntentResult {
        #if BREEZE_APP
        try await HomeConnection.shared.performWidgetAction(deviceID: deviceID, action: action, value: value)
        #else
        // The app-process conformance below selects the SDK-backed implementation.
        throw WidgetCommandError.appProcessRequired
        #endif
        return .result()
    }
}

#if BREEZE_APP
// Retain the app-process routing witness while also declaring modern supportedModes.
@available(*, deprecated)
extension ControlConnectedFanIntent: ForegroundContinuableIntent {}
#endif
