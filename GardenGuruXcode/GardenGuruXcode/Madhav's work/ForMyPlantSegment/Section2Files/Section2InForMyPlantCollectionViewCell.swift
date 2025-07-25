//
//  Section2InForMyPlantCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 15/01/25.
//

import UIKit
import SDWebImage

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
    
    // Configure cell with a Fertilizer object
    func configure(with fertilizer: Fertilizer) {
        if let urlString = fertilizer.fertilizerImage?.trimmingCharacters(in: .whitespacesAndNewlines),
           let url = URL(string: urlString) {
            imageViewForMyPlantSegment.sd_setImage(with: url, placeholderImage: UIImage(named: "fertilizer_placeholder"))
        } else {
            imageViewForMyPlantSegment.image = UIImage(named: "fertilizer_placeholder")
        }
        descriptionOfImageInforMyPlantSegment.text = fertilizer.fertilizerName
    }
    
    // Keep the old method for backward compatibility if needed
    func configure(with fertilizerName: String) {
        imageViewForMyPlantSegment.image = UIImage(named: fertilizerName)
        descriptionOfImageInforMyPlantSegment.text = fertilizerName
    }

    

}
