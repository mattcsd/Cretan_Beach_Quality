//
//  Requests.swift
//  Cretan Beach Quality
//
//  Created by Admin on 22/4/26.
//

import Foundation

struct WeatherRequest: WeatherAPIRequest {
    typealias Response = WeatherResponse

    let latitude: Double
    let longitude: Double
    let forecastDays = 7
    
    var path: String { "/v1/forecast" }
    var urlParameters: [String: Any] {
        [
            "latitude": latitude,
            "longitude": longitude,
            "current": "temperature_2m,weather_code,wind_speed_10m,wind_direction_10m",
            "hourly": "temperature_2m,wind_speed_10m,wind_direction_10m,weather_code",
            "timezone": "auto",
            "forecast_days": forecastDays
        ]
    }
}

struct BeachListRequest: GovAPIRequest {
    typealias Response = [WaterQuality]
    
    var path: String { "/api/v1/query/apdkriti-swimwater" }
    var urlParameters: [String: Any] { [:] }
}

struct GeoNamesRequest<ResponseType: Decodable>: GeoAPIRequest {
    typealias Response = ResponseType
    
    let query: String
    let username: String = "geonames1"
    
    var path: String { "/searchJSON" }
    var urlParameters: [String: Any] {
        [
            "q": query,
            "country": "GR",
            "maxRows": 1,
            "username": username
        ]
    }
}

typealias GeocodingRequest = GeoNamesRequest<GeoNamesSearchResponse>
