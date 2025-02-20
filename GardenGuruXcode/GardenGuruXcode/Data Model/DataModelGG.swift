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
}

struct UsersPlantDisease {
    var usersPlantDisease : UUID //PK FOR USERPLANT DISEASE
    var usersPlantRelationID : UUID //FK FOR USER PLANT
    var diseaseID : UUID //FK FOR PLANT DISEASE
    var detectedDate : Date = .now
}


struct CareReminder_{
    var upcomingReminderForWater : Date
    var upcomingReminderForFertilizers : Date
    var upcomingReminderForRepotted : Date
    var isCompleted : Bool
}

struct careReminderOfUserPlant{
    var careReminderID : UUID = UUID()
    var userPlantRelationID : UUID  //FK FOR USER PLANT
}

enum Season {
    case winter , summer , rainy, Spring
}

enum Category {
    case medicinal , Ornamental, Flowering
}
