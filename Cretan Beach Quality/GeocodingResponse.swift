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
    let lat: String
    let lng: String
    let countryName: String?
    let adminName1: String?
    let toponymName: String?
    let fcl: String?     // Feature class (P = populated place, etc.)
    let fcode: String?
    
    // computed properties for easy access
    var latitude: Double? {
        return Double(lat)
    }
    
    var longitude: Double? {
        return Double(lng)
    }
}
