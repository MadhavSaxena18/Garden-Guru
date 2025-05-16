//
//  DataControllerGG.swift
//  GardenGuruXcode
//
//  Created by SUKRIT RAJ on 30/01/25.
//

import Foundation
import UIKit
import Supabase
import CoreLocation

class supaBaseController {
    static let shared = supaBaseController()
    public let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://swygmlgykjhvncaqsnxw.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3eWdtbGd5a2podm5jYXFzbnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMTg5NDcsImV4cCI6MjA2MDc5NDk0N30.1n8et91JSCN2LMZ24bTzcuEER-449Dx0GDc8Nr1XTXU"
        )
    }
}

// Add this struct near the top of the file with other model definitions
private struct UserTableInsert: Encodable {
    let id: String
    let user_email: String
    let userName: String
    let location: String
    let reminderAllowed: Bool
}

class DataControllerGG: NSObject, CLLocationManagerDelegate {
    static let shared = DataControllerGG()
    private let supabase = supaBaseController.shared.client
    private var reminderCompletionStates: [UUID: [String: Bool]] = [:]
    let currentDate = Date()
    
    private override init() {
        super.init()
    }
    
    // MARK: - User Functions
    
    func getUser() async throws -> userInfo? {
        print("🔍 Fetching first user from Supabase...")
        
        // Try to get the email from UserDefaults
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            print("❌ No email found in UserDefaults")
            return nil
        }
        
        let response = try await supabase
            .database
            .from("UserTable")
            .select()
            .eq("user_email", value: email)
            .execute()
        
        print("📡 Raw response data: \(String(describing: response.data))")
        
