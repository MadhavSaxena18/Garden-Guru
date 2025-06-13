//
//  AllDataCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 19/02/25.
//

import UIKit
import SDWebImage

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
        
        if let urlString = plant.plantImage, let url = URL(string: urlString) {
            plantImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_plant"))
        } else {
            plantImageView.image = UIImage(named: "placeholder_plant")
        }
        
        nameLabel.setNeedsLayout()
        descriptionLabel.setNeedsLayout()
        layoutIfNeeded()
    }
    
    func configureForDisease(with disease: Diseases) {
        // Set disease name with proper formatting
        nameLabel.text = disease.diseaseName
        
        // Format disease information in paragraphs
        var descriptionText = ""
        
        // Add symptoms without label
        if let symptoms = disease.diseaseSymptoms, !symptoms.isEmpty {
            // Convert array of Characters to String
            let symptomString = symptoms.map { String($0) }.joined()
            descriptionText = symptomString
        }
        
        if descriptionText.isEmpty {
            descriptionText = "No information available"
        }
        
        // Create attributed string with paragraph styling
        let attributedString = NSMutableAttributedString(string: descriptionText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 12
        
        // Apply paragraph style to entire text
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                    value: paragraphStyle,
                                    range: NSRange(location: 0, length: descriptionText.count))
        
        // Apply text attributes for better readability
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ], range: NSRange(location: 0, length: descriptionText.count))
        
        descriptionLabel.attributedText = attributedString
        
        // Load and display disease image
        if let urlString = disease.diseaseImage {
            print("🖼️ Loading disease image from URL: \(urlString)")
            if let url = URL(string: urlString) {
                plantImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_disease")) { image, error, cacheType, url in
                    if let error = error {
                        print("❌ Error loading disease image: \(error)")
                    } else {
                        print("✅ Successfully loaded disease image from: \(url?.absoluteString ?? "unknown URL")")
                    }
                }
            } else {
                print("❌ Invalid disease image URL: \(urlString)")
                plantImageView.image = UIImage(named: "placeholder_disease")
            }
        } else {
            print("❌ No disease image URL provided")
            // Try to load image by disease name
            if let diseaseImage = UIImage(named: disease.diseaseName.lowercased().replacingOccurrences(of: " ", with: "_")) {
                print("✅ Found local image for disease: \(disease.diseaseName)")
                plantImageView.image = diseaseImage
            } else {
                print("❌ No local image found for disease: \(disease.diseaseName)")
            plantImageView.image = UIImage(named: "placeholder_disease")
            }
        }
        
        // Ensure proper layout
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func configureForFertilizer(with fertilizer: Fertilizer) {
        nameLabel.text = fertilizer.fertilizerName
        descriptionLabel.text = fertilizer.fertilizerDescription ?? "No description available"
        
        if let urlString = fertilizer.fertilizerImage, let url = URL(string: urlString) {
            plantImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "fertilizer_placeholder"))
        } else {
            plantImageView.image = UIImage(named: "fertilizer_placeholder")
        }
        
        nameLabel.setNeedsLayout()
        descriptionLabel.setNeedsLayout()
        layoutIfNeeded()
    }
    
    func configureForPreventionTip(with preventionTip: PreventionTip) {
        nameLabel.text = preventionTip.title
        descriptionLabel.text = preventionTip.message
        
        if let urlString = preventionTip.imageUrl, let url = URL(string: urlString) {
            plantImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "leaf.fill")) // Use a generic leaf placeholder
        } else {
            plantImageView.image = UIImage(systemName: "leaf.fill")
        }
        
        nameLabel.setNeedsLayout()
        descriptionLabel.setNeedsLayout()
        layoutIfNeeded()
    }
}
