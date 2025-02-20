//
//  AllDataCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 19/02/25.
//

import UIKit

class AllDataCollectionViewCell: UICollectionViewCell {

        // MARK: - Outlets
        @IBOutlet weak var plantImageView: UIImageView!
        @IBOutlet weak var nameLabel: UILabel!
        @IBOutlet weak var descriptionLabel: UILabel!
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }
        
        private func setupUI() {
            // Setup content view
            contentView.layer.cornerRadius = 12
            contentView.layer.masksToBounds = true
            contentView.backgroundColor = .white
            
            // Setup shadow
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 8
            layer.shadowOpacity = 0.15
            layer.masksToBounds = false
            
            // Add some padding around the cell
            layer.cornerRadius = 12
            
            // Setup image view
            plantImageView.contentMode = .scaleAspectFill
            plantImageView.clipsToBounds = true
            plantImageView.layer.cornerRadius = 12
            
            // Setup labels
            nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
            descriptionLabel.font = .systemFont(ofSize: 14)
            descriptionLabel.numberOfLines = 2
            descriptionLabel.textColor = .darkGray
            
            // Add a background view for better shadow visibility
            backgroundColor = .clear
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Update shadow path for better performance
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        }
        
    func configure(with plant: Plant) {
        nameLabel.text = plant.plantName
        descriptionLabel.text = plant.plantDescription
        if let imageName = plant.plantImage.first {
            plantImageView.image = UIImage(named: imageName)
        }
    }
    
    func configureForDisease(with disease: Diseases) {
        nameLabel.text = disease.diseaseName
        descriptionLabel.text = disease.diseaseSymptoms.joined(separator: "\n")
        if let imageName = disease.diseaseImage.first {
            plantImageView.image = UIImage(named: imageName)
        }
    }

}
