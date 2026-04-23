//
//  ViewController.swift
//  Cretan Beach Quality
//
//  Created by Admin on 23/3/26.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private let viewModel = ViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
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
        //setupCallbacks()
        setupBindings()
        
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
    
    private func setupBindings() {
        // subscribe to isLoading
        viewModel.$isLoading
        //prin mpei den einai se main thread. otan ftanei edw theloume na ensure oti einai/thampei main thread.
            .receive(on: DispatchQueue.main)   // ensuring UI updates on main thread
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    if !self.refreshControl.isRefreshing {
                        self.activityIndicator.startAnimating()
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        // subscribe to displayedBeaches data changing
        viewModel.$displayedBeaches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.tableView.isHidden = false
                self?.errorLabel.isHidden = true
                self?.retryButton.isHidden = true
            }
            .store(in: &cancellables)

        // subscribe to errorMessage
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
        
            .compactMap { $0 }   // ignore nil, ama einai mh steileis sto set
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
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
        //dwse mou ena palio cell, if no reusable creates a new
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //ftiakse ta texts sto viewmodel
        let displayTitles = viewModel.displayTextForBeach(at: indexPath.row)
        
        // creates modern iOS 14+, holds all the cell's content (text, font, color, etc
        var config = cell.defaultContentConfiguration()
        
        config.text = displayTitles.title
        config.secondaryText = displayTitles.subtitle
        config.secondaryTextProperties.numberOfLines = 2
        
        //apply configurations
        cell.contentConfiguration = config
        //bazei to gkribelaki sta deksia
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // show loading spinner on the cell
        if let cell = tableView.cellForRow(at: indexPath) {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            cell.accessoryView = spinner
        }
        
        // need Task to call async function
        Task {
            // await the result from ViewModel
            let result = await viewModel.handleBeachSelection(at: indexPath.row)
            print("from viewcontroller!! item:\(result.item), lat:\(result.latitude), lon:\(result.longitude)")
            await MainActor.run {
                // Remove spinner (back on main thread)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryView = nil
                }
                
                // Create and navigate to DetailViewController
                let detailVC = DetailViewController()
                let detViewModel = DetailViewModel(
                    beachItem: result.item,
                    latitude: result.latitude,
                    longitude: result.longitude
                )
                detailVC.viewModel = detViewModel
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.searchBeaches(with: query)
    }
}
