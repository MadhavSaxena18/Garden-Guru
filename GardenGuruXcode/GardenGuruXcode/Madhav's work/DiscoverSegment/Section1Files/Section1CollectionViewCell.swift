//
//  TopWinterPlantsCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit
import SDWebImage

class Section1CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantDescriptionLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    var plant: DataOfSection1InDicoverSegment? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        
        // Add explicit constraints for labels to ensure consistent padding
        plantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        plantDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Constraints for plantNameLabel
            plantNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            plantNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            plantNameLabel.topAnchor.constraint(equalTo: plantImage.bottomAnchor, constant: 8),
            
            // Constraints for plantDescriptionLabel
            plantDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            plantDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            plantDescriptionLabel.topAnchor.constraint(equalTo: plantNameLabel.bottomAnchor, constant: 4)
        ])
    }
    
    private func setupUI() {
        // Configure cell appearance
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = .white
        
        // Configure image view
        plantImage.contentMode = .scaleAspectFill
        plantImage.clipsToBounds = true
        
        // Configure labels
        plantNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        plantDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        plantDescriptionLabel.numberOfLines = 2
    }
    
    private func updateUI() {
        guard let plant = plant else { return }
        
        // Load image from URL using SDWebImage
        if let imageURL = URL(string: plant.image) {
            plantImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder_plant"))
        } else {
            plantImage.image = UIImage(named: "placeholder_plant")
        }
        
        plantNameLabel.text = plant.plantName
        plantDescriptionLabel.text = plant.plantDescription
        }
}

