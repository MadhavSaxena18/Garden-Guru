//
//  TopWinterPlantsCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit

class Section1CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var plantImage: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var plantDescriptionLabel: UILabel!
    func updateDataOfSection1(with indexPath: IndexPath){
        plantImage.image = ExploreScreen.dataOfSection1InDiscoverSegment[indexPath.row].image
        
        plantNameLabel.text = ExploreScreen.dataOfSection1InDiscoverSegment[indexPath.row].plantName
        
        plantDescriptionLabel.text = ExploreScreen.dataOfSection1InDiscoverSegment[indexPath.row].plantDescription
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.1
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        cardView.layer.shadowRadius = 4
        
    }
    

}
