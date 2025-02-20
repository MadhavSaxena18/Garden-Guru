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
    
//    func updateDataOfSection1InForMyPlantSegment(with indexPath: IndexPath){
//        imageViewForMyPlantSegment.image = ExploreScreen.dataOfSection1InforMyPlantSection[indexPath.row].image
//        descriptionLabelForMyPlantSegment.text = ExploreScreen.dataOfSection1InforMyPlantSection[indexPath.row].discription
//    }
    
    func configure(with disease: Diseases) {
//            titleLabel.text = disease.diseaseName
        if let firstImage = disease.diseaseImage.first {
                imageViewForMyPlantSegment.image = UIImage(named: firstImage)
            } else {
                imageViewForMyPlantSegment.image = UIImage(named: "placeholder") // Default image
            }
        descriptionLabelForMyPlantSegment.text = disease.diseaseName
        }

}
