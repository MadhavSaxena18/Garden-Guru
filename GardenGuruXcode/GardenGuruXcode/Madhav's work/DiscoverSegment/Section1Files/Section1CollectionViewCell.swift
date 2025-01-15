//
//  TopWinterPlantsCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit

class Section1CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var plantImage: UIImageView!
    
    
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var plantDescriptionLabel: UILabel!
    func updateDataOfSection1(with indexPath: IndexPath){
        plantImage.image = ExploreScreen.dataOfSection1InDiscoverSegment[indexPath.row].image
        
        plantNameLabel.text = ExploreScreen.dataOfSection1InDiscoverSegment[indexPath.row].plantName
        
        plantDescriptionLabel.text = ExploreScreen.dataOfSection1InDiscoverSegment[indexPath.row].plantDescription
        
    }
    

}
