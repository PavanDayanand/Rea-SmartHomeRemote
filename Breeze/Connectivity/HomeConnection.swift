import Foundation
import Observation
import WidgetKit
import AppIntents
@preconcurrency import ThingSmartHomeKit

/// All vendor calls live here. SwiftUI screens only call these plain methods.
/// This is device connectivity, not an AI integration.
@MainActor
@Observable
final class HomeConnection: NSObject {
    static let shared = HomeConnection()
    private(set) var isConfigured = false
    private(set) var isLoggedIn = false
    private(set) var isBusy = false
    private(set) var isPairing = false
    private(set) var isReadyForHotspot = false
    private(set) var isReadyForHomeWiFi = false
    private(set) var pairingProgress = PairingProgress()
    let supportsEZPairing = Bundle.main.object(forInfoDictionaryKey: "BreezeCanUseEZ") as? Bool == true
    private(set) var homeName = "My home"
    // SwiftUI watches this value. The vendor's home object below is not observable.
    private(set) var selectedHomeID: Int64?
    private(set) var devices: [ConnectedDevice] = []
    var requestedDeviceID: String?
    var navigationRequest = UUID()
    var message: String?
    var errorMessage: String?

    @ObservationIgnored private let homeManager = ThingSmartHomeManager()
    @ObservationIgnored private var activator = ThingSmartActivator()
    @ObservationIgnored private var home: ThingSmartHome?
    @ObservationIgnored private var liveDevices: [String: ThingSmartDevice] = [:]
    @ObservationIgnored private var pairingTask: Task<Void, Never>?
    @ObservationIgnored private var pairingSessionID: UUID?
    @ObservationIgnored private var pairingSecurityConfiguration: [AnyHashable: Any]?
    @ObservationIgnored private var pairingToken = ""
    @ObservationIgnored private var pairingSSID = ""
    @ObservationIgnored private var pairingPassword = ""

    override init() {
        super.init()
        configureSDK()
        if ProcessInfo.processInfo.arguments.contains("--controls-preview") {
            devices = [ConnectedDevice(id: "preview", name: "Preview fan", isOnline: true, controls: [
                DeviceControl(id: "power", name: "Power", kind: "bool", isWritable: true, boolValue: true, numberValue: 0, textValue: "", minimum: 0, maximum: 0, step: 1, choices: []),
                DeviceControl(id: "speed", name: "WindSpeed", kind: "enum", isWritable: true, boolValue: false, numberValue: 0, textValue: "2", minimum: 0, maximum: 0, step: 1, choices: ["1", "2", "3", "4", "5", "6"]),
                DeviceControl(id: "mode", name: "Mode", kind: "enum", isWritable: true, boolValue: false, numberValue: 0, textValue: "Normal", minimum: 0, maximum: 0, step: 1, choices: ["Normal", "Turbo", "Sleep", "Breeze", "Reverse"]),
                DeviceControl(id: "timer", name: "Timer", kind: "enum", isWritable: true, boolValue: false, numberValue: 0, textValue: "0", minimum: 0, maximum: 0, step: 1, choices: ["0", "2", "4", "6", "8"]),
                DeviceControl(id: "light", name: "Light", kind: "enum", isWritable: true, boolValue: false, numberValue: 0, textValue: "Off", minimum: 0, maximum: 0, step: 1, choices: ["Off", "Level1", "Level2", "Level3"])
            ])]
        }
    }

