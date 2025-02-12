//
//  ExplorePageDataModel.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import Foundation
import UIKit
struct DataOfSection1InDicoverSegment{
    var image: UIImage
    var plantName: String
    var plantDescription: String
}

struct DataOfSection2InDiscoverSegment{
    var image: UIImage
    var diseaseName: String
    var plantName: String
    var plantDescription: String
}

struct DataOfSection3InDicoverSegment {
    var designImage: UIImage
    var designName: String
}


struct DataOfSection1InforMyPlantSegment{
    var image: UIImage
    var discription: String
}

struct DataOfSection2InforMyPlantSegment{
    var image: UIImage
    var discription: String
}

struct DataOfSection3InforMyPlantSegment{
    var image: UIImage
    
}

struct CardDetailsSection1{
    var imageOfPlant: UIImage
    var imageOfLable1: UIImage
    var info1: String
    var imageOfLable2: UIImage
    var info2: String
    var imageOfLable3: UIImage
    var info3: String
}

struct CardDetailsSection2{
    var plantName: String
    var description: String
}

struct CardDetailsSection3{
    var plantImage: UIImage
}

class ExploreScreen{
    static var dataOfSection1InDiscoverSegment: [DataOfSection1InDicoverSegment] = [DataOfSection1InDicoverSegment(image: UIImage(named: "parlor palm")!, plantName: "Parlor Palm", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   DataOfSection1InDicoverSegment(image:  UIImage(named: "string of pearls")!, plantName: "String of Pearls", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   DataOfSection1InDicoverSegment(image:  UIImage(named: "rose plant")!, plantName: "Rose Plant", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   DataOfSection1InDicoverSegment(image: UIImage(named: "Hibiscus")!, plantName: "Hibiscus", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   ]
    
    static var dataOfSection2InDiscoverSegment: [DataOfSection2InDiscoverSegment] = [DataOfSection2InDiscoverSegment(image: UIImage(named: "root rot in string of pearls")!, diseaseName: "Root rot", plantName: "String of Pearls", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                                                     DataOfSection2InDiscoverSegment(image:  UIImage(named: "yellowing leaves in parlor palm")!, diseaseName: "Yellowing leaves", plantName: "Parlor Palm", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                                                     DataOfSection2InDiscoverSegment(image:  UIImage(named: "black spots in rose")!, diseaseName: "Black Spots", plantName: "Rose", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                                                     DataOfSection2InDiscoverSegment(image: UIImage(named: "bud drop in hiobiscus")!, diseaseName: "Bud Drop", plantName: "Hibiscus", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   ]
    static var dataOfSection3InDiscoverSegment: [DataOfSection3InDicoverSegment] = [DataOfSection3InDicoverSegment(designImage: UIImage(named: "design2")!, designName: "The Art of Nature🌸"),
                                                   DataOfSection3InDicoverSegment(designImage: UIImage(named: "design1")!, designName: "The Art of Nature🌸"),
                                                                                    DataOfSection3InDicoverSegment(designImage: UIImage(named: "design3")!, designName: "The Art of Nature🌸"),
                                                                                    DataOfSection3InDicoverSegment(designImage: UIImage(named: "design4")!, designName: "The Art of Nature🌸"),
    ]
    static var headerData: [String] = ["Top Winter Plants", "Common Issues", "Top Designs"]
    
    
    
    
    // "For My plant" segment
    
    static var dataOfSection1InforMyPlantSection: [DataOfSection1InforMyPlantSegment] = [DataOfSection1InforMyPlantSegment(image: UIImage(named: "black spots in rose")!, discription: "Black Spots: A Call for Help"),
                                                                                         DataOfSection1InforMyPlantSegment(image: UIImage(named: "root rot in string of pearls")!, discription: "Root Rot: The Silent Threat"),
                                                                                         DataOfSection1InforMyPlantSegment(image: UIImage(named: "black spots in rose")!, discription: "Black Spots: A Call for Help"),
                                                                                                                                                                              DataOfSection1InforMyPlantSegment(image: UIImage(named: "root rot in string of pearls")!, discription: "Root Rot: The Silent Threat"),
    ]
    
    
    static var dataOfSection2InforMyPlantSection: [DataOfSection2InforMyPlantSegment] = [DataOfSection2InforMyPlantSegment(image: UIImage(named: "f2")!, discription: "Osmocote Smart-Release Plant: Balanced nutrient"),
                                                                                         DataOfSection2InforMyPlantSegment(image: UIImage(named: "f1")!, discription: "Root Rot: The Silent Threat"),
    ]
    
    static var dataOfSection3InforMyPlantSection: [DataOfSection3InforMyPlantSegment] = [
        DataOfSection3InforMyPlantSegment(image: UIImage(named: "design3")!),
        DataOfSection3InforMyPlantSegment(image: UIImage(named: "design4")!),
                                                                                        
    ]
    
    static var headerForInMyPlantSegment: [String] = ["Common Issues in Rose Plant", "Common fertilizer for Parlor Palm", "Aesthetic Design Idea"]
    
    static var cardDetailSection1: [CardDetailsSection1] = [
        CardDetailsSection1(imageOfPlant: UIImage(named: "parlor palm")!, imageOfLable1: UIImage(named: "watering")!, info1: "once a day", imageOfLable2: UIImage(named: "fertilizer")!, info2: "once a week", imageOfLable3: UIImage(named: "watering")!, info3: "Part-Full"),
        CardDetailsSection1(imageOfPlant: UIImage(named: "string of pearls")!, imageOfLable1: UIImage(named: "watering")!, info1: "once a day", imageOfLable2: UIImage(named: "fertilizer")!, info2: "once a week", imageOfLable3: UIImage(named: "watering")!, info3: "Part-Full"),
        CardDetailsSection1(imageOfPlant: UIImage(named: "string of pearls")!, imageOfLable1: UIImage(named: "watering")!, info1: "once a day", imageOfLable2: UIImage(named: "fertilizer")!, info2: "once a week", imageOfLable3: UIImage(named: "watering")!, info3: "Part-Full"),
        CardDetailsSection1(imageOfPlant: UIImage(named: "string of pearls")!, imageOfLable1: UIImage(named: "watering")!, info1: "once a day", imageOfLable2: UIImage(named: "fertilizer")!, info2: "once a week", imageOfLable3: UIImage(named: "watering")!, info3: "Part-Full"),
        
        
        ]
    static var cardDetailSection2: [CardDetailsSection2] = [CardDetailsSection2(plantName: "Parlor Palm" , description: "Parlor Palms (scientifically known as Chamaedorea elegans) are small, elegant indoor plants that are popular for their attractive, feathery foliage and ease of care. Native to the tropical regions of Central America, they thrive in low to medium light conditions, making them perfect for indoor spaces")]
    
    static var cardDetailSection3: [CardDetailsSection3] = [CardDetailsSection3(plantImage: UIImage(named: "parlor palm1")!), CardDetailsSection3(plantImage: UIImage(named: "parlor palm2")!), CardDetailsSection3(plantImage: UIImage(named: "parlor palm")!), CardDetailsSection3(plantImage: UIImage(named: "parlor palm1")!)]
}
    
