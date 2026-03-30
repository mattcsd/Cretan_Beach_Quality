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
    
    func fetch<T: Decodable>(
        from url:URL,
        completion: @escaping (Result<T, Error>) -> Void){

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
    
    func fetchCoordinates(for place: String, completion: @escaping (Result<GeocodingResult, Error>) -> Void){
        
        let query = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(query)&count=1"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Bad URL", code: -1)))
            return
        }
        
        fetch(from: url) {(result: Result<GeocodingResponse, Error>) in
            
            switch result{
            case .success(let response):
                print("HEREEEE \(response.results)")
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }/*
    func fetchCoordinates(for place: String, completion: @escaping (Result<GeocodingResult, Error>) -> Void){
        
        let query = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(query)&count=1"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Bad URL", code: -1)))
            return
        }
        
        print("🌐 URL: \(urlString)")
        
        // TEMPORARY: Direct URLSession to see raw JSON
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            // Print raw JSON as string
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📝 Raw JSON response:")
                print(jsonString)
            }
            
            // Try to decode
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GeocodingResponse.self, from: data)
                print("✅ Successfully decoded: \(response)")
                print("Results count: \(response.results?.count ?? 0)")
                
                if let firstResult = response.results?.first {
                    print("First result: \(firstResult)")
                    DispatchQueue.main.async {
                        completion(.success(firstResult))
                    }
                } else {
                    print("❌ No results found")
                    let error = NSError(domain: "Geocoding", code: -2, userInfo: [NSLocalizedDescriptionKey: "No results found"])
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } catch {
                print("❌ Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }*/
}


