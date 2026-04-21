//
//  HourlyForecastCell.swift
//  Cretan Beach Quality
//
//  Created by Admin on 21/4/26.
//

import UIKit

class HourlyForecastCell: UICollectionViewCell {
    
    static let identifier = "HourlyForecastCell"
    
    private let timeLabel = UILabel()
    private let iconImageView = UIImageView()
    private let tempLabel = UILabel()
    private let windLabel = UILabel()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = .secondaryLabel
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        
        tempLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        windLabel.font = .systemFont(ofSize: 10)
        windLabel.textColor = .secondaryLabel
        
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(tempLabel)
        stackView.addArrangedSubview(windLabel)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with forecast: HourlyForecast){
        timeLabel.text = forecast.time
        iconImageView.image = UIImage(systemName: forecast.imageName)
        tempLabel.text = "\(Int(forecast.temperature))°"
        windLabel.text = "\(Int(forecast.windSpeed))"
    }
    
        
        
        
    
}
