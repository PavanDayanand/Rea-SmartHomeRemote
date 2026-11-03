import CoreLocation
import NetworkExtension
import Observation

/// iOS treats the Wi-Fi name as location information. We never request coordinates.
@MainActor
@Observable
final class CurrentWiFi: NSObject, CLLocationManagerDelegate {
    let isAvailable = Bundle.main.object(forInfoDictionaryKey: "BreezeCanReadWiFi") as? Bool == true
    private(set) var name = ""
    private(set) var isChecking = false
    private(set) var explanation = "Breeze can fill in the Wi-Fi name with your permission."
    @ObservationIgnored private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        if !isAvailable {
            explanation = "Automatic detection isn’t available in this build. Enter your home Wi-Fi name below."
        }
    }

    func detect() {
        // A free Personal Team cannot sign Apple's Wi-Fi information capability.
        guard isAvailable else { return }
        guard !isChecking else { return }
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            guard locationManager.accuracyAuthorization == .fullAccuracy else {
                explanation = "Enable Precise Location for Breeze in Settings to detect Wi-Fi, or type its name below."
                return
            }
            isChecking = true
            // Only pass the name back to the main actor, not the network object.
            NEHotspotNetwork.fetchCurrent { [weak self] network in
                let detectedName = network?.ssid ?? ""
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    name = detectedName
                    isChecking = false
                    explanation = detectedName.isEmpty
                        ? "Wi-Fi name unavailable. Join your home Wi-Fi in Settings, or type its name below."
                        : "Current network detected. Check that it supports 2.4 GHz."
                }
            }
        case .denied, .restricted:
            explanation = "Wi-Fi detection needs location access. You can enable it in Settings or type the name below."
        @unknown default:
            explanation = "Type your home Wi-Fi name below."
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor [weak self] in
            // Avoid a permission prompt just because this helper was created.
            guard let self, locationManager.authorizationStatus != .notDetermined else { return }
            detect()
        }
    }
}
