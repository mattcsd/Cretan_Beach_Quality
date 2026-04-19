//
//  DetailViewController.swift
//  Cretan Beach Quality
//
//  Created by Admin on 30/3/26.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - ViewModel
    var viewModel: DetailViewModel!
    //pros stigmhn tha to afhsw. mellontika to kanw optional kai kathe fora unwrap// i think i need ! to say YES I HAVE CREATED THIS OUTSIDE OF HERE
    
    private let currentWeatherView = CurrentWeatherView()
    private let tableView = UITableView()
    
    private var weatherErrorLabel: UILabel?
    
    //water quality section
    private let waterQualityTitle: UILabel = {
        let label = UILabel()
        label.text = "Water Quality Information"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    // MARK: UI elements
    private let coastLabel = UILabel()
    private let regionLabel = UILabel()
    private let ecoliLabel = UILabel()
    private let enterococciLabel = UILabel()
    private let dateLabel = UILabel()
       
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCallbacks()
        configureWaterQuality()
        currentWeatherView.showLoading()
        print(viewModel != nil ? "DETAILVIEWMODEL NOT nil" : "DETAILVIEWMODEL IS nil")
        //TESTING ASYNC
        //viewModel.loadWeather()
        Task {
            await viewModel.loadWeatherAsync()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // an de to xw sprwxnei to header pros ta panw kai krybei to miso
        // to rresize header if needed for rotation or dynamic font changes)
        if let headerView = tableView.tableHeaderView {
            let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if headerView.frame.size.height != size.height {
                headerView.frame.size.height = size.height
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    
    // MARK: callback setup
    private func setupCallbacks(){
        viewModel.onWeatherLoaded = {[weak self] in
            guard let self = self else {return }
            
            //update current weather view
            if let weather = self.viewModel.weatherData {
                self.currentWeatherView.configure(with: weather)
            }
            //reload the forecast table
            self.tableView.reloadData()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            /*print("Weather error: \(errorMessage)")
            // show simple error label inside the weather view
            let errorLabel = UILabel()
            errorLabel.text = "Weather data unavailable"
            errorLabel.textColor = .secondaryLabel
            errorLabel.textAlignment = .center
            self?.currentWeatherView.addSubview(errorLabel)
            self?.currentWeatherView.showErrorMessage(errorMessage)*/
            self?.currentWeatherView.showErrorMessage("Weather data unavailable")
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
          if isLoading {
              self?.currentWeatherView.showLoading()
          } else {
              self?.currentWeatherView.hideLoading()
          }
        }
    }
    
    // MARK: - Header View Creation

    private func createTableHeaderView() -> UIView {
        let headerView = UIView()
        
        // water quality stack
        let waterQualityStack = UIStackView(arrangedSubviews: [
            waterQualityTitle, coastLabel, regionLabel, ecoliLabel, enterococciLabel, dateLabel
        ])
        waterQualityStack.axis = .vertical
        waterQualityStack.spacing = 8
        
        // current weather stack
        let weatherStack = UIStackView(arrangedSubviews: [currentWeatherView])
        weatherStack.axis = .vertical
        weatherStack.spacing = 12
        
        // ivider between water quality and weather
        let divider = createDivider()
        
        // main stack containign everything
        let mainStack = UIStackView(arrangedSubviews: [
            waterQualityStack,
            divider,
            weatherStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])
        
        return headerView
    }
    
    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white
        
        //  table view configurations
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.identifier)
        
        // seet delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // add table view to view hierarchy
        view.addSubview(tableView)
        
        // table view constraints make it fill entire screen
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // create and set the header view
        let headerView = createTableHeaderView()
        tableView.tableHeaderView = headerView
        
        // force layout to calculate header height
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        // update header height after layout
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
        }
    }
    
    // simple gray divider
    private func createDivider () -> UIView {
        let divider = UIView()
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.backgroundColor = .systemGray4
        return divider
    }
    
    //data manipulated in DetailViewModel
    private func configureWaterQuality() {
        coastLabel.text = "Coast: \(viewModel.coastName)"
        regionLabel.text = "Region: \(viewModel.regionName)"
        ecoliLabel.text = viewModel.ecoliText
        enterococciLabel.text = viewModel.enterococciText
        dateLabel.text = viewModel.formattedDate
    }
}

// MARK: - UITableView Delegate & DataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfForecastDays
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastCell.identifier, for: indexPath) as? DailyForecastCell else {
            return UITableViewCell()
        }
        
        let forecast = viewModel.forecast(at: indexPath.row)
        let isExpanded = viewModel.isExpanded(at: indexPath.row)
        
        cell.configure(with: forecast, isExpanded: isExpanded)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.isExpanded(at: indexPath.row) ? 220 : 70
    }
    //reload only the selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleExpanded(at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("--- DEBUG START: Row Clicked ---")
        print("DEBUG: [Click] User tapped row: \(indexPath.row)")
        viewModel.toggleExpanded(at: indexPath.row)
        //tableView.beginUpdates()
        //tableView.endUpdates()
        tableView.reloadRows(at: [indexPath], with: .fade)
        print("--- DEBUG END ---")
    }*/
}

// MARK: - DailyForecastCellDelegate
extension DetailViewController: DailyForecastCellDelegate {

    func didTapExpandButton(for cell: DailyForecastCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.toggleExpanded(at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
