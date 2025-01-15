//
//  ExplorePageDataModel.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import Foundation
import UIKit
struct DataOfSection1{
    var image: UIImage
    var plantName: String
    var plantDescription: String
}

struct DataOfSection2{
    var image: UIImage
    var plantName: String
    var plantDescription: String
}

struct DataOfSection3 {
    var designImage: UIImage
    var designName: String
}

class ExploreScreen{
    static var dataOfSection1: [DataOfSection1] = [DataOfSection1(image: UIImage(named: "image1")!, plantName: "String of pearls", plantDescription: "The unique and striking foliage of these plants  are aaaaabbbaaaaaaaaabbbbbbbbbbbb"),
                                                   DataOfSection1(image:  UIImage(named: "image2")!, plantName: "Parlor Palm", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
                                                   DataOfSection1(image:  UIImage(named: "image3")!, plantName: "Rose Plant", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
                                                   DataOfSection1(image: UIImage(named: "image4")!, plantName: "Hibiscus", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
                                                   ]
    
    static var dataOfSection2: [DataOfSection2] = [DataOfSection2(image: UIImage(named: "image2")!, plantName: "String of pearls", plantDescription: "The unique and striking foliage of these plants  are aaaaabbbaaaaabbbaaaaaaaaaaaaaaaabbbbbbbbbbb"),
                                                   DataOfSection2(image:  UIImage(named: "image2")!, plantName: "Parlor Palm", plantDescription: "The unique and striking foliage of these plants  are aaaaabbbaaaaaaaaaaaaaaaabbbbbbbbbbb"),
                                                   DataOfSection2(image:  UIImage(named: "image3")!, plantName: "Rose Plant", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
                                                   DataOfSection2(image: UIImage(named: "image1")!, plantName: "Hibiscus", plantDescription: "The unique and striking foliage of these plants  are aaaaabbb"),
                                                   ]
    static var dataOfSection3: [DataOfSection3] = [DataOfSection3(designImage: UIImage(named: "image1")!, designName: "The Art of Nature🌸"),
                                                   DataOfSection3(designImage: UIImage(named: "image2")!, designName: "The Art of Nature🌸"),
    ]
    static var headerData: [String] = ["Top Winter Plants", "Common Issues", "Top Designs"]
}
    
