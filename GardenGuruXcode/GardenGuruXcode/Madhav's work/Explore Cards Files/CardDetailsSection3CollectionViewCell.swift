//
//  CardDetailsSection3CollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 20/01/25.
//

import UIKit

class CardDetailsSection3CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var CardImageSection3: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func updateCardSection3(with indexPath: IndexPath){
        CardImageSection3.image = ExploreScreen.cardDetailSection3[indexPath.row].plantImage
    }

}
