//
//  MySpaceDataModel.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//


import Foundation
import UIKit
struct MySpaceSection1Data {
//    let id = UUID()
    let name: String
    let nickName: String
    let imageURL: String
    //check commit
  
}
struct MySpaceSection2Data {
//    let id = UUID()
    let name: String
    let nickName: String
    let imageURL: String
  
}
struct MySpaceSection3Data {
//    let id = UUID()
    let name: String
    let nickName: String
    let imageURL: String
  
}
struct MySpaceSection4Data {
//    let id = UUID()
    let name: String
    let nickName: String
    let imageURL: String
  
}

//struct Reminder {
////    let id = UUID()
//    let plantID: UUID
//    let type: String
//    let dateTime: Date
//    let isCompleted: Bool
//}

//struct User {
//    let id = UUID()
//    var plants: [Plant]
//    var reminders: [Reminder]
//}
class MySpaceScreen {
    static  var  mySpaceSection1Data: [MySpaceSection1Data] = [
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant")
    ]
    static  var  mySpaceSection2Data: [MySpaceSection1Data] = [
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant")
    ]
    static  var  mySpaceSection3Data: [MySpaceSection1Data] = [
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant")
    ]
    static  var  mySpaceSection4Data: [MySpaceSection1Data] = [
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant"),
        MySpaceSection1Data(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm" ),
        MySpaceSection1Data(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant")
    ]
    static var sectionHeaderNames:[String] = [
        "Parlor Palm",
        "Snake Plants",
        "String of Pearls"
    ]
    static var totalPlants:Int?
    
//    var  reminders = [
//        Reminder(plantID: plants[0].id, type: "Watering", dateTime: Date(), isCompleted: false),
//        Reminder(plantID: plants[1].id, type: "Pruning", dateTime: Date().addingTimeInterval(86400), isCompleted: false)
//    ]
}


