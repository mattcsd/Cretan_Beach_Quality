//
//  WeatherView.swift
//  Cretan Beach Quality
//
//  Created by Admin on 31/3/26.
//

import UIKit

class WeatherView: UIView {
    
    // MARK: - Current Weather Views
    private let currentWeatherContainer = UIView()
    private let weatherIconImageView = UIImageView()
    private let temperatureLabel = UILabel()
    private let windSpeedLabel = UILabel()
    private let windDirectionArrow = UIImageView()
    private let timeLabel = UILabel()
    
    // MARK: - Hourly Forecast Views
    private let hourlyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hourly Forecast"
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let hourlyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let errorLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Setup current weather container
        currentWeatherContainer.layer.cornerRadius = 12
        currentWeatherContainer.layer.masksToBounds = true
        
        // Configure labels
        temperatureLabel.font = .systemFont(ofSize: 36, weight: .bold)
        windSpeedLabel.font = .systemFont(ofSize: 14)
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
        
        // Configure wind direction arrow
        windDirectionArrow.contentMode = .scaleAspectFit
        windDirectionArrow.tintColor = .label
        
        // Configure weather icon
        weatherIconImageView.contentMode = .scaleAspectFit
        weatherIconImageView.tintColor = .label
        
        // Configure error label
        errorLabel.textAlignment = .center
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        // Add subviews
        addSubview(currentWeatherContainer)
        addSubview(hourlyTitleLabel)
        addSubview(scrollView)
        addSubview(loadingIndicator)
        addSubview(errorLabel)
        
        scrollView.addSubview(hourlyStackView)
        
        currentWeatherContainer.addSubview(weatherIconImageView)
        currentWeatherContainer.addSubview(temperatureLabel)
        currentWeatherContainer.addSubview(windSpeedLabel)
        currentWeatherContainer.addSubview(windDirectionArrow)
        currentWeatherContainer.addSubview(timeLabel)
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        [currentWeatherContainer, hourlyTitleLabel, scrollView, loadingIndicator, errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [weatherIconImageView, temperatureLabel, windSpeedLabel, windDirectionArrow, timeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        hourlyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Current weather container
            currentWeatherContainer.topAnchor.constraint(equalTo: topAnchor),
            currentWeatherContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            currentWeatherContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            currentWeatherContainer.heightAnchor.constraint(equalToConstant: 120),
            
            // Weather icon
            weatherIconImageView.leadingAnchor.constraint(equalTo: currentWeatherContainer.leadingAnchor, constant: 20),
            weatherIconImageView.centerYAnchor.constraint(equalTo: currentWeatherContainer.centerYAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 50),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Temperature
            temperatureLabel.leadingAnchor.constraint(equalTo: weatherIconImageView.trailingAnchor, constant: 20),
            temperatureLabel.topAnchor.constraint(equalTo: currentWeatherContainer.topAnchor, constant: 20),
            
            // Wind speed
            windSpeedLabel.leadingAnchor.constraint(equalTo: temperatureLabel.leadingAnchor),
            windSpeedLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
            
            // Wind direction arrow
            windDirectionArrow.leadingAnchor.constraint(equalTo: windSpeedLabel.trailingAnchor, constant: 8),
            windDirectionArrow.centerYAnchor.constraint(equalTo: windSpeedLabel.centerYAnchor),
            windDirectionArrow.widthAnchor.constraint(equalToConstant: 20),
            windDirectionArrow.heightAnchor.constraint(equalToConstant: 20),
            
            // Time
            timeLabel.trailingAnchor.constraint(equalTo: currentWeatherContainer.trailingAnchor, constant: -20),
            timeLabel.bottomAnchor.constraint(equalTo: currentWeatherContainer.bottomAnchor, constant: -12),
            
            // Hourly forecast section
            hourlyTitleLabel.topAnchor.constraint(equalTo: currentWeatherContainer.bottomAnchor, constant: 24),
            hourlyTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: hourlyTitleLabel.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 120),
            
            hourlyStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hourlyStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
            hourlyStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
            hourlyStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hourlyStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Error label
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with weather: WeatherResponse) {
        loadingIndicator.stopAnimating()
        errorLabel.isHidden = true
        
        let current = weather.current
        
        // Debug: Print hourly data
            print("🌤️ HOURLY FORECAST DEBUG:")
            print("   Total hourly entries: \(weather.hourly.time.count)")
            print("   Times: \(weather.hourly.time)")
            print("   Temperatures: \(weather.hourly.temperature)")
            
            let forecasts = weather.hourly.getHourlyForecast(upTo: 8)
            print("   Filtered forecasts count: \(forecasts.count)")
            for forecast in forecasts {
                print("   \(forecast.time): \(forecast.temperature)°C")
            }
            
        
        // Configure background color based on temperature
        currentWeatherContainer.backgroundColor = current.backgroundColor.withAlphaComponent(0.2)
        
        // Configure weather icon
        weatherIconImageView.image = UIImage(systemName: current.imageName)
        
        // Configure temperature
        temperatureLabel.text = "\(Int(current.temperature))°C"
        
        // Configure wind
        windSpeedLabel.text = "Wind: \(Int(current.windSpeed)) km/h"
        
        // Configure wind direction arrow
        let angle = CGFloat(current.windDirection) * .pi / 180
        windDirectionArrow.image = UIImage(systemName: "arrow.up")
        windDirectionArrow.transform = CGAffineTransform(rotationAngle: angle)
        
        // Configure time
        timeLabel.text = current.formattedTime
        
        // Configure hourly forecast
        configureHourlyForecast(weather.hourly.getHourlyForecast(upTo: 8))
    }
    
    private func configureHourlyForecast(_ forecasts: [HourlyForecast]) {
        print("📊 Configuring hourly forecast with \(forecasts.count) items")
        
        // Clear existing views
        hourlyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for forecast in forecasts {
            print("   Adding: \(forecast.time) - \(forecast.temperature)°C")
            let hourView = createHourlyForecastView(forecast)
            hourlyStackView.addArrangedSubview(hourView)
        }
        
        // If no forecasts, show a message
        if forecasts.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No hourly data available"
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.font = .systemFont(ofSize: 14)
            emptyLabel.textAlignment = .center
            hourlyStackView.addArrangedSubview(emptyLabel)
        }
    }
    
    private func createHourlyForecastView(_ forecast: HourlyForecast) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabel = UILabel()
        timeLabel.text = forecast.time
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: forecast.imageName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        
        let tempLabel = UILabel()
        tempLabel.text = "\(Int(forecast.temperature))°"
        tempLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        let windLabel = UILabel()
        windLabel.text = "\(Int(forecast.windSpeed))"
        windLabel.font = .systemFont(ofSize: 10)
        windLabel.textColor = .secondaryLabel
        
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(tempLabel)
        stackView.addArrangedSubview(windLabel)
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return container
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        errorLabel.isHidden = true
        currentWeatherContainer.isHidden = true
        hourlyTitleLabel.isHidden = true
        scrollView.isHidden = true
    }
    
    func showError(_ message: String) {
        loadingIndicator.stopAnimating()
        errorLabel.text = message
        errorLabel.isHidden = false
        currentWeatherContainer.isHidden = true
        hourlyTitleLabel.isHidden = true
        scrollView.isHidden = true
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        currentWeatherContainer.isHidden = false
        hourlyTitleLabel.isHidden = false
        scrollView.isHidden = false
    }
}
