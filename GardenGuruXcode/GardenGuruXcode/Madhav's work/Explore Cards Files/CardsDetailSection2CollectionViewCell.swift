//
//  CardsDetailSection2CollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 20/01/25.
//

import UIKit

class CardsDetailSection2CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var plantDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCardSection2(with indexPath: IndexPath){
        plantNameLabel.text = ExploreScreen.cardDetailSection2[indexPath.row].plantName
        plantDescription.text = ExploreScreen.cardDetailSection2[indexPath.row].description
    }
    
//    func updateCardSection2(at index: Int) {
//        guard index >= 0, index < ExploreScreen.cardDetailSection1.count else {
//            print("Index out of bounds.")
//            return
//        }
//        let data = ExploreScreen.cardDetailSection2[index]
//        plantDescription.text = data.description
//    }

}
