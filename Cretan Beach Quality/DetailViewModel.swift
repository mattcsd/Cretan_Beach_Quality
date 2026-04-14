//
//  DetailViewModel.swift
//  Cretan Beach Quality
//
//  Created by kez542 on 13/4/26.
//

import Foundation

class DetailViewModel{
    // MARK: - data(private
    private let beachItem: WaterQuality
    private let latitude: Double?
    private let longitude: Double?
    
    private(set) var weatherData: WeatherResponse?
    private(set) var dailyForecasts: [DailyForecast] = []
    private(set) var expandedIndex: Int?
    
    //MARK: callbacks
    var onWeatherLoaded: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    
    
    //MARK: computed properties for View
    var coastName: String { beachItem.coast ?? "Unknown"}
    var regionName: String { beachItem.regionName }
    var ecoliText: String { "E. coli: \(beachItem.ecoli ?? "N/A")" }
    var enterococciText: String { "Enterococci: \(beachItem.intenterococci)" ?? "N/A"}
    var formattedDate: String {formatDate(beachItem.sampleTimestamp)}
    
    var numberOfForecastDays: Int {dailyForecasts.count}
    func forecast(at index: Int) -> DailyForecast { dailyForecasts[index] }
    func isExpanded(at index: Int) -> Bool {expandedIndex == index}
    
    //MARK: init
    init(beachItem: WaterQuality, latitude: Double?, longitude: Double?){
        self.beachItem = beachItem
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: Actions
    
    func loadWeather() {
        guard let lat = latitude, let lon = longitude else {
            onError?("Location not available")
            return
        }
        
        onLoadingChanged?(true)
        
        NetworkManager.shared.fetchWeather(latitude: lat, longitude: lon) { [weak self] result in
            // bgainei giati hdh exei mpei sto main apo to networkmanager.fetch??
            
            //DispatchQueue.main.async {
                self?.onLoadingChanged?(false)
                switch result {
                case .success(let weather):
                    self?.weatherData = weather
                    self?.dailyForecasts = weather.getDailyForecasts()
                    self?.onWeatherLoaded?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
              //  }
            }
        }
    }
    
    func toggleExpanded(at index: Int) {
            if expandedIndex == index {
                expandedIndex = nil
            } else {
                expandedIndex = index
            }
            onWeatherLoaded?()  // tell table to reload rows
        }
        
    // MARK: - Helpers
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString, !dateString.isEmpty else {
            return "Date: N/A"
        }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, yyyy 'at' HH:mm:ss"
            return "Date: \(outputFormatter.string(from: date))"
        }
        return "Date: \(dateString)"
    }
}
