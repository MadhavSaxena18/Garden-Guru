//
//  CareReminderDataModel.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 17/01/25.
//

import Foundation

enum ReminderType: String, CaseIterable {
    case watering = "Watering"
    case fertilizing = "Fertilizing"
    
}

struct CareReminder {
    let id = UUID()
    let plantName: String
    let nickname: String
    let plantImageName: String
    let type: ReminderType
    let dueDate: Date
    var isCompleted: Bool
}

// Dummy data
class CareReminderData{
    static  var reminders: [CareReminder] = [
        CareReminder( plantName: "Snake Plant", nickname: "Near Dining Table", plantImageName: "snake_plant", type: .watering, dueDate: Date(), isCompleted: false),
        CareReminder( plantName: "Parlor Palm", nickname: "Near Sofa", plantImageName: "parlor_palm", type: .watering, dueDate: Date(),  isCompleted: false),
        CareReminder( plantName: "Parlor Palm", nickname: "near Window", plantImageName: "snake_plant", type: .fertilizing, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,  isCompleted: false),
        CareReminder( plantName: "Snake Plant", nickname: "In Living Room", plantImageName: "parlor_palm", type: .fertilizing, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,  isCompleted: false)
    ]
    static var careReminderSectionHeaderNames: [String] = [
        "Watering","Fertilization"
    ]
}
