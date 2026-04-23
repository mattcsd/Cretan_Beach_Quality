//
//  APIRequest.swift
//  Cretan Beach Quality
//
//  Created by Admin on 22/4/26.
//
import Foundation

protocol APIRequest {
    associatedtype Response: Decodable
    var url: URL { get }
    var method: String { get } // "GET", "POST"
    var headers: [String: String] { get }
    // optional body (για POST)
}
//default
extension APIRequest {
    var method: String { "GET" }
    var headers: [String: String] { [:] }
}


