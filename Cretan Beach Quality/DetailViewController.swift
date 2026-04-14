//
//  DetailViewController.swift
//  Cretan Beach Quality
//
//  Created by Admin on 30/3/26.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - ViewModel (injected from ViewController)
    var viewModel: DetailViewModel! // the ! is needed? yes compiler error
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let currentWeatherView = CurrentWeatherView()
    private var dailyTableView = SelfSizingTableView()
    
    
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
        viewModel.loadWeather()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // force the table to update its height based on content
        dailyTableView.invalidateIntrinsicContentSize()
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
            self.dailyTableView.reloadData()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            print("Weather error: \(errorMessage)")
            // show simple error label inside the weather view
            let errorLabel = UILabel()
            errorLabel.text = "Weather data unavailable"
            errorLabel.textColor = .secondaryLabel
            errorLabel.textAlignment = .center
            self?.currentWeatherView.addSubview(errorLabel)
            self?.currentWeatherView.showErrorMessage(errorMessage)
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
          if isLoading {
              self?.currentWeatherView.showLoading()
          } else {
              self?.currentWeatherView.hideLoading()
          }
        }
    }
    
    
    private func setupDailyForecastTable() {
        dailyTableView.delegate = self
        dailyTableView.dataSource = self
        dailyTableView.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.identifier)
        dailyTableView.separatorStyle = .none
        dailyTableView.backgroundColor = .clear
        dailyTableView.isScrollEnabled = false
        
        // enable automatic row height
        dailyTableView.rowHeight = UITableView.automaticDimension
        dailyTableView.estimatedRowHeight = 70
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Style labels
        coastLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        regionLabel.font = .systemFont(ofSize: 16)
        ecoliLabel.font = .systemFont(ofSize: 16)
        enterococciLabel.font = .systemFont(ofSize: 16)
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        
        // Water quality stack
        let waterQualityStack = UIStackView(arrangedSubviews: [
            waterQualityTitle, coastLabel, regionLabel, ecoliLabel, enterococciLabel, dateLabel
        ])
        waterQualityStack.axis = .vertical
        waterQualityStack.spacing = 8
        
        // Weather stack
        let weatherStack = UIStackView(arrangedSubviews: [currentWeatherView])
        weatherStack.axis = .vertical
        weatherStack.spacing = 12
        
        // Daily forecast title
        let dailyTitleLabel = UILabel()
        dailyTitleLabel.text = "7-Day Forecast"
        dailyTitleLabel.font = .boldSystemFont(ofSize: 18)
        
        // Setup table view
        dailyTableView.delegate = self
        dailyTableView.dataSource = self
        dailyTableView.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.identifier)
        dailyTableView.separatorStyle = .none
        dailyTableView.backgroundColor = .clear
        dailyTableView.isScrollEnabled = false
        dailyTableView.rowHeight = UITableView.automaticDimension
        dailyTableView.estimatedRowHeight = 70
        let dailyStack = UIStackView(arrangedSubviews: [dailyTitleLabel, dailyTableView])
        dailyStack.axis = .vertical
        dailyStack.spacing = 12
        
        // Main stack
        let mainStack = UIStackView(arrangedSubviews: [
            waterQualityStack,
            createDivider(),
            weatherStack,
            dailyStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("--- DEBUG START: Row Clicked ---")
        print("DEBUG: [Click] User tapped row: \(indexPath.row)")
        viewModel.toggleExpanded(at: indexPath.row)
        //tableView.reloadRows(at: [indexPath], with: .automatic)
        //tableView.beginUpdates()
        //tableView.endUpdates()
        tableView.reloadRows(at: [indexPath], with: .fade)
        print("--- DEBUG END ---")
        
    }
}

// MARK: - DailyForecastCellDelegate
extension DetailViewController: DailyForecastCellDelegate {

    func didTapExpandButton(for cell: DailyForecastCell) {
        guard let indexPath = dailyTableView.indexPath(for: cell) else { return }
        viewModel.toggleExpanded(at: indexPath.row)
        dailyTableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Self-sizing UITableView

// A UITableView that reports its contentSize as its intrinsicContentSize.

// Standard UITableView has no intrinsicContentSize, which causes problems when
// placed inside a UIStackView - the stack view collapses the table to zero height.

//This subclass overrides intrinsicContentSize to return the actual content height,
// allowing the table to properly size itself within a stack view while still
// supporting dynamic cell heights (like expanded/collapsed forecast cells).

private class SelfSizingTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            // every time the content size changes,cells are added/removed/expanded
            // tell Auto -ayout that intrinsic size has changed
            invalidateIntrinsicContentSize() }
    }
    override var intrinsicContentSize: CGSize {
        //ensure layout is up to date before calculating height
        layoutIfNeeded()
        //return the current content height, but no intrinsic width constraints will do that
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
