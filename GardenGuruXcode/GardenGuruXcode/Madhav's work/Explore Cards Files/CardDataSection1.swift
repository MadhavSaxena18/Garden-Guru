//
//  CardsDetailCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 18/01/25.
//

import UIKit
import SDWebImage

class CardDataSection1: UICollectionViewCell {
    
    @IBOutlet var plantImageOutlet: UIImageView!
    @IBOutlet var infoImage1Outlet: UIImageView!
    @IBOutlet var infoImage2Outlet: UIImageView!
    @IBOutlet var infoImage3Outlet: UIImageView!
    @IBOutlet var infoLabel1Outlet: UILabel!
    @IBOutlet var infoLabel2Outlet: UILabel!
    @IBOutlet var infoLabel3Outlet: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set up icons for the info boxes
        infoImage1Outlet.image = UIImage(systemName: "drop.fill") // Water icon
        //infoImage2Outlet.image = UIImage(systemName: "leaf.fill") // Fertilizer icon
        infoImage3Outlet.image = UIImage(systemName: "sun.max.fill") // Light icon
    }
    
    func update(with data: Any?) {
        guard let data = data else {
            resetCell()
            return
        }

        if let plant = data as? Plant {
            // Set plant image from URL if available
            if let urlString = plant.imageURLs.first, let url = URL(string: urlString.replacingOccurrences(of: "//01", with: "/01").replacingOccurrences(of: "//", with: "/").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                plantImageOutlet.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultPlantImage")) { image, error, cacheType, url in
                    if let error = error {
                        print("❌ Error loading plant image: \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully loaded plant image from: \(url?.absoluteString ?? "unknown URL")")
                    }
                }
            } else {
                plantImageOutlet.image = UIImage(named: "defaultPlantImage")
                print("❌ Plant image URL is nil or malformed for plant: \(plant.plantName)")
            }
            
            // Water frequency
            print("DEBUG: Raw waterFrequency: \(String(describing: plant.waterFrequency))")
            infoLabel1Outlet.text = "Every \(plant.waterFrequency ?? 0) days"
            
            // Fertilizer frequency
//            infoImage2Outlet.image = UIImage(systemName: "leaf.fill")
            print("DEBUG: Raw fertilizerFrequency: \(String(describing: plant.fertilizerFrequency))")
            infoLabel2Outlet.text = "Every \(plant.fertilizerFrequency ?? 0) days"
            
            // Handle optional season
            if let season = plant.favourableSeason {
                infoLabel3Outlet.text = "Season: \(season.rawValue)"
            } else {
                infoLabel3Outlet.text = "Season: Not specified"
            }
            
        } else if let disease = data as? Diseases {
            if let urlString = disease.diseaseImage, let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    guard let self = self, let data = data, error == nil else {
                        DispatchQueue.main.async {
                            self?.plantImageOutlet.image = UIImage(named: "defaultDiseaseImage")
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.plantImageOutlet.image = UIImage(data: data)
                    }
                }.resume()
            } else {
                plantImageOutlet.image = UIImage(named: "defaultDiseaseImage")
            }
            resetInfoLabels()
        }
    }

    private func resetCell() {
        plantImageOutlet.image = UIImage(named: "defaultPlantImage")
        resetInfoLabels()
    }
    
    private func resetInfoLabels() {
        infoLabel1Outlet.text = "N/A"
        infoLabel2Outlet.text = "N/A"
        infoLabel3Outlet.text = "N/A"
    }
}
