//
//  CacheManager.swift
//  GardenGuruXcode
//
//  Cache manager for storing and retrieving plant and reminder data
//

import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private init() {}
    
    // MARK: - Cache Keys
    private enum CacheKeys {
        static func myPlantsKey(for userEmail: String) -> String {
            return "cache_myplants_\(userEmail)"
        }
        
        static func careRemindersKey(for userEmail: String) -> String {
            return "cache_reminders_\(userEmail)"
        }
        
        static func cacheTimestampKey(for key: String) -> String {
            return "\(key)_timestamp"
        }
    }
    
    // MARK: - Cache Expiry
    private let cacheExpiryInterval: TimeInterval = 300 // 5 minutes
    
    // MARK: - My Plants Cache
    
    /// Save My Plants data to cache
    func saveMyPlants(_ plants: [(userPlant: UserPlant, plant: Plant)], for userEmail: String) {
        print("💾 Saving \(plants.count) plants to cache for \(userEmail)")
        
        do {
            // Convert to codable structure
            let cacheable = plants.map { plantData -> CacheablePlant in
                CacheablePlant(
                    userPlantID: plantData.userPlant.userplantID,
                    userPlantRelationID: plantData.userPlant.userPlantRelationID,
                    userId: plantData.userPlant.userId,
                    userPlantNickName: plantData.userPlant.userPlantNickName,
                    userPlantImage: plantData.userPlant.userPlantImage,
                    lastWatered: plantData.userPlant.lastWatered,
                    lastFertilized: plantData.userPlant.lastFertilized,
                    lastRepotted: plantData.userPlant.lastRepotted,
                    plantID: plantData.plant.plantID,
                    plantName: plantData.plant.plantName,
                    plantBotanicalName: plantData.plant.plantBotanicalName,
                    plantImage: plantData.plant.plantImage,
                    plantDescription: plantData.plant.plantDescription,
                    category: plantData.plant.category_new,
                    waterFrequency: plantData.plant.waterFrequency,
                    fertilizerFrequency: plantData.plant.fertilizerFrequency,
                    repottingFrequency: plantData.plant.repottingFrequency
                )
            }
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(cacheable)
            
            let key = CacheKeys.myPlantsKey(for: userEmail)
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.set(Date(), forKey: CacheKeys.cacheTimestampKey(for: key))
            
            print("✅ Successfully cached \(plants.count) plants")
        } catch {
            print("❌ Error caching plants: \(error)")
        }
    }
    
    /// Load My Plants data from cache
    func loadMyPlants(for userEmail: String) -> [(userPlant: UserPlant, plant: Plant)]? {
        let key = CacheKeys.myPlantsKey(for: userEmail)
        
        // Check if cache exists
        guard let data = UserDefaults.standard.data(forKey: key) else {
            print("⚠️ No cached plants found for \(userEmail)")
            return nil
        }
        
        // Check if cache is expired
        if let timestamp = UserDefaults.standard.object(forKey: CacheKeys.cacheTimestampKey(for: key)) as? Date {
            let age = Date().timeIntervalSince(timestamp)
            if age > cacheExpiryInterval {
                print("⏰ Cache expired (\(Int(age))s old) - will fetch fresh data")
            } else {
                print("✅ Cache is fresh (\(Int(age))s old)")
            }
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let cacheable = try decoder.decode([CacheablePlant].self, from: data)
            
            // Convert back to tuples - use JSON encoding/decoding to create proper struct instances
            let plants = try cacheable.map { cached -> (userPlant: UserPlant, plant: Plant) in
                // Encode and decode to create proper UserPlant
                let userPlantDict: [String: Any?] = [
                    "userPlantRelationID": cached.userPlantRelationID.uuidString,
                    "userId": cached.userId.uuidString,
                    "userplantID": cached.userPlantID?.uuidString,
                    "userPlantNickName": cached.userPlantNickName,
                    "userPlantImage": cached.userPlantImage,
                    "lastWatered": cached.lastWatered?.ISO8601Format(),
                    "lastFertilized": cached.lastFertilized?.ISO8601Format(),
                    "lastRepotted": cached.lastRepotted?.ISO8601Format()
                ]
                let userPlantData = try JSONSerialization.data(withJSONObject: userPlantDict.compactMapValues { $0 })
                let userPlant = try JSONDecoder().decode(UserPlant.self, from: userPlantData)
                
                // Encode and decode to create proper Plant
                let plantDict: [String: Any?] = [
                    "plantID": cached.plantID.uuidString,
                    "plantName": cached.plantName,
                    "plantImage": cached.plantImage,
                    "plantBotanicalName": cached.plantBotanicalName,
                    "plantDescription": cached.plantDescription,
                    "waterFrequency": cached.waterFrequency,
                    "fertilizerFrequency": cached.fertilizerFrequency,
                    "repottingFrequency": cached.repottingFrequency,
                    "category_new": cached.category?.rawValue
                ]
                let plantData = try JSONSerialization.data(withJSONObject: plantDict.compactMapValues { $0 })
                let plant = try JSONDecoder().decode(Plant.self, from: plantData)
                
                return (userPlant: userPlant, plant: plant)
            }
            
            print("📦 Loaded \(plants.count) plants from cache")
            return plants
        } catch {
            print("❌ Error loading cached plants: \(error)")
            return nil
        }
    }
    
    // MARK: - Care Reminders Cache
    
    /// Save Care Reminders data to cache
    func saveCareReminders(_ reminders: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)], for userEmail: String) {
        print("💾 Saving \(reminders.count) reminders to cache for \(userEmail)")
        
        do {
            // Convert to codable structure
            let cacheable = reminders.map { reminderData -> CacheableReminder in
                CacheableReminder(
                    // UserPlant fields
                    userPlantID: reminderData.userPlant.userplantID,
                    userPlantRelationID: reminderData.userPlant.userPlantRelationID,
                    userId: reminderData.userPlant.userId,
                    userPlantNickName: reminderData.userPlant.userPlantNickName,
                    userPlantImage: reminderData.userPlant.userPlantImage,
                    lastWatered: reminderData.userPlant.lastWatered,
                    lastFertilized: reminderData.userPlant.lastFertilized,
                    lastRepotted: reminderData.userPlant.lastRepotted,
                    // Plant fields
                    plantID: reminderData.plant.plantID,
                    plantName: reminderData.plant.plantName,
                    plantImage: reminderData.plant.plantImage,
                    waterFrequency: reminderData.plant.waterFrequency,
                    fertilizerFrequency: reminderData.plant.fertilizerFrequency,
                    repottingFrequency: reminderData.plant.repottingFrequency,
                    // CareReminder fields
                    careReminderID: reminderData.reminder.careReminderID,
                    wateringEnabled: reminderData.reminder.wateringEnabled,
                    fertilizerEnabled: reminderData.reminder.fertilizerEnabled,
                    repottingEnabled: reminderData.reminder.repottingEnabled,
                    isWateringCompleted: reminderData.reminder.isWateringCompleted,
                    isFertilizingCompleted: reminderData.reminder.isFertilizingCompleted,
                    isRepottingCompleted: reminderData.reminder.isRepottingCompleted,
                    upcomingReminderForWater: reminderData.reminder.upcomingReminderForWater,
                    upcomingReminderForFertilizers: reminderData.reminder.upcomingReminderForFertilizers,
                    upcomingReminderForRepotted: reminderData.reminder.upcomingReminderForRepotted,
                    last_water_completed_date: reminderData.reminder.last_water_completed_date,
                    last_fertilizer_completed_date: reminderData.reminder.last_fertilizer_completed_date,
                    last_repot_completed_date: reminderData.reminder.last_repot_completed_date
                )
            }
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(cacheable)
            
            let key = CacheKeys.careRemindersKey(for: userEmail)
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.set(Date(), forKey: CacheKeys.cacheTimestampKey(for: key))
            
            print("✅ Successfully cached \(reminders.count) reminders")
        } catch {
            print("❌ Error caching reminders: \(error)")
        }
    }
    
    /// Load Care Reminders data from cache
    func loadCareReminders(for userEmail: String) -> [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)]? {
        let key = CacheKeys.careRemindersKey(for: userEmail)
        
        // Check if cache exists
        guard let data = UserDefaults.standard.data(forKey: key) else {
            print("⚠️ No cached reminders found for \(userEmail)")
            return nil
        }
        
        // Check if cache is expired
        if let timestamp = UserDefaults.standard.object(forKey: CacheKeys.cacheTimestampKey(for: key)) as? Date {
            let age = Date().timeIntervalSince(timestamp)
            if age > cacheExpiryInterval {
                print("⏰ Cache expired (\(Int(age))s old) - will fetch fresh data")
            } else {
                print("✅ Cache is fresh (\(Int(age))s old)")
            }
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let cacheable = try decoder.decode([CacheableReminder].self, from: data)
            
            // Convert back to tuples using JSON encoding/decoding
            let reminders = try cacheable.map { cached -> (userPlant: UserPlant, plant: Plant, reminder: CareReminder_) in
                // Create UserPlant
                let userPlantDict: [String: Any?] = [
                    "userPlantRelationID": cached.userPlantRelationID.uuidString,
                    "userId": cached.userId.uuidString,
                    "userplantID": cached.userPlantID?.uuidString,
                    "userPlantNickName": cached.userPlantNickName,
                    "userPlantImage": cached.userPlantImage,
                    "lastWatered": cached.lastWatered?.ISO8601Format(),
                    "lastFertilized": cached.lastFertilized?.ISO8601Format(),
                    "lastRepotted": cached.lastRepotted?.ISO8601Format()
                ]
                let userPlantData = try JSONSerialization.data(withJSONObject: userPlantDict.compactMapValues { $0 })
                let userPlant = try JSONDecoder().decode(UserPlant.self, from: userPlantData)
                
                // Create Plant
                let plantDict: [String: Any?] = [
                    "plantID": cached.plantID.uuidString,
                    "plantName": cached.plantName,
                    "plantImage": cached.plantImage,
                    "waterFrequency": cached.waterFrequency,
                    "fertilizerFrequency": cached.fertilizerFrequency,
                    "repottingFrequency": cached.repottingFrequency
                ]
                let plantData = try JSONSerialization.data(withJSONObject: plantDict.compactMapValues { $0 })
                let plant = try JSONDecoder().decode(Plant.self, from: plantData)
                
                // Create CareReminder_
                let reminderDict: [String: Any?] = [
                    "careReminderID": cached.careReminderID.uuidString,
                    "wateringEnabled": cached.wateringEnabled,
                    "fertilizerEnabled": cached.fertilizerEnabled,
                    "repottingEnabled": cached.repottingEnabled,
                    "isWateringCompleted": cached.isWateringCompleted,
                    "isFertilizingCompleted": cached.isFertilizingCompleted,
                    "isRepottingCompleted": cached.isRepottingCompleted,
                    "upcomingReminderForWater": cached.upcomingReminderForWater?.ISO8601Format(),
                    "upcomingReminderForFertilizers": cached.upcomingReminderForFertilizers?.ISO8601Format(),
                    "upcomingReminderForRepotted": cached.upcomingReminderForRepotted?.ISO8601Format(),
                    "last_water_completed_date": cached.last_water_completed_date?.ISO8601Format(),
                    "last_fertilizer_completed_date": cached.last_fertilizer_completed_date?.ISO8601Format(),
                    "last_repot_completed_date": cached.last_repot_completed_date?.ISO8601Format()
                ]
                let reminderData = try JSONSerialization.data(withJSONObject: reminderDict.compactMapValues { $0 })
                let reminder = try JSONDecoder().decode(CareReminder_.self, from: reminderData)
                
                return (userPlant: userPlant, plant: plant, reminder: reminder)
            }
            
            print("📦 Loaded \(reminders.count) reminders from cache")
            return reminders
        } catch {
            print("❌ Error loading cached reminders: \(error)")
            return nil
        }
    }
    
    // MARK: - Clear Cache
    
    /// Clear all cached data for a specific user
    func clearCache(for userEmail: String) {
        print("🗑️ Clearing cache for \(userEmail)")
        
        let plantsKey = CacheKeys.myPlantsKey(for: userEmail)
        let remindersKey = CacheKeys.careRemindersKey(for: userEmail)
        
        UserDefaults.standard.removeObject(forKey: plantsKey)
        UserDefaults.standard.removeObject(forKey: CacheKeys.cacheTimestampKey(for: plantsKey))
        UserDefaults.standard.removeObject(forKey: remindersKey)
        UserDefaults.standard.removeObject(forKey: CacheKeys.cacheTimestampKey(for: remindersKey))
        
        print("✅ Cache cleared")
    }
    
    /// Clear all cached data (for logout)
    func clearAllCache() {
        print("🗑️ Clearing all cache data")
        
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix("cache_") {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        print("✅ All cache cleared")
    }
}

