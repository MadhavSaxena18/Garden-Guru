//
//  TopWinterPlantsCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit

class Section1CollectionViewCell: UICollectionViewCell {

    var dataController: DataControllerGG?
    @IBOutlet weak var plantImage: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var plantDescriptionLabel: UILabel!
    
    private let weatherService = WeatherService()
    private let locationManager = LocationManager()
    private var currentWeather: WeatherService.WeatherResponse?

//    override func awakeFromNib() {
//        <#code#>
//    }

    

    func updateDataOfSection1(with indexPath: IndexPath){
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.9
//        cardView.layer.shadowOffset = CGSize(width: 4, height: 4)
//        cardView.layer.shadowRadius = 50
//        cardView.layer.masksToBounds = false
        
       // plantImage.image = dataController?.plants[indexPath.row].
        plantImage.image = ExploreScreen.dataOfSection1InDiscoverSegment[indexPath.row].image
       // plantImage.image = dataController?.plants[indexPath.row].plantImage
        plantNameLabel.text = ExploreScreen.dataOfSection1InDiscoverSegment[indexPath.row].plantName
        
        plantDescriptionLabel.text = ExploreScreen.dataOfSection1InDiscoverSegment[indexPath.row].plantDescription
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.1
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        cardView.layer.shadowRadius = 4
        
    }
    
    func configure(with plant: Plant) {
//            titleLabel.text = plant.plantName
//            imageView.image = UIImage(named: plant.plantImage.first ?? "placeholder")
        plantNameLabel.text = plant.plantName
        plantImage.image = UIImage(named: plant.plantImage.first ?? "placeholder")
        plantDescriptionLabel.text = plant.plantDescription
        }
    

}

