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
    
    func configure(with userPlant: UserPlant, plant: Plant) {
        section1PlantImageView.image = UIImage(named: plant.plantImage[0])
        section1NickNameLabel.text = userPlant.userPlantNickName
    }
}
