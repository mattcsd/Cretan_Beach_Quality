//
//  GeocodingResponse.swift
//  Cretan Beach Quality
//
//  Created by Admin on 30/3/26.
//

import Foundation

// For GeoNames API response
struct GeoNamesSearchResponse: Decodable {
    let totalResultsCount: Int
    let geonames: [GeoNamesResult]?
}

struct GeoNamesResult: Decodable {
    let geonameId: Int
    let name: String
    let lat: String      // Note: Comes as String, not Double
    let lng: String      // Note: Comes as String, not Double
    let countryName: String?
    let adminName1: String?  // Region/state name
    let toponymName: String?  // Main name if different from 'name'
    let fcl: String?     // Feature class (P = populated place, etc.)
    let fcode: String?   // Feature code
    
    // Computed properties for easy access
    var latitude: Double? {
        return Double(lat)
    }
    
    var longitude: Double? {
        return Double(lng)
    }
}
