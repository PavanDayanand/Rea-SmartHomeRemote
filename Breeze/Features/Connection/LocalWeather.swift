import Foundation
import CoreLocation
import Observation

/// One foreground location request. No background tracking or stored coordinates.
@MainActor @Observable
final class LocalWeather: NSObject, @preconcurrency CLLocationManagerDelegate {
    var current: WeatherReading?
    var isLoading = false
    var message: String?
    private let manager = CLLocationManager()
    private var requestTask: Task<Void, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func refresh() {
        guard !isLoading else { return }
        isLoading = true
        message = nil
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse: manager.requestLocation()
        default: finish("Allow location in Settings to see local weather.")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isLoading else { return }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: manager.requestLocation()
        case .denied, .restricted: finish("Allow location in Settings to see local weather.")
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isLoading, let location = locations.last else { return }
        requestTask?.cancel()
        requestTask = Task {
            do {
                // Round to roughly 1 km; weather does not need a precise address.
                let latitude = (location.coordinate.latitude * 100).rounded() / 100
                let longitude = (location.coordinate.longitude * 100).rounded() / 100
                let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code,is_day&forecast_days=1")!
                var request = URLRequest(url: url)
                request.timeoutInterval = 20
                let (data, response) = try await URLSession.shared.data(for: request)
                guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
                current = try JSONDecoder().decode(WeatherResponse.self, from: data).current
                isLoading = false
            } catch {
                if !Task.isCancelled { finish("Weather is unavailable. Tap to try again.") }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish("Couldn't find your location. Tap to try again.")
    }

    private func finish(_ text: String) {
        message = text
        isLoading = false
    }
}
