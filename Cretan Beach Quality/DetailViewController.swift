//
//  DetailViewController.swift
//  Cretan Beach Quality
//
//  Created by Admin on 30/3/26.
//

import UIKit

class DetailViewController: UIViewController {

    var item: WaterQuality? //to hold the selected data
    
    private let coastLabel = UILabel()
    private let regionLabel = UILabel()
    private let ecoliLabel = UILabel()
    private let enterococciLabel = UILabel()
    private let dateLabel = UILabel()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configure()
    }
    
    private func setupUI(){
        view.backgroundColor = .white // or .white

        let stackView = UIStackView(arrangedSubviews: [
            coastLabel,
            regionLabel,
            ecoliLabel,
            enterococciLabel,
            dateLabel
        ])
        coastLabel.textColor = .label
        regionLabel.textColor = .label
        ecoliLabel.textColor = .label
        enterococciLabel.textColor = .label
        dateLabel.textColor = .label

        // adjusting fonts
        coastLabel.font = .boldSystemFont(ofSize: 18)
        regionLabel.font = .systemFont(ofSize: 16)
        ecoliLabel.font = .systemFont(ofSize: 16)
        enterococciLabel.font = .systemFont(ofSize: 16)
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
            ])
        
    }
    
    private func configure(){
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
