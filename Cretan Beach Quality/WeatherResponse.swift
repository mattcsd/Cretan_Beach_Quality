//
//  WeatherResponse.swift
//  Cretan Beach Quality
//
//  Created by Admin on 31/3/26.
//

import Foundation
import UIKit

struct WeatherResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let current: CurrentWeather
    let hourly: HourlyWeather
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case current = "current"
        case hourly = "hourly"
    }
}

struct CurrentWeather: Decodable {
    let temperature: Double
    let weatherCode: Int
    let windSpeed: Double
    let windDirection: Double
    let time: String
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case weatherCode = "weather_code"
        case windSpeed = "wind_speed_10m"
        case windDirection = "wind_direction_10m"
        case time
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        if let date = formatter.date(from: time) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "HH:mm"
            return outputFormatter.string(from: date)
        }
        return time
    }
    
    // Background color based on temperature
    var backgroundColor: UIColor {
        switch temperature {
        case ..<11:
            return .systemBlue
        case 11...25:
            return .systemGreen
        default:
            return .systemRed
        }
    }
    
    // Image name based on weather code (using SF Symbols)
    var imageName: String {
        switch weatherCode {
        case 0...3:
            return "sun.max.fill"
        case 4...10:
            return "cloud.fill"
        default:
            return "cloud.rain.fill"
        }
    }
}

struct HourlyWeather: Decodable {
    let time: [String]
    let temperature: [Double]
    let windSpeed: [Double]
    let windDirection: [Double]
    let weatherCode: [Int]
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case windSpeed = "wind_speed_10m"
        case windDirection = "wind_direction_10m"
        case weatherCode = "weather_code"
    }
    
    // Get hours from current time up to 23:00 (or next few hours)
    func getHourlyForecast(upTo limit: Int = 10) -> [HourlyForecast] {
        var forecasts: [HourlyForecast] = []
        
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        
        for i in 0..<min(time.count, limit) {
            let timeString = time[i]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            
            if let date = formatter.date(from: timeString) {
                let hour = calendar.component(.hour, from: date)
                
                // Only show future hours (including current)
                if hour >= currentHour && forecasts.count < limit {
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "HH:mm"
                    
                    forecasts.append(HourlyForecast(
                        time: outputFormatter.string(from: date),
                        temperature: temperature[i],
                        windSpeed: windSpeed[i],
                        windDirection: windDirection[i],
                        weatherCode: weatherCode[i]
                    ))
                }
            }
        }
        
        return forecasts
    }
}

struct HourlyForecast {
    let time: String
    let temperature: Double
    let windSpeed: Double
    let windDirection: Double
    let weatherCode: Int
    
    var imageName: String {
        switch weatherCode {
        case 0...3:
            return "sun.max.fill"
        case 4...10:
            return "cloud.fill"
        default:
            return "cloud.rain.fill"
        }
    }
}
