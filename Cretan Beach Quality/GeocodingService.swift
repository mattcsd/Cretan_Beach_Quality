//
//  GeocodingService.swift
//  Cretan Beach Quality
//
//  Created by kez542 on 13/4/26.
//


import Foundation

class GeocodingService {
    static let shared = GeocodingService()
    private let geonamesUsername = "mattsik"
    
    private init() {}
    
    func geocode(beachName: String, region: String) async throws -> (latitude: Double, longitude: Double) {
        let searchQuery = "\(beachName) \(region)"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://secure.geonames.org/searchJSON?q=\(encodedQuery)&country=GR&maxRows=1&username=\(geonamesUsername)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeocodingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        // fetch async returns the response directly OR throws an error
        //let response: GeoNamesSearchResponse = try await NetworkManager.shared.fetchAsync(from: url)
        let request = GeocodingRequest(query: "falasarna")
        let response: GeoNamesSearchResponse = try await NetworkManager.shared.fetchAsync(request)
        
        //REMEMBER TO check response
        guard let location = response.geonames?.first,
              let lat = location.latitude,
              let lon = location.longitude else {
            throw NSError(domain: "GeocodingService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No coordinates found"])
        }
        return (lat, lon)
    }
    /*
        // use the existing GeoNamesSearchResponse model
        NetworkManager.shared.fetchAsync(from: url)
            switch result {
                //no need for dispatch as it inherits from netwman.fetch
            case .success(let response):
                guard let location = response.geonames?.first,
                      let lat = location.latitude,
                      let lon = location.longitude else {
                    let error = NSError(domain: "GeocodingService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No coordinates found"])
                    completion(.failure(error))
                    return
                }
                completion(.success((lat, lon)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }*/
}
