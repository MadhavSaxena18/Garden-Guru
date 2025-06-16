import UIKit

class CardsDetailSection2CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var plantDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        plantNameLabel.numberOfLines = 0 // Allow multiple lines for plant name
        plantNameLabel.lineBreakMode = .byWordWrapping // Ensure text wraps
        plantDescription.numberOfLines = 0 // Allow multiple lines for plant description
        plantDescription.lineBreakMode = .byWordWrapping // Ensure text wraps
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set preferredMaxLayoutWidth for labels to enable proper self-sizing
        // The labels have 12pt leading and 15pt trailing from the content view in the XIB.
        let availableWidth = contentView.bounds.width - 12 - 15 
        plantNameLabel.preferredMaxLayoutWidth = availableWidth
        plantDescription.preferredMaxLayoutWidth = availableWidth
    }
    
    func updateCardSection2(with plant: Plant?) {
        guard let plant = plant else {
            print("Error: Plant data is nil")
            resetCell()
            return
        }

        plantNameLabel.text = plant.plantName
        plantDescription.text = plant.plantDescription
        setNeedsLayout()
        layoutIfNeeded()
    }
    func updateCardSection2WithDisease(with disease: Diseases?) {
            guard let disease = disease else {
                resetCell()
                return
            }

        plantNameLabel.text = disease.diseaseName
        
        var descriptionText = "Symptoms: "
        if let symptoms = disease.diseaseSymptoms {
            descriptionText += symptoms
        } else {
            descriptionText += "Not specified"
        }
        
        descriptionText += "\nCure: "
        if let cure = disease.diseaseCure {
            descriptionText += cure
        } else {
            descriptionText += "Not specified"
        }
        
        plantDescription.text = descriptionText
        setNeedsLayout()
        layoutIfNeeded()
        }


    private func resetCell() {
        plantNameLabel.text = "N/A"
        plantDescription.text = "No description available"
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
