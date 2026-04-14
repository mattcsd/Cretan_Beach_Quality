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
    
    func geocode(beachName: String, region: String, completion: @escaping (Result<(latitude: Double, longitude: Double), Error>) -> Void) {
        let searchQuery = "\(beachName) \(region)"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://secure.geonames.org/searchJSON?q=\(encodedQuery)&country=GR&maxRows=1&username=\(geonamesUsername)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "GeocodingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // use the existing GeoNamesSearchResponse model
        NetworkManager.shared.fetch(from: url) { (result: Result<GeoNamesSearchResponse, Error>) in
            switch result {
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
    }
}
