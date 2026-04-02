//
//  HourlyForecastView.swift
//  Cretan Beach Quality
//
//  Created by Admin on 2/4/26.
//


import UIKit

class HourlyForecastView: UIView {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private let contentView = UIView()
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray5
        layer.cornerRadius = 12
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        [scrollView, contentView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            scrollView.heightAnchor.constraint(equalToConstant: 100),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with forecasts: [HourlyForecast], for date: Date) {
        // clear any existing views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for forecast in forecasts {
            let hourView = createHourlyView(forecast)
            stackView.addArrangedSubview(hourView)
            hourView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        }
    }
    
    private func createHourlyView(_ forecast: HourlyForecast) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabel = UILabel()
        timeLabel.text = forecast.time
        timeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = .secondaryLabel
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: forecast.imageName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        
        let tempLabel = UILabel()
        tempLabel.text = "\(Int(forecast.temperature))°"
        tempLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
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
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return container
    }
}
