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
    
    func fetch<T: Decodable>(
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
    
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void){
        let forecastDays: Int = 7 // how many days to get data for.
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,weather_code&timezone=auto&forecast_days=\(forecastDays)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Bad URL", code: -1)))
            return
        }
        
        print("Fetching weather for beach at \(latitude) \(longitude)")
        
        fetch(from: url) { (result: Result<WeatherResponse, Error>) in
            switch result {
            case .success(let weather):
                print("Weather data received - Temp \(weather.current.temperature)C")
                completion(.success(weather))
            case .failure(let error):
                print("Weather fetch failed: \(error)")
                completion(.failure(error))
            }
            
        }
    }
}


