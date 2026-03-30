//
//  GeocodingResponse.swift
//  Cretan Beach Quality
//
//  Created by Admin on 30/3/26.
//

import Foundation

struct GeocodingResponse: Decodable {
    let results: [GeocodingResult]?
}

struct GeocodingResult: Decodable {
    let id: Int  // Required field from API
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?  // Optional fields from API
    let admin1: String?   // Region/state
    let timezone: String? // Timezone
}
