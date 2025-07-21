import UIKit
import SDWebImage

class SectionWiseDetailViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!

    func configureForFertilizer(with fertilizer: Fertilizer) {
        print("[DEBUG] Configuring fertilizer cell for: \(fertilizer.fertilizerName)")
        nameLabel.text = fertilizer.fertilizerName ?? "No Name"
        descriptionLabel.text = fertilizer.fertilizerDescription ?? "No description available"
        contentView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2) // TEMP: highlight cell
        
        if let urlString = fertilizer.fertilizerImage, let url = URL(string: urlString) {
            plantImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "fertilizer_placeholder"))
        } else {
            plantImageView.image = UIImage(named: "fertilizer_placeholder")
        }
        
        nameLabel.setNeedsLayout()
        descriptionLabel.setNeedsLayout()
        layoutIfNeeded()
    }
} 