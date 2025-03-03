//
//  DataModelGG.swift
//  GardenGuruXcode
//
//  Created by SUKRIT RAJ on 30/01/25.
//

import Foundation

struct userInfo{
    var userName:String
    var userId : UUID = UUID()//PK FOR USER
    var location:String
    var reminderAllowed : Bool
}

struct Plant: Equatable {
    var plantID: UUID = UUID() // Primary Key FOR PLANT
    var plantName: String
    var plantImage: [String]
    var plantBotanicalName: String
    var category: Category
    var plantDescription: String
    var favourableSeason: Season
    var waterFrequency: Int
    var fertilizerFrequency: Int
    var repottingFrequency: Int
    var pruningFrequency: Int
    let idealTemperature: [Double]  // Array of suitable temperatures
    let lightRequirement: String 
}

struct Diseases : Equatable{
    var diseaseName : String
    var diseaseID : UUID = UUID() //PK for disease
    var diseaseDescription : String = ""
    var diseaseSymptoms : [String]
    var diseaseImage : [String]
    var diseaseCure : [String]
    var diseaseFertilizers : [String]
    var cureDuration : Int
    var diseaseDetail : [String : [String]]
    var diseaseSeason : Season
}


struct PlantDisease {
    var plantDiseaseID:UUID
    var plantID:UUID //FK FOR PLANT
    var diseaseID:UUID //FK FOR DISEASE
}


struct UserPlant {
    var userPlantRelationID : UUID = UUID()//PK FOR USER PLANT
    var userId : UUID  // FK FOR USER
    var userplantID : UUID //FK FOR PLANTS
    var userPlantNickName : String
    var lastWatered : Date
    var lastFertilized : Date
    var lastRepotted : Date
    var isWateringCompleted: Bool = false
    var isFertilizingCompleted: Bool = false
    var isRepottingCompleted: Bool = false
}

struct UsersPlantDisease {
    var usersPlantDisease : UUID //PK FOR USERPLANT DISEASE
    var usersPlantRelationID : UUID //FK FOR USER PLANT
    var diseaseID : UUID //FK FOR PLANT DISEASE
    var detectedDate : Date = .now
}


class CareReminder_ {
    let careReminderID: UUID
    var upcomingReminderForWater: Date
    var upcomingReminderForFertilizers: Date
    var upcomingReminderForRepotted: Date
    var isWateringCompleted: Bool
    var isFertilizingCompleted: Bool
    var isRepottingCompleted: Bool
    
    init(upcomingReminderForWater: Date, upcomingReminderForFertilizers: Date, upcomingReminderForRepotted: Date, isWateringCompleted: Bool, isFertilizingCompleted: Bool, isRepottingCompleted: Bool) {
        self.careReminderID = UUID()
        self.upcomingReminderForWater = upcomingReminderForWater
        self.upcomingReminderForFertilizers = upcomingReminderForFertilizers
        self.upcomingReminderForRepotted = upcomingReminderForRepotted
        self.isWateringCompleted = isWateringCompleted
        self.isFertilizingCompleted = isFertilizingCompleted
        self.isRepottingCompleted = isRepottingCompleted
    }
}

struct CareReminderOfUserPlant{
    var careReminderOfUserPlantID : UUID = UUID()
    var userPlantRelationID : UUID  //FK FOR USER PLANT
    var careReminderId : UUID //FK FOR CARE REMINDER
}

enum Season {
    case winter , summer , rainy, Spring
}

enum Category {
    case medicinal , Ornamental, Flowering
}
struct Design {
    var designID: UUID = UUID() //PK
    var name: String
    var description: String
    var image: String
}
struct PlantDesign {
    var plantDesignID: UUID = UUID()
    var plantID: UUID // FK FOR PLANT
    var designID: UUID // FK FOR DESIGN
}

//we have to add fertilizer and make its relation with diseases

struct Fertilizer {
    var fertilizerName: String
    var fertilizerId: UUID = UUID() // Unique ID
    var fertilizerImage: String
    var fertilizerDescription: String
    var type: String // Example: "Organic", "Chemical"
    var applicationMethod: String // Example: "Mix with soil"
    var applicationFrequency: String // Example: "Once per 2 weeks"
    var warningSigns: [String] // Example: ["Leaf burn", "Yellowing leaves"]
    var alternativeFertilizers: [String] // Example: ["Compost", "Bone meal"]
}

struct DiseaseFertilizer {
    var diseaseFertilizerId : UUID = UUID() //PK
    var diseaseID : UUID //FK FOR DISEASE
    var fertilizerId : UUID //FK FOR FETRTILIZER
}
