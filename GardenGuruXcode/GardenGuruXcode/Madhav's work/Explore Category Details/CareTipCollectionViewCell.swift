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
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.4).cgColor
        contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        messageLabel.numberOfLines = 0
    }
    
    func configure(with tip: String) {
        messageLabel.text = "🌿 \(tip)"
    }
}
