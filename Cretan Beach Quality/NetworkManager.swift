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
    func fetchAsync<T: APIRequest> (_ request: T) async throws -> T.Response {
        print("fetchAsync: Starting request for \(request.url)")
        //it runs on a backgroun thread automatically
        let (data, response) = try await URLSession.shared.data(from: request.url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "NetworkManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server Error \(httpResponse.statusCode)"])
            }
        }
        
        print("!!!DOULEYEI ME REQUEST!: Received \(data.count) bytes")
        // data decoding
        do {
            let decoded = try JSONDecoder().decode(T.Response.self, from: data)
            print("fetchAsync: Succesfully decoded \(T.self)")
            return decoded
        } catch {
            print("fetchAsync: Decoding error: \(error)")
            throw error
        }
    }
    /*
    //bres pou kaleitai kai kane to request ekei.
    func fetchWeatherAsync(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let request = WeatherRequest(latitude: latitude, longitude: longitude)
        return try await fetchAsync(request)
    }*/
}
