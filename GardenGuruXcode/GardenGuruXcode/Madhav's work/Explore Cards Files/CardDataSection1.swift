//
//  CardsDetailCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 18/01/25.
//

import UIKit

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
            // Set plant image
            plantImageOutlet.image = UIImage(named: plant.plantImage.first ?? "defaultPlantImage")
            
            // Water frequency
            let waterDays = plant.waterFrequency
            infoLabel1Outlet.text = "Every \(waterDays) days"
            
            // Fertilizer frequency
            let fertilizerDays = plant.fertilizerFrequency
            infoLabel2Outlet.text = "Every \(fertilizerDays) days"
            
            // Light requirement (using water requirement as placeholder since light isn't in the model)
            infoLabel3Outlet.text = plant.lightRequirement
            
        } else if let disease = data as? Diseases {
            plantImageOutlet.image = UIImage(named: disease.diseaseImage.first ?? "defaultDiseaseImage")
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
