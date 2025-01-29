//
//  MySpaceDataModel.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//


import Foundation
import UIKit
struct MySpaceSectionData {
//    let id = UUID()
    let name: String
    let nickName: String
    let imageURL: String
    //check commit
  
}
//struct MySpaceSection2Data {
////    let id = UUID()
//    let name: String
//    let nickName: String
//    let imageURL: String
//  
//}
//struct MySpaceSection3Data {
////    let id = UUID()
//    let name: String
//    let nickName: String
//    let imageURL: String
//  
//}
//struct MySpaceSection4Data {
////    let id = UUID()
//    let name: String
//    let nickName: String
//    let imageURL: String
//  
//}

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
    static  var  mySpaceSection1Data: [MySpaceSectionData] = [
        MySpaceSectionData(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm3" ),
        MySpaceSectionData(name: "Parlor Palm", nickName: "On the Roof", imageURL: "parlor_palm2"),
       
        MySpaceSectionData(name: "Parlor Palm", nickName: "Near Sofa", imageURL: "parlor_palm3" ),
        MySpaceSectionData(name: "Parlor Palm", nickName: "On the Roof", imageURL: "parlor_palm4")
    ]
    static  var  mySpaceSection2Data: [MySpaceSectionData] = [
        MySpaceSectionData(name: "Snake Plant", nickName: "Near Window", imageURL: "snake_plant4" ),
        MySpaceSectionData(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant2"),
        MySpaceSectionData(name: "Snake Plant", nickName: "Near Sofa", imageURL: "snake_plant3" ),
        MySpaceSectionData(name: "Snake Plant", nickName: "On the Roof", imageURL: "snake_plant4"),
        MySpaceSectionData(name: "Snake Plant", nickName: "Near Sofa", imageURL: "snake_plant5" )
        
    ]
    static  var  mySpaceSection3Data: [MySpaceSectionData] = [
        MySpaceSectionData(name: "String of Pearls", nickName: "Near Table", imageURL: "string_of_pearls5" ),
        MySpaceSectionData(name: "String of Pearls", nickName: "On the Roof", imageURL: "string_of_pearls4"),
        MySpaceSectionData(name: "String of Pearls", nickName: "Near Sofa", imageURL: "string_of_pearls3" ),
        MySpaceSectionData(name: "String of Pearls", nickName: "On the Roof", imageURL: "string_of_pearls2"),
        MySpaceSectionData(name: "String of Pearls", nickName: "Near Sofa", imageURL: "parlor_palm" )
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


