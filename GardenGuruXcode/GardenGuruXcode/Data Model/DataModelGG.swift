//
//  DataModelGG.swift
//  GardenGuruXcode
//
//  Created by SUKRIT RAJ on 30/01/25.
//

import Foundation

struct user{
    var userName:String
    var userId : UUID
    var location:String
    var reminderAllowed : Bool
    var plants : [UserPlant]
}

//struct Plant : Equatable{
//    static func == (lhs: Plant, rhs: Plant) -> Bool {
//        return lhs.plantID == rhs.plantID
//    }
//    
//    //plant Info
//    var plantName:String
//    var plantID:UUID = UUID()
//    var plantNickName : String
//    var plantImage : [String]
//    var plantBotanicalName : String
//    var category : Category
//    var plantDescription : String
//    var favourableSeason : Season
//    
//    //common Issue variables
//    var commonIssue:[Diseases]
////    var commonIssueName : [String]
////    var commonIssueImages : [String]
////    var commonIssueDescription : [String]
//    
//    //reminders variable
//    var waterFrequency : Int
//    var fertilizerFrequency : Int
//    var repottingFrequency : Int
//    var pruningFrequency : Int
//    
////    //design ideas
////    var designName : [String]
////    var designImages : [String]
//    
//    //disease
//    var disease : [Diseases]
//    
////    init(
////            plantName: String,
////            plantNickName: String,
////            plantImage: [String],
////            plantBotanicalName: String,
////            category: Category,
////            plantDescription: String,
////            favourableSeason: Season,
////            disease: [Diseases],  // Pass all possible diseases
////            waterFrequency: Int,
////            fertilizerFrequency: Int,
////            repottingFrequency: Int,
////            pruningFrequency: Int,
////            commonIssue:[Diseases],
////            commonIssuesNames: [String] // Provide names of common issues
////        ) {
////            self.plantName = plantName
////            self.plantNickName = plantNickName
////            self.plantImage = plantImage
////            self.plantBotanicalName = plantBotanicalName
////            self.category = category
////            self.plantDescription = plantDescription
////            self.favourableSeason = favourableSeason
////            self.disease = disease  // Store all diseases
////            
////            // Automatically assign common issues by filtering diseases
////            self.commonIssue = disease.filter { commonIssuesNames.contains($0.diseaseName) }
////            
////            self.waterFrequency = waterFrequency
////            self.fertilizerFrequency = fertilizerFrequency
////            self.repottingFrequency = repottingFrequency
////            self.pruningFrequency = pruningFrequency
////        }
//}
struct Plant: Equatable {
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        return lhs.plantID == rhs.plantID
    }
    
    var plantName: String
    var plantID: UUID = UUID()
    var plantNickName: String
    var plantImage: [String]
    var plantBotanicalName: String
    var category: Category
    var plantDescription: String
    var favourableSeason: Season
    
    var disease: [Diseases]
    var commonIssue: [Diseases]
    
    var waterFrequency: Int
    var fertilizerFrequency: Int
    var repottingFrequency: Int
    var pruningFrequency: Int

    init(
        plantName: String,
        plantNickName: String,
        plantImage: [String],
        plantBotanicalName: String,
        category: Category,
        plantDescription: String,
        favourableSeason: Season,
        disease: [Diseases],
        waterFrequency: Int,
        fertilizerFrequency: Int,
        repottingFrequency: Int,
        pruningFrequency: Int
    ) {
        self.plantName = plantName
        self.plantNickName = plantNickName
        self.plantImage = plantImage
        self.plantBotanicalName = plantBotanicalName
        self.category = category
        self.plantDescription = plantDescription
        self.favourableSeason = favourableSeason
        self.disease = disease
        self.waterFrequency = waterFrequency
        self.fertilizerFrequency = fertilizerFrequency
        self.repottingFrequency = repottingFrequency
        self.pruningFrequency = pruningFrequency
        
       
        self.commonIssue = disease.filter { $0.diseaseSeason == favourableSeason }
    }
}



struct Diseases : Equatable{
    static func == (lhs: Diseases, rhs: Diseases) -> Bool {
        return lhs.diseaseName == rhs.diseaseName
    }
    var diseaseName : String
    var diseaseID : Int8
    var diseaseSymptoms : [String]
    var diseaseImage : [String]
    var diseaseCure : [String]
    var diseaseFertilizers : [String]
    var cureDuration : Int
    var diseaseSeason : Season
}

enum Season {
    case winter , summer , rainy, Spring
}

enum Category {
    case medicinal , Ornamental, Flowering
}

struct UserPlant {
    var userplant : [Plant]
    var lastWatered : Date
    var lastFertilized : Date
    var lastRepotted : Date
    var userDisease : [Diseases]
}


struct CareReminder_{
    var reminderOfPlant : [UserPlant]
    var upcomingReminderForWater : Date
    var upcomingReminderForFertilizers : Date
    var upcomingReminderForRepotted : Date
    var isCompleted : Bool
}
