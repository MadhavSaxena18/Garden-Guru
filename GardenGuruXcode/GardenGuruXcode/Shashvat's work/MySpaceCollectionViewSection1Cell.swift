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
   
    
    
    @IBOutlet var  section1NickNameLabel: UILabel!
    
    func updatesection1Data(with indexPath: IndexPath){
        section1PlantImageView.image = UIImage(named: MySpaceScreen.mySpaceSection1Data[indexPath.row].imageURL)
        section1NickNameLabel.text = MySpaceScreen.mySpaceSection1Data[indexPath.row].nickName
    }

}
