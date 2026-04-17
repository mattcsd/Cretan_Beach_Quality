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
    
    // MARK: TODO
    // async await calls.
    //maybe add the Geocodingservice and remove the file
    
    /*func fetch<T: Decodable>(
        from url:URL,
        completion: @escaping (Result<T, Error>) -> Void){

        //currently in backgrounf thread
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // error handling
            if let error = error {
                DispatchQueue.main.async{
                    completion(.failure(error))
                }
                return
            }
            
            // check data exists
            guard let data = data else {
                DispatchQueue.main.async{
                    completion(.failure(NSError(domain:"No data", code:-1)))
                }
                return
            }
            print("YES Data size: \(data.count) bytes")
            // Geocode
            do{
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async{
                    completion(.success(decoded))
                }
            }catch{
                DispatchQueue.main.async{
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
     
     func fetchAsync<T: Decodable>(from url: URL) async throws -> T {
         print("fetchAsync called for URL: \(url)")
         
         //1. Fetch data (automatically on background thread)
         let (data, _) = try await URLSession.shared.data(from: url)
         
         //2. decode data
         let decoded = try JSONDecoder().decode(T.self, from: data)
         
         //3. Return the result(automatically back on original thread)
         return decoded
     }
     
     */
    //MARK: Adding async/await network calls                                    oxi Lambda genikou typou
    

    //Generic async/await fetch for any Decodble type
    // - Parameter url: The URL to fetch from
    // - Returns: Decoded object of type T
    // - Throws: Network error or decoding error
    
    func fetchAsync<T: Decodable> (from url: URL) async throws -> T {
        print("fetchAsync: Starting request for \(url)")
        
        //URLSession.shared.data(from:) is already async/await
        //It runs on a backgroun thread automatically
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // check HTTP response code (optional but better)
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
        
        // Decode the data
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
        let forecastDays: Int = 7
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,weather_code&timezone=auto&forecast_days=\(forecastDays)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        print("ASYNc CALLED.networkmanager")

        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return decoded
    }
}
/*func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void){
    let forecastDays: Int = 7 // how many days to get data for.
    
    let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,weather_code&timezone=auto&forecast_days=\(forecastDays)"
    
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "Bad URL", code: -1)))
        return
    }
    
    print("Fetching weather for beach at \(latitude) \(longitude)")
    
    
    fetch(from: url) { (result: Result<WeatherResponse, Error>) in
    //now in main thread, inherited from above
        switch result {
        case .success(let weather):
            print("Weather data received - Temp \(weather.current.temperature)C")
            completion(.success(weather))
        case .failure(let error):
            print("Weather fetch failed: \(error)")
            completion(.failure(error))
        }
        
    }
}*/

