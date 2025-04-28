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
        
        // Add fixed height constraint to image view
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        plantImageView.heightAnchor.constraint(equalToConstant: 250).isActive = true  // Adjust this value as needed
    }
    
    private func setupUI() {
        // Content view setup
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
        // Image view setup
        plantImageView.contentMode = .scaleAspectFill
        plantImageView.clipsToBounds = true
        plantImageView.layer.cornerRadius = 20
        
        // Labels setup
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 0
        
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        
        // Cell shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        layer.cornerRadius = 20
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update shadow path for better performance
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }
    
    func configure(with plant: Plant) {
        nameLabel.text = plant.plantName
        descriptionLabel.text = plant.plantDescription
        
        if let plantImages = plant.plantImage, let firstImage = plantImages.first {
            plantImageView.image = UIImage(named: String(firstImage))
        } else {
            plantImageView.image = UIImage(named: "placeholder_plant")
        }
        
        // Ensure labels are visible and properly laid out
        nameLabel.setNeedsLayout()
        descriptionLabel.setNeedsLayout()
        layoutIfNeeded()
    }
    
    func configureForDisease(with disease: Diseases) {
        nameLabel.text = disease.diseaseName
        
        // Format symptoms with bullet points
        if let symptoms = disease.diseaseSymptoms {
            let symptomsText = symptoms.map { "• \($0)" }.joined(separator: "\n")
        descriptionLabel.text = symptomsText
        } else {
            descriptionLabel.text = "No symptoms available"
        }
        
        if let diseaseImages = disease.diseaseImage, let firstImage = diseaseImages.first {
            plantImageView.image = UIImage(named: String(firstImage))
        } else {
            plantImageView.image = UIImage(named: "placeholder_disease")
        }
        
        // Ensure labels are visible and properly laid out
        nameLabel.setNeedsLayout()
        descriptionLabel.setNeedsLayout()
        layoutIfNeeded()
    }
    
    // Update the method signature to accept a Fertilizer object
    func configureForFertilizer(with fertilizer: Fertilizer) {
        // Configure the cell with fertilizer data
        nameLabel.text = fertilizer.fertilizerName
        descriptionLabel.text = fertilizer.fertilizerDescription ?? "No description available"
        
        // Load the fertilizer image
        if let imageName = fertilizer.fertilizerImage {
            plantImageView.image = UIImage(named: imageName) ?? UIImage(named: "fertilizer_placeholder")
        } else {
            plantImageView.image = UIImage(named: "fertilizer_placeholder")
        }
        
        // Ensure labels are visible and properly laid out
        nameLabel.setNeedsLayout()
        descriptionLabel.setNeedsLayout()
        layoutIfNeeded()
    }
    
}
