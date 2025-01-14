//
//  Section3CollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit

class Section3CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var designImageView: UIImageView!
    @IBOutlet weak var designDescriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateDataOfSection3(with indexPath: IndexPath){
        designImageView.image = ExploreScreen.dataOfSection3[indexPath.row].designImage
        
        designDescriptionLabel.text = ExploreScreen.dataOfSection3[indexPath.row].designName
    }

}
