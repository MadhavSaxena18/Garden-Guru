//
//  DataModelGG.swift
//  GardenGuruXcode
//
//  Created by SUKRIT RAJ on 30/01/25.
//

import Foundation

// MARK: - Data Models

struct userInfo: Codable, Hashable {
    var userEmail: String
    var userName: String
    var location: String
    var reminderAllowed: Bool
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case userEmail = "user_email"
        case userName
        case location
        case reminderAllowed
        case id
    }
    
    init(userEmail: String, userName: String, location: String, reminderAllowed: Bool, id: String = UUID().uuidString) {
        self.userEmail = userEmail
        self.userName = userName
        self.location = location
        self.reminderAllowed = reminderAllowed
        self.id = id
    }
}

struct Plant: Codable, Hashable, Equatable {
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

struct Diseases: Codable, Hashable {
    let diseaseID: UUID
    let diseaseName: String
    let diseaseDescription: String
    let diseaseImage: [String]
    let diseaseSymptoms: [String]
    let symptoms: [String]
    let causes: [String]
    let treatment: [String]
    let prevention: [String]
    let diseaseSeason: Season
    let diseaseCure: [String]
    let diseaseFertilizers: [String]
    let cureDuration: Int
    let diseaseDetail: [String: [String]]
    
    // Add memberwise initializer
    init(diseaseID: UUID = UUID(),
         diseaseName: String,
         diseaseDescription: String = "",
         diseaseImage: [String] = [],
         diseaseSymptoms: [String] = [],
         symptoms: [String] = [],
         causes: [String] = [],
         treatment: [String] = [],
         prevention: [String] = [],
         diseaseSeason: Season,
         diseaseCure: [String] = [],
         diseaseFertilizers: [String] = [],
         cureDuration: Int = 0,
         diseaseDetail: [String: [String]] = [:]) {
        self.diseaseID = diseaseID
        self.diseaseName = diseaseName
        self.diseaseDescription = diseaseDescription
        self.diseaseImage = diseaseImage
        self.diseaseSymptoms = diseaseSymptoms
        self.symptoms = symptoms
        self.causes = causes
        self.treatment = treatment
        self.prevention = prevention
        self.diseaseSeason = diseaseSeason
        self.diseaseCure = diseaseCure
        self.diseaseFertilizers = diseaseFertilizers
        self.cureDuration = cureDuration
        self.diseaseDetail = diseaseDetail
    }
    
    // Add computed properties to maintain compatibility
    var diseaseSymptomsList: [String] {
        return diseaseSymptoms.isEmpty ? symptoms : diseaseSymptoms
    }
    
    var diseaseCauses: [String] {
        return causes
    }
    
    var diseaseTreatment: [String] {
        return treatment.isEmpty ? diseaseCure : treatment
    }
    
    var diseasePrevention: [String] {
        return prevention
    }
    
    // Custom coding keys to handle both old and new property names
    private enum CodingKeys: String, CodingKey {
        case diseaseID
        case diseaseName
        case diseaseDescription
        case diseaseImage
        case diseaseSymptoms
        case symptoms
        case causes
        case treatment
        case prevention
        case diseaseSeason
        case diseaseCure
        case diseaseFertilizers
        case cureDuration
        case diseaseDetail
    }
    
    // Custom initializer to set default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        diseaseID = try container.decode(UUID.self, forKey: .diseaseID)
        diseaseName = try container.decode(String.self, forKey: .diseaseName)
        diseaseDescription = try container.decodeIfPresent(String.self, forKey: .diseaseDescription) ?? ""
        diseaseImage = try container.decodeIfPresent([String].self, forKey: .diseaseImage) ?? []
        
        // Handle both old and new symptom properties
        if let oldSymptoms = try? container.decode([String].self, forKey: .diseaseSymptoms) {
            diseaseSymptoms = oldSymptoms
            symptoms = oldSymptoms
        } else {
            let newSymptoms = try container.decodeIfPresent([String].self, forKey: .symptoms) ?? []
            diseaseSymptoms = newSymptoms
            symptoms = newSymptoms
        }
        
