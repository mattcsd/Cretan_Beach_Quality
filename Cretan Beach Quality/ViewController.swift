//
//  ViewController.swift
//  Cretan Beach Quality
//
//  Created by Admin on 23/3/26.
//

import UIKit

class ViewController: UIViewController {
    
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
    
    
    // MARK - Data
    private var waterQualityData: [WaterQuality] = []
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Beach Water Quality"
        view.backgroundColor = .systemBackground
        
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
        
        // SEtup button action
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
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
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        
            DispatchQueue.main.async{
                guard let self = self else { return }
                
                self.activityIndicator.stopAnimating()
                
                //Handle error
                if let error = error {
                    print("Network error: \(error)")
                    self.showError("Network error: \(error.localizedDescription)")
                    return
                }
                
                //Check response
                if let httpResponse = response as? HTTPURLResponse{
                    print("Status code:\(httpResponse.statusCode)")
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
                        print("First item: \(first.coast) in \(first.perunit)")
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
        task.resume()
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
        return waterQualityData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = waterQualityData[indexPath.row]
        
        //Configure cell
        var config = cell.defaultContentConfiguration()
        config.text = item.coast
        config.secondaryText = "\(item.perunit) | E. coli: \(item.ecoli) | Enterococci \(item.intenterococci)"
        
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
        
        let item  = waterQualityData[indexPath.row]
        
        // Show alert with more details
        let alert = UIAlertController(
            title: "\(item.coast)",
            message: """
                Region: \(item.perunit)
                E. coli: \(item.ecoli)
                Enterococci: \(item.intenterococci)
                Sample Date: \(item.sampleTimestamp)
                """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
