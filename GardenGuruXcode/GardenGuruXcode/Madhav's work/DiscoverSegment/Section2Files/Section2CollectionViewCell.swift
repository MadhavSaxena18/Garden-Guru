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
        
        // Load image from URL
        if let imageURL = URL(string: disease.image) {
            URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.imageViewLabel.image = UIImage(data: data)
                }
            }.resume()
        }
        
        diseaseNameLabel.text = disease.diseaseName
        //plantNameLabel.text = disease.diseaseName
        plantDescriptionLabel.text = disease.diseaseCure
    }
}
