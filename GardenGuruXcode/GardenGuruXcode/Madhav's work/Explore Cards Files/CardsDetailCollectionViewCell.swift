//
//  CardsDetailCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 18/01/25.
//

import UIKit

class CardsDetailCollectionViewCell: UICollectionViewCell {
    var detailData : ExploreScreen?
    @IBOutlet var plantImageOutlet: UIImageView!
    @IBOutlet var infoImage1Outlet: UIImageView!
    @IBOutlet var infoImage2Outlet: UIImageView!
    @IBOutlet var infoImage3Outlet: UIImageView!
    @IBOutlet var infoLabel1Outlet: UILabel!
    @IBOutlet var infoLabel2Outlet: UILabel!
    @IBOutlet var infoLabel3Outlet: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }
    

    func update(with data: CardDetailsSection1){
        
        plantImageOutlet.image = data.imageOfPlant
        infoImage1Outlet.image = data.imageOfLable1
        infoImage2Outlet.image = data.imageOfLable2
        infoImage3Outlet.image = data.imageOfLable3
        infoLabel1Outlet.text = data.info1
        infoLabel2Outlet.text = data.info2
        
//        plantImageOutlet.image = ExploreScreen.cardDetailSection1[indexPath.row].imageOfPlant
//        infoImage1Outlet.image = ExploreScreen.cardDetailSection1[indexPath.row].imageOfLable1
//        infoImage2Outlet.image = ExploreScreen.cardDetailSection1[indexPath.row].imageOfLable2
//        infoImage3Outlet.image = ExploreScreen.cardDetailSection1[indexPath.row].imageOfLable3
//        infoLabel1Outlet.text = ExploreScreen.cardDetailSection1[indexPath.row].info1
//        infoLabel2Outlet.text = ExploreScreen.cardDetailSection1[indexPath.row].info2
//        infoLabel3Outlet.text = ExploreScreen.cardDetailSection1[indexPath.row].info3
    }
}
