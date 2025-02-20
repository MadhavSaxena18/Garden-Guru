//
//  Section2InForMyPlantCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 15/01/25.
//

import UIKit

class Section2InForMyPlantCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageViewForMyPlantSegment: UIImageView!
    
   
    @IBOutlet weak var descriptionOfImageInforMyPlantSegment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
//    func updateDataOfSection2InForMyPlantSegment(with indexPath: IndexPath){
//        imageViewForMyPlantSegment.image = ExploreScreen.dataOfSection2InforMyPlantSection[indexPath.row].image
//        descriptionOfImageInforMyPlantSegment.text = ExploreScreen.dataOfSection2InforMyPlantSection[indexPath.row].discription
//    }
    
    func configure(with fertilizer: String) {
//            titleLabel.text = fertilizer
        imageViewForMyPlantSegment.image = UIImage(named: fertilizer)
        descriptionOfImageInforMyPlantSegment.text = fertilizer
        }

    

}
