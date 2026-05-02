//
//  WeatherAPIRequest.swift
//  Cretan Beach Quality
//
//  Created by Admin on 30/4/26.
//

protocol WeatherAPIRequest : APIRequest {
    
}

extension WeatherAPIRequest {
    var baseUrl: String {"api.open-meteo.com"}
}
