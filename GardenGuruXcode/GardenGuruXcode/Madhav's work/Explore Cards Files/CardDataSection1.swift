//
//  CardsDetailCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 18/01/25.
//

import UIKit
import SDWebImage

class CardDataSection1: UICollectionViewCell {
    
    private var plantImageOutlet: UIImageView!
    
    private var plantNameLabel: UILabel!
    private var botanicalNameLabel: UILabel!
    private var gradientLayer: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Plant image view (full screen hero)
        plantImageOutlet = UIImageView()
        plantImageOutlet.translatesAutoresizingMaskIntoConstraints = false
        plantImageOutlet.contentMode = .scaleAspectFill
        plantImageOutlet.clipsToBounds = true
        contentView.addSubview(plantImageOutlet)
        
        // Gradient overlay
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor
        ]
        gradientLayer.locations = [0.3, 1.0]
        plantImageOutlet.layer.addSublayer(gradientLayer)
        
        // Plant name label (overlaid on image)
        plantNameLabel = UILabel()
        plantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        plantNameLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        plantNameLabel.textColor = .white
        plantNameLabel.numberOfLines = 2
        plantNameLabel.layer.shadowColor = UIColor.black.cgColor
        plantNameLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        plantNameLabel.layer.shadowRadius = 4
        plantNameLabel.layer.shadowOpacity = 0.8
        contentView.addSubview(plantNameLabel)
        
        // Botanical name label
        botanicalNameLabel = UILabel()
        botanicalNameLabel.translatesAutoresizingMaskIntoConstraints = false
        botanicalNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        botanicalNameLabel.textColor = .white.withAlphaComponent(0.95)
        botanicalNameLabel.layer.shadowColor = UIColor.black.cgColor
        botanicalNameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        botanicalNameLabel.layer.shadowRadius = 3
        botanicalNameLabel.layer.shadowOpacity = 0.6
        contentView.addSubview(botanicalNameLabel)
        
        NSLayoutConstraint.activate([
            plantImageOutlet.topAnchor.constraint(equalTo: contentView.topAnchor),
            plantImageOutlet.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            plantImageOutlet.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            plantImageOutlet.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            plantNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            plantNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            plantNameLabel.bottomAnchor.constraint(equalTo: botanicalNameLabel.topAnchor, constant: -4),
            
            botanicalNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            botanicalNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            botanicalNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = plantImageOutlet.bounds
    }
    
    func update(with data: Any?) {
        guard let data = data else {
            resetCell()
            return
        }

        if let plant = data as? Plant {
            // Set plant image from URL if available
            if let urlString = plant.imageURLs.first, let url = URL(string: urlString.replacingOccurrences(of: "//01", with: "/01").replacingOccurrences(of: "//", with: "/").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                plantImageOutlet.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultPlantImage")) { image, error, cacheType, url in
                    if let error = error {
                        print("❌ Error loading plant image: \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully loaded plant image from: \(url?.absoluteString ?? "unknown URL")")
                    }
                }
            } else {
                plantImageOutlet.image = UIImage(named: "defaultPlantImage")
                print("❌ Plant image URL is nil or malformed for plant: \(plant.plantName)")
            }
            
            // Update plant name and botanical name
            plantNameLabel.text = plant.plantName
            botanicalNameLabel.text = plant.plantBotanicalName ?? "Botanical name"
            
        } else if let disease = data as? Diseases {
            if let urlString = disease.diseaseImage?.trimmingCharacters(in: .whitespacesAndNewlines), let url = URL(string: urlString) {
                plantImageOutlet.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultDiseaseImage")) { image, error, cacheType, url in
                    if let error = error {
                        print("❌ Error loading disease image: \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully loaded disease image from: \(url?.absoluteString ?? "unknown URL")")
                    }
                }
            } else {
                plantImageOutlet.image = UIImage(named: "defaultDiseaseImage")
            }
            
            plantNameLabel.text = disease.diseaseName
            botanicalNameLabel.text = "Disease Information"
        } else if let fertilizer = data as? Fertilizer {
            // Load fertilizer image using SDWebImage with the raw URL, trimmed
            if let urlString = fertilizer.fertilizerImage?.trimmingCharacters(in: .whitespacesAndNewlines), let url = URL(string: urlString) {
                plantImageOutlet.sd_setImage(with: url, placeholderImage: UIImage(named: "fertilizer_placeholder")) { image, error, cacheType, url in
                    if let error = error {
                        print("❌ Error loading fertilizer image: \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully loaded fertilizer image from: \(url?.absoluteString ?? "unknown URL")")
                    }
                }
            } else {
                plantImageOutlet.image = UIImage(named: "fertilizer_placeholder")
                print("❌ Fertilizer image URL is nil or malformed for fertilizer: \(fertilizer.fertilizerName ?? "Unknown")")
            }
            
            plantNameLabel.text = fertilizer.fertilizerName ?? "Fertilizer"
            botanicalNameLabel.text = "Fertilizer Information"
        }
    }

    private func resetCell() {
        plantImageOutlet.image = UIImage(named: "defaultPlantImage")
        plantNameLabel.text = ""
        botanicalNameLabel.text = ""
    }
}