    private func configureSDK() {
        // UI tests must not sign in or contact a real device service.
        guard !ProcessInfo.processInfo.arguments.contains("--connection-preview") else { return }
        do {
            if let saved = try SDKKeychain().load() {
                startSDK(credentials: saved)
                return
            }
        } catch {
            errorMessage = error.localizedDescription
            return
        }
        guard let url = Bundle.main.url(forResource: "TuyaSecrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let values = try? PropertyListDecoder().decode([String: String].self, from: data),
              let key = values["AppKey"], !key.isEmpty,
              let secret = values["AppSecret"], !secret.isEmpty else { return }

        startSDK(credentials: SDKCredentials(appKey: key, appSecret: secret))
    }

    func saveSDKSettings(appKey: String, appSecret: String) throws {
        let credentials = SDKCredentials(
            appKey: appKey.trimmingCharacters(in: .whitespacesAndNewlines),
            appSecret: appSecret.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        guard !credentials.appKey.isEmpty, !credentials.appSecret.isEmpty else {
            throw ConnectionError.notConfigured
        }
        try SDKKeychain().save(credentials)
        startSDK(credentials: credentials)
    }

    private func startSDK(credentials: SDKCredentials) {
        ThingSmartSDK.sharedInstance().debugMode = false
        ThingSmartSDK.sharedInstance().start(withAppKey: credentials.appKey, secretKey: credentials.appSecret)
        isConfigured = true
        isLoggedIn = ThingSmartUser.sharedInstance().isLogin
        activator.delegate = self
    }

    func run(_ action: @escaping @MainActor () async throws -> Void) {
        guard !isBusy else { return }
        isBusy = true
        errorMessage = nil
        Task {
            defer { isBusy = false }
            do { try await action() }
            catch { errorMessage = error.localizedDescription }
        }
    }

    func login(email: String, password: String, countryCode: String) async throws {
        guard isConfigured else { throw ConnectionError.notConfigured }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ThingSmartUser.sharedInstance().login(byEmail: countryCode, email: email, password: password) {
                continuation.resume()
            } failure: { error in
                continuation.resume(throwing: error ?? ConnectionError.requestFailed)
            }
        }
        isLoggedIn = true
        try await loadHome()
    }

    func sendCode(email: String, countryCode: String) async throws {
        guard isConfigured else { throw ConnectionError.notConfigured }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ThingSmartUser.sharedInstance().sendVerifyCode(withUserName: email, countryCode: countryCode, type: 1) {
                continuation.resume()
            } failure: { error in
                continuation.resume(throwing: error ?? ConnectionError.requestFailed)
            }
        }
        message = "Check your email for the verification code."
    }

