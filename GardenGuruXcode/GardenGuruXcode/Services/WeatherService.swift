import Foundation
import CoreLocation

class WeatherService {
    private let apiKey = "9db51a031c8952c1420e63d09e85e161"  // Example: "a1b2c3d4e5f6g7h8i9j0..."
    
    struct WeatherResponse: Codable {
        let main: MainWeather
        let weather: [Weather]
        let name: String
        let coord: Coordinates
    }
    
    struct MainWeather: Codable {
        let temp: Double
        let humidity: Int
    }
    
    struct Weather: Codable {
        let main: String
        let description: String
    }
    
    struct Coordinates: Codable {
        let lat: Double
        let lon: Double
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        
        print("Fetching weather from URL: \(urlString)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Received data: \(jsonString)")
        }
        
        let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return weather
    }
} 
