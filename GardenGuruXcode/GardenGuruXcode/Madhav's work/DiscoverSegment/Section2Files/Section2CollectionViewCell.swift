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
        
        // Configure disease name label (maximum bold title)
        if let sfProBlack = UIFont(name: "SFProDisplay-Black", size: 25) {
            diseaseNameLabel.font = sfProBlack
        } else if let sfProHeavy = UIFont(name: "SFProDisplay-Heavy", size: 25) {
            diseaseNameLabel.font = sfProHeavy
        } else if let sfProBold = UIFont(name: "SFProDisplay-Bold", size: 25) {
            diseaseNameLabel.font = sfProBold
        } else {
            diseaseNameLabel.font = UIFont.systemFont(ofSize: 25, weight: .black)
        }
        diseaseNameLabel.numberOfLines = 0
        diseaseNameLabel.lineBreakMode = .byWordWrapping
        
        // Configure plant name label (if used)
        plantNameLabel.font = UIFont.systemFont(ofSize: 14)
        plantNameLabel.numberOfLines = 1
        plantNameLabel.lineBreakMode = .byTruncatingTail
        
        // Configure description label
        plantDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        plantDescriptionLabel.numberOfLines = 0
        plantDescriptionLabel.lineBreakMode = .byWordWrapping
        plantDescriptionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        plantDescriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
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
        
        // Set disease name with proper formatting
        diseaseNameLabel.text = disease.diseaseName
        
        // Debug font info
        print("[DEBUG] Font being used: \(diseaseNameLabel.font.fontName), size: \(diseaseNameLabel.font.pointSize)")
        
        // Set plant name if available (currently commented out)
        //plantNameLabel.text = disease.diseaseName
        
        // Set description with proper wrapping
        plantDescriptionLabel.text = disease.diseaseCure
        
        // Force layout update to ensure proper text wrapping
        setNeedsLayout()
        layoutIfNeeded()
    }
}
