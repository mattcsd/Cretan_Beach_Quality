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
}


