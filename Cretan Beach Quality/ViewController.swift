//
//  ViewController.swift
//  Cretan Beach Quality
//
//  Created by Admin on 23/3/26.
//

import UIKit

class ViewController: UIViewController {
    let GEONAMES_USERNAME = "mattsik"

    //MARK: UI Components
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Try again", for: .normal)
        button.isHidden = true
        return button
    }()
    
    //MARK: - Search Bar
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredData: [WaterQuality] = []
    private var isSearching = false
    
    // MARK: - REfresh
    private let refreshControl = UIRefreshControl()
    
    @objc private func refreshData(){
        fetchData()
    }
    
    // MARK: - Data
    private var waterQualityData: [WaterQuality] = []
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Beach Water Quality"
        view.backgroundColor = .systemBackground
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by beach name"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        setupUI()
        fetchData()
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //for the refresh
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        

        
        // SEtup button action
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20)
        ])
    }
    
    //MARK - Network Call
    private func fetchData() {
        if !refreshControl.isRefreshing{
            activityIndicator.startAnimating()
        }
        // Show loading
        activityIndicator.startAnimating()
        errorLabel.isHidden = true
        retryButton.isHidden = true

        let urlString = "https://data.gov.gr/api/v1/query/apdkriti-swimwater"
        
        guard let url = URL(string: urlString) else {
            showError("Invalid URL")
            return
        }
        print("Fetching data...")
        
        
        //REFINEMENT 2
        /*let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        
            DispatchQueue.main.async{
                guard let self = self else { return }
                
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                //Handle error
                if let error = error {
                    print("Network error: \(error)")
                    self.showError("Network error: \(error.localizedDescription)")
                    return
                }
                
                //Check response
                if let httpResponse = response as? HTTPURLResponse{
                    print("Status code:\(httpResponse.statusCode)")
                    // Check for non-200 status codes
                     guard (200...299).contains(httpResponse.statusCode) else {
                         self.showError("Server error: \(httpResponse.statusCode)")
                         return
                     }
                }
                
                // Check data
                guard let data = data else {
                    print("No data received")
                    self.showError("No data received")
                    return
                }
                
                print("Data size: \(data.count) bytes")
                
                // Try to decode
                
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode([WaterQuality].self, from: data)
                    
                    print("Success! Decoded \(decodedData.count) items")
                    if let first = decodedData.first{
                        print("First item: \(first.coast) in \(first.perunit) and \(first.sampleTimestamp)") 
                    }
                    
                    self.waterQualityData = decodedData
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                } catch{
                    print("Decoding error: \(error)")
                    self.showError("Failed to parse data: \(error.localizedDescription)")
                    
                }
            }
            
        }
        task.resume()*/
        
        NetworkManager.shared.fetch(from: url){ [weak self] (result: Result<[WaterQuality], Error>) in
            guard let self = self else{return}
            self.activityIndicator.stopAnimating()
            
            switch result{
            case .success(let data):
                self.waterQualityData = data
                self.tableView.reloadData()
                self.tableView.isHidden = false
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
            
            
        }
    }
    
    @objc private func retryButtonTapped(){
        fetchData()
    }
    
    private func showError(_ message: String){
        errorLabel.text = "\n\(message)"
        errorLabel.isHidden = false
        retryButton.isHidden = false
        tableView.isHidden = true
    }
}

//MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredData.count : waterQualityData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = isSearching ? filteredData[indexPath.row] : waterQualityData[indexPath.row]

        //Configure cell
        var config = cell.defaultContentConfiguration()
        config.text = item.coast ?? "Unknown"
        config.secondaryText =
        "\(item.perunit ?? "N/A") | E. coli: \(item.ecoli ?? "N/A") | Enterococci: \(item.intenterococci ?? "N/A")"
        
        config.secondaryTextProperties.numberOfLines = 2
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        return cell
        
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = isSearching ? filteredData[indexPath.row] : waterQualityData[indexPath.row]
        
        // Clean the beach name - remove "_" and extra text
        var coastName = (item.coast ?? "")
            .components(separatedBy: "_")
            .first ?? ""
        
        coastName = coastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let searchQuery = "\(coastName) Crete"
        print("Searching GeoNames for: \(searchQuery)")
        
        // Show loading indicator
        if let cell = tableView.cellForRow(at: indexPath) {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            cell.accessoryView = spinner
        }
        
        NetworkManager.shared.fetchCoordinatesGeoNames(for: searchQuery,
                                                         username: GEONAMES_USERNAME) { result in
            DispatchQueue.main.async {
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryView = nil
                }
            }
            
            switch result {
            case .success(let location):
                print("Beach found: \(location.name)")
                print("Lat: \(location.latitude ?? 0), Lon: \(location.longitude ?? 0)")
                
                // Use the coordinates (e.g., show on map, get weather, etc.)
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: location.name,
                        message: """
                        Location: \(location.adminName1 ?? location.countryName ?? "Greece")
                        Coordinates: \(location.latitude?.rounded(to: 4) ?? 0), 
                                    \(location.longitude?.rounded(to: 4) ?? 0)
                        """,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
                
            case .failure(let error):
                print("Could not find coordinates for '\(coastName)': \(error)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Location Not Found",
                        message: "Could not find '\(coastName)' on GeoNames.\nTry a different beach name.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
        
        let vc = DetailViewController()
        vc.item = item
        navigationController?.pushViewController(vc, animated: true)
    }


}
// Helper extension for rounding
extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""

        if searchText.isEmpty {
            isSearching = false
            filteredData = []
        } else {
            isSearching = true
            filteredData = waterQualityData.filter { item in
                (item.coast ?? "").lowercased().contains(searchText.lowercased()) ||
                (item.perunit ?? "").lowercased().contains(searchText.lowercased())
            }
        }

        tableView.reloadData()
    }
}
