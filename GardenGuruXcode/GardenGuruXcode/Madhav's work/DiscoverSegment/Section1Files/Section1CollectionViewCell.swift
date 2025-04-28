//
//  TopWinterPlantsCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit

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
        
        // Load image from URL
        if let imageURL = URL(string: plant.image) {
            URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.plantImage.image = UIImage(data: data)
                }
            }.resume()
        }
        
        plantNameLabel.text = plant.plantName
        plantDescriptionLabel.text = plant.plantDescription
        }
}

