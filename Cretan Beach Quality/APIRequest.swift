//
//  APIRequest.swift
//  Cretan Beach Quality
//
//  Created by Admin on 22/4/26.
//
import Foundation

protocol APIRequest {
    //inheriting from Decodable
    associatedtype Response: Decodable

    var baseUrl: String { get }
    var path: String { get  }
    var method: String { get }
    var headers: [String: Any] { get }

    var hasBody: Bool { get }
    var urlParameters: [String:Any] { get  }
}

//default
extension APIRequest {
    var method: String { "GET" }
    var hasBody: Bool { false }
    var headers: [String: Any] { [:] }
    var bodyParameters: [String:Any]? {nil}
    
    // URL built using reduce (exactly the pattern you showed, but corrected)
    var url: URL {
        // Helper to percent‑encode a string for URL query
        func encode(_ value: String) -> String {
            value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        }
        
        // Build query string starting with "?"
        let queryString = urlParameters.reduce("?") { partial, pair in
            let separator = partial == "?" ? "" : "&"
            let encodedKey = encode(pair.key)
            let encodedValue = encode("\(pair.value)")
            return partial + separator + "\(encodedKey)=\(encodedValue)"
        }
        
        // If there are no parameters, the reduce result would be just "?" – remove it
        let finalQuery = urlParameters.isEmpty ? "" : queryString
        
        let urlString = "https://\(baseUrl)\(path)" + finalQuery
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL: \(urlString)")
        }
        return url
    }
}


