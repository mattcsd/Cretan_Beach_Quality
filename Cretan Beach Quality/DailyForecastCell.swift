//
//  DailyForecastCell.swift
//  Cretan Beach Quality
//
//  Created by Admin on 1/4/26.
//


import UIKit

// listener - "messenger-ballboy" if expanded
protocol DailyForecastCellDelegate: AnyObject {
    func didTapExpandButton(for cell: DailyForecastCell)
}

class DailyForecastCell: UITableViewCell {
    static let identifier = "DailyForecastCell"
    
    weak var delegate: DailyForecastCellDelegate?

    private var hourlyForecastView: HourlyForecastView?
    private var isExpanded = false
    
    // container to fill days in
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    // misc elements for EACH day
    private let weatherIcon = UIImageView()
    private let dayLabel = UILabel()
    private let tempLabel = UILabel()
    private let windLabel = UILabel()
    private let expandButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [weatherIcon, dayLabel, tempLabel, windLabel, expandButton].forEach {
            // again using auto layout
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        weatherIcon.contentMode = .scaleAspectFit
        weatherIcon.tintColor = .label
        
        // make day label smaller because of overlapping
        dayLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dayLabel.numberOfLines = 1
        dayLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        tempLabel.font = .systemFont(ofSize: 16, weight: .medium)
        windLabel.font = .systemFont(ofSize: 12)
        windLabel.textColor = .secondaryLabel
        
        expandButton.setTitle("▼", for: .normal)
        expandButton.titleLabel?.font = .systemFont(ofSize: 12)
        expandButton.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),

            // anchor the icon to the TOP of the container (not centerY of container).
            // verything else centers relative to the icon, not the container.
            // this breaks the circular dependency that prevents automaticDimension from working.
            weatherIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            weatherIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 11),
            weatherIcon.widthAnchor.constraint(equalToConstant: 30),
            weatherIcon.heightAnchor.constraint(equalToConstant: 30),

            dayLabel.leadingAnchor.constraint(equalTo: weatherIcon.trailingAnchor, constant: 10),
            dayLabel.centerYAnchor.constraint(equalTo: weatherIcon.centerYAnchor),
            dayLabel.trailingAnchor.constraint(lessThanOrEqualTo: tempLabel.leadingAnchor, constant: -8),

            tempLabel.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor, constant: -8),
            tempLabel.centerYAnchor.constraint(equalTo: weatherIcon.centerYAnchor),

            windLabel.trailingAnchor.constraint(equalTo: tempLabel.leadingAnchor, constant: -8),
            windLabel.centerYAnchor.constraint(equalTo: weatherIcon.centerYAnchor),

            expandButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            expandButton.centerYAnchor.constraint(equalTo: weatherIcon.centerYAnchor),
            expandButton.widthAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    // listener for expand click
    @objc private func expandButtonTapped() {
        delegate?.didTapExpandButton(for: self)
    }
    
    func configure(with forecast: DailyForecast, isExpanded: Bool) {
        self.isExpanded = isExpanded
        
        weatherIcon.image = UIImage(systemName: forecast.imageName)
        dayLabel.text = forecast.formattedDate
        tempLabel.text = "\(Int(forecast.middayTemperature))°C"
        windLabel.text = "\(Int(forecast.maxWindSpeed)) km/h"
        expandButton.setTitle(isExpanded ? "▲" : "▼", for: .normal)
        
        if isExpanded {
            if hourlyForecastView == nil {
                hourlyForecastView = HourlyForecastView()
                hourlyForecastView?.translatesAutoresizingMaskIntoConstraints = false
                
                containerView.addSubview(hourlyForecastView!) // maybe handle this force unwrap differently, maybe with if let view = hourlyForecastView
                
                let bottomAnchor = hourlyForecastView!.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
                bottomAnchor.priority = UILayoutPriority(999) // meaning almost required, but can break if necessary
                
                NSLayoutConstraint.activate([
                    hourlyForecastView!.topAnchor.constraint(equalTo: weatherIcon.bottomAnchor, constant: 12),
                    hourlyForecastView!.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                    hourlyForecastView!.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                    bottomAnchor
                ])
            }
            hourlyForecastView?.configure(with: forecast.hourlyForecasts, for: forecast.date)
            hourlyForecastView?.isHidden = false
        } else {
            //BATCH UPDATE
            //hourlyForecastView?.isHidden = true // messes up the view. afinei keno to expanded hourly
            //temp fix
            hourlyForecastView?.removeFromSuperview()
            hourlyForecastView = nil // keeping memory clear. not efficient though
        }
        
        //force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
