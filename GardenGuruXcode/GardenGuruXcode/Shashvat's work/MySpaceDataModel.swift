//
//  MySpaceDataModel.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//


import Foundation
import UIKit
struct Plant {
//    let id = UUID()
    let name: String
    let nickName: String
    let imageURL: String
  
}

struct Reminder {
//    let id = UUID()
    let plantID: UUID
    let type: String
    let dateTime: Date
    let isCompleted: Bool
}

struct User {
    let id = UUID()
    var plants: [Plant]
    var reminders: [Reminder]
}
class SectionData {
    static  var  plants: [Plant] = [
        Plant(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        Plant(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        Plant(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        Plant(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        Plant(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        Plant(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        Plant(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        Plant(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant")
    ]
    static var sectionHeaderNames:[String] = [
        "Parlor Palm",
        "Snake Plants",
        "String of Pearls"
    ]
    
//    var  reminders = [
//        Reminder(plantID: plants[0].id, type: "Watering", dateTime: Date(), isCompleted: false),
//        Reminder(plantID: plants[1].id, type: "Pruning", dateTime: Date().addingTimeInterval(86400), isCompleted: false)
//    ]
}


