//
//  MySpaceSection2CollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 16/01/25.
//

import UIKit

class MySpaceSection2CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var section2PlantImageView: UIImageView!
    @IBOutlet weak var section2NickNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func updatesection2Data(with indexPath: IndexPath){
        section2PlantImageView.image = UIImage(named: MySpaceScreen.mySpaceSection1Data[indexPath.row].imageURL)
        section2NickNameLabel.text = MySpaceScreen.mySpaceSection1Data[indexPath.row].nickName
    }


}
