//
//  HourlyForecastView.swift
//  Cretan Beach Quality
//
//  Created by Admin on 2/4/26.
//

import UIKit

class HourlyForecastView: UIView {
    private var forecasts: [HourlyForecast] = []
    
    //need var so we can change it
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 100)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        backgroundColor = .systemGray5
        layer.cornerRadius = 12
        
        // create flow layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 100) //fixed card size
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.identifier)
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
             collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
             collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
             collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
             collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
             //collectionView.heightAnchor.constraint(equalToConstant: 100)   // keep fixed height as before
         ])
     }
    
    func configure(with forecasts: [HourlyForecast], for date: Date){
        self.forecasts = forecasts
        collectionView.reloadData()
    }
}

// MARK: UICollectionView DataSource and Delegate
extension HourlyForecastView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        forecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCell.identifier, for: indexPath) as? HourlyForecastCell else {
            return UICollectionViewCell()
        }
        let forecast = forecasts[indexPath.row]
        cell.configure(with: forecast)
        return cell
    }
}
