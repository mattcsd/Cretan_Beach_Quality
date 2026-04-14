//
//  ViewController.swift
//  Cretan Beach Quality
//
//  Created by Admin on 23/3/26.
//

import UIKit

// Create a ViewModel instance
//not here //let viewModel = ViewModel()

class ViewController: UIViewController {
    // should i create the viewmodel instance here?
    private let viewModel = ViewModel()
    
    
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
    
    // MARK: - Refresh
    private let refreshControl = UIRefreshControl()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Beach Water Quality"
        view.backgroundColor = .systemBackground
        
        //helpers to prepare the communciation with viewmodel
        setupSearchController()
        setupCallbacks()
        
        setupUI()
        setupRefreshControl()
        viewModel.loadBeaches()
    }
    
    
    // MARK: - Setup Methods
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by beach name"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupCallbacks() {
        // callback for loading state
        viewModel.onLoadingChanged = { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading {
                // If refresh control is already refreshing, don't start the normal spinner
                if !self.refreshControl.isRefreshing {
                    self.activityIndicator.startAnimating()
                }
            } else {
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        }
        
        // callback for data update (success case)
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            print("DEBUG: onDataUpdated called")
            self.tableView.reloadData()
            self.tableView.isHidden = false
            self.errorLabel.isHidden = true
            self.retryButton.isHidden = true
        }
        
        // callback for error
        viewModel.onError = { [weak self] errorMessage in
            guard let self = self else { return }
            self.showError(errorMessage)
        }
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)
        
        
        tableView.delegate = self
        tableView.dataSource = self

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
    
    private func setupRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        viewModel.refreshBeaches()
    }

    @objc private func retryButtonTapped(){
        viewModel.loadBeaches()
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
        //ask the viewmodel to return the number of beaches
        return viewModel.numberOfBeaches
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //again ask viewmodel for the particular row-beach
        let item = viewModel.beach(at: indexPath.row)

        //configure cell
        var config = cell.defaultContentConfiguration()
        config.text = item.coast ?? "Unknown"
        // modify here to add/remove data
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
        
        let item = viewModel.beach(at: indexPath.row)
        
        // clean the beach name, remove "_" and extra text, fianlly keep only first name
        var coastName = (item.coast ?? "")
            .components(separatedBy: "_")
            .first ?? ""
        coastName = coastName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let region = item.regionName
        
        // show loading spinner on the cell
        if let cell = tableView.cellForRow(at: indexPath) {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            cell.accessoryView = spinner
        }
        
        // GeocodingService to fetxh coordinates
        GeocodingService.shared.geocode(beachName: coastName, region: region) { [weak self] result in
            guard let self = self else { return }
            
            //already in main thread, wrapped in geocodingservice
            //DispatchQueue.main.async {
                // Remove spinner from cell
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryView = nil
                }
                
                switch result {
                case .success(let (latitude, longitude)):
                    // create ViewModel with valid coordinates
                    // i dont think this can happen another way? seems alittle odd to be done in the network call.
                    let viewModel = DetailViewModel(beachItem: item, latitude: latitude, longitude: longitude)
                    let detailVC = DetailViewController()
                    detailVC.viewModel = viewModel
                    self.navigationController?.pushViewController(detailVC, animated: true)
                    
                case .failure(let error):
                    print("Geocoding failed: \(error)")
                    // still show detail, (weather will be unavailable)
                    let viewModel = DetailViewModel(beachItem: item, latitude: nil, longitude: nil)
                    let detailVC = DetailViewController()
                    detailVC.viewModel = viewModel
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            //}
        }
        
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.searchBeaches(with: query)
    }
}
