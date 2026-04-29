//
//  DetailViewModel.swift
//  Cretan Beach Quality
//
//  Created by kez542 on 13/4/26.
//

import Foundation
import Combine

class DetailViewModel{
    enum RowType {
        case summary(Int, DailyForecast)
        case detail(Int, DailyForecast)
    }
    
    // MARK: - data(private set with init)
    private let beachItem: WaterQuality
    private let beachLatitude: Double?
    private let beachLongitude: Double?
    
    // (set) used so only this instance can write to these, everyone can (get)
    //private(set) var weatherData: WeatherResponse?
    //private(set) var expandedIndex: Int?
    private(set) var expandedIndexes: Set<Int> = []
    
    //MARK: listeners/announcers
    @Published var dailyForecasts: [DailyForecast] = []
    @Published var weatherData: WeatherResponse?
    @Published var onError: String? = nil
    @Published var det_isLoading: Bool = false
    @Published var rows: [RowType] = []
    
    //MARK: computed properties for View
    var coastName: String { beachItem.coast ?? "Unknown"}
    var regionName: String { beachItem.regionName }
    var ecoliText: String { "E. coli: \(beachItem.ecoli ?? "N/A")" }
    var enterococciText: String { "Enterococci: \(beachItem.intenterococci ?? "N/A")"}
    var formattedDate: String {formatDate(beachItem.sampleTimestamp)}
    
    var numberOfForecastDays: Int {dailyForecasts.count}
    func forecast(at index: Int) -> DailyForecast { dailyForecasts[index] }
    //func isExpanded(at index: Int) -> Bool {expandedIndex == index}
    
    //MARK: init
    init(beachItem: WaterQuality, latitude: Double?, longitude: Double?){
        self.beachItem = beachItem
        self.beachLatitude = latitude
        self.beachLongitude = longitude
    }
    
    //MARK: async/await version==========================
    func loadWeatherAsync() async {
        guard let lat = beachLatitude, let lon = beachLongitude else {
            onError = "Location not available"
            return
        }
        print("ASYNc CALLED.detailviewModel")
        self.det_isLoading = true
        
        do {
            //let weather = try await NetworkManager.shared.fetchWeatherAsync(latitude: lat, longitude: lon)
            let request = WeatherRequest(latitude: lat, longitude: lon)
            let weather = try await NetworkManager.shared.fetchAsync(request)
            
            //efoson einai published tha to mathei monos tou
            self.weatherData = weather
            self.dailyForecasts = weather.getDailyForecasts()
            self.updateRows()
            self.det_isLoading = false
            /* pleon me to self.weatherData = weather*/
            //self.onWeatherLoaded?()
            
        } catch {
            self.det_isLoading = false
            self.onError = error.localizedDescription
        }
    }
    //===================================end async/await
    
    func isExpanded(at index: Int) -> Bool {
        expandedIndexes.contains(index)
    }

    func toggleExpanded(at index: Int) {
        if expandedIndexes.contains(index) {
            expandedIndexes.remove(index)
        } else {
            expandedIndexes.insert(index)
        }
        updateRows()
    }
        
    // MARK: - Helpers
    private func updateRows() {
        var newRows: [RowType] = []
        for(idx, forecast) in dailyForecasts.enumerated() {
            newRows.append(.summary(idx, forecast))
            if expandedIndexes.contains(idx){
                newRows.append(.detail(idx, forecast))
            }
        }
        rows = newRows
    }
    
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
