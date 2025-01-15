//
//  MySpaceCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit
import Foundation
class MySpaceCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plantImageLabel: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    
    func updatesectionData(with indexPath: IndexPath){
        plantImageLabel.image = UIImage(named: SectionData.plants[indexPath.row].imageURL)
    }

}
