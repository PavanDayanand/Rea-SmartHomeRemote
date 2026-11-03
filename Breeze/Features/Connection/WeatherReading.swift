import Foundation

struct WeatherResponse: Decodable {
    let current: WeatherReading
}

struct WeatherReading: Decodable {
    let temperature_2m: Double
    let weather_code: Int
    let is_day: Int

    var condition: String {
        switch weather_code {
        case 0: "Clear sky"
        case 1, 2: "Partly cloudy"
        case 3: "Overcast"
        case 45, 48: "Foggy"
        case 51...67, 80...82: "Rainy"
        case 71...77, 85, 86: "Snowy"
        case 95...99: "Thunderstorms"
        default: "Current weather"
        }
    }
    var symbol: String {
        switch weather_code {
        case 0: is_day == 1 ? "sun.max.fill" : "moon.stars.fill"
        case 1, 2: is_day == 1 ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3: "cloud.fill"
        case 45, 48: "cloud.fog.fill"
        case 51...67, 80...82: "cloud.rain.fill"
        case 71...77, 85, 86: "cloud.snow.fill"
        case 95...99: "cloud.bolt.rain.fill"
        default: "cloud.fill"
        }
    }
}
