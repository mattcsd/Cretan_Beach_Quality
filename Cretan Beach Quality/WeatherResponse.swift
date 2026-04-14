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
    
    // image name based on weather code with SF Symbols
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
    
    //get hours from current time  //not used in the end
    func getHourlyForecast(upTo limit: Int = 10) -> [HourlyForecast] {
        var forecasts: [HourlyForecast] = []
        
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        
        for i in 0..<time.count {
            let timeString = time[i]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            
            if let date = formatter.date(from: timeString) {
                let hour = calendar.component(.hour, from: date)
                
                //show all hours from current hour onward, with limit
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
        
        if forecasts.isEmpty && time.count > 0 {
            print("No remaining hours today, showing first available hours")
            for i in 0..<min(time.count, limit) {
                let timeString = time[i]
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
                
                if let date = formatter.date(from: timeString) {
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

// adding the dayily and the hourly forecast

struct DailyForecast {
    let date: Date
    let dayName: String
    let formattedDate: String
    let middayTemperature: Double
    let maxWindSpeed: Double
    let weatherCode: Int
    var hourlyForecasts: [HourlyForecast] = []
    
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

extension WeatherResponse {
    func getDailyForecasts() -> [DailyForecast] {
        var dailyForecasts: [DailyForecast] = []
        let calendar = Calendar.current
        
        // group hourly data by day
        var dailyData: [Date: [Int: (temp: Double, wind: Double, weatherCode: Int)]] = [:]
        
        for i in 0..<hourly.time.count {
            let timeString = hourly.time[i]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            
            if let date = formatter.date(from: timeString) {
                let startOfDay = calendar.startOfDay(for: date)
                let hour = calendar.component(.hour, from: date)
                
                if dailyData[startOfDay] == nil {
                    dailyData[startOfDay] = [:]
                }
                
                dailyData[startOfDay]?[hour] = (
                    temp: hourly.temperature[i],
                    wind: hourly.windSpeed[i],
                    weatherCode: hourly.weatherCode[i]
                )
            }
        }
        
        // convert to DailyForecast objects
        let sortedDays = dailyData.keys.sorted()
        for (index, day) in sortedDays.enumerated() {
            guard let hours = dailyData[day] else { continue }
            
            // find midday temperature (12:00-14:00)
            var middayTemp: Double?
            for hour in 12...14 {
                if let data = hours[hour] {
                    middayTemp = data.temp
                    break
                }
            }
            
            // if no midday data, use the temperature from the middle of available hours
            if middayTemp == nil && !hours.isEmpty {
                let middleHour = hours.keys.sorted()[hours.count / 2]
                middayTemp = hours[middleHour]?.temp
            }
            
            // get max wind speed for the day
            let maxWind = hours.values.map { $0.wind }.max() ?? 0
            
            // get most common weather code for the day
            var weatherCodeCounts: [Int: Int] = [:]
            for data in hours.values {
                weatherCodeCounts[data.weatherCode, default: 0] += 1
            }
            let dominantWeatherCode = weatherCodeCounts.max(by: { $0.value < $1.value })?.key ?? 0
            
            // get hourly forecasts for this day
            var dayHourlyForecasts: [HourlyForecast] = []
            for hour in hours.keys.sorted() {
                if let data = hours[hour] {
                    let timeString = String(format: "%02d:00", hour)
                    dayHourlyForecasts.append(HourlyForecast(
                        time: timeString,
                        temperature: data.temp,
                        windSpeed: data.wind,
                        windDirection: 0, // not available in hourly data
                        weatherCode: data.weatherCode
                    ))
                }
            }
            
            // format day name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d"
            let formattedDate = dateFormatter.string(from: day)
            
            let dayNameFormatter = DateFormatter()
            dayNameFormatter.dateFormat = "EEEE"
            let dayName = dayNameFormatter.string(from: day)
            
            let forecast = DailyForecast(
                date: day,
                dayName: dayName,
                formattedDate: formattedDate,
                middayTemperature: middayTemp ?? 0,
                maxWindSpeed: maxWind,
                weatherCode: dominantWeatherCode,
                hourlyForecasts: dayHourlyForecasts
            )
            
            dailyForecasts.append(forecast)
        }
        
        return dailyForecasts
    }
}
