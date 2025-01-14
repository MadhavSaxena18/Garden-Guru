//
//  CommonIssueCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit

class Section2CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageViewLabel: UIImageView!
    
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var plantDescriptionLabel: UILabel!
    func updateDataOfSection2(with indexPath: IndexPath){
        imageViewLabel.image = ExploreScreen.dataOfSection2[indexPath.row].image
        plantNameLabel.text = ExploreScreen.dataOfSection2[indexPath.row].plantName
        plantDescriptionLabel.text = ExploreScreen.dataOfSection2[indexPath.row].plantDescription
    }
   
    

}
