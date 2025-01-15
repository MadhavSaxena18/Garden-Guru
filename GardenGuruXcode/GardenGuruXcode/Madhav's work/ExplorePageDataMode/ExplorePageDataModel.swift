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

class ExploreScreen{
    static var dataOfSection1InDiscoverSegment: [DataOfSection1InDicoverSegment] = [DataOfSection1InDicoverSegment(image: UIImage(named: "image1")!, plantName: "String of pearls", plantDescription: "The unique and striking foliage of these plants  are aaaaabbbaaaaaaaaabbbbbbbbbbbb"),
                                                   DataOfSection1InDicoverSegment(image:  UIImage(named: "image2")!, plantName: "Parlor Palm", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
                                                   DataOfSection1InDicoverSegment(image:  UIImage(named: "image3")!, plantName: "Rose Plant", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
                                                   DataOfSection1InDicoverSegment(image: UIImage(named: "image4")!, plantName: "Hibiscus", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
                                                   ]
    
    static var dataOfSection2InDiscoverSegment: [DataOfSection2InDiscoverSegment] = [DataOfSection2InDiscoverSegment(image: UIImage(named: "image2")!, plantName: "String of pearls", plantDescription: "The unique and striking foliage of these plants  are aaaaabbbaaaaabbbaaaaaaaaaaaaaaaabbbbbbbbbbb"),
                                                   DataOfSection2InDiscoverSegment(image:  UIImage(named: "image2")!, plantName: "Parlor Palm", plantDescription: "The unique and striking foliage of these plants  are aaaaabbbaaaaaaaaaaaaaaaabbbbbbbbbbb"),
                                                   DataOfSection2InDiscoverSegment(image:  UIImage(named: "image3")!, plantName: "Rose Plant", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
                                                   DataOfSection2InDiscoverSegment(image: UIImage(named: "image1")!, plantName: "Hibiscus", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
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
}
    
