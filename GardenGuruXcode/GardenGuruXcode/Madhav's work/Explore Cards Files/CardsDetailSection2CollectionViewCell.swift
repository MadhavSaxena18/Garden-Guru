import UIKit

class CardsDetailSection2CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var plantDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCardSection2(with plant: Plant?) {
        guard let plant = plant else {
            print("Error: Plant data is nil")
            resetCell()
            return
        }

        plantNameLabel.text = plant.plantName
        plantDescription.text = plant.plantDescription
    }
    func updateCardSection2WithDisease(with disease: Diseases?) {
            guard let disease = disease else {
                resetCell()
                return
            }

        plantNameLabel.text = disease.diseaseName
        plantDescription.text = "Symptoms: \(disease.diseaseSymptoms.joined(separator: ", "))\nCure: \(disease.diseaseCure.joined(separator: ", "))"
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
