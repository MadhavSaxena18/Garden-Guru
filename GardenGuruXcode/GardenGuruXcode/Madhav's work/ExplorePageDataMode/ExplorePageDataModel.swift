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
    static var dataOfSection1InDiscoverSegment: [DataOfSection1InDicoverSegment] = [DataOfSection1InDicoverSegment(image: UIImage(named: "image1")!, plantName: "String of pearls", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   DataOfSection1InDicoverSegment(image:  UIImage(named: "image2")!, plantName: "Parlor Palm", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   DataOfSection1InDicoverSegment(image:  UIImage(named: "image3")!, plantName: "Rose Plant", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   DataOfSection1InDicoverSegment(image: UIImage(named: "image4")!, plantName: "Hibiscus", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   ]
    
    static var dataOfSection2InDiscoverSegment: [DataOfSection2InDiscoverSegment] = [DataOfSection2InDiscoverSegment(image: UIImage(named: "image2")!, plantName: "String of pearls", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   DataOfSection2InDiscoverSegment(image:  UIImage(named: "image2")!, plantName: "Parlor Palm", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   DataOfSection2InDiscoverSegment(image:  UIImage(named: "image3")!, plantName: "Rose Plant", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   DataOfSection2InDiscoverSegment(image: UIImage(named: "image1")!, plantName: "Hibiscus", plantDescription: "This unique and attractive succulent plant scientifically known as Senecio rowleyanus (recently reclassified as Curio rowleyanus)."),
                                                   ]
    static var dataOfSection3InDiscoverSegment: [DataOfSection3InDicoverSegment] = [DataOfSection3InDicoverSegment(designImage: UIImage(named: "image1")!, designName: "The Art of Nature🌸"),
                                                   DataOfSection3InDicoverSegment(designImage: UIImage(named: "image2")!, designName: "The Art of Nature🌸"),
    ]
    static var headerData: [String] = ["Top Winter Plants", "Common Issues", "Top Designs"]
    
    
    
    
    // "For My plant" segment
    
    static var dataOfSection1InforMyPlantSection: [DataOfSection1InforMyPlantSegment] = [DataOfSection1InforMyPlantSegment(image: UIImage(named: "image1")!, discription: "Black Spots: A Call for Help"),
                                                                                         DataOfSection1InforMyPlantSegment(image: UIImage(named: "image2")!, discription: "Root Rot: The Silent Threat"),
                                                                                         DataOfSection1InforMyPlantSegment(image: UIImage(named: "image3")!, discription: "AAAA"),
                                                                                         DataOfSection1InforMyPlantSegment(image: UIImage(named: "image4")!, discription: "Root Rot: The Silent Threat")
    ]
    
    
    static var dataOfSection2InforMyPlantSection: [DataOfSection2InforMyPlantSegment] = [DataOfSection2InforMyPlantSegment(image: UIImage(named: "image2")!, discription: "Osmocote Smart-Release Plant: Balanced nutrient"),
                                                                                         DataOfSection2InforMyPlantSegment(image: UIImage(named: "image2")!, discription: "Root Rot: The Silent Threat"),
    ]
    
    static var dataOfSection3InforMyPlantSection: [DataOfSection3InforMyPlantSegment] = [
        DataOfSection3InforMyPlantSegment(image: UIImage(named: "image1")!),
        DataOfSection3InforMyPlantSegment(image: UIImage(named: "image2")!),
                                                                                        
    ]
    
    static var headerForInMyPlantSegment: [String] = ["Common Issues for Parlor Palm", "Common fertilizer for Parlor Palm", "Aesthetic Design Idea"]
    
    static var cardDetailSection1: [CardDetailsSection1] = [CardDetailsSection1(imageOfPlant: UIImage(named: "image1")!, imageOfLable1: UIImage(named: "watering")!, info1: "once a day", imageOfLable2: UIImage(named: "fertilizer")!, info2: "once a week", imageOfLable3: UIImage(named: "watering")!, info3: "Part-Full"),
                                                           ]
    static var cardDetailSection2: [CardDetailsSection2] = [CardDetailsSection2(plantName: "String of Pearls" , description: "String of pearls plants are unique vining succulents that are easily recognizable by their tiny pea-shaped leaves. The leaves grow on trailing stems that gracefully spill over the sides of planters and hanging baskets much like the string of rubies succulent. The plant is a robust and quick grower—gaining about five to 15 inches per year—but does not live long without propagation. Thankfully it is easy to propagate the plant using its stems.")]
    
    static var cardDetailSection3: [CardDetailsSection3] = [CardDetailsSection3(plantImage: UIImage(named: "image1")!), CardDetailsSection3(plantImage: UIImage(named: "image1")!), CardDetailsSection3(plantImage: UIImage(named: "image1")!), CardDetailsSection3(plantImage: UIImage(named: "image1")!)]
}
    