    func register(email: String, password: String, code: String, countryCode: String) async throws {
        guard isConfigured else { throw ConnectionError.notConfigured }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ThingSmartUser.sharedInstance().register(byEmail: countryCode, email: email, password: password, code: code) {
                continuation.resume()
            } failure: { error in
                continuation.resume(throwing: error ?? ConnectionError.requestFailed)
            }
        }
        try await login(email: email, password: password, countryCode: countryCode)
    }

    func loadHome() async throws {
        guard isConfigured, isLoggedIn, !isPairing else { return }
        let homeID: Int64? = try await withCheckedThrowingContinuation { continuation in
            homeManager.getHomeList { homes in
                continuation.resume(returning: homes?.first?.homeId)
            } failure: { error in
                continuation.resume(throwing: error ?? ConnectionError.requestFailed)
            }
        }
        guard let homeID else {
            home = nil
            selectedHomeID = nil
            devices = []
            return
        }
        home = ThingSmartHome(homeId: homeID)
        guard home != nil else { throw ConnectionError.noHome }
        try await refreshDevices()
        selectedHomeID = homeID
    }

    var hasHome: Bool { selectedHomeID != nil }

    func createHome(name: String) async throws {
        // A previous tap may have created a home while the old screen stayed visible.
        // Reuse that home rather than creating a duplicate.
        try await loadHome()
        guard !hasHome else { return }
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { throw ConnectionError.invalidValue }
        let homeID: Int64 = try await withCheckedThrowingContinuation { continuation in
            homeManager.addHome(withName: cleanName, geoName: "", rooms: ["Bedroom", "Living room"], latitude: 0, longitude: 0) { id in
                continuation.resume(returning: id)
            } failure: { error in
                continuation.resume(throwing: error ?? ConnectionError.requestFailed)
            }
        }
        home = ThingSmartHome(homeId: homeID)
        guard home != nil else { throw ConnectionError.noHome }
        try await refreshDevices()
        selectedHomeID = homeID
    }

    func refreshDevices() async throws {
        guard let home else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            home.getDataWithSuccess { _ in
                continuation.resume()
            } failure: { error in
                continuation.resume(throwing: error ?? ConnectionError.requestFailed)
            }
        }
        refreshCachedDevices()
    }

    private func refreshCachedDevices() {
        homeName = home?.homeModel.name ?? "My home"
        let models = home?.deviceList ?? []
        var currentDevices: [String: ThingSmartDevice] = [:]
        devices = models.compactMap { model in
            guard let id = model.devId, let device = ThingSmartDevice(deviceId: id) else { return nil }
            device.delegate = self
            currentDevices[id] = device
            return ConnectedDevice(
                id: id, name: model.name ?? "My fan", isOnline: model.isOnline,
                controls: (model.schemaArray ?? []).compactMap { schema in
                    guard let id = schema.dpId else { return nil }
                    let value = model.dps?[id]
                    return DeviceControl(
                        id: id, name: schema.name ?? schema.code ?? "Control",
                        kind: (schema.type == "obj" ? schema.property?.type : schema.type) ?? "",
                        isWritable: schema.mode != "ro" && value != nil,
                        boolValue: value as? Bool ?? false,
                        numberValue: value as? Int ?? 0,
                        textValue: value as? String ?? "",
                        minimum: Int(schema.property?.min ?? 0), maximum: Int(schema.property?.max ?? 0),
                        step: max(1, Int(schema.property?.step ?? 1)),
                        choices: schema.property?.range as? [String] ?? []
                    )
                }
            )
        }
        liveDevices = currentDevices
        ConnectedFanSnapshot.save(devices.map { device in
            let summary = device.controls.map { control in
                let value = control.kind == "bool" ? (control.boolValue ? "On" : "Off")
                    : control.kind == "value" ? String(control.numberValue) : control.textValue
                return "\(control.displayName): \(value)"
            }.joined(separator: " · ")
            return ConnectedFanSnapshot(id: device.id, name: device.name,
                isOnline: device.isOnline, summary: summary, updatedAt: .now,
                controls: device.controls.filter { $0.isWritable && $0.kind == "enum" }.map {
                    WidgetFanControl(id: $0.id, name: $0.displayName, symbol: $0.symbol, value: $0.textValue, choices: $0.choices)
                },
                isOn: device.controls.first(where: { $0.name.lowercased().contains("power") && $0.kind == "bool" })?.boolValue,
                speed: device.controls.first(where: { $0.name.lowercased().contains("speed") })?.textValue,
                speeds: device.controls.first(where: { $0.name.lowercased().contains("speed") && $0.kind == "enum" })?.choices)
        })
        WidgetCenter.shared.reloadTimelines(ofKind: "BreezeConnectedFans")
        BreezeShortcuts.updateAppShortcutParameters()
    }

    func performWidgetAction(deviceID: String, action: String, value: String) async throws {
        for _ in 0..<20 where isBusy { try await Task.sleep(for: .milliseconds(500)) }
        guard !isBusy, !isPairing else { throw ConnectionError.requestFailed }
        guard isConfigured, isLoggedIn else { throw ConnectionError.signInRequired }
        isBusy = true
        defer { isBusy = false }
        try await loadHome()
        guard let device = devices.first(where: { $0.id == deviceID }) else { throw ConnectionError.missingDevice }
        let name = action == "power" ? "power" : "speed"
        guard let control = device.controls.first(where: {
            action.hasPrefix("control:") ? $0.id == String(action.dropFirst(8)) : $0.name.lowercased().contains(name)
        }), action.hasPrefix("control:") || ["power", "speed"].contains(action) else { throw ConnectionError.invalidValue }
        let command: Any
        if action == "power", control.kind == "bool", ["on", "off"].contains(value) { command = value == "on" }
        else if control.kind == "enum" { command = value }
        else if action == "speed", control.kind == "value", let number = Int(value) { command = number }
        else { throw ConnectionError.invalidValue }
        try await setValue(deviceID: deviceID, controlID: control.id, value: command)
        try await refreshDevices()
    }

    /// Relative speed must use a fresh device report, never the widget snapshot.
    func changeSpeed(deviceID: String, increase: Bool) async throws -> String {
        for _ in 0..<20 where isBusy { try await Task.sleep(for: .milliseconds(500)) }
        guard !isBusy, !isPairing else { throw ConnectionError.requestFailed }
        guard isConfigured, isLoggedIn else { throw ConnectionError.signInRequired }
        isBusy = true
        defer { isBusy = false }
        try await loadHome()
        guard let device = devices.first(where: { $0.id == deviceID }), device.isOnline else {
            throw ConnectionError.missingDevice
        }
        if device.controls.contains(where: { $0.name.lowercased().contains("power") && $0.kind == "bool" && !$0.boolValue }) {
            throw ConnectionError.fanIsOff
        }
        guard let control = device.controls.first(where: { $0.name.lowercased().contains("speed") && $0.isWritable }) else {
            throw ConnectionError.invalidValue
        }
        let current: String
        let next: String
        let command: Any
        if control.kind == "enum" {
            current = control.textValue
            guard let selected = FanSpeedStep.next(current: current, choices: control.choices, increase: increase) else {
                throw ConnectionError.invalidValue
            }
            next = selected
            command = selected
        } else if control.kind == "value" {
            current = String(control.numberValue)
            let selected = increase
                ? min(control.maximum, control.numberValue + control.step)
                : max(control.minimum, control.numberValue - control.step)
            next = String(selected)
            command = selected
        } else { throw ConnectionError.invalidValue }
        guard next != current else {
            return "\(device.name) is already at its \(increase ? "highest" : "lowest") speed."
        }
        try await setValue(deviceID: deviceID, controlID: control.id, value: command)
        try await refreshDevices()
        return "\(device.name) set to speed \(next)."
    }

    func handleWidgetCommand(deviceID: String, action: String?, value: String?) {
        Task {
            // The app may already be refreshing after a cold launch.
            for _ in 0..<20 where isBusy { try? await Task.sleep(for: .milliseconds(500)) }
            guard !isBusy else { errorMessage = "Please wait for the home refresh, then try again."; return }
            run {
                try await self.loadHome()
                guard let action, let value,
                      let device = self.devices.first(where: { $0.id == deviceID }) else { return }
                let name = action == "power" ? "power" : "speed"
                guard let control = device.controls.first(where: {
                    action.hasPrefix("control:") ? $0.id == String(action.dropFirst(8)) : $0.name.lowercased().contains(name)
                }), action.hasPrefix("control:") || ["power", "speed"].contains(action) else { return }
                let command: Any
                if action == "power", control.kind == "bool", ["on", "off"].contains(value) { command = value == "on" }
                else if (action == "speed" || action.hasPrefix("control:")), control.kind == "enum" { command = value }
                else { throw ConnectionError.invalidValue }
                try await self.setValue(deviceID: deviceID, controlID: control.id, value: command)
            }
        }
    }

    func renameDevice(deviceID: String, name: String) async throws {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, let device = liveDevices[deviceID] else { throw ConnectionError.invalidValue }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            device.updateName(name) { continuation.resume() }
            failure: { error in continuation.resume(throwing: error ?? ConnectionError.requestFailed) }
        }
        try await refreshDevices()
    }

    func setValue(deviceID: String, controlID: String, value: Any) async throws {
        guard let device = liveDevices[deviceID], device.deviceModel.isOnline else {
            throw ConnectionError.missingDevice
        }
        guard let control = devices.first(where: { $0.id == deviceID })?.controls.first(where: { $0.id == controlID }),
              control.isWritable else { throw ConnectionError.invalidValue }
        switch control.kind {
        case "bool":
            guard value is Bool else { throw ConnectionError.invalidValue }
        case "enum":
            guard let choice = value as? String, control.choices.contains(choice) else { throw ConnectionError.invalidValue }
        case "value":
            guard let number = value as? Int,
                  (control.minimum...max(control.minimum, control.maximum)).contains(number),
                  (number - control.minimum).isMultiple(of: control.step) else { throw ConnectionError.invalidValue }
        default:
            throw ConnectionError.invalidValue
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            device.publishDps([controlID: value]) {
                continuation.resume()
            } failure: { error in
                continuation.resume(throwing: error ?? ConnectionError.requestFailed)
            }
        }
        // The SDK's device report supplies state; do not pretend the command is a report.
        message = "Command sent. Waiting for the fan’s reported state."
        refreshCachedDevices()
    }

    func startPairing(ssid: String, password: String, useAPMode: Bool) {
        guard !isPairing else { return }
        guard isConfigured, isLoggedIn, let homeID = selectedHomeID else {
            errorMessage = ConnectionError.noHome.localizedDescription
            return
        }
        guard !ssid.isEmpty else {
            errorMessage = "Enter your home Wi-Fi name first."
            return
        }
        guard useAPMode || supportsEZPairing else {
            errorMessage = "Fast-blinking EZ pairing is unavailable in this build. Use slow-blinking AP mode and join the fan’s hotspot."
            return
        }
        activator.delegate = nil
        activator.stopConfigWiFi()
        activator = ThingSmartActivator()
        activator.delegate = self
        let sessionID = UUID()
        pairingSessionID = sessionID
        pairingSSID = ssid
        pairingPassword = password
        isPairing = true
        message = nil
        errorMessage = nil
        pairingProgress = PairingProgress()
        pairingProgress.update(.token, detail: "Requesting a pairing token. Keep your phone connected to the internet.", timeout: 25)
        startPairingWatchdog()

        // A separate watchdog can stop waiting even if the cloud never calls back.
        activator.getTokenWithHomeId(homeID) { [weak self] token in
            Task { @MainActor [weak self] in
                guard let self, pairingSessionID == sessionID, isPairing else { return }
                guard let token, !token.isEmpty else {
                    failPairing("The service returned an empty pairing token. Check your internet connection and try again.")
                    return
                }
                pairingToken = token
                if useAPMode {
                    prepareAPSecurityConfiguration(sessionID: sessionID)
                } else {
                    pairingProgress.update(.connecting, detail: "Sending Wi-Fi details. Keep the phone on your home Wi-Fi and allow Local Network access.", timeout: 125)
                    activator.startConfigWiFi(.EZ, ssid: pairingSSID, password: pairingPassword, token: token, timeout: 120)
                    pairingPassword = ""
                }
            }
        } failure: { [weak self] error in
            let reason = Self.pairingErrorDescription(error)
            Task { @MainActor [weak self] in
                guard let self, pairingSessionID == sessionID, isPairing else { return }
                failPairing("Could not prepare pairing. " + reason)
            }
        }
    }

    private func prepareAPSecurityConfiguration(sessionID: UUID) {
        pairingProgress.update(.token, detail: "Pairing token received. Fetching the device security configuration before leaving home Wi-Fi.", timeout: 25)
        activator.getDeviceSecurityConfigs { [weak self] configuration in
            // Transfer JSON data across actors, not the SDK's untyped dictionary.
            let data = configuration.flatMap { try? JSONSerialization.data(withJSONObject: $0) }
            Task { @MainActor [weak self] in
                guard let self, pairingSessionID == sessionID, isPairing else { return }
                guard let data,
                      let values = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      !values.isEmpty else {
                    failPairing("The service returned no usable device security configuration. Remain on home Wi-Fi and try again.")
                    return
                }
                pairingSecurityConfiguration = values
                isReadyForHotspot = true
                pairingProgress.update(.hotspot, detail: "Token and device security configuration received. Open Settings → Wi-Fi, join the fan’s temporary network, then return and confirm below.", timeout: 550)
            }
        } failure: { [weak self] error in
            let reason = Self.pairingErrorDescription(error)
            Task { @MainActor [weak self] in
                guard let self, pairingSessionID == sessionID, isPairing else { return }
                failPairing("Could not fetch device security configuration. " + reason)
            }
        }
    }

    func continueAfterJoiningHotspot() {
        guard isPairing, isReadyForHotspot, !pairingToken.isEmpty, pairingSecurityConfiguration != nil else { return }
        isReadyForHotspot = false
        pairingProgress.update(.connecting, detail: "Contacting the fan through its hotspot. Allow Local Network access if iOS asks. Keep Breeze open.", timeout: 125)
        activator.startConfigWiFi(.AP, ssid: pairingSSID, password: pairingPassword, token: pairingToken, regInfo: pairingSecurityConfiguration, timeout: 120)
        pairingToken = ""
        pairingPassword = ""
    }

    func continueAfterReturningHome() {
        guard isPairing, isReadyForHomeWiFi else { return }
        isReadyForHomeWiFi = false
        pairingProgress.update(.registered, detail: "Continuing activation after your confirmation that the phone is back on home Wi-Fi.")
        activator.continueConfigSecurityLevelDevice()
    }

    func checkPairingDeadline() {
        // Also called on foreground return: suspended apps cannot run a timer.
        guard isPairing, pairingProgress.hasExpired(at: .now) else { return }
        let reason: String
        switch pairingProgress.stage {
        case .token:
            reason = "The pairing service did not respond within 25 seconds. Check internet access and try again."
        case .hotspot:
            reason = "The hotspot step expired. Re-enter the fan’s pairing mode and prepare a new connection."
        case .connecting:
            reason = "No completed activation was received from the fan. Confirm slow blinking, join the fan’s hotspot before continuing, and allow Local Network access. Also check the exact 2.4 GHz Wi-Fi name and password."
        case .returnToWiFi:
            reason = "The fan requested a return to home Wi-Fi, but activation did not finish in time. Reconnect your phone to home Wi-Fi and try pairing again."
        default:
            reason = "The fan was found but did not finish activation. Check the home Wi-Fi password and internet access. The device may also be restricted to its manufacturer’s app; the last reported stage is shown below."
        }
        failPairing(reason)
    }

    private func startPairingWatchdog() {
        pairingTask?.cancel()
        pairingTask = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(1)) }
                catch { return }
                guard let self, isPairing else { return }
                checkPairingDeadline()
            }
        }
    }

    private func failPairing(_ reason: String) {
        let lastStage = pairingProgress.stage.title
        stopPairing()
        pairingProgress.update(.failed, detail: reason + " Last stage: " + lastStage + ".")
        errorMessage = pairingProgress.detail
    }

    private func finishPairing() {
        stopPairing()
        pairingProgress.update(.complete, detail: "The device service confirmed activation. Return your phone to home Wi-Fi if needed, then view your fans.")
        message = "Fan connected."
        run { try await self.refreshDevices() }
    }

    nonisolated private static func pairingErrorDescription(_ error: Error?) -> String {
        guard let error else { return "The device service did not supply an error code." }
        let problem = error as NSError
        // The SDK documents these router failure codes for AP pairing.
        if problem.domain == ThingSmartPairingConnectWiFiFailedErrorDomain {
            switch problem.code {
            case 2: return "The fan could not find the router. Check the 2.4 GHz Wi-Fi name. (Code 2)"
            case 3: return "The fan reported an incorrect Wi-Fi password. (Code 3)"
            case 4: return "The fan could not connect to the router. (Code 4)"
            case 5: return "The router did not assign the fan an IP address. (Code 5)"
            default: break
            }
        }
        return "\(problem.localizedDescription) [\(problem.domain), code \(problem.code)]"
    }

    func stopPairing() {
        pairingTask?.cancel()
        pairingTask = nil
        pairingSessionID = nil
        activator.stopConfigWiFi()
        if isPairing { pairingProgress.update(.cancelled, detail: "You can prepare a new connection when ready.") }
        isPairing = false
        isReadyForHotspot = false
        isReadyForHomeWiFi = false
        pairingToken = ""
        pairingSSID = ""
        pairingPassword = ""
        pairingSecurityConfiguration = nil
    }

}

