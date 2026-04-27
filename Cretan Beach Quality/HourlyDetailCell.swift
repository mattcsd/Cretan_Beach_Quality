//
//  HourlyDetailCell.swift
//  Cretan Beach Quality
//
//  Created by Admin on 27/4/26.
//
import UIKit

class HourlyDetailCell: UITableViewCell {
    static let identifier = "HourlyDetailCell"
        
    private let hourlyView = HourlyForecastView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(hourlyView)
        hourlyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hourlyView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hourlyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hourlyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hourlyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with forecasts: [HourlyForecast], date: Date){
        print("DEBUG: HourlyDetailCell received \(forecasts.count) forecasts")
        hourlyView.configure(with: forecasts, for: date)
    }
}
