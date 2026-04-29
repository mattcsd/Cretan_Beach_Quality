//
//  ViewModel.swift
//  Cretan Beach Quality
//
//  Created by Admin on 9/4/26.
//

import Foundation
import Combine

//not yet, swiftUI //@Observable
//combine, codeco(vpn)


class ViewModel{
    // MARK: Publishers (expose state changes)
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var displayedBeaches: [WaterQuality] = []
    
    // MARK: Private Data (only ViewModel can change)
    private var allBeaches: [WaterQuality] = [] {
        didSet{updateDisplayedBeaches() }
    }
    private var filteredBeaches: [WaterQuality] = []
    private var isSearching: Bool = false
    private var searchQuery: String = ""
        
    //MARK: - Computed Properties for ViewController to read
    var numberOfBeaches: Int{
        //let count = isSearching ? filteredBeaches.count : allBeaches.count
        return displayedBeaches.count
    }
    
    func beach(at index: Int) -> WaterQuality {
        //return isSearching ? filteredBeaches[index] : allBeaches[index]
        displayedBeaches[index]
    }
    
    // MARK: Helper methods
    private func updateDisplayedBeaches(){
        if isSearching && !searchQuery.isEmpty{
            displayedBeaches = allBeaches.filter { item in
                (item.coast ?? "").lowercased().contains(searchQuery.lowercased()) ||
                (item.perunit ?? "").lowercased().contains(searchQuery.lowercased())
            }
        }else {
            displayedBeaches = allBeaches
        }
    }
    
    func getCleanedBeachName(at index: Int) -> String {
        let item = beach(at: index)
        var cleanedName = (item.coast ?? "N/A")
            .components(separatedBy: "_")
            .first ?? ""
        cleanedName = cleanedName.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanedName
    }
    
    func getRegion(at index: Int) -> String {
            let item = beach(at: index)
        return item.regionName // no need fo unwrapping
    }
    
    func displayTextForBeach(at index: Int) -> (title: String, subtitle: String) {
        let item = beach(at: index)
        let title = item.coast ?? "Unknown"
        let subtitle = "\(item.perunit ?? "N/A") | E. coli: \(item.ecoli ?? "N/A") | Enterococci: \(item.intenterococci ?? "N/A")"
        return (title, subtitle)
    }
    
    //MARK: NAvigationHandling
    func handleBeachSelection(at index: Int) async -> (item: WaterQuality, latitude: Double?, longitude: Double?){
        
        let item = beach(at: index)
        let cleanedName = getCleanedBeachName(at: index)
        let region = getRegion(at: index)
        let searchQuery = "\(cleanedName) \(region)"

        do {
            
            print("MPHKAME KAI KANOME REQUESTING GEOCODE FOR \(searchQuery)")
            let request = GeocodingRequest(query: searchQuery)
            let response: GeoNamesSearchResponse = try await NetworkManager.shared.fetchAsync(request)
            
            guard let location = response.geonames?.first,
                  let lat = location.latitude,
                  let lon = location.longitude else {
                print("No coordinates found for \(searchQuery)")
                return (item, nil, nil)
            }
            print("==========RECEIVED GEOCODE FOR \(searchQuery) with lat, long \(lat), \(lon)")
            return (item, lat, lon)
            
        } catch {
            print("Geocoding error: \(error)")
            return (item, nil, nil)
        }
    }
    
    //MARK: Public Actions
    func loadBeaches(){
        //these are observed so the viewcontroller "listens"
        isLoading = true
        errorMessage = nil
        
        /*let urlString = "https://data.gov.gr/api/v1/query/apdkriti-swimwater"
        guard let url = URL(string: urlString) else {
            //onLoadingChanged?(false)
            //onError?("Invalid URL")
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }*/
        
        Task { /* NOT do i need [weak self] in guard let self = self else {return} nomizw naiu giati an o user bgei kai to network call akoma petaei?*/
            do {
                //let data: [WaterQuality] = try await NetworkManager.shared.fetchAsync(from:url)
                let request = BeachListRequest()
                let data: [WaterQuality] = try await NetworkManager.shared.fetchAsync(request)
                
                self.allBeaches = data
                self.isLoading = false
                
                //an edw ekana kati heavy tha eprepe explixitly na tou pw meine sto background thread!
                
            } catch {
                //again 
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    
    func refreshBeaches(){
        //same as loadbeaches, but viewcontroller might treat it differently (puultorefresh)
        loadBeaches()
    }
    
    func searchBeaches(with query: String) {
        /*if query.isEmpty {
            isSearching = false
            filteredBeaches = []
        } else {
            isSearching = true
            applySearchFilter(for: query)
        }
        onDataUpdated?()  // tell ViewController: reload table*/
        searchQuery = query
        isSearching = !query.isEmpty
        updateDisplayedBeaches()
    }
    
    
    private func applySearchFilter(for query: String? = nil){
        let searchText = (query ?? "").lowercased()
        if searchText.isEmpty {
            filteredBeaches = []
            return
        }
        filteredBeaches = allBeaches.filter { item in
            (item.coast ?? "").lowercased().contains(searchText) ||
            (item.perunit ?? "").lowercased().contains(searchText)
        }
    }
    
}
