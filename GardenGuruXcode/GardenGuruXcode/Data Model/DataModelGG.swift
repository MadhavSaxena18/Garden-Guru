//
//  DataModelGG.swift
//  GardenGuruXcode
//
//  Created by SUKRIT RAJ on 30/01/25.
//

import Foundation
import SDWebImage

// MARK: - Data Models

struct userInfo: Codable, Hashable {
    var id: String
    var userName: String
    var location: String?
    var reminderAllowed: Bool?
    var userEmail: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName
        case location
        case reminderAllowed
        case userEmail = "user_email"
    }
    
    init(id: String, userName: String, location: String? = nil, reminderAllowed: Bool? = nil, userEmail: String? = nil) {
        self.id = id
        self.userName = userName
        self.location = location
        self.reminderAllowed = reminderAllowed
        self.userEmail = userEmail
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decode(String.self, forKey: .id)
        userName = try container.decode(String.self, forKey: .userName)
        
        // Optional fields
        location = try container.decodeIfPresent(String.self, forKey: .location)
        reminderAllowed = try container.decodeIfPresent(Bool.self, forKey: .reminderAllowed)
        userEmail = try container.decodeIfPresent(String.self, forKey: .userEmail)
    }
}

struct Plant: Codable, Hashable, Equatable {
    var plantID: UUID
    var plantName: String
    var plantImage: String?
    var plantBotanicalName: String?
    var plantDescription: String?
    var waterFrequency: Int64?
    var fertilizerFrequency: Int64?
    var repottingFrequency: Int64?
    var pruningFrequency: Int64?
    var favourableSeason: Season?
    var category_new: Category?
    
    enum CodingKeys: String, CodingKey {
        case plantID
        case plantName
        case plantImage
        case plantBotanicalName
        case plantDescription
        case waterFrequency
        case fertilizerFrequency
        case repottingFrequency
        case pruningFrequency
        case favourableSeason
        case category_new
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID decoding
        if let uuidString = try? container.decode(String.self, forKey: .plantID) {
            plantID = UUID(uuidString: uuidString) ?? UUID()
        } else {
            plantID = UUID()
        }
        
        // Decode other properties
        plantName = try container.decode(String.self, forKey: .plantName)
        plantImage = try container.decodeIfPresent(String.self, forKey: .plantImage)
        plantBotanicalName = try container.decodeIfPresent(String.self, forKey: .plantBotanicalName)
        plantDescription = try container.decodeIfPresent(String.self, forKey: .plantDescription)
        waterFrequency = try container.decodeIfPresent(Int64.self, forKey: .waterFrequency)
        fertilizerFrequency = try container.decodeIfPresent(Int64.self, forKey: .fertilizerFrequency)
        repottingFrequency = try container.decodeIfPresent(Int64.self, forKey: .repottingFrequency)
        pruningFrequency = try container.decodeIfPresent(Int64.self, forKey: .pruningFrequency)
        favourableSeason = try container.decodeIfPresent(Season.self, forKey: .favourableSeason)
        category_new = try container.decodeIfPresent(Category.self, forKey: .category_new)
    }
}

struct Diseases: Codable, Hashable {
    let diseaseID: UUID
    let diseaseName: String
    var diseaseSymptoms: String?
    var diseaseImage: String?
    var diseaseCure: String?
    var diseaseFertilizers: String?
    var cureDuration: Int64?
    var diseaseSeason: Season?
    var diseasePreventiveMeasures: String?
    var diseaseVideoSolution: String?
    
    enum CodingKeys: String, CodingKey {
        case diseaseID = "diseaseID"
        case diseaseName = "diseaseName"
        case diseaseSymptoms = "diseaseSymptoms"
        case diseaseImage = "diseaseImage"
        case diseaseCure = "diseaseCure"
        case diseaseFertilizers = "diseaseFertilizers"
        case cureDuration = "cureDuration"
        case diseaseSeason = "diseaseSeason"
        case diseasePreventiveMeasures = "diseasePreventiveMeasures"
        case diseaseVideoSolution = "diseaseVideoSolution"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID decoding with better error handling
        if let uuidString = try? container.decode(String.self, forKey: .diseaseID) {
            print("📝 Decoded diseaseID: \(uuidString)")
            diseaseID = UUID(uuidString: uuidString) ?? UUID()
        } else {
            print("⚠️ Failed to decode diseaseID, using new UUID")
            diseaseID = UUID()
        }
        
