//
//  MySpaceCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit
import Foundation
class MySpaceCollectionViewSection1Cell: UICollectionViewCell {
    @IBOutlet weak var section1PlantImageView: UIImageView!
    @IBOutlet var section1NickNameLabel: UILabel!
    
    var optionsHandler: (() -> Void)?
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(hex: "284329")
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(optionsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        setupOptionsButton()
    }
    
    private func setupOptionsButton() {
        contentView.addSubview(optionsButton)
        
        NSLayoutConstraint.activate([
            optionsButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            optionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            optionsButton.widthAnchor.constraint(equalToConstant: 30),
            optionsButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func optionsButtonTapped() {
        optionsHandler?()
    }
    
    func configure(with userPlant: UserPlant, plant: Plant) {
        section1PlantImageView.image = UIImage(named: plant.plantImage[0])
        section1NickNameLabel.text = userPlant.userPlantNickName
        
        section1PlantImageView.contentMode = .scaleAspectFill
        section1PlantImageView.clipsToBounds = true
        
        backgroundColor = .white
        layer.cornerRadius = 25
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
    }
}