        guard let jsonObject = response.data as? [[String: Any]],
              let firstUser = jsonObject.first else {
            print("❌ No user data found")
            return nil
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: firstUser)
            let user = try JSONDecoder().decode(userInfo.self, from: jsonData)
            print("✅ Successfully decoded user with email: \(user.userEmail)")
            return user
        } catch {
            print("❌ Failed to decode user data: \(error)")
            return nil
        }
    }
    
    func getUsers() async throws -> [userInfo] {
        let response = try await supabase
            .database
            .from("UserTable")
            .select()
            .execute()
        
        if let jsonData = response.data as? Data {
            return try JSONDecoder().decode([userInfo].self, from: jsonData)
        }
        return []
    }
    
    // MARK: - Plant Functions
    
    func getPlant(by plantID: UUID) async throws -> Plant? {
        print("🔍 Fetching plant with ID: \(plantID)")
        let response = try await supabase
            .database
            .from("Plant")
            .select()
            .eq("plantID", value: plantID.uuidString)
            .execute()
        
        print("📡 Raw plant response data: \(String(describing: response.data))")
        
        if let jsonData = response.data as? Data {
            let plants = try JSONDecoder().decode([Plant].self, from: jsonData)
            print("✅ Decoded plants count: \(plants.count)")
            return plants.first
        }
        print("❌ Failed to decode plant data")
        return nil
    }
    
    func getUserPlants(for userEmail: String) async throws -> [UserPlant] {
        print("🔍 Fetching user plants for user email: \(userEmail)")
        
        // First get the user's ID from UserTable
        let userResponse = try await supabase
            .database
            .from("UserTable")
            .select()
            .eq("user_email", value: userEmail)
            .execute()
        
        print("📡 Raw user response: \(String(describing: userResponse.data))")
        
       if let jsonData = userResponse.data as? Data,
           let users = try? JSONDecoder().decode([userInfo].self, from: jsonData),
           let user = users.first {
            print("✅ Found user ID: \(user.id)")
            
            // Now get the user's plants using the correct ID
            let response = try await supabase
                .database
                .from("UserPlant")
                .select()
                .eq("userId", value: user.id)
                .execute()
            
            print("📡 Raw user plants response: \(String(describing: response.data))")
            
            if let jsonData = response.data as? Data {
                let userPlants = try JSONDecoder().decode([UserPlant].self, from: jsonData)
                print("✅ Decoded \(userPlants.count) user plants")
                return userPlants
            } else if let jsonObject = response.data as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
                let userPlants = try JSONDecoder().decode([UserPlant].self, from: jsonData)
                print("✅ Decoded \(userPlants.count) user plants")
                return userPlants
            }
        }
        
        print("❌ No user plants found")

        // Try to decode the response data
        var userIdString: String?
        if let data = userResponse.data as? Data {
            do {
                let users = try JSONDecoder().decode([userInfo].self, from: data)
                if let firstUser = users.first {
                    userIdString = firstUser.id
                    print("✅ Found user ID: \(firstUser.id)")
                }
            } catch {
                print("❌ Error decoding user data: \(error)")
            }
        } else if let jsonObject = userResponse.data as? [[String: Any]],
                  let firstUser = jsonObject.first,
                  let id = firstUser["id"] as? String {
            userIdString = id
            print("✅ Found user ID: \(id)")
        }
        
        guard let userId = userIdString else {
            print("❌ Could not find user ID for email: \(userEmail)")
            return []
        }
        
        // Now get the user's plants using the correct ID
        let response = try await supabase
            .database
            .from("UserPlant")
            .select()
            .eq("userId", value: userId)
            .execute()
        
        print("📡 Raw user plants response: \(String(describing: response.data))")
        
        if let data = response.data as? Data {
            do {
                let userPlants = try JSONDecoder().decode([UserPlant].self, from: data)
                print("✅ Decoded user plants count: \(userPlants.count)")
                return userPlants
            } catch {
                print("❌ Error decoding user plants: \(error)")
            }
        } else if let jsonObject = response.data as? [[String: Any]] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
                let userPlants = try JSONDecoder().decode([UserPlant].self, from: jsonData)
                print("✅ Decoded user plants count: \(userPlants.count)")
                return userPlants
            } catch {
                print("❌ Error decoding user plants: \(error)")
            }
        }
        
        print("❌ Failed to decode user plants data")

        return []
    }
    
    // MARK: - Care Reminder Functions
    
    func getCareReminders(for userPlantID: UUID) async throws -> CareReminder_? {
        print("\n=== Fetching Care Reminder ===")
        print("🔍 Looking for reminder with userPlantID: \(userPlantID)")
        
        // First get the care reminder link
        print("📡 Querying CareReminderOfUserPlant table...")
        let linkResponse = try await supabase
            .database
            .from("CareReminderOfUserPlant")
            .select("careReminderId")
            .eq("userPlantRelationID", value: userPlantID.uuidString)
            .execute()
        
        print("📡 Raw link response type: \(type(of: linkResponse.data))")
        
        // Handle Data response
        guard let data = linkResponse.data as? Data,
              let jsonString = String(data: data, encoding: .utf8) else {
            print("❌ Could not get data from response")
            return nil
        }
        
        print("📡 Response as string: \(jsonString)")
        
        // Parse the JSON string
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
              let firstLink = jsonArray.first,
              let careReminderId = firstLink["careReminderId"] as? String else {
            print("❌ No care reminder link found")
            return nil
        }
        
        print("✅ Found careReminderId: \(careReminderId)")
        
        // Then get the actual care reminder
        print("\n📡 Querying CareReminder_ table for ID: \(careReminderId)")
        let reminderResponse = try await supabase
            .database
            .from("CareReminder_")
            .select()
            .eq("careReminderID", value: careReminderId)
            .execute()
        
        print("📡 Raw reminder response type: \(type(of: reminderResponse.data))")
        
        // Handle reminder Data response
        guard let reminderData = reminderResponse.data as? Data,
              let reminderString = String(data: reminderData, encoding: .utf8) else {
            print("❌ Could not get reminder data")
            return nil
        }
        
        print("📡 Reminder response as string: \(reminderString)")
        
        // Parse the reminder JSON
        if let reminderJsonData = reminderString.data(using: .utf8) {
            do {
                let reminders = try JSONDecoder().decode([CareReminder_].self, from: reminderJsonData)
                print("✅ Successfully decoded \(reminders.count) reminders")
                return reminders.first
            } catch {
                print("❌ Failed to decode reminder: \(error)")
            }
        }
        
        print("❌ No care reminder found")
        return nil
    }
    
    func updateCareReminderStatus(userPlantID: UUID, type: String, isCompleted: Bool) async throws {
        // First get the plant details to know the frequency
        let userPlants = try await getUserPlantsWithBasicDetails(for: UserDefaults.standard.string(forKey: "userEmail") ?? "")
        guard let userPlant = userPlants.first(where: { $0.userPlant.userPlantRelationID == userPlantID }) else {
            print("❌ Plant not found for updating reminder")
            return
        }
        
        // Get the care reminder
        guard let reminder = try await getCareReminders(for: userPlantID) else {
            print("❌ Care reminder not found")
            return
        }
        
        // Create a properly typed update object
        var update = CareReminderUpdate()
        let calendar = Calendar.current
        let dateFormatter = ISO8601DateFormatter()
        let currentDate = Date()
        
        switch type.lowercased() {
        case "water":
            update.isWateringCompleted = isCompleted
            if isCompleted {
                // Set the completion timestamp
                update.lastWaterCompletedDate = dateFormatter.string(from: currentDate)
                if let waterFreq = userPlant.plant.waterFrequency {
                    // Set next water date based on frequency
                    if let nextDate = calendar.date(byAdding: .day, value: Int(waterFreq), to: currentDate) {
                        update.upcomingReminderForWater = dateFormatter.string(from: nextDate)
                    }
                }
            }
        case "fertilizer":
            update.isFertilizingCompleted = isCompleted
            if isCompleted {
                // Set the completion timestamp
                update.lastFertilizerCompletedDate = dateFormatter.string(from: currentDate)
                if let fertFreq = userPlant.plant.fertilizerFrequency {
                    // Set next fertilizer date based on frequency
                    if let nextDate = calendar.date(byAdding: .day, value: Int(fertFreq), to: currentDate) {
                        update.upcomingReminderForFertilizers = dateFormatter.string(from: nextDate)
                    }
                }
            }
        case "repot":
            update.isRepottingCompleted = isCompleted
            if isCompleted {
                // Set the completion timestamp
                update.lastRepotCompletedDate = dateFormatter.string(from: currentDate)
                if let repotFreq = userPlant.plant.repottingFrequency {
                    // Set next repotting date based on frequency
                    if let nextDate = calendar.date(byAdding: .day, value: Int(repotFreq), to: currentDate) {
                        update.upcomingReminderForRepotted = dateFormatter.string(from: nextDate)
                    }
                }
            }
        default:
            break
        }
        
        // Update the reminder status and next date if completed
        try await supabase
            .database
            .from("CareReminder_")
            .update(update)
            .eq("careReminderID", value: reminder.careReminderID.uuidString)
            .execute()
    }
    
    func deleteUserPlant(userPlantID: UUID) async throws {
        // First delete the care reminder linking record
        try await supabase
            .database
            .from("CareReminderOfUserPlant")
            .delete()
            .eq("userPlantRelationID", value: userPlantID.uuidString)
            .execute()
            
        // Then delete the care reminder
        try await supabase
            .database
            .from("CareReminder_")
            .delete()
            .eq("careReminderID", value: userPlantID.uuidString)
            .execute()
            
        // Finally delete the user plant
        try await supabase
            .database
            .from("UserPlant")
            .delete()
            .eq("userPlantRelationID", value: userPlantID.uuidString)
            .execute()
    }
    
    // MARK: - Plant Functions
    
    func getPlants() async throws -> [Plant] {
        print("🔍 Fetching all plants from Supabase...")
                let response = try await supabase
                    .database
                    .from("Plant")
                    .select()
                    .execute()
                
                print("📡 Raw plants response: \(String(describing: response.data))")
        print("📡 Response type: \(type(of: response.data))")
                
        if let data = response.data as? Data {
            print("✅ Successfully got Data response")
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let plants = try decoder.decode([Plant].self, from: data)
                    print("✅ Successfully decoded \(plants.count) plants")
                return plants
            } catch {
                print("❌ Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type) at path: \(context.codingPath)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: expected \(type) at path: \(context.codingPath)")
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key) at path: \(context.codingPath)")
                    case .dataCorrupted(let context):
                        print("Data corrupted at path: \(context.codingPath)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                throw error
            }
        }
        print("❌ Failed to get Data from response")
        return []
    }
    
    // Function to get a single plant by ID
    func getPlantbyName(by name: String) async throws -> Plant? {
        let response = try await supabase
            .database
            .from("Plant")
            .select()
            .eq("plantName", value: name)
            .execute()
        
        if let jsonData = response.data as? Data {
            return try JSONDecoder().decode([Plant].self, from: jsonData).first
        }
        return nil
    }
    
    // Function to get plant by name (new method name)
    func getPlantByName(by name: String) async throws -> Plant? {
        return try await getPlantbyName(by: name)
    }
    
    // Function to update plant images with support for both URL strings and UIImage
    func updatePlantImages(plantID: UUID, imageURLs: [String]) async throws {
        try await supabase
            .database
            .from("Plant")
            .update(["imageURLs": imageURLs])
            .eq("plantID", value: plantID.uuidString)
            .execute()
    }
    
    // Legacy method for updating plant images with UIImage
    func updatePlantImages(plantName: String, newImage: UIImage) {
        // Convert UIImage to URL or base64 string as needed
        // This is a placeholder implementation
        print("Legacy updatePlantImages called with plantName: \(plantName)")
    }
    
    // MARK: - Disease Functions
    
    func getDiseases(for plantID: UUID) async throws -> [Diseases] {
        print("🔍 Fetching diseases for plant ID: \(plantID)")
        
        // First get the plant-disease relationships
        let plantDiseasesResponse = try await supabase
            .database
            .from("PlantDisease")
            .select()
            .eq("plantID", value: plantID.uuidString)
            .execute()
        
        print("📡 Raw plant diseases response: \(String(describing: plantDiseasesResponse.data))")
        
        var diseases: [Diseases] = []
        
        if let jsonObject = plantDiseasesResponse.data as? [[String: Any]] {
            print("✅ Found \(jsonObject.count) plant-disease relationships")
            
            for plantDisease in jsonObject {
                guard let diseaseIDString = plantDisease["diseaseID"] as? String,
                      let diseaseID = UUID(uuidString: diseaseIDString) else {
                    print("⚠️ Invalid disease ID in plant disease relationship")
                    continue
                }
                
                // Get disease details
                let diseaseResponse = try await supabase
                    .database
                    .from("Diseases")
                    .select()
                    .eq("diseaseID", value: diseaseID.uuidString)
                    .execute()
                
                if let diseaseJsonObject = diseaseResponse.data as? [[String: Any]],
                   let diseaseData = try? JSONSerialization.data(withJSONObject: diseaseJsonObject.first ?? [:]),
                   let disease = try? JSONDecoder().decode(Diseases.self, from: diseaseData) {
                    diseases.append(disease)
                    print("✅ Added disease: \(disease.diseaseName)")
                }
            }
        }
        
        print("✅ Total diseases found: \(diseases.count)")
        return diseases
    }
    
    // Function to get disease details
    func getDiseaseDetails(by diseaseID: UUID) async throws -> Diseases? {
        let response = try await supabase
            .database
            .from("Diseases")
            .select()
            .eq("diseaseID", value: diseaseID.uuidString)
            .execute()
        
        if let jsonData = response.data as? Data {
            return try JSONDecoder().decode([Diseases].self, from: jsonData).first
        }
        return nil
    }
    
    // MARK: - Season Plants Functions
    
    func getTopSeasonPlants() -> [Plant] {
        // This is a synchronous wrapper for UI that can't handle async
        var plants: [Plant] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            let response = try await supabase
                .database
                .from("Plant")
                .select()
                .execute()
            
            if let jsonData = response.data as? Data {
                plants = try JSONDecoder().decode([Plant].self, from: jsonData)
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return plants
    }
    
    // MARK: - Common Issues Functions
    
    func getCommonIssues() async throws -> [Diseases] {
        print("🔍 Fetching common issues from Supabase...")
                let response = try await supabase
                    .database
                    .from("Diseases")
                    .select()
                    .execute()
                
                print("📡 Raw diseases response: \(String(describing: response.data))")
        print("📡 Response type: \(type(of: response.data))")
        
        if let jsonData = response.data as? Data {
            print("✅ Successfully got Data response")
            do {
                let diseases = try JSONDecoder().decode([Diseases].self, from: jsonData)
                    print("✅ Successfully decoded \(diseases.count) diseases")
                return diseases
            } catch {
                print("❌ Decoding error: \(error)")
                print("Error details: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key.stringValue), context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: \(type), context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: \(type), context: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                return []
            }
        } else if let jsonObject = response.data as? [[String: Any]] {
            print("✅ Successfully got JSON object array")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
                let diseases = try JSONDecoder().decode([Diseases].self, from: jsonData)
                print("✅ Successfully decoded \(diseases.count) diseases")
                return diseases
            } catch {
                print("❌ JSON serialization/decoding error: \(error)")
                print("Error details: \(error.localizedDescription)")
                return []
            }
        }
        
        print("❌ Failed to decode diseases data - unexpected response type")
        return []
    }
    
    // MARK: - User Plant Functions
    
    func getCommonIssuesForUserPlants() -> [Diseases] {
        // This is a synchronous wrapper for UI that can't handle async
        var diseases: [Diseases] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            let response = try await supabase
                .database
                .from("Diseases")
                .select()
                .execute()
            
            if let jsonData = response.data as? Data {
                diseases = try JSONDecoder().decode([Diseases].self, from: jsonData)
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return diseases
    }
    
    // MARK: - Fertilizer Functions
    
    func getCommonFertilizers() async throws -> [Fertilizer] {
        print("🔍 Fetching common fertilizers from Supabase...")
            let response = try await supabase
                .database
                .from("Fertilizer")
                .select()
                .execute()
            
        print("📡 Raw fertilizers response: \(String(describing: response.data))")
        print("📡 Response type: \(type(of: response.data))")
        
        if let data = response.data as? Data {
            print("✅ Successfully got Data response")
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let fertilizers = try decoder.decode([Fertilizer].self, from: data)
                print("✅ Successfully decoded \(fertilizers.count) fertilizers")
        return fertilizers
            } catch {
                print("❌ Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type) at path: \(context.codingPath)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: expected \(type) at path: \(context.codingPath)")
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key) at path: \(context.codingPath)")
                    case .dataCorrupted(let context):
                        print("Data corrupted at path: \(context.codingPath)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                throw error
            }
        }
        print("❌ Failed to get Data from response")
        return []
    }
    
    // Helper method to determine season based on date and location
    func getCurrentSeason() -> Season {
        let location = getCurrentLocationSync()
        let date = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        
        // Default to northern hemisphere if location not available
        let isNorthernHemisphere = location?.coordinate.latitude ?? 0 >= 0
        
        switch month {
        case 3...5:
            return isNorthernHemisphere ? .Spring : .Autumn
        case 6...8:
            return isNorthernHemisphere ? .Summer : .Winter
        case 9...11:
            return isNorthernHemisphere ? .Autumn : .Spring
        default: // 12, 1, 2
            return isNorthernHemisphere ? .Winter : .Summer
        }
    }
    
    // Helper method to get current location description
    func getLocationDescription() -> String {
        guard let location = getCurrentLocationSync() else {
            return "Unknown Location"
        }
        
        let geocoder = CLGeocoder()
        let semaphore = DispatchSemaphore(value: 0)
        var result = "Unknown Location"
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            defer { semaphore.signal() }
            
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }
            
            if let placemark = placemarks?.first {
                let components = [
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }
                
                result = components.joined(separator: ", ")
            }
        }
        
        _ = semaphore.wait(timeout: .now() + 5) // 5 second timeout
        return result
    }
    
    // Helper functions
    private func getUserLocation() -> String {
        return UserDefaults.standard.string(forKey: "userLocation") ?? "North India"
    }
    
    func addUserPlant(userPlant: UserPlant) async throws {
        try await supabase
            .database
            .from("UserPlant")
            .insert(userPlant)
            .execute()
    }
    
    // Synchronous wrapper for addUserPlant
    func addUserPlantSync(userPlant: UserPlant) {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await addUserPlant(userPlant: userPlant)
            } catch {
                print("Error adding user plant: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
    }

    // Synchronous wrapper for getPlantbyName
    func getPlantbyNameSync(name: String) -> Plant? {
        var plant: Plant?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                plant = try await getPlantbyName(by: name)
            } catch {
                print("Error getting plant by name: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return plant
    }

    // Synchronous wrapper for getDiseaseDetails
    func getDiseaseDetailsSync(diseaseID: UUID) -> Diseases? {
        var disease: Diseases?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                disease = try await getDiseaseDetails(by: diseaseID)
            } catch {
                print("Error getting disease details: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return disease
    }

    // MARK: - Complex Data Fetching
    
    func getUserPlantsWithDetails(for userId: String) async throws -> [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] {
        print("\n=== Getting User Plants With Details ===")
        print("🔍 Fetching details for user ID: \(userId)")
        
        let userPlants = try await getUserPlants(for: userId)
        print("✅ Found \(userPlants.count) user plants")
        
        var result: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []
        
        for userPlant in userPlants {
            print("\n🌿 Processing plant with relation ID: \(userPlant.userPlantRelationID)")
            
            if let plantId = userPlant.userplantID {
                print("🔍 Looking up plant with ID: \(plantId)")
                if let plant = try await getPlant(by: plantId) {
                    print("✅ Found plant: \(plant.plantName)")
                    
                    print("🔍 Looking up care reminder...")
                    if let reminder = try await getCareReminders(for: userPlant.userPlantRelationID) {
                        print("✅ Found existing reminder")
                        result.append((userPlant: userPlant, plant: plant, reminder: reminder))
                    } else {
                        print("ℹ️ No reminder found for this plant")
                    }
                } else {
                    print("❌ Plant not found for ID: \(plantId)")
                }
            } else {
                print("❌ User plant has no plant ID")
            }
        }
        
        print("\n📊 Final Results:")
        print("Total user plants: \(userPlants.count)")
        print("Successfully processed with reminders: \(result.count)")
        
        return result
    }
    
    // Synchronous wrapper for getUserPlantsWithDetails
    func getUserPlantsWithDetailsSync(for userId: String) -> [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] {
        var result: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                result = try await getUserPlantsWithDetails(for: userId)
            } catch {
                print("Error getting user plants with details: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return result
    }
    
    // Function to get user plants with basic details
    func getUserPlantsWithBasicDetails(for userEmail: String) async throws -> [(userPlant: UserPlant, plant: Plant)] {
        print("\n=== Getting User Plants with Basic Details ===")
        print("🔍 Fetching for user email: \(userEmail)")
        
        let userPlants = try await getUserPlants(for: userEmail)
        print("📱 Found \(userPlants.count) user plants")
        
        if userPlants.isEmpty {
            print("⚠️ No user plants found for email: \(userEmail)")
            print("🔍 Checking if user exists in UserTable...")
            if let user = try await getUser() {
                print("✅ User exists: \(user.userEmail)")
            } else {
                print("❌ User not found in UserTable")
            }
        }
        
        var result: [(userPlant: UserPlant, plant: Plant)] = []
        
        for userPlant in userPlants {
            print("\n🌿 Processing user plant:")
            print("- Relation ID: \(userPlant.userPlantRelationID)")
            print("- Plant ID: \(userPlant.userplantID?.uuidString ?? "nil")")
            print("- Nickname: \(userPlant.userPlantNickName ?? "nil")")
            
            if let plantID = userPlant.userplantID {
                print("🔍 Looking up plant with ID: \(plantID)")
                if let plant = try await getPlant(by: plantID) {
                    print("✅ Found plant: \(plant.plantName)")
                    result.append((userPlant: userPlant, plant: plant))
                } else {
                    print("❌ No plant found for ID: \(plantID)")
                }
            } else {
                print("⚠️ User plant has no plant ID")
            }
        }
        
        print("\n📊 Final Results:")
        print("Total user plants processed: \(userPlants.count)")
        print("Successfully matched plants: \(result.count)")
        
        return result
    }
    
    // Synchronous wrapper for getUserPlantsWithBasicDetails
    func getUserPlantsWithBasicDetailsSync(for userEmail: String) -> [(userPlant: UserPlant, plant: Plant)]? {
        print("\n=== Getting User Plants with Basic Details (Sync) ===")
        print("📧 User email: \(userEmail)")
        
        var result: [(userPlant: UserPlant, plant: Plant)]?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                result = try await getUserPlantsWithBasicDetails(for: userEmail)
                print("✅ Successfully fetched \(result?.count ?? 0) plants")
            } catch {
                print("❌ Error getting user plants: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return result
    }
    
    // Function to update care reminder with all details
    func updateCareReminderWithDetails(userPlantID: UUID, type: String, isCompleted: Bool) async throws {
        print("\n=== Updating Care Reminder ===")
        print("🔍 Looking for reminder with userPlantID: \(userPlantID)")
        print("📝 Update type: \(type), isCompleted: \(isCompleted)")
        
        // Get the care reminder link
        let linkResponse = try await supabase
            .database
            .from("CareReminderOfUserPlant")
            .select("careReminderId")
            .eq("userPlantRelationID", value: userPlantID.uuidString)
            .execute()
        
        print("📡 Raw link response: \(String(describing: linkResponse.data))")
        
        guard let linkData = linkResponse.data as? Data,
              let linkString = String(data: linkData, encoding: .utf8) else {
            print("❌ Could not decode link response")
            throw APIError(message: "Failed to decode link response")
        }
        
        print("📡 Link string: \(linkString)")
        
        guard let linkJsonData = linkString.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: linkJsonData) as? [[String: Any]],
              let firstLink = jsonArray.first,
              let careReminderId = firstLink["careReminderId"] as? String else {
            print("❌ Could not parse care reminder ID")
            throw APIError(message: "Failed to parse care reminder ID")
        }
        
        print("✅ Found careReminderId: \(careReminderId)")
        
        // Create update object
        var update = CareReminderUpdate()
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let currentDate = Date()
        
        print("📅 Current date: \(currentDate)")
        
        // Get the current reminder to check its dates
        let reminderResponse = try await supabase
            .database
            .from("CareReminder_")
            .select()
            .eq("careReminderID", value: careReminderId)
            .execute()
            
        guard let reminderData = reminderResponse.data as? Data,
              let reminderString = String(data: reminderData, encoding: .utf8),
              let reminderJsonData = reminderString.data(using: .utf8),
              let reminders = try? JSONDecoder().decode([CareReminder_].self, from: reminderJsonData),
              let currentReminder = reminders.first else {
            print("❌ Could not get current reminder")
            throw APIError(message: "Failed to get current reminder")
        }
        
        switch type.lowercased() {
        case "water":
            update.isWateringCompleted = isCompleted
            if isCompleted {
                // Set the completion date
                update.lastWaterCompletedDate = dateFormatter.string(from: currentDate)
                
                // Only update the next reminder date if today's date is over
                if let currentReminderDate = currentReminder.upcomingReminderForWater,
                   !Calendar.current.isDateInToday(currentReminderDate) {
                    // Get the plant frequency
                    if let userPlants = try? await getUserPlantsWithBasicDetails(for: UserDefaults.standard.string(forKey: "userEmail") ?? ""),
                       let userPlant = userPlants.first(where: { $0.userPlant.userPlantRelationID == userPlantID }),
                       let waterFreq = userPlant.plant.waterFrequency {
                        // Calculate next date from the current reminder date
                        if let nextDate = Calendar.current.date(byAdding: .day, value: Int(waterFreq), to: currentReminderDate) {
                            update.upcomingReminderForWater = dateFormatter.string(from: nextDate)
                            print("💧 Setting next water date: \(update.upcomingReminderForWater ?? "nil")")
                        }
                    }
                }
            }
            
        case "fertilizer":
            update.isFertilizingCompleted = isCompleted
            if isCompleted {
                // Set the completion date
                update.lastFertilizerCompletedDate = dateFormatter.string(from: currentDate)
                
                // Only update the next reminder date if today's date is over
                if let currentReminderDate = currentReminder.upcomingReminderForFertilizers,
                   !Calendar.current.isDateInToday(currentReminderDate) {
                    // Get the plant frequency
                    if let userPlants = try? await getUserPlantsWithBasicDetails(for: UserDefaults.standard.string(forKey: "userEmail") ?? ""),
                       let userPlant = userPlants.first(where: { $0.userPlant.userPlantRelationID == userPlantID }),
                       let fertFreq = userPlant.plant.fertilizerFrequency {
                        // Calculate next date from the current reminder date
                        if let nextDate = Calendar.current.date(byAdding: .day, value: Int(fertFreq), to: currentReminderDate) {
                            update.upcomingReminderForFertilizers = dateFormatter.string(from: nextDate)
                            print("🌱 Setting next fertilizer date: \(update.upcomingReminderForFertilizers ?? "nil")")
                        }
                    }
                }
            }
            
        case "repot":
            update.isRepottingCompleted = isCompleted
            if isCompleted {
                // Set the completion date
                update.lastRepotCompletedDate = dateFormatter.string(from: currentDate)
                
                // Only update the next reminder date if today's date is over
                if let currentReminderDate = currentReminder.upcomingReminderForRepotted,
                   !Calendar.current.isDateInToday(currentReminderDate) {
                    // Get the plant frequency
                    if let userPlants = try? await getUserPlantsWithBasicDetails(for: UserDefaults.standard.string(forKey: "userEmail") ?? ""),
                       let userPlant = userPlants.first(where: { $0.userPlant.userPlantRelationID == userPlantID }),
                       let repotFreq = userPlant.plant.repottingFrequency {
                        // Calculate next date from the current reminder date
                        if let nextDate = Calendar.current.date(byAdding: .day, value: Int(repotFreq), to: currentReminderDate) {
                            update.upcomingReminderForRepotted = dateFormatter.string(from: nextDate)
                            print("🪴 Setting next repot date: \(update.upcomingReminderForRepotted ?? "nil")")
                        }
                    }
                }
            }
            
        default:
            print("❌ Invalid reminder type: \(type)")
            throw APIError(message: "Invalid reminder type")
        }
        
        print("📝 Update object: \(update)")
        
        // Update the reminder
        print("📡 Sending update to database...")
        let updateResponse = try await supabase
            .database
            .from("CareReminder_")
            .update(update)
            .eq("careReminderID", value: careReminderId)
            .execute()
        
        print("✅ Update response: \(String(describing: updateResponse.data))")
    }
    
    // Synchronous wrapper for updateCareReminderWithDetails
    func updateCareReminderWithDetailsSync(userPlantID: UUID, type: String, isCompleted: Bool) {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await updateCareReminderWithDetails(userPlantID: userPlantID, type: type, isCompleted: isCompleted)
            } catch {
                print("Error updating care reminder with details: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
    }

    // Function to add a new care reminder
    func addCareReminder(userPlantID: UUID, reminderAllowed: Bool) async throws {
        print("\n=== Adding New Care Reminder ===")
        // Create a new UUID for the care reminder
        let careReminderId = UUID()
        print("📝 Created new careReminderId: \(careReminderId.uuidString)")
        
        let currentDate = ISO8601DateFormatter().string(from: Date())
        
        // Create a struct that conforms to Encodable for inserting
        struct CareReminderInsert: Encodable {
            let careReminderID: String
            let upcomingReminderForWater: String
            let upcomingReminderForFertilizers: String
            let upcomingReminderForRepotted: String
            let isWateringCompleted: Bool
            let isFertilizingCompleted: Bool
            let isRepottingCompleted: Bool
        }
        
        // Prepare data using properly typed struct
        let careReminder = CareReminderInsert(
            careReminderID: careReminderId.uuidString,
            upcomingReminderForWater: currentDate,
            upcomingReminderForFertilizers: currentDate,
            upcomingReminderForRepotted: currentDate,
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        print("📝 Inserting care reminder with ID: \(careReminderId.uuidString)")
        // Insert the care reminder as a single operation with all fields
        try await supabase
            .database
            .from("CareReminder_")
            .insert(careReminder)
            .execute()
            
        print("✅ Successfully created care reminder record")
            
        // Then create the link in CareReminderOfUserPlant
        let link: [String: String] = [
            "careReminderOfUserPlantID": UUID().uuidString,
            "userPlantRelationID": userPlantID.uuidString,
            "careReminderId": careReminderId.uuidString  // Use the same ID created above
        ]
        
        print("📝 Creating link between care reminder and user plant")
        try await supabase
            .database
            .from("CareReminderOfUserPlant")
            .insert(link)
            .execute()
            
        print("✅ Successfully created care reminder link")
    }
    
    // Synchronous wrapper for addCareReminder
    func addCareReminderSync(userPlantID: UUID, reminderAllowed: Bool) {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await addCareReminder(userPlantID: userPlantID, reminderAllowed: reminderAllowed)
            } catch {
                print("Error adding care reminder: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
    }

    // MARK: - User Management
    
    func initializeUser(email: String) async throws -> userInfo? {
        print("\n=== Checking User Data ===")
        
        // Check UserTable for existing user data
        do {
            print("🔍 Checking UserTable for email: \(email)")
            let response = try await supabase
                .database
                .from("UserTable")
                .select("id, user_email, userName, location, reminderAllowed")
                .eq("user_email", value: email)
                .execute()
            
            print("📡 Raw response type: \(type(of: response.data))")
            
            // Convert Data to JSON string for debugging
            if let data = response.data as? Data,
               let jsonString = String(data: data, encoding: .utf8) {
                print("📡 JSON String: \(jsonString)")
                
                // Try to decode directly from the Data
                if let users = try? JSONDecoder().decode([userInfo].self, from: data),
                   let user = users.first {
                    print("✅ Successfully decoded user: \(user.userName)")
                    return user
                }
            }
            
            print("❌ Could not decode user data")
        } catch {
            print("ℹ️ Error fetching user data: \(error.localizedDescription)")
        }
        
        print("❌ User not found and creation is disabled")
        return nil
    }
    
    // Synchronous wrapper for getting user
    func getUserSync() -> userInfo? {
        print("\n=== Getting User Synchronously ===")
        var user: userInfo?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                if let storedEmail = UserDefaults.standard.string(forKey: "userEmail") {
                    print("📧 Using stored email: \(storedEmail)")
                    user = try await initializeUser(email: storedEmail)
                    if user == nil {
                        print("⚠️ No user data found in UserTable for stored email")
                    }
                } else {
                    print("⚠️ No stored email found")
                }
            } catch {
                print("❌ Error getting user: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return user
    }

    // MARK: - Location Management
    
    private var locationManager: CLLocationManager?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var isRequestingLocation = false
    
    private func setupLocationManagerIfNeeded() {
        guard locationManager == nil else { return }
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.distanceFilter = 1000
    }
    
    func requestLocationAuthorization() async -> CLAuthorizationStatus {
        setupLocationManagerIfNeeded()
        
        let status = locationManager?.authorizationStatus ?? .notDetermined
        
        // Return immediately if status is already determined
        guard status == .notDetermined else {
            return status
        }
        
        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    func requestLocation() async throws -> CLLocation {
        setupLocationManagerIfNeeded()
        
        guard let manager = locationManager else {
            throw LocationError.managerNotInitialized
        }
        
        // Check if we're already requesting location
        guard !isRequestingLocation else {
            throw LocationError.requestInProgress
        }
        
        // Check authorization first
        let authStatus = manager.authorizationStatus
        guard authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways else {
            throw LocationError.notAuthorized
        }
        
        // If we have a recent location (less than 5 minutes old), use it
        if let lastLocation = manager.location,
           Date().timeIntervalSince(lastLocation.timestamp) < 300 {
            return lastLocation
        }
        
        // Stop any existing updates
        manager.stopUpdatingLocation()
        locationContinuation = nil
        isRequestingLocation = true
        
        do {
            let location = try await withCheckedThrowingContinuation { continuation in
                locationContinuation = continuation
                
                // Set a timeout
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                    self?.handleLocationTimeout()
                }
                
                // Start requesting location
                manager.startUpdatingLocation()
            }
            return location
        } catch {
            cleanupLocationRequest()
            throw error
        }
    }
    
    private func handleLocationTimeout() {
        guard isRequestingLocation,
              let continuation = locationContinuation else { return }
        
        cleanupLocationRequest()
        continuation.resume(throwing: LocationError.timeout)
    }
    
    private func cleanupLocationRequest() {
        locationManager?.stopUpdatingLocation()
        locationContinuation = nil
        isRequestingLocation = false
    }
    
    // Synchronous wrapper with better error handling
    func getCurrentLocationSync() -> CLLocation? {
        // Default to North India coordinates if location is not available
        let defaultLocation = CLLocation(latitude: 28.6139, longitude: 77.2090)
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: CLLocation?
        
        Task {
            do {
                result = try await requestLocation()
            } catch {
                print("Location error: \(error.localizedDescription)")
                result = defaultLocation
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return result ?? defaultLocation
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isRequestingLocation,
              let location = locations.last,
              let continuation = locationContinuation else { return }
        
        cleanupLocationRequest()
        continuation.resume(returning: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard isRequestingLocation,
              let continuation = locationContinuation else { return }
        
        cleanupLocationRequest()
        
        let mappedError: LocationError
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                mappedError = .notAuthorized
            case .network:
                mappedError = .networkError
            default:
                mappedError = .unknown(clError)
            }
        } else {
            mappedError = .unknown(error)
        }
        
        continuation.resume(throwing: mappedError)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if let continuation = authorizationContinuation {
            authorizationContinuation = nil
            continuation.resume(returning: manager.authorizationStatus)
        }
    }

    // MARK: - Authentication Functions
    
    func signIn(email: String, password: String) async throws -> (Session, userInfo?) {
        print("\n=== Signing In User ===")
        print("🔑 Attempting to sign in with email: \(email)")
        
        // First authenticate with Supabase auth
        let session = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        
        print("✅ Authentication successful")
        
        // Store the email for future use
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        // After successful authentication, fetch user data from UserTable
        print("🔍 Fetching user data from UserTable")
        let userData = try await initializeUser(email: email)
        
        if let userData = userData {
            print("✅ User data found in UserTable")
        } else {
            print("⚠️ No user data found in UserTable")
            // Print all users to debug
            await printAllUsers()
        }
        
        return (session, userData)
    }

    // Add this function after the signIn function
    func signUp(email: String, password: String, userName: String) async throws -> (AuthResponse, userInfo?) {
        print("\n=== Signing Up New User ===")
        print("🔑 Attempting to sign up with email: \(email)")
        
        // First create the auth user in Supabase with email verification disabled
        let authResponse = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["email_confirm": true] // This disables email verification
        )
        
        print("✅ Authentication successful")
        
        // Store the email for future use
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        // Create user in UserTable with provided name
        print("📝 Creating user in UserTable")
        let userData = try await createUser(
            email: email,
            userName: userName
        )
        
        print("✅ User created in UserTable")
        return (authResponse, userData)
    }

    // MARK: - Error Types
    
    struct APIError: Error {
        let message: String
        let errorCode: String?
        
        init(message: String, errorCode: String? = nil) {
            self.message = message
            self.errorCode = errorCode
        }
    }

    // MARK: - Auth Errors

    enum AuthError: LocalizedError {
        case noAuthenticatedUser
        case invalidCredentials
        case networkError
        case rateLimitExceeded
        case invalidOTP
        case passwordUpdateFailed
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .noAuthenticatedUser:
                return "No account found with this email address"
            case .invalidCredentials:
                return "Invalid email or password"
            case .networkError:
                return "Network error during authentication"
            case .rateLimitExceeded:
                return "Please wait a minute before trying again"
            case .invalidOTP:
                return "Invalid verification code"
            case .passwordUpdateFailed:
                return "Failed to update password. Please try again"
            case .unknown(let error):
                return "Error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - User Creation
    
    func createUser(email: String, userName: String, location: String = "North India") async throws -> userInfo {
        print("\n=== Creating New User ===")
        print("📝 Creating user with email: \(email)")
        
        let userId = UUID().uuidString
        let insertData = UserTableInsert(
            id: userId,
            user_email: email,
            userName: userName,
            location: location,
            reminderAllowed: true
        )
        
        try await supabase
            .database
            .from("UserTable")
            .insert(insertData)
            .execute()
        
        print("✅ Created user data in UserTable")
        
        return userInfo(
            userEmail: email,
            userName: userName,
            location: location,
            reminderAllowed: true,
            id: userId
        )
    }

    // MARK: - Debug Functions
    
    func printAllUsers() async {
        print("\n=== Printing All Users in UserTable ===")
        do {
            let response = try await supabase
                .database
                .from("UserTable")
                .select("id, user_email, userName, location, reminderAllowed")
                .execute()
            
            print("📡 Response type: \(type(of: response.data))")
            
            // Convert Data to JSON
            if let data = response.data as? Data,
               let jsonString = String(data: data, encoding: .utf8) {
                print("📡 JSON String: \(jsonString)")
                
                if let jsonData = jsonString.data(using: .utf8),
                   let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
                    print("\n📊 Found \(jsonObject.count) users:")
                    for (index, user) in jsonObject.enumerated() {
                        print("\n👤 User \(index + 1):")
                        print("   Email: \(user["user_email"] ?? "N/A")")
                        print("   Name: \(user["userName"] ?? "N/A")")
                        print("   ID: \(user["id"] ?? "N/A")")
                        print("   Location: \(user["location"] ?? "N/A")")
                        print("   Reminders Allowed: \(user["reminderAllowed"] ?? "N/A")")
                    }
                } else {
                    print("❌ Could not parse JSON into array of users")
                }
            } else {
                print("❌ Invalid data format")
                print("📡 Response data: \(String(describing: response.data))")
            }
        } catch {
            print("❌ Error fetching users: \(error)")
        }
    }

    // Function to get disease by name with better error handling
    func getDiseaseByName(name: String) async throws -> Diseases? {
        print("🔍 Fetching disease with name: \(name)")
        
        // Clean up the disease name
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🔍 Cleaned disease name: \(cleanedName)")
        
        let response = try await supabase
            .database
            .from("Diseases")
            .select()
            .execute()
        
        print("📡 Response data type: \(type(of: response.data))")
        
        if let data = response.data as? Data {
            print("📡 Attempting to decode Data response")
            do {
                // First try to convert Data to JSON array
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    print("✅ Successfully parsed JSON array with \(jsonArray.count) items")
                    
                    // Look for a disease with matching name
                    for item in jsonArray {
                        if let diseaseName = item["diseaseName"] as? String,
                           diseaseName.lowercased() == cleanedName.lowercased() {
                            print("✅ Found matching disease: \(diseaseName)")
                            
                            // Convert back to JSON data for decoding
                            let itemData = try JSONSerialization.data(withJSONObject: item)
                            let disease = try JSONDecoder().decode(Diseases.self, from: itemData)
                            print("✅ Successfully decoded disease")
                            return disease
                        }
                    }
                }
            } catch {
                print("❌ Error parsing JSON: \(error)")
            }
        } else if let jsonArray = response.data as? [[String: Any]] {
            print("📡 Got direct JSON array with \(jsonArray.count) items")
            
            // Look for a disease with matching name
            for item in jsonArray {
                if let diseaseName = item["diseaseName"] as? String,
                   diseaseName.lowercased() == cleanedName.lowercased() {
                    print("✅ Found matching disease: \(diseaseName)")
                    
                    do {
                        let itemData = try JSONSerialization.data(withJSONObject: item)
                        let disease = try JSONDecoder().decode(Diseases.self, from: itemData)
                        print("✅ Successfully decoded disease")
                        return disease
                    } catch {
                        print("❌ Error decoding disease: \(error)")
                    }
                }
            }
        }
        
        print("❌ No disease found with name: \(cleanedName)")
        return nil
    }

    // Synchronous wrapper with better error handling
    func getDiseaseByNameSync(name: String) -> Diseases? {
        print("\n=== Getting Disease By Name Synchronously ===")
        print("🔍 Looking for disease: \(name)")
        
        var disease: Diseases?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                disease = try await getDiseaseByName(name: name)
                if let disease = disease {
                    print("✅ Found disease: \(disease.diseaseName)")
                    print("   Symptoms: \(disease.diseaseSymptoms ?? "None")")
                    print("   Cure: \(disease.diseaseCure ?? "None")")
                } else {
                    print("❌ Disease not found")
                }
            } catch {
                print("❌ Error getting disease: \(error.localizedDescription)")
                print("❌ Error details: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return disease
    }


    // MARK: - Password Reset Functions

    func sendPasswordResetOTP(email: String) async throws {
        print("📧 Attempting to send reset OTP to: \(email)")
        
        // Clean up the email
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        do {
            // Send OTP email for password reset
            try await supabase.auth.resetPasswordForEmail(cleanEmail)
            print("✅ Reset OTP sent successfully")
        } catch {
            print("❌ Error sending reset OTP: \(error)")
            if error.localizedDescription.contains("rate limit") {
                throw AuthError.rateLimitExceeded
            }
            throw AuthError.unknown(error)
        }
    }

    func verifyPasswordResetOTP(email: String, otp: String) async throws {
        print("🔐 Verifying reset OTP for email: \(email)")
        
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        do {
            try await supabase.auth.verifyOTP(
                email: cleanEmail,
                token: otp,
                type: .recovery
            )
            print("✅ Reset OTP verified successfully")
        } catch {
            print("❌ Reset OTP verification failed: \(error)")
            throw AuthError.invalidOTP
        }
    }

    func updatePassword(newPassword: String) async throws {
        print("🔄 Updating password")
        
        do {
            try await supabase.auth.update(user: UserAttributes(password: newPassword))
            print("✅ Password updated successfully")
        } catch {
            print("❌ Password update failed: \(error)")
            throw AuthError.passwordUpdateFailed
        }
    }

    // Add this method in the DataControllerGG class
    func updateUsername(email: String, newUsername: String) async throws {
        print("🔄 Updating username for email: \(email)")
        try await supabase
            .database
            .from("UserTable")
            .update(["userName": newUsername])
            .eq("user_email", value: email)
            .execute()
        print("✅ Username updated successfully in Supabase")

    }

    // MARK: - Image Upload Functions

    // Function to upload image to Supabase storage
    func uploadPlantImage(_ image: UIImage, fileName: String? = nil) async throws -> String {
        print(" Uploading Plant Image to Supabase")
        print("Starting image upload process...")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data")
            throw APIError(message: "Failed to convert image to JPEG data")
        }
        
        // Generate a unique filename with timestamp if not provided
        let imageFileName = fileName ?? "plant_\(Date().timeIntervalSince1970).jpg"
        print(" Using filename: \(imageFileName)")
        
        // Use the predefined bucket name - assume it already exists
        let bucketName = "user.image"
        print("Using existing bucket: \(bucketName)")
        
        // Make sure we're authenticated
        do {
            // Get the current session
            let session = try await supabase.auth.session
            print("User authenticated with ID: \(session.user.id)")
        } catch {
            print(" Authentication check failed: \(error.localizedDescription)")
            // Continue anyway - we might still be able to upload with public permissions
        }
        
        // Upload image directly to Supabase storage
        do {
            print(" Uploading file: \(imageFileName)")
            try await supabase.storage.from(bucketName).upload(
                path: imageFileName,
                file: imageData,
                options: FileOptions(contentType: "image/jpeg")
            )
            print(" Image uploaded successfully!")
            
            // Get public URL
            let publicURL = try supabase.storage.from(bucketName).getPublicURL(path: imageFileName)
            print("🔗 Public URL: \(publicURL.absoluteString)")
            
            return publicURL.absoluteString
        } catch {
            print(" Upload failed: \(error.localizedDescription)")
            print(" Detailed error: \(error)")
            
            // If bucket name is wrong, try with a different common name
            if error.localizedDescription.contains("security policy") || 
               error.localizedDescription.contains("not found") {
                // Try with other common bucket names
                let alternateBucketName = "images"
                print(" Trying alternate bucket name: \(alternateBucketName)")
                
                do {
                    try await supabase.storage.from(alternateBucketName).upload(
                        path: imageFileName,
                        file: imageData,
                        options: FileOptions(contentType: "image/jpeg")
                    )
                    print(" Image uploaded successfully to alternate bucket!")
                    
                    let publicURL = try supabase.storage.from(alternateBucketName).getPublicURL(path: imageFileName)
                    print("🔗 Public URL: \(publicURL.absoluteString)")
                    
                    return publicURL.absoluteString
                } catch {
                    print(" Alternate upload also failed: \(error.localizedDescription)")
                }
            }
            
            // Fallback to hardcoded URL for testing
            print(" Using fallback image URL for testing")
            return "https://swygmlgykjhvncaqsnxw.supabase.co/storage/v1/object/public/images/plant_fallback.jpg"
        }
    }

    // Function to update UserPlant with image URL
    func updateUserPlantWithImage(userEmail: String, plantName: String, imageURL: String) async throws {
        print("\n=== Updating UserPlant with Image URL (Improved) ===")
        print(" User email: \(userEmail)")
        print(" Plant name: \(plantName)")
        print(" Image URL: \(imageURL)")
        
        // Get user from UserTable
        let userResponse = try await supabase
            .database
            .from("UserTable")
            .select()
            .eq("user_email", value: userEmail)
            .execute()
        
        // Parse user ID
        var userId: String? = nil
        
        if let jsonObject = userResponse.data as? [[String: Any]],
           let firstUser = jsonObject.first,
           let id = firstUser["id"] as? String {
            userId = id
            print("Found user ID: \(id)")
        } else if let data = userResponse.data as? Data,
                  let jsonString = String(data: data, encoding: .utf8),
                  let jsonData = jsonString.data(using: .utf8),
                  let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                  let firstUser = jsonArray.first,
                  let id = firstUser["id"] as? String {
            userId = id
            print("Found user ID from JSON conversion: \(id)")
        }
        
        guard let userId = userId else {
            print(" Could not find user ID for email: \(userEmail)")
            throw APIError(message: "User not found")
        }
        
        // Find plant by name
        let plantResponse = try await supabase
            .database
            .from("Plant")
            .select()
            .ilike("plantName", value: plantName)  // Use case-insensitive search
            .execute()
        
        // Parse plant ID
        var plantId: UUID? = nil
        
        if let jsonObject = plantResponse.data as? [[String: Any]],
           let firstPlant = jsonObject.first,
           let plantIdString = firstPlant["plantID"] as? String,
           let id = UUID(uuidString: plantIdString) {
            plantId = id
            print(" Found plant ID: \(id.uuidString)")
        } else if let data = plantResponse.data as? Data,
                  let jsonString = String(data: data, encoding: .utf8),
                  let jsonData = jsonString.data(using: .utf8),
                  let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                  let firstPlant = jsonArray.first,
                  let plantIdString = firstPlant["plantID"] as? String,
                  let id = UUID(uuidString: plantIdString) {
            plantId = id
            print(" Found plant ID from JSON conversion: \(id.uuidString)")
        }
        
        guard let plantId = plantId else {
            print(" Could not find plant with name: \(plantName)")
            throw APIError(message: "Plant not found")
        }
        
        // Check if the plant already exists in user's garden
        print("🔍 Checking if plant already exists in user's garden")
        let existingPlantsResponse = try await supabase
            .database
            .from("UserPlant")
            .select()
            .eq("userId", value: userId)
            .eq("userplantID", value: plantId.uuidString)
            .execute()
        
        // Process the response to check if the plant exists
        var existingUserPlantId: UUID? = nil
        
        if let jsonObject = existingPlantsResponse.data as? [[String: Any]],
           !jsonObject.isEmpty,
           let firstPlant = jsonObject.first,
           let relationIdString = firstPlant["userPlantRelationID"] as? String,
           let relationId = UUID(uuidString: relationIdString) {
            existingUserPlantId = relationId
            print("Plant already exists with ID: \(relationId.uuidString)")
        } else if let data = existingPlantsResponse.data as? Data,
                  let jsonString = String(data: data, encoding: .utf8),
                  let jsonData = jsonString.data(using: .utf8),
                  let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                  !jsonArray.isEmpty,
                  let firstPlant = jsonArray.first,
                  let relationIdString = firstPlant["userPlantRelationID"] as? String,
                  let relationId = UUID(uuidString: relationIdString) {
            existingUserPlantId = relationId
            print("Plant already exists with ID: \(relationId.uuidString)")
        }
        
        if let existingId = existingUserPlantId {
            // Update existing plant with the new image URL
            print("📝 Updating existing plant with new image URL")
            
            try await supabase
                .database
                .from("UserPlant")
                .update(["userPlantImage": imageURL])
                .eq("userPlantRelationID", value: existingId.uuidString)
                .execute()
            
            print(" Successfully updated existing plant with new image URL")
        } else {
            // Create a new user plant entry
            print("Creating new plant entry with image URL")
            
            // Generate a unique ID for the user plant
            let userPlantId = UUID()
            print("Created user plant ID: \(userPlantId.uuidString)")
            
            // Create a struct that conforms to Encodable for inserting
            struct UserPlantInsert: Encodable {
                let userPlantRelationID: String
                let userId: String
                let userplantID: String
                let userPlantNickName: String
                let userPlantImage: String
            }
            
            // Prepare data using properly typed struct
            let userPlantData = UserPlantInsert(
                userPlantRelationID: userPlantId.uuidString,
                userId: userId,
                userplantID: plantId.uuidString,
                userPlantNickName: plantName,
                userPlantImage: imageURL
            )
            
            // Insert into UserPlant table
            try await supabase
                .database
                .from("UserPlant")
                .insert(userPlantData)
                .execute()
            
            print("Successfully created new plant with image URL")
        }
    }

    // Synchronous wrapper for uploadPlantImage
    func uploadPlantImageSync(_ image: UIImage) -> String? {
        var imageURL: String?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                imageURL = try await uploadPlantImage(image)
            } catch {
                print("DataControllerGG: Error uploading image: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 10)
        return imageURL
    }

    // Synchronous wrapper for updateUserPlantWithImage
    func updateUserPlantWithImageSync(userEmail: String, plantName: String, imageURL: String) -> Bool {
        var success = false
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await updateUserPlantWithImage(userEmail: userEmail, plantName: plantName, imageURL: imageURL)
                success = true
            } catch {
                print("❌ DataControllerGG: Error updating UserPlant with image: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 10)
        return success
    }
    
    // Function to thoroughly delete a user plant from all related tables
    func thoroughlyDeleteUserPlant(userPlantID: UUID) async throws {
        print("\n=== Thoroughly Deleting User Plant ===")
        print("🗑️ Deleting userPlantID: \(userPlantID.uuidString)")
        
        // 1. First delete the care reminder linking record
        print("🔍 Removing from CareReminderOfUserPlant table...")
        try await supabase
            .database
            .from("CareReminderOfUserPlant")
            .delete()
            .eq("userPlantRelationID", value: userPlantID.uuidString)
            .execute()
        
        // 2. Then delete the care reminder itself
        print("🔍 Removing from CareReminder_ table...")
        try await supabase
            .database
            .from("CareReminder_")
            .delete()
            .eq("careReminderID", value: userPlantID.uuidString)
            .execute()
        
        // 3. Finally delete the user plant
        print("🔍 Removing from UserPlant table...")
        try await supabase
            .database
            .from("UserPlant")
            .delete()
            .eq("userPlantRelationID", value: userPlantID.uuidString)
            .execute()
        
        print("✅ User plant completely removed from all tables")
    }
    
    // Synchronous wrapper for thoroughlyDeleteUserPlant
    func thoroughlyDeleteUserPlantSync(userPlantID: UUID) {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await thoroughlyDeleteUserPlant(userPlantID: userPlantID)
            } catch {
                print("Error thoroughly deleting user plant: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
    }
    
    // Function to check if plant exists with better cache clearing
    func doesPlantExistInUserGarden(plantName: String, userEmail: String) async throws -> Bool {
        print("\n=== Checking if Plant Exists in User's Garden (Improved) ===")
        print("🔍 Checking if \(plantName) exists for user \(userEmail)")
        
        // Get user from UserTable
        let userResponse = try await supabase
            .database
            .from("UserTable")
            .select()
            .eq("user_email", value: userEmail)
            .execute()
        
        // Parse user ID
        var userId: String? = nil
        
        if let jsonObject = userResponse.data as? [[String: Any]],
           let firstUser = jsonObject.first,
           let id = firstUser["id"] as? String {
            userId = id
        } else if let data = userResponse.data as? Data,
                  let jsonString = String(data: data, encoding: .utf8),
                  let jsonData = jsonString.data(using: .utf8),
                  let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                  let firstUser = jsonArray.first,
                  let id = firstUser["id"] as? String {
            userId = id
        }
        
        guard let userId = userId else {
            print("❌ Could not find user ID for email: \(userEmail)")
            return false
        }
        
        // Get plant ID from Plant table using case-insensitive search
        let plantResponse = try await supabase
            .database
            .from("Plant")
            .select()
            .ilike("plantName", value: plantName)
            .execute()
        
        // Parse plant ID
        var plantId: String? = nil
        
        if let jsonObject = plantResponse.data as? [[String: Any]],
           let firstPlant = jsonObject.first,
           let id = firstPlant["plantID"] as? String {
            plantId = id
        } else if let data = plantResponse.data as? Data,
                  let jsonString = String(data: data, encoding: .utf8),
                  let jsonData = jsonString.data(using: .utf8),
                  let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                  let firstPlant = jsonArray.first,
                  let id = firstPlant["plantID"] as? String {
            plantId = id
        }
        
        guard let plantId = plantId else {
            print("❌ Could not find plant with name: \(plantName)")
            return false
        }
        
        // Check if the plant exists in the user's garden
        print("🔍 Checking UserPlant table with plantID: \(plantId)")
        let userPlantResponse = try await supabase
            .database
            .from("UserPlant")
            .select()
            .eq("userId", value: userId)
            .eq("userplantID", value: plantId)
            .execute()
        
        if let data = userPlantResponse.data as? Data,
           let jsonString = String(data: data, encoding: .utf8),
           let jsonData = jsonString.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
            let exists = !jsonArray.isEmpty
            print(exists ? "✅ Plant exists in user's garden" : "❌ Plant does not exist in user's garden")
            
            // If debugging, print the actual plants found
            if exists {
                print("📝 Found \(jsonArray.count) matching plants:")
                for (index, plant) in jsonArray.enumerated() {
                    print("  Plant \(index + 1): ID=\(plant["userPlantRelationID"] ?? "unknown"), Name=\(plant["userPlantNickName"] ?? "unknown")")
                }
            }
            
            return exists
        }
        
        print("❌ No plant data found")
        return false
    }
    
    // Synchronous wrapper for doesPlantExistInUserGarden
    func doesPlantExistInUserGardenSync(plantName: String, userEmail: String) -> Bool {
        var exists = false
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                exists = try await doesPlantExistInUserGarden(plantName: plantName, userEmail: userEmail)
            } catch {
                print("Error checking if plant exists: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return exists
    }
}

// Helper struct for decoding nested JSON response
private struct UserPlantWithDetails: Codable {
    let userPlant: UserPlant
    let plant: Plant
    let careReminder: CareReminder_
}

// Add synchronous wrappers in extension
extension DataControllerGG {
    func getUsersSync() -> [userInfo] {
        var users: [userInfo] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                users = try await getUsers()
            } catch {
                print("Error getting users: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return users
    }
    
    func getUserPlantsSync(for userEmail: String) -> [UserPlant] {
        print("\n=== Getting User Plants Synchronously ===")
        var plants: [UserPlant] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                plants = try await getUserPlants(for: userEmail)
                print("✅ Got \(plants.count) plants for user \(userEmail)")
            } catch {
                print("❌ Error getting user plants: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return plants
    }
    
    func getPlantSync(by plantID: UUID) -> Plant? {
        var plant: Plant?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                plant = try await getPlant(by: plantID)
            } catch {
                print("Error getting plant: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return plant
    }
    
    func getCareRemindersSync(for userPlantID: UUID) -> CareReminder_? {
        var reminder: CareReminder_?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                reminder = try await getCareReminders(for: userPlantID)
            } catch {
                print("Error getting care reminders: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return reminder
    }
    
    func updateCareReminderStatusSync(userPlantID: UUID, type: String, isCompleted: Bool) {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await updateCareReminderStatus(userPlantID: userPlantID, type: type, isCompleted: isCompleted)
            } catch {
                print("Error updating care reminder status: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
    }
    
    func deleteUserPlantSync(userPlantID: UUID) {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await deleteUserPlant(userPlantID: userPlantID)
            } catch {
                print("Error deleting user plant: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
    }
    
    func getDiseasesSync(for plantID: UUID) -> [Diseases] {
        var diseases: [Diseases] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                diseases = try await getDiseases(for: plantID)
            } catch {
                print("Error getting diseases: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return diseases
    }
}

// MARK: - Location Errors

enum LocationError: LocalizedError {
    case managerNotInitialized
    case notAuthorized
    case requestInProgress
    case timeout
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .managerNotInitialized:
            return "Location services not initialized"
        case .notAuthorized:
            return "Location access not authorized"
        case .requestInProgress:
            return "Location request already in progress"
        case .timeout:
            return "Location request timed out"
        case .networkError:
            return "Network error while getting location"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
