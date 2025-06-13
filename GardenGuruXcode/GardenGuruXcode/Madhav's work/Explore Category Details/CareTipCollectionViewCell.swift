//
//  CareTipCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Batch - 2 on 10/06/25.
//

import UIKit

class CareTipCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor(hex: "4CAF50").cgColor
        contentView.backgroundColor = UIColor(hex: "E8F5E9")
        messageLabel.numberOfLines = 0
        
        // Add constraints to messageLabel for proper alignment within the cell
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with tip: String) {
        messageLabel.text = "🌿 \(tip)"
    }
}