// MARK: - Codable Structures

struct CacheablePlant: Codable {
    let userPlantID: UUID?
    let userPlantRelationID: UUID
    let userId: UUID
    let userPlantNickName: String?
    let userPlantImage: String?
    let lastWatered: Date?
    let lastFertilized: Date?
    let lastRepotted: Date?
    
    let plantID: UUID
    let plantName: String
    let plantBotanicalName: String?
    let plantImage: String?
    let plantDescription: String?
    let category: Category?
    let waterFrequency: Int64?
    let fertilizerFrequency: Int64?
    let repottingFrequency: Int64?
}

struct CacheableReminder: Codable {
    // UserPlant fields
    let userPlantID: UUID?
    let userPlantRelationID: UUID
    let userId: UUID
    let userPlantNickName: String?
    let userPlantImage: String?
    let lastWatered: Date?
    let lastFertilized: Date?
    let lastRepotted: Date?
    
    // Plant fields
    let plantID: UUID
    let plantName: String
    let plantImage: String?
    let waterFrequency: Int64?
    let fertilizerFrequency: Int64?
    let repottingFrequency: Int64?
    
    // CareReminder fields
    let careReminderID: UUID
    let wateringEnabled: Bool
    let fertilizerEnabled: Bool
    let repottingEnabled: Bool
    let isWateringCompleted: Bool?
    let isFertilizingCompleted: Bool?
    let isRepottingCompleted: Bool?
    let upcomingReminderForWater: Date?
    let upcomingReminderForFertilizers: Date?
    let upcomingReminderForRepotted: Date?
    let last_water_completed_date: Date?
    let last_fertilizer_completed_date: Date?
    let last_repot_completed_date: Date?
}
