//
//  CommonIssueCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit

class Section2CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageViewLabel: UIImageView!
    
    @IBOutlet weak var diseaseNameLabel: UILabel!
    
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantDescriptionLabel: UILabel!
    func updateDataOfSection2(with indexPath: IndexPath){
        imageViewLabel.image = ExploreScreen.dataOfSection2InDiscoverSegment[indexPath.row].image
        diseaseNameLabel.text = ExploreScreen.dataOfSection2InDiscoverSegment[indexPath.row].diseaseName
//        plantNameLabel.text = ExploreScreen.dataOfSection2InDiscoverSegment[indexPath.row].plantName
        plantDescriptionLabel.text = ExploreScreen.dataOfSection2InDiscoverSegment[indexPath.row].plantDescription
        
    }
    
    func configure(with disease: Diseases) {
        if let firstImageName = disease.diseaseImage.first {
            imageViewLabel.image = UIImage(named: firstImageName) // Load image from name
        } else {
            imageViewLabel.image = UIImage(named: "placeholder") // Default placeholder image
        }

        diseaseNameLabel.text = disease.diseaseName
        
        
        let symptomsText = disease.diseaseSymptoms.joined(separator: ", ")
        plantDescriptionLabel.text = "Symptoms: \(symptomsText)"

    }

}
