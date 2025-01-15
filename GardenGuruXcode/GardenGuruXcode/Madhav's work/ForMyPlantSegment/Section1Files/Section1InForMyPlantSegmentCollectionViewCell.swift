//
//  Section1InForMyPlantSegmentCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 15/01/25.
//

import UIKit

class Section1InForMyPlantSegmentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageViewForMyPlantSegment: UIImageView!
    
    @IBOutlet weak var descriptionLabelForMyPlantSegment: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateDataOfSection1InForMyPlantSegment(with indexPath: IndexPath){
        imageViewForMyPlantSegment.image = ExploreScreen.dataOfSection1InforMyPlantSection[indexPath.row].image
        descriptionLabelForMyPlantSegment.text = ExploreScreen.dataOfSection1InforMyPlantSection[indexPath.row].discription
    }

}
