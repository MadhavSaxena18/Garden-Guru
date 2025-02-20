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
        // Initialization code
       
    }
    

//    func update(with indexPath : IndexPath){
//        plantImageOutlet.image = ExploreScreen.cardDetailSection1[indexPath.row].imageOfPlant
//        infoImage1Outlet.image = ExploreScreen.cardDetailSection1[indexPath.row].imageOfLable1
//        infoImage2Outlet.image = ExploreScreen.cardDetailSection1[indexPath.row].imageOfLable2
//        infoImage3Outlet.image = ExploreScreen.cardDetailSection1[indexPath.row].imageOfLable3
//        infoLabel1Outlet.text = ExploreScreen.cardDetailSection1[indexPath.row].info1
//        infoLabel2Outlet.text = ExploreScreen.cardDetailSection1[indexPath.row].info2
//        infoLabel3Outlet.text = ExploreScreen.cardDetailSection1[indexPath.row].info3
//    }
    func update(with data: Any?) {
            guard let data = data else {
                resetCell()
                return
            }

            if let plant = data as? Plant {
                plantImageOutlet.image = UIImage(named: plant.plantImage.first ?? "defaultPlantImage")
                infoLabel1Outlet.text = plant.plantName
            } else if let disease = data as? Diseases {
                plantImageOutlet.image = UIImage(named: disease.diseaseImage.first ?? "defaultDiseaseImage")
                infoLabel1Outlet.text = disease.diseaseName
            }
        }

        private func resetCell() {
            plantImageOutlet.image = UIImage(named: "defaultPlantImage")
            infoLabel1Outlet.text = "N/A"
        }
   }
