//
//  DetailViewController.swift
//  Cretan Beach Quality
//
//  Created by Admin on 30/3/26.
//

import UIKit
import Combine

class DetailViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - ViewModel
    var viewModel: DetailViewModel!
    //pros stigmhn tha to afhsw. mellontika to kanw optional kai kathe fora unwrap// i think i need ! to say SINCE I HAVE CREATED THIS OUTSIDE OF HERE

    private let currentWeatherView = CurrentWeatherView()
    private let tableView = UITableView()
        
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
        setupBindings()
        configureWaterQuality()
        currentWeatherView.showLoading()
        
        Task {
            await viewModel.loadWeatherAsync()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            // Update width to match table view
            var frame = headerView.frame
            frame.size.width = tableView.bounds.width
            headerView.frame = frame
            
            // Then update height (as before)
            let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if frame.size.height != size.height {
                frame.size.height = size.height
                headerView.frame = frame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    // MARK: bindings setup
    private func setupBindings(){
        viewModel.$dailyForecasts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                //self?.rebuildRows()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$weatherData
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] weatherData in
                guard let self = self else {return }
                
                //update current weather view
                if let weather = self.viewModel.weatherData {
                    self.currentWeatherView.configure(with: weather)
                }
                //reload the forecast table
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$onError
            .receive(on: DispatchQueue.main)
            .compactMap{ $0 }
            .sink { [weak self] errorMessage in
                self?.currentWeatherView.showErrorMessage("Weather data unavailable")
            
            }
            .store(in: &cancellables)
        
        viewModel.$det_isLoading
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] det_isLoading in
                if det_isLoading {
                    self?.currentWeatherView.showLoading()
                } else {
                    self?.currentWeatherView.hideLoading()
                }
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Header View Creation

    private func createTableHeaderView() -> UIView {
        let headerView = UIView()
        //headerView.backgroundColor = .red
        
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
        
        
        //edw?? ayto to balame me allakse alla mou ta xalaei pali. des
        //headerView.translatesAutoresizingMaskIntoConstraints = false
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
        
        //adding the 2 cell types
        tableView.register(DailySummaryCell.self, forCellReuseIdentifier: DailySummaryCell.identifier)
        tableView.register(HourlyDetailCell.self, forCellReuseIdentifier: HourlyDetailCell.identifier)
        
        //  table view configurations
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
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
        var frame = headerView.frame
        frame.size.width = tableView.bounds.width
        headerView.frame = frame
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
        return viewModel.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.rows[indexPath.row]{
        case .summary(let idx, let forecast):
            let cell = tableView.dequeueReusableCell(withIdentifier: DailySummaryCell.identifier, for: indexPath) as! DailySummaryCell
            let isExpanded = viewModel.isExpanded(at: idx)
            cell.configure(with: forecast, isExpanded: isExpanded)
            cell.delegate = self
            return cell
        case .detail(_, let forecast):
            print("DEBUG: Detail cell for day \(forecast.date), hourly count: \(forecast.hourlyForecasts.count)")
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyDetailCell.identifier, for: indexPath) as! HourlyDetailCell
            cell.configure(with: forecast.hourlyForecasts, date: forecast.date)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return /*viewModel.isExpanded(at: indexPath.row) ? 220 :*/ 70
    }
    //reload only the selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*viewModel.toggleExpanded(at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)*/
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - DailySummaryCellDelegate
extension DetailViewController: DailySummaryCellDelegate {

    func didTapExpandButton(for cell: DailySummaryCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        //find originalday index from summary
        guard case .summary(let dayIndex, _) = viewModel.rows[indexPath.row] else { return }

        
        viewModel.toggleExpanded(at: dayIndex)
        //rebuildRows()
        tableView.reloadData()
        
        /*guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.toggleExpanded(at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)*/
    }
}
