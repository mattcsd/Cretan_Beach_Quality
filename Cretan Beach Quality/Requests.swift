//
//  Requests.swift
//  Cretan Beach Quality
//
//  Created by Admin on 22/4/26.
//

import Foundation

struct WeatherRequest: APIRequest{
    typealias Response = WeatherResponse
    let latitude: Double
    let longitude: Double
    
    var url: URL {
        let forecastDays = 7
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,weather_code&timezone=auto&forecast_days=\(forecastDays)"
        return URL(string: urlString)!
    }
}

struct BeachListRequest: APIRequest {
    typealias Response = [WaterQuality]
    
    var url: URL{
        URL(string: "https://data.gov.gr/api/v1/query/apdkriti-swimwater")!
    }
}

struct GeocodingRequest: APIRequest {
    typealias Response = GeoNamesSearchResponse
    
    let query: String
    let username = "mattsik"
    
    
    var url: URL {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://secure.geonames.org/searchJSON?q=\(encodedQuery)&country=GR&maxRows=1&username=\(username)"
        return URL(string: urlString)!
    }
}