        causes = try container.decodeIfPresent([String].self, forKey: .causes) ?? []
        treatment = try container.decodeIfPresent([String].self, forKey: .treatment) ?? []
        prevention = try container.decodeIfPresent([String].self, forKey: .prevention) ?? []
        diseaseSeason = try container.decode(Season.self, forKey: .diseaseSeason)
        diseaseCure = try container.decodeIfPresent([String].self, forKey: .diseaseCure) ?? []
        diseaseFertilizers = try container.decodeIfPresent([String].self, forKey: .diseaseFertilizers) ?? []
        cureDuration = try container.decodeIfPresent(Int.self, forKey: .cureDuration) ?? 0
        diseaseDetail = try container.decodeIfPresent([String: [String]].self, forKey: .diseaseDetail) ?? [:]
    }
}

struct PlantDisease: Codable, Hashable {
    var plantDiseaseID: UUID
    var plantID: UUID //FK FOR PLANT
    var diseaseID: UUID //FK FOR DISEASE
}

struct UserPlant: Codable, Hashable {
    var userPlantRelationID: UUID
    var userplantID: UUID
    var userId: String  // Changed from UUID to String to match database schema
    var userPlantNickName: String
    var lastWatered: Date
    var lastFertilized: Date
    var lastRepotted: Date
    var isWateringCompleted: Bool = false
    var isFertilizingCompleted: Bool = false
    var isRepottingCompleted: Bool = false
}

struct UsersPlantDisease: Codable, Hashable {
    var usersPlantDisease: UUID //PK FOR USERPLANT DISEASE
    var usersPlantRelationID: UUID //FK FOR USER PLANT
    var diseaseID: UUID //FK FOR PLANT DISEASE
    var detectedDate: Date = .now
}

class CareReminder_: Codable {
    let careReminderID: UUID
    var upcomingReminderForWater: Date
    var upcomingReminderForFertilizers: Date
    var upcomingReminderForRepotted: Date
    var isWateringCompleted: Bool
    var isFertilizingCompleted: Bool
    var isRepottingCompleted: Bool
    
    init(userPlantID: UUID, wateringDate: Date?, fertilizingDate: Date?, repottingDate: Date?) {
        self.careReminderID = userPlantID
        self.upcomingReminderForWater = wateringDate ?? Date.distantFuture
        self.upcomingReminderForFertilizers = fertilizingDate ?? Date.distantFuture
        self.upcomingReminderForRepotted = repottingDate ?? Date.distantFuture
        self.isWateringCompleted = false
        self.isFertilizingCompleted = false
        self.isRepottingCompleted = false
    }
    
    // Required for Codable when using a class
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        careReminderID = try container.decode(UUID.self, forKey: .careReminderID)
        upcomingReminderForWater = try container.decode(Date.self, forKey: .upcomingReminderForWater)
        upcomingReminderForFertilizers = try container.decode(Date.self, forKey: .upcomingReminderForFertilizers)
        upcomingReminderForRepotted = try container.decode(Date.self, forKey: .upcomingReminderForRepotted)
        isWateringCompleted = try container.decode(Bool.self, forKey: .isWateringCompleted)
        isFertilizingCompleted = try container.decode(Bool.self, forKey: .isFertilizingCompleted)
        isRepottingCompleted = try container.decode(Bool.self, forKey: .isRepottingCompleted)
    }
    
    // CodingKeys to match the database column names
    private enum CodingKeys: String, CodingKey {
        case careReminderID
        case upcomingReminderForWater
        case upcomingReminderForFertilizers
        case upcomingReminderForRepotted
        case isWateringCompleted
        case isFertilizingCompleted
        case isRepottingCompleted
    }
}

struct CareReminderOfUserPlant: Codable, Hashable {
    var careReminderOfUserPlantID: UUID = UUID()
    var userPlantRelationID: UUID  //FK FOR USER PLANT
    var careReminderId: UUID //FK FOR CARE REMINDER
}

enum Season: String, Codable, Hashable {
    case winter, summer, spring, autumn
}

enum Category: String, Codable, Hashable {
    case medicinal, Ornamental, Flowering
}

struct Design: Codable, Hashable {
    var designID: UUID = UUID() //PK
    var name: String
    var description: String
    var image: String
}

struct PlantDesign: Codable, Hashable {
    var plantDesignID: UUID = UUID()
    var plantID: UUID // FK FOR PLANT
    var designID: UUID // FK FOR DESIGN
}

struct Fertilizer: Codable, Hashable {
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

struct DiseaseFertilizer: Codable, Hashable {
    var diseaseFertilizerId: UUID = UUID() //PK
    var diseaseID: UUID //FK FOR DISEASE
    var fertilizerId: UUID //FK FOR FETRTILIZER
}

// Add notification name extension
extension Notification.Name {
    static let plantAdded = Notification.Name("NewPlantAdded")
}
