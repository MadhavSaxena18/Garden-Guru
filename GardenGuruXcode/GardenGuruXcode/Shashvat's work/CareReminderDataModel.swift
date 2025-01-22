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
    case pruning = "Pruning"
    
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
            CareReminder( plantName: "Snake Plant", nickname: "Near Dining Table", plantImageName: "snake_plant3", type: .watering, dueDate: Date(), isCompleted: false),
            CareReminder( plantName: "Parlor Palm", nickname: "Near Sofa", plantImageName: "parlor_palm4", type: .pruning, dueDate: Date(),  isCompleted: false),
            CareReminder( plantName: "Dragon Plant", nickname: "Near Window", plantImageName: "dragon_plant2", type: .watering, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,  isCompleted: false),
            CareReminder( plantName: "Babies Tears", nickname: "In Living Room", plantImageName: "babys_tears2", type: .fertilizing, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,  isCompleted: false),
            CareReminder( plantName: "Money Tree", nickname: "Near kitchen", plantImageName: "money_tree2", type: .watering, dueDate: Date(), isCompleted: false),
            CareReminder( plantName: "Fibre Optic Grass", nickname: "Near Sofa", plantImageName: "fibre_optic_grass_plant3", type: .fertilizing, dueDate: Date(),  isCompleted: false),
            CareReminder( plantName: "Peace Lily", nickname: "Near Window", plantImageName: "peace_lily3", type: .pruning, dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,  isCompleted: false),
            CareReminder( plantName: "Strings of Pearls", nickname: "In Living Room", plantImageName: "string_of_pearls2", type: .fertilizing, dueDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!,  isCompleted: false),
            CareReminder( plantName: "Parlor Palm", nickname: "Near Dining Table", plantImageName: "parlor_palm3", type: .pruning, dueDate: Date(), isCompleted: false)
        ]
    static var careReminderSectionHeaderNames: [String] = [
        "Watering","Fertilization","Pruning"
    ]
}