        // Decode required fields with error handling
        do {
            diseaseName = try container.decode(String.self, forKey: .diseaseName)
            print("📝 Decoded diseaseName: \(diseaseName)")
        } catch {
            print("❌ Error decoding diseaseName: \(error)")
            throw error
        }
        
        // Decode optional fields with better error handling
        do {
            if let symptoms = try container.decodeIfPresent(String.self, forKey: .diseaseSymptoms) {
                print("📝 Decoded symptoms: \(symptoms)")
                diseaseSymptoms = symptoms
            }
            
            if let image = try container.decodeIfPresent(String.self, forKey: .diseaseImage) {
                print("📝 Decoded image URL: \(image)")
                diseaseImage = image
            }
            
            if let cure = try container.decodeIfPresent(String.self, forKey: .diseaseCure) {
                print("📝 Decoded cure: \(cure)")
                diseaseCure = cure
            }
            
            if let fertilizers = try container.decodeIfPresent(String.self, forKey: .diseaseFertilizers) {
                print("📝 Decoded fertilizers: \(fertilizers)")
                diseaseFertilizers = fertilizers
            }
            
            if let duration = try container.decodeIfPresent(Int64.self, forKey: .cureDuration) {
                print("📝 Decoded duration: \(duration)")
                cureDuration = duration
            }
            
            if let season = try container.decodeIfPresent(Season.self, forKey: .diseaseSeason) {
                print("📝 Decoded season: \(season)")
                diseaseSeason = season
            }
            
            if let preventiveMeasures = try container.decodeIfPresent(String.self, forKey: .diseasePreventiveMeasures) {
                print("📝 Decoded preventive measures: \(preventiveMeasures)")
                diseasePreventiveMeasures = preventiveMeasures
            }
            
            if let videoSolution = try container.decodeIfPresent(String.self, forKey: .diseaseVideoSolution) {
                print("📝 Decoded video solution: \(videoSolution)")
                diseaseVideoSolution = videoSolution
            }
        } catch {
            print("⚠️ Error decoding optional fields: \(error)")
            // Don't throw here, just continue with nil values
        }
    }
}

struct UserPlant: Codable, Hashable {
    var userPlantRelationID: UUID
    var userId: UUID
    var userplantID: UUID?
    var userPlantNickName: String?
    var userPlantImage: String?
    var lastWatered: Date?
    var lastFertilized: Date?
    var lastRepotted: Date?
    var associatedDiseases: [Diseases]?
    
    init(userPlantRelationID: UUID,
         userId: UUID,
         userplantID: UUID?,
         userPlantNickName: String? = nil,
         userPlantImage: String? = nil,
         lastWatered: Date? = nil,
         lastFertilized: Date? = nil,
         lastRepotted: Date? = nil,
         associatedDiseases: [Diseases]? = nil) {
        self.userPlantRelationID = userPlantRelationID
        self.userId = userId
        self.userplantID = userplantID
        self.userPlantNickName = userPlantNickName
        self.userPlantImage = userPlantImage
        self.lastWatered = lastWatered
        self.lastFertilized = lastFertilized
        self.lastRepotted = lastRepotted
        self.associatedDiseases = associatedDiseases
    }
    
    enum CodingKeys: String, CodingKey {
        case userPlantRelationID
        case userId
        case userplantID
        case userPlantNickName
        case userPlantImage
        case lastWatered
        case lastFertilized
        case lastRepotted
        case associatedDiseases
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID decoding
        if let relationIDString = try? container.decode(String.self, forKey: .userPlantRelationID) {
            userPlantRelationID = UUID(uuidString: relationIDString) ?? UUID()
        } else {
            userPlantRelationID = UUID()
        }
        
        if let userIDString = try? container.decode(String.self, forKey: .userId) {
            userId = UUID(uuidString: userIDString) ?? UUID()
        } else {
            userId = UUID()
        }
        
        // Decode optional UUID
        if let plantIDString = try container.decodeIfPresent(String.self, forKey: .userplantID) {
            userplantID = UUID(uuidString: plantIDString)
        }
        
        // Decode other properties
        userPlantNickName = try container.decodeIfPresent(String.self, forKey: .userPlantNickName)
        userPlantImage = try container.decodeIfPresent(String.self, forKey: .userPlantImage)
        
