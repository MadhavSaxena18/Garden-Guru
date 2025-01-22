//
//  MySpaceSection3CollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 16/01/25.
//

import UIKit

class MySpaceSection3CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var section3PlantImageView: UIImageView!
    @IBOutlet weak var section3NickNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func updatesection3Data(with indexPath: IndexPath){
        section3PlantImageView.image = UIImage(named: MySpaceScreen.mySpaceSection3Data[indexPath.row].imageURL)
        section3NickNameLabel.text = MySpaceScreen.mySpaceSection3Data[indexPath.row].nickName
    }
    

}
