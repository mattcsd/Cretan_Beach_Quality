//
//  DetailViewController.swift
//  Cretan Beach Quality
//
//  Created by Admin on 30/3/26.
//

import UIKit

class DetailViewController: UIViewController {

    var item: WaterQuality? //to hold the selected data
    var weatherData: WeatherResponse?
    
    var latitude: Double?
    var longitude: Double?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var dailyForecasts: [DailyForecast] = []
    private var expandedIndex: Int?
    private var dailyTableView = SelfSizingTableView()
    
    
    //water quality section
    private let waterQualityTitle: UILabel = {
        let label = UILabel()
        label.text = "Water Quality Information"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let coastLabel = UILabel()
    private let regionLabel = UILabel()
    private let ecoliLabel = UILabel()
    private let enterococciLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let currentWeatherView = CurrentWeatherView()
    //private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureWaterQuality()
        
        if let weather = weatherData {
            currentWeatherView.configure(with: weather)
            self.dailyForecasts = weather.getDailyForecasts()
            setupDailyForecastTable()
            dailyTableView.reloadData()
        } else if let lat = latitude, let lon = longitude {
            NetworkManager.shared.fetchWeather(latitude: lat, longitude: lon) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let weather):
                        print("Weather loaded: \(weather.current.temperature)°C")
                        self.weatherData = weather
                        self.currentWeatherView.configure(with: weather)
                        self.dailyForecasts = weather.getDailyForecasts()
                        self.setupDailyForecastTable()
                        self.dailyTableView.reloadData()
                        
                    case .failure(let error):
                        print("Error fetching weather: \(error)")
                    }
                }
            }
        } else {
            // show error state for current weather
            let errorLabel = UILabel()
            errorLabel.text = "Weather data unavailable"
            errorLabel.textColor = .secondaryLabel
            errorLabel.textAlignment = .center
            currentWeatherView.addSubview(errorLabel)
        }
    }
    
    private func setupDailyForecastTable() {
        dailyTableView.delegate = self
        dailyTableView.dataSource = self
        dailyTableView.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.identifier)
        dailyTableView.separatorStyle = .none
        dailyTableView.backgroundColor = .clear
        dailyTableView.isScrollEnabled = false
        
        // Enable automatic row height
        dailyTableView.rowHeight = UITableView.automaticDimension
        dailyTableView.estimatedRowHeight = 70
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // force the table to update its height based on content
        dailyTableView.invalidateIntrinsicContentSize()
    }
    
    /*private func toggleExpanded(at index: Int) {
        if expandedIndex == index {
            expandedIndex = nil
        } else {
            expandedIndex = index
        }
        
        // reload the row to animate height change
        dailyTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        
        //force the table to update its intrinsic content size
        DispatchQueue.main.async {
            self.dailyTableView.invalidateIntrinsicContentSize()
            self.view.layoutIfNeeded()
        }
    }*/
    private func toggleExpanded(at index: Int) {
        let oldIndex = expandedIndex
        
        if expandedIndex == index {
            expandedIndex = nil
        } else {
            expandedIndex = index
        }
        
        // Smoothly update the heights without "restarting" the cell instances
        dailyTableView.performBatchUpdates({
            var rowsToReload = [IndexPath(row: index, section: 0)]
            if let old = oldIndex, old != index {
                rowsToReload.append(IndexPath(row: old, section: 0))
            }
            // This is better than reloadRows for expanded states
            dailyTableView.reloadRows(at: rowsToReload, with: .fade)
        }, completion: { _ in
            // Keep the table height in sync with the ScrollView
            self.dailyTableView.invalidateIntrinsicContentSize()
            self.view.layoutIfNeeded()
        })
    }
    
    private func setupUI(){
        view.backgroundColor = .white // or .background
        
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
        
        // configure labels
        coastLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        regionLabel.font = .systemFont(ofSize: 16)
        ecoliLabel.font = .systemFont(ofSize: 16)
        enterococciLabel.font = .systemFont(ofSize: 16)
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        
        // create water qaulity stack
        let waterQualityStack = UIStackView(arrangedSubviews: [
            waterQualityTitle,
            coastLabel,
            regionLabel,
            ecoliLabel,
            enterococciLabel,
            dateLabel
        ])
        waterQualityStack.axis = .vertical
        waterQualityStack.spacing = 8
        
        // crete weather section stack
        let weatherStack = UIStackView(arrangedSubviews: [
            currentWeatherView
        ])
    
        weatherStack.axis = .vertical
        weatherStack.spacing = 12
        
        // create daily stack with title
        let dailyTitleLabel = UILabel()
        dailyTitleLabel.text = "7-Day Forecast"
        dailyTitleLabel.font = .boldSystemFont(ofSize: 18)

        let dailyStack = UIStackView(arrangedSubviews: [
            dailyTitleLabel,
            dailyTableView
        ])
        dailyStack.axis = .vertical
        dailyStack.spacing = 12

        // main stack
        let mainStack = UIStackView(arrangedSubviews: [
            waterQualityStack,
            createDivider(),
            weatherStack,
            createDivider(),
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
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    
    }
    
    private func createDivider () -> UIView {
        let divider = UIView()
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.backgroundColor = .systemGray4
        return divider
    }
    
    private func configureWaterQuality(){
        guard let item = item else { return }
        coastLabel.text = "Coast: \(item.coast ?? "Unknown")"
        regionLabel.text = "Region: \(item.perunit ?? "N/A")"
        ecoliLabel.text = "E. coli: \(item.ecoli ?? "N/A")"
        enterococciLabel.text = "Enterococci: \(item.intenterococci ?? "N/A")"
        
        // date formatting einai se iso kai mporw na to customarw poly
        // Format the ISO 8601 date string to a human-readable format
        if let dateString = item.sampleTimestamp, !dateString.isEmpty {
            // Create a formatter to parse the input date string
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")
            inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            if let date = inputFormatter.date(from: dateString) {
                // create a formatter for the output
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "MMM d, yyyy 'at' HH:mm:ss"
                outputFormatter.locale = Locale(identifier: "en_US")
                
                dateLabel.text = "Date: \(outputFormatter.string(from: date))"
            } else {
                // if parsing fails, show the original string
                dateLabel.text = "Date: \(dateString)"
            }
        } else {
            dateLabel.text = "Date: N/A"
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
// MARK: - UITableView Delegate & DataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG: [Table Count] System asking for row count. Returning: \(dailyForecasts.count)")
        return dailyForecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastCell.identifier, for: indexPath) as? DailyForecastCell else {
            return UITableViewCell()
        }
        
        let forecast = dailyForecasts[indexPath.row]
        let isExpanded = expandedIndex == indexPath.row
        cell.configure(with: forecast, isExpanded: isExpanded)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return expandedIndex == indexPath.row ? 220 : 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("--- DEBUG START: Row Clicked ---")
        print("DEBUG: [Click] User tapped row: \(indexPath.row)")
        toggleExpanded(at: indexPath.row)
        //tableView.reloadRows(at: [indexPath], with: .automatic)
        //tableView.beginUpdates()
        //tableView.endUpdates()
            
        print("--- DEBUG END ---")
        
    }
}

// MARK: - DailyForecastCellDelegate
extension DetailViewController: DailyForecastCellDelegate {

    func didTapExpandButton(for cell: DailyForecastCell) {
        guard let indexPath = dailyTableView.indexPath(for: cell) else { return }
        toggleExpanded(at: indexPath.row)
        dailyTableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Self-sizing UITableView
// UITableView has no intrinsicContentSize by default, so inside a UIStackView
// it collapses to zero height. This subclass fixes that by reporting contentSize.
private class SelfSizingTableView: UITableView {
    override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
