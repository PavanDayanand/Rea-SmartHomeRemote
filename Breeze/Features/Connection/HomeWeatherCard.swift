import SwiftUI

struct HomeWeatherCard: View {
    @State private var weather = LocalWeather()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 18) {
                Image(systemName: weather.current?.symbol ?? "cloud.sun.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 40))
                    .symbolEffect(.pulse, isActive: weather.isLoading && !reduceMotion)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Outside now").font(.caption).foregroundStyle(.secondary)
                    if let reading = weather.current {
                        Text(Measurement(value: reading.temperature_2m, unit: UnitTemperature.celsius), format: .measurement(width: .abbreviated, usage: .weather))
                            .font(.largeTitle.bold())
                        Text(reading.condition).font(.subheadline)
                    } else {
                        Text(weather.isLoading ? "Finding your weather…" : "Your local weather")
                            .font(.headline)
                    }
                }
                Spacer(minLength: 0)
                if weather.current != nil {
                    Button("Refresh weather", systemImage: "arrow.clockwise") { weather.refresh() }
                        .labelStyle(.iconOnly).frame(minWidth: 44, minHeight: 44)
                        .disabled(weather.isLoading)
                }
            }
            if weather.current == nil {
                Text(weather.message ?? "Use your approximate location for temperature and conditions. Coordinates are sent to Open-Meteo.")
                    .font(.caption).foregroundStyle(.secondary)
                Button(weather.message == nil ? "Use my location" : "Try again", systemImage: "location") { weather.refresh() }
                    .buttonStyle(.bordered).disabled(weather.isLoading)
            } else if let message = weather.message {
                Text(message).font(.caption).foregroundStyle(.secondary)
            }
            Link("Weather by Open-Meteo", destination: URL(string: "https://open-meteo.com/")!)
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}
