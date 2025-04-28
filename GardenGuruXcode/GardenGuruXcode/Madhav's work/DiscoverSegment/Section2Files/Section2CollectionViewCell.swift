//
//  CommonIssueCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit
import SDWebImage

class Section2CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageViewLabel: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantDescriptionLabel: UILabel!
    
    var disease: DataOfSection2InDiscoverSegment? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Configure cell appearance
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = .white
        
        // Configure image view
        imageViewLabel.contentMode = .scaleAspectFill
        imageViewLabel.clipsToBounds = true
        
        // Configure labels
        diseaseNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        plantNameLabel.font = UIFont.systemFont(ofSize: 14)
        plantDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        plantDescriptionLabel.numberOfLines = 2
    }
    
    private func updateUI() {
        guard let disease = disease else { return }
        
        // Debug print statement
        print("[DEBUG] Loading image for disease: \(disease.diseaseName), image URL: \(disease.image)")
        
        // Load image from URL using SDWebImage
        if let imageURL = URL(string: disease.image) {
            imageViewLabel.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder_disease"), options: [], completed: { [weak self] image, error, _, _ in
                if let error = error {
                    print("[DEBUG] Error loading image for disease \(disease.diseaseName):", error)
                }
            })
        } else {
            print("[DEBUG] No valid image URL for disease: \(disease.diseaseName)")
            imageViewLabel.image = UIImage(named: "placeholder_disease")
        }
        
        diseaseNameLabel.text = disease.diseaseName
        //plantNameLabel.text = disease.diseaseName
        plantDescriptionLabel.text = disease.diseaseCure
    }
}
