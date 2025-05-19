//
//  Section1InForMyPlantSegmentCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 15/01/25.
//

import UIKit
import SDWebImage

class Section1InForMyPlantSegmentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageViewForMyPlantSegment: UIImageView!
    
    @IBOutlet weak var descriptionLabelForMyPlantSegment: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Image view setup
        imageViewForMyPlantSegment.contentMode = .scaleAspectFill
        imageViewForMyPlantSegment.clipsToBounds = true
        imageViewForMyPlantSegment.layer.cornerRadius = 12
    }
    
//    func updateDataOfSection1InForMyPlantSegment(with indexPath: IndexPath){
//        imageViewForMyPlantSegment.image = ExploreScreen.dataOfSection1InforMyPlantSection[indexPath.row].image
//        descriptionLabelForMyPlantSegment.text = ExploreScreen.dataOfSection1InforMyPlantSection[indexPath.row].discription
//    }
    
    func configure(with disease: Diseases) {
        if let imageUrlString = disease.diseaseImage, let url = URL(string: imageUrlString) {
            print("🖼️ Loading disease image from URL: \(imageUrlString)")
            imageViewForMyPlantSegment.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")) { image, error, cacheType, url in
                if let error = error {
                    print("❌ Error loading disease image: \(error)")
                } else {
                    print("✅ Successfully loaded disease image from: \(url?.absoluteString ?? "unknown URL")")
                }
            }
            } else {
            print("❌ No disease image URL provided or invalid URL")
            imageViewForMyPlantSegment.image = UIImage(named: "placeholder")
            }
        
        descriptionLabelForMyPlantSegment.text = disease.diseaseName
        }

}