extension HomeConnection: ThingSmartActivatorDelegate, ThingSmartDeviceDelegate {
    nonisolated func activator(_ activator: ThingSmartActivator, didReceiveDevice deviceModel: ThingSmartDeviceModel?, error: Error?) {
        let activatorID = ObjectIdentifier(activator)
        let succeeded = deviceModel != nil && error == nil
        let problem = Self.pairingErrorDescription(error)
        Task { @MainActor [weak self] in
            guard let self, isPairing, ObjectIdentifier(self.activator) == activatorID else { return }
            if succeeded { finishPairing() }
            else { failPairing(problem) }
        }
    }

    nonisolated func activator(_ activator: ThingSmartActivator, didReceiveDevice deviceModel: ThingSmartDeviceModel?, step: ThingActivatorStep, error: Error?) {
        let activatorID = ObjectIdentifier(activator)
        let stepNumber = step.rawValue
        let hasDevice = deviceModel != nil
        let problemCode = error as NSError?
        let hasError = problemCode != nil && !(problemCode?.domain == ThingSmartPairingConnectWiFiFailedErrorDomain && problemCode?.code == 0)
        let problem = Self.pairingErrorDescription(error)
        Task { @MainActor [weak self] in
            guard let self, isPairing, ObjectIdentifier(self.activator) == activatorID else { return }
            if hasError { failPairing(problem); return }
            // Values come from ThingSmartPairingHeader.h, not elapsed-time guesses.
            switch stepNumber {
            case 1:
                pairingProgress.update(.found, detail: "The SDK found your fan. Waiting for registration on the device service.")
            case 2:
                pairingProgress.update(.registered, detail: "The device service registered your fan. Waiting for initialization.")
            case 3:
                if hasDevice { finishPairing() }
            case 4:
                failPairing("The device SDK timed out. Check Wi-Fi details, pairing mode and Local Network permission.")
            default: break
            }
        }
    }

    nonisolated func deviceStateError(_ error: Error) {
        let problem = Self.pairingErrorDescription(error)
        Task { @MainActor [weak self] in
            guard let self, isPairing else { return }
            failPairing(problem)
        }
    }

    nonisolated func activator(_ activator: ThingSmartActivator, didPassWIFIToSecurityLevelDeviceWithUUID uuid: String) {
        let activatorID = ObjectIdentifier(activator)
        Task { @MainActor [weak self] in
            guard let self, isPairing, ObjectIdentifier(self.activator) == activatorID else { return }
            isReadyForHomeWiFi = true
            pairingProgress.update(.returnToWiFi, detail: "The fan received the Wi-Fi details and asked you to return to your home network. Open Settings → Wi-Fi, join your home network, then confirm below.")
        }
    }

    nonisolated func device(_ device: ThingSmartDevice, dpsUpdate dps: [AnyHashable: Any]) {
        Task { @MainActor [weak self] in
            self?.refreshCachedDevices()
            self?.message = nil
        }
    }

    nonisolated func deviceInfoUpdate(_ device: ThingSmartDevice) {
        Task { @MainActor [weak self] in self?.refreshCachedDevices() }
    }
}