        // Handle date decoding with custom date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let lastWateredString = try container.decodeIfPresent(String.self, forKey: .lastWatered) {
            lastWatered = dateFormatter.date(from: lastWateredString)
        }
        if let lastFertilizedString = try container.decodeIfPresent(String.self, forKey: .lastFertilized) {
            lastFertilized = dateFormatter.date(from: lastFertilizedString)
        }
        if let lastRepottedString = try container.decodeIfPresent(String.self, forKey: .lastRepotted) {
            lastRepotted = dateFormatter.date(from: lastRepottedString)
        }
        associatedDiseases = try container.decodeIfPresent([Diseases].self, forKey: .associatedDiseases)
    }
}

struct UsersPlantDisease: Codable, Hashable {
    var usersPlantDisease: UUID //PK FOR USERPLANT DISEASE
    var usersPlantRelationID: UUID //FK FOR USER PLANT
    var diseaseID: UUID //FK FOR PLANT DISEASE
    var detectedDate: Date = .now
}

struct CareReminder_: Codable, Hashable {
    var careReminderID: UUID
    var upcomingReminderForWater: Date?
    var upcomingReminderForFertilizers: Date?
    var upcomingReminderForRepotted: Date?
    var isWateringCompleted: Bool?
    var isFertilizingCompleted: Bool?
    var isRepottingCompleted: Bool?
    var last_water_completed_date: Date?
    var last_fertilizer_completed_date: Date?
    var last_repot_completed_date: Date?
    var wateringEnabled: Bool = false
    var fertilizerEnabled: Bool = false
    var repottingEnabled: Bool = false
    
    init(careReminderID: UUID,
         upcomingReminderForWater: Date? = nil,
         upcomingReminderForFertilizers: Date? = nil,
         upcomingReminderForRepotted: Date? = nil,
         isWateringCompleted: Bool? = nil,
         isFertilizingCompleted: Bool? = nil,
         isRepottingCompleted: Bool? = nil,
         last_water_completed_date: Date? = nil,
         last_fertilizer_completed_date: Date? = nil,
         last_repot_completed_date: Date? = nil,
         wateringEnabled: Bool = false,
         fertilizerEnabled: Bool = false,
         repottingEnabled: Bool = false) {
        self.careReminderID = careReminderID
        self.upcomingReminderForWater = upcomingReminderForWater
        self.upcomingReminderForFertilizers = upcomingReminderForFertilizers
        self.upcomingReminderForRepotted = upcomingReminderForRepotted
        self.isWateringCompleted = isWateringCompleted
        self.isFertilizingCompleted = isFertilizingCompleted
        self.isRepottingCompleted = isRepottingCompleted
        self.last_water_completed_date = last_water_completed_date
        self.last_fertilizer_completed_date = last_fertilizer_completed_date
        self.last_repot_completed_date = last_repot_completed_date
        self.wateringEnabled = wateringEnabled
        self.fertilizerEnabled = fertilizerEnabled
        self.repottingEnabled = repottingEnabled
    }
    
    enum CodingKeys: String, CodingKey {
        case careReminderID
        case upcomingReminderForWater
        case upcomingReminderForFertilizers
        case upcomingReminderForRepotted
        case isWateringCompleted
        case isFertilizingCompleted
        case isRepottingCompleted
        case last_water_completed_date
        case last_fertilizer_completed_date
        case last_repot_completed_date
        case wateringEnabled
        case fertilizerEnabled
        case repottingEnabled
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID decoding
        if let uuidString = try? container.decode(String.self, forKey: .careReminderID) {
            careReminderID = UUID(uuidString: uuidString) ?? UUID()
        } else {
            careReminderID = UUID()
        }
        
        // Create date formatters
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Function to parse date string using multiple formatters
        func parseDate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Date? {
            guard let dateString = try? container.decode(String.self, forKey: key) else { return nil }
            
            // Try ISO8601 format first
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            
            // Try simple date format next
            if let date = simpleDateFormatter.date(from: dateString) {
                return date
            }
            
            print("⚠️ Could not parse date string: \(dateString)")
            return nil
        }
        
        // Decode dates using the helper function
        upcomingReminderForWater = parseDate(from: container, forKey: .upcomingReminderForWater)
        upcomingReminderForFertilizers = parseDate(from: container, forKey: .upcomingReminderForFertilizers)
        upcomingReminderForRepotted = parseDate(from: container, forKey: .upcomingReminderForRepotted)
        last_water_completed_date = parseDate(from: container, forKey: .last_water_completed_date)
        last_fertilizer_completed_date = parseDate(from: container, forKey: .last_fertilizer_completed_date)
        last_repot_completed_date = parseDate(from: container, forKey: .last_repot_completed_date)
        
