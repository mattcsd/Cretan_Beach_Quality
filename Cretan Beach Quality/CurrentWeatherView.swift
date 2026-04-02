//
//  CurrentWeatherView.swift
//  Cretan Beach Quality
//
//  Created by Admin on 2/4/26.
//


import UIKit

class CurrentWeatherView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let weatherIcon = UIImageView()
    private let temperatureLabel = UILabel()
    private let windSpeedLabel = UILabel()
    private let windDirectionArrow = UIImageView()
    private let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [weatherIcon, temperatureLabel, windSpeedLabel, windDirectionArrow, timeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        temperatureLabel.font = .systemFont(ofSize: 36, weight: .bold)
        windSpeedLabel.font = .systemFont(ofSize: 14)
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
        
        windDirectionArrow.contentMode = .scaleAspectFit
        windDirectionArrow.tintColor = .label
        weatherIcon.contentMode = .scaleAspectFit
        weatherIcon.tintColor = .label
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            
            weatherIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            weatherIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 50),
            weatherIcon.heightAnchor.constraint(equalToConstant: 50),
            
            temperatureLabel.leadingAnchor.constraint(equalTo: weatherIcon.trailingAnchor, constant: 20),
            temperatureLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            
            windSpeedLabel.leadingAnchor.constraint(equalTo: temperatureLabel.leadingAnchor),
            windSpeedLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
            
            windDirectionArrow.leadingAnchor.constraint(equalTo: windSpeedLabel.trailingAnchor, constant: 8),
            windDirectionArrow.centerYAnchor.constraint(equalTo: windSpeedLabel.centerYAnchor),
            windDirectionArrow.widthAnchor.constraint(equalToConstant: 20),
            windDirectionArrow.heightAnchor.constraint(equalToConstant: 20),
            
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
        ])
    }
    
    func configure(with weather: WeatherResponse) {
        let current = weather.current
        
        containerView.backgroundColor = current.backgroundColor.withAlphaComponent(0.2)
        weatherIcon.image = UIImage(systemName: current.imageName)
        temperatureLabel.text = "\(Int(current.temperature))°C"
        windSpeedLabel.text = "Wind: \(Int(current.windSpeed)) km/h"
        
        let angle = CGFloat(current.windDirection) * .pi / 180
        windDirectionArrow.image = UIImage(systemName: "arrow.up")
        windDirectionArrow.transform = CGAffineTransform(rotationAngle: angle)
        
        timeLabel.text = current.formattedTime
    }
}
