//
//  ViewModel.swift
//  Cretan Beach Quality
//
//  Created by Admin on 9/4/26.
//
import Foundation



//extension ViewController { // sth prokeimenh isws de xreiazetai alla gia na mathoume an eixame panw apo ena View, pou exoume to DetailViewController
    
    
//not yet, swiftUI //@Observable

class ViewModel{
    // slot to inform controller that activityIndicator should be changed
    // MARK: - Callbacks (communication to ViewController)
    var onLoadingChanged: ((Bool) -> Void)?
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: Private Data (only ViewModel can change)
    
    private var allBeaches: [WaterQuality] = []
    private var filteredBeaches: [WaterQuality] = []
    private var isSearching: Bool = false
    
    //MARK: - Computed Properties for ViewController to read
    var numberOfBeaches: Int{
        let count = isSearching ? filteredBeaches.count : allBeaches.count
        print("DEBUG: numberOfBeaches = \(count) (isSearching: \(isSearching))")
        return count
    }
    
    func beach(at index: Int) -> WaterQuality {
        return isSearching ? filteredBeaches[index] : allBeaches[index]
    }
    
    
    //MARK: Public Actions
    func loadBeaches(){
        //tell the viewcontroller: loading started
        onLoadingChanged?(true)
        
        let urlString = "https://data.gov.gr/api/v1/query/apdkriti-swimwater"
        guard let url = URL(string: urlString) else {
            onLoadingChanged?(false)
            onError?("Invalid URL")
            return
        }
        
        NetworkManager.shared.fetch(from: url) { [weak self] (result: Result<[WaterQuality], Error>) in
            //check if exists or has corrupted/failer
            guard let self = self else {return}
            
            //tell viewcontroller: loading has finished (either success or error)
            self.onLoadingChanged?(false)
            
            switch result {
            case .success(let data):
                //if currently searching, re-apply search filter
                if self.isSearching {
                    self.applySearchFilter()
                }
                print("DEBUG: received \(data.count) beaches")
                //assign the data
                self.allBeaches = data
                print("DEBUG: allBeaches now has \(self.allBeaches.count) beaches")
                
                //tell viewcontroller: data is ready
                self.onDataUpdated?()
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
                
    }
    
    
    func refreshBeaches(){
        //same as loadbeaches, but viewcontroller might treat it differently (puultorefresh)
        loadBeaches()
    }
    
    func searchBeaches(with query: String) {
        if query.isEmpty {
            isSearching = false
            filteredBeaches = []
        } else {
            isSearching = true
            applySearchFilter(for: query)
        }
        onDataUpdated?()  // tell ViewController: reload table
    }
    
    // MARK: - Private Helpers
    private func applySearchFilter(for query: String? = nil) {
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
