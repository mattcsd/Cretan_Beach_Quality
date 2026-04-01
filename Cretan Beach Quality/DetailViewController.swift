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
    
    private let weatherView = WeatherView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configureWaterQuality()
        
        if let weather = weatherData{
            // we got the data
            // already stopps in configure weatherView.hideLoading()
            weatherView.configure(with: weather)
        } else if let lat = latitude, let lon = longitude{
            // we have coordinates, fetch weather
            NetworkManager.shared.fetchWeather(latitude: lat, longitude: lon) { [weak self] result in
                guard let self = self else {return}
                
                DispatchQueue.main.async {
                    switch result {
                    case.success(let weather):
                        print("Weather loaded: \(weather.current.temperature)C")
                        self.weatherData = weather
                        self.weatherView.hideLoading()
                        
                        self.weatherView.configure(with: weather)
                    case .failure(let error):
                        print("Error fetching weather: \(error)")
                        self.weatherView.showError("Failed to fetch weather data.")
                    }
                }
            }
        } else{
            weatherView.showError("Weather data unavailable for this beach")
        }
                    
    }
    
    private func setupUI(){
        view.backgroundColor = .white // or .white
        
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
            weatherView
        ])
    
        weatherStack.axis = .vertical
        weatherStack.spacing = 12
        
        // main stack
        let mainStack = UIStackView(arrangedSubviews: [
            waterQualityStack,
            createDivider(),
            weatherStack
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
            
            weatherView.heightAnchor.constraint(greaterThanOrEqualToConstant: 280)
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
            inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Important for ISO dates
            inputFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Assuming the date is in UTC
            
            if let date = inputFormatter.date(from: dateString) {
                // Create a formatter for the output
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "MMM d, yyyy 'at' HH:mm:ss"
                outputFormatter.locale = Locale(identifier: "en_US")
                
                dateLabel.text = "Date: \(outputFormatter.string(from: date))"
            } else {
                // If parsing fails, show the original string
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