        // Decode boolean values
        isWateringCompleted = try container.decodeIfPresent(Bool.self, forKey: .isWateringCompleted)
        isFertilizingCompleted = try container.decodeIfPresent(Bool.self, forKey: .isFertilizingCompleted)
        isRepottingCompleted = try container.decodeIfPresent(Bool.self, forKey: .isRepottingCompleted)
        
        // Decode enabled states
        wateringEnabled = try container.decodeIfPresent(Bool.self, forKey: .wateringEnabled) ?? false
        fertilizerEnabled = try container.decodeIfPresent(Bool.self, forKey: .fertilizerEnabled) ?? false
        repottingEnabled = try container.decodeIfPresent(Bool.self, forKey: .repottingEnabled) ?? false
        
        // Print decoded dates for debugging
        print("📅 Decoded Water Date: \(upcomingReminderForWater?.description ?? "nil")")
        print("📅 Decoded Fertilizer Date: \(upcomingReminderForFertilizers?.description ?? "nil")")
        print("📅 Decoded Repot Date: \(upcomingReminderForRepotted?.description ?? "nil")")
        print("🔔 Enabled States:")
        print("- Water: \(wateringEnabled)")
        print("- Fertilizer: \(fertilizerEnabled)")
        print("- Repotting: \(repottingEnabled)")
    }
}

struct CareReminderUpdate: Encodable {
    var upcomingReminderForWater: String?
    var upcomingReminderForFertilizers: String?
    var upcomingReminderForRepotted: String?
    var isWateringCompleted: Bool?
    var isFertilizingCompleted: Bool?
    var isRepottingCompleted: Bool?
    var last_water_completed_date: String?
    var last_fertilizer_completed_date: String?
    var last_repot_completed_date: String?
    
    enum CodingKeys: String, CodingKey {
        case upcomingReminderForWater
        case upcomingReminderForFertilizers
        case upcomingReminderForRepotted
        case isWateringCompleted
        case isFertilizingCompleted
        case isRepottingCompleted
        case last_water_completed_date
        case last_fertilizer_completed_date
        case last_repot_completed_date
    }
}

// Add this struct near other model definitions
struct CareReminderInsert: Encodable {
    let careReminderID: String
    let upcomingReminderForWater: String?
    let upcomingReminderForFertilizers: String?
    let upcomingReminderForRepotted: String?
    let isWateringCompleted: Bool
    let isFertilizingCompleted: Bool
    let isRepottingCompleted: Bool
    let last_water_completed_date: String?
    let last_fertilizer_completed_date: String?
    let last_repot_completed_date: String?
    let wateringEnabled: Bool
    let fertilizerEnabled: Bool
    let repottingEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case careReminderID
        case upcomingReminderForWater
        case upcomingReminderForFertilizers
        case upcomingReminderForRepotted
        case isWateringCompleted
        case isFertilizingCompleted
        case isRepottingCompleted
        case last_water_completed_date
        case last_fertilizer_completed_date
        case last_repot_completed_date
        case wateringEnabled
        case fertilizerEnabled
        case repottingEnabled
    }
}

struct CareReminderOfUserPlant: Codable, Hashable {
    var careReminderOfUserPlantID: UUID = UUID()
    var userPlantRelationID: UUID  //FK FOR USER PLANT
    var careReminderId: UUID //FK FOR CARE REMINDER
}

enum Season: String, Codable, Hashable {
    case Winter = "winter"
    case Summer = "summer"
    case Spring = "spring"
    case Autumn = "autumn"
}

enum Category: String, Codable, Hashable {
    case ornamental, flowering, medical
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
    var fertilizerId: UUID
    var fertilizerName: String
    var fertilizerImage: String?
    var fertilizerDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case fertilizerId
        case fertilizerName
        case fertilizerImage
        case fertilizerDescription
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID decoding
        if let uuidString = try? container.decode(String.self, forKey: .fertilizerId) {
            fertilizerId = UUID(uuidString: uuidString) ?? UUID()
        } else {
            fertilizerId = UUID()
        }
        
        // Decode required fields
        fertilizerName = try container.decode(String.self, forKey: .fertilizerName)
        
        // Decode optional fields
        fertilizerImage = try container.decodeIfPresent(String.self, forKey: .fertilizerImage)
        fertilizerDescription = try container.decodeIfPresent(String.self, forKey: .fertilizerDescription)
    }
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
