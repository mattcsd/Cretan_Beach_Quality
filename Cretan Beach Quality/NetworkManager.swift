//
//  NetworkManager.swift
//  Cretan Beach Quality
//
//  Created by Admin on 30/3/26.
//

import Foundation

final class NetworkManager{
    static let shared = NetworkManager()
    private init(){}
    
    
    //MARK: Adding async/await network calls
    
    
    //Generic async/await fetch for any Decodble type
    // - Parameter url: The URL to fetch from
    // - Returns: Decoded object of type T
    // - Throws: Network error or decoding error
    
    func fetchAsync<T: Decodable> (from url: URL) async throws -> T {
        print("fetchAsync: Starting request for \(url)")
        
        //URLSession.shared.data(from:) is already async
        //it runs on a backgroun thread automatically
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // check HTTP response code (optional but good practise)
        if let httpResponse = response as? HTTPURLResponse {
            print("fetchAsync: HTTP Status code: \(httpResponse.statusCode)")
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NSError(
                    domain: "NetworkManager",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Server returned error code \(httpResponse.statusCode)"]
                )
            }
        }
        
        print("!!!fetchAsync: Received \(data.count) bytes")
        
        // data decoding
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            print("fetchAsync: Succesfully decoded \(T.self)")
            return decoded
        } catch {
            print("fetchAsync: Decoding error: \(error)")
            throw error
        }
    }
    
    func fetchWeatherAsync(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let forecastDays = 7
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,weather_code&timezone=auto&forecast_days=\(forecastDays)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        // use the above fetchAsync
        return try await fetchAsync(from: url)
    }
}
