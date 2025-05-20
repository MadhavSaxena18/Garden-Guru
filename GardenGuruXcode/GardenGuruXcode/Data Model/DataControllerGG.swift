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
    
    func clearSession() async {
        print("\n=== Clearing Supabase Session ===")
        do {
            // Sign out using the auth client
            try await client.auth.signOut()
            print("✅ Supabase session cleared")
        } catch {
            print("❌ Error clearing Supabase session: \(error)")
        }
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

// Add this struct near the top with other model definitions
private struct UserPlantInsert: Encodable {
    let userPlantRelationID: String
    let userId: String
    let userplantID: String
    let userPlantImage: String?
    let userPlantNickName: String?
}

class DataControllerGG: NSObject, CLLocationManagerDelegate {
    static let shared = DataControllerGG()
    private let supabase = supaBaseController.shared.client
    private var reminderCompletionStates: [UUID: [String: Bool]] = [:]
    let currentDate = Date()
    
    private override init() {
        super.init()
    }
    
    // Add public method to check session state
    func checkSessionValid() async throws -> Bool {
        print("\n=== Checking Session Validity ===")
        do {
            _ = try await supabase.auth.session
            print("✅ Session is valid")
            return true
        } catch {
            print("❌ Session is invalid: \(error)")
            return false
        }
    }
    
    // MARK: - User Functions
    
    func getUser() async throws -> userInfo? {
        print("🔍 Fetching user data from UserTable")
        
        // Try to get the email from UserDefaults
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            print("❌ No email found in UserDefaults")
            return nil
        }
        
        print("[DEBUG] Current user email: \(email)")
        
        // Try to get the existing user
        if let user = try await initializeUser(email: email) {
            print("✅ User data found in UserTable")
            return user
        }
        
        print("⚠️ No user data found in UserTable")
            return nil
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
        print("🔍 Fetching user plants for email: \(userEmail)")
        
        // First get the user's ID from UserTable
        let userResponse = try await supabase
            .database
            .from("UserTable")
            .select()
            .eq("user_email", value: userEmail)
            .execute()
        
        print("📡 Raw user response: \(String(describing: userResponse.data))")
        
        // Try to decode the user data
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
                
                // Try parsing as JSON array if direct decoding fails
                if let jsonString = String(data: data, encoding: .utf8),
                   let jsonData = jsonString.data(using: .utf8),
                   let users = try? JSONDecoder().decode([userInfo].self, from: jsonData),
                   let user = users.first {
                    userIdString = user.id
                    print("✅ Found user ID from JSON string: \(user.id)")
                }
            }
        } else if let jsonArray = userResponse.data as? [[String: Any]],
                  let firstUser = jsonArray.first,
                  let id = firstUser["id"] as? String {
            userIdString = id
            print("✅ Found user ID from JSON array: \(id)")
        }
        
        guard let userId = userIdString else {
            print("❌ Could not find user ID for email: \(userEmail)")
            return []
        }
        
        // Now get the user's plants using the correct ID
        print("🔍 Fetching plants for user ID: \(userId)")
        let response = try await supabase
            .database
            .from("UserPlant")
            .select()
            .eq("userId", value: userId)
            .execute()
        
        print("📡 Raw user plants response: \(String(describing: response.data))")
        
        if let data = response.data as? Data {
            do {
                var userPlants = try JSONDecoder().decode([UserPlant].self, from: data)
                print("✅ Successfully decoded \(userPlants.count) user plants")
                
                // Fetch associated diseases for each plant
                for i in 0..<userPlants.count {
                    if let diseases = try? await getAssociatedDiseases(for: userPlants[i].userPlantRelationID) {
                        userPlants[i].associatedDiseases = diseases
                    }
                }
                
                return userPlants
            } catch {
                print("❌ Error decoding user plants from Data: \(error)")
                
                // Try parsing as JSON array if direct decoding fails
                if let jsonString = String(data: data, encoding: .utf8),
                   let jsonData = jsonString.data(using: .utf8),
                   var userPlants = try? JSONDecoder().decode([UserPlant].self, from: jsonData) {
                    print("✅ Successfully decoded \(userPlants.count) user plants from JSON string")
                    
                    // Fetch associated diseases for each plant
                    for i in 0..<userPlants.count {
                        if let diseases = try? await getAssociatedDiseases(for: userPlants[i].userPlantRelationID) {
                            userPlants[i].associatedDiseases = diseases
                        }
                    }
                    
                    return userPlants
                }
            }
        } else if let jsonArray = response.data as? [[String: Any]] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
                var userPlants = try JSONDecoder().decode([UserPlant].self, from: jsonData)
                print("✅ Successfully decoded \(userPlants.count) user plants from JSON array")
                
                // Fetch associated diseases for each plant
                for i in 0..<userPlants.count {
                    if let diseases = try? await getAssociatedDiseases(for: userPlants[i].userPlantRelationID) {
                        userPlants[i].associatedDiseases = diseases
                    }
                }
                
                return userPlants
            } catch {
                print("❌ Error decoding user plants from JSON array: \(error)")
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
        
        // First try to decode as Data
        if let data = response.data as? Data {
            print("✅ Got Data response, attempting to decode...")
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let fertilizers = try decoder.decode([Fertilizer].self, from: data)
                print("✅ Successfully decoded \(fertilizers.count) fertilizers from Data")
        return fertilizers
            } catch {
                print("❌ Failed to decode Data response: \(error)")
            }
        }
        
        // If Data decoding fails, try JSON array
        if let jsonArray = response.data as? [[String: Any]] {
            print("✅ Got JSON array response with \(jsonArray.count) items")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let fertilizers = try decoder.decode([Fertilizer].self, from: jsonData)
                print("✅ Successfully decoded \(fertilizers.count) fertilizers from JSON array")
                return fertilizers
            } catch {
                print("❌ Failed to decode JSON array: \(error)")
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
        
        print("❌ Unexpected response format")
        throw NSError(domain: "DataController", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format from Supabase"])
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
    
    // Modify the addUserPlant function to handle image URL
    func addUserPlant(userPlant: UserPlant) async throws {
        print("\n=== Adding New User Plant ===")
        
        // Get the stored image URL from UserDefaults
        let imageURL = UserDefaults.standard.string(forKey: "tempPlantImageURL")
        print("📸 Retrieved image URL from UserDefaults: \(imageURL ?? "nil")")
        
        let userPlantRecord = UserPlantInsert(
            userPlantRelationID: userPlant.userPlantRelationID.uuidString,
            userId: userPlant.userId.uuidString,
            userplantID: userPlant.userplantID?.uuidString ?? "",
            userPlantImage: imageURL,
            userPlantNickName: userPlant.userPlantNickName
        )
        
        try await supabase
            .database
            .from("UserPlant")
            .insert(userPlantRecord)
            .execute()
            
        print("✅ User plant added successfully with image URL")
        
        // Clear the temporary image URL from UserDefaults
        UserDefaults.standard.removeObject(forKey: "tempPlantImageURL")
        UserDefaults.standard.removeObject(forKey: "tempPlantID")
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
        let careReminderId = UUID()
        let currentDate = ISO8601DateFormatter().string(from: Date())
        
        // First create the care reminder
        let careReminder: [String: String] = [
            "careReminderID": careReminderId.uuidString,
            "upcomingReminderForWater": currentDate,
            "upcomingReminderForFertilizers": currentDate,
            "upcomingReminderForRepotted": currentDate
        ]
        
        // Insert the care reminder
        try await supabase
            .database
            .from("CareReminder_")
            .insert(careReminder)
            .execute()
            
        // Update the boolean fields
        let booleanData: [String: Bool] = [
            "isWateringCompleted": false,
            "isFertilizingCompleted": false,
            "isRepottingCompleted": false
        ]
        
        try await supabase
            .database
            .from("CareReminder_")
            .update(booleanData)
            .eq("careReminderID", value: careReminderId.uuidString)
            .execute()
            
        // Then create the link in CareReminderOfUserPlant
        let link: [String: String] = [
            "careReminderOfUserPlantID": UUID().uuidString,
            "userPlantRelationID": userPlantID.uuidString,
            "careReminderId": careReminderId.uuidString
        ]
        
        try await supabase
            .database
            .from("CareReminderOfUserPlant")
            .insert(link)
            .execute()
            
        // Create the linking record in CareReminderOfUserPlant
        let linkingRecord: [String: String] = [
            "careReminderOfUserPlantID": UUID().uuidString,
            "userPlantRelationID": userPlantID.uuidString,
            "careReminderId": userPlantID.uuidString
        ]
        
        try await supabase
            .database
            .from("CareReminderOfUserPlant")
            .insert(linkingRecord)
            .execute()
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
                .select()
                .eq("user_email", value: email)
                .execute()
            
            print("📡 Raw response type: \(type(of: response.data))")
            
            // Try to decode the response data
            if let data = response.data as? Data {
                do {
                    let users = try JSONDecoder().decode([userInfo].self, from: data)
                    if let user = users.first {
                        print("✅ Successfully decoded user: \(user.userName)")
                        return user
                    }
                } catch {
                    print("❌ Error decoding user data: \(error)")
                
                    // Try parsing as JSON array if direct decoding fails
                    if let jsonString = String(data: data, encoding: .utf8),
                       let jsonData = jsonString.data(using: .utf8),
                       let users = try? JSONDecoder().decode([userInfo].self, from: jsonData),
                   let user = users.first {
                        print("✅ Successfully decoded user from JSON string: \(user.userName)")
                    return user
                }
            }
            } else if let jsonArray = response.data as? [[String: Any]] {
                print("📡 JSON Array: \(jsonArray)")
                
                if !jsonArray.isEmpty {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonArray[0])
                        let user = try JSONDecoder().decode(userInfo.self, from: jsonData)
                        print("✅ Successfully decoded user: \(user.userName)")
                        return user
        } catch {
                        print("❌ Error decoding user data: \(error)")
                    }
                }
            }
            
            print("❌ No existing user found")
            return nil
            
        } catch {
            print("❌ Error fetching user data: \(error)")
        return nil
        }
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
        
        // Save the session
        saveSession(session)
        
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
        
        // Post notification that user signed in
        NotificationCenter.default.post(name: Notification.Name("UserSignedIn"), object: nil)
        
        return (session, userData)
    }

    // Add this function after the signIn function
    func signUp(email: String, password: String, userName: String) async throws -> (AuthResponse, userInfo?) {
        print("\n=== Signing Up New User ===")
        print("🔑 Attempting to sign up with email: \(email)")
        
        // First create the auth user in Supabase
        let authResponse = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["email_confirm": true]
        )
        
        print("✅ Authentication successful")
        
        if let session = authResponse.session {
            // Save the session
            saveSession(session)
        }
        
        // Store the email for future use
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        // Create user in UserTable with provided name
        print("📝 Creating user in UserTable")
        let userData = try await createUser(
            email: email,
            userName: userName
        )
        
        print("✅ User created in UserTable")
        
        // Post notification that user signed up
        NotificationCenter.default.post(name: Notification.Name("UserSignedUp"), object: nil)
        
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
            id: userId,
            userName: userName,
            location: location,
            reminderAllowed: true,
            userEmail: email
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

    // Get plant diseases for a specific plant
    func getPlantDiseases(for plantId: UUID) async throws -> [PlantDisease] {
        print("🔍 Fetching diseases for plant ID: \(plantId)")
        let response = try await supabase.database
            .from("PlantDisease")
            .select()
            .eq("plantID", value: plantId.uuidString)
            .execute()
        
        print("📡 Raw plant diseases response: \(String(describing: response.data))")
        print("📡 Response type: \(type(of: response.data))")
        
        // First try to decode as Data
        if let data = response.data as? Data {
            print("✅ Got Data response, attempting to decode...")
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let plantDiseases = try decoder.decode([PlantDisease].self, from: data)
                print("✅ Successfully decoded \(plantDiseases.count) plant diseases from Data")
                return plantDiseases
            } catch {
                print("❌ Failed to decode Data response: \(error)")
                // If direct decoding fails, try parsing as JSON string
                if let jsonString = String(data: data, encoding: .utf8),
                   let jsonData = jsonString.data(using: .utf8) {
                    do {
                        let plantDiseases = try JSONDecoder().decode([PlantDisease].self, from: jsonData)
                        print("✅ Successfully decoded \(plantDiseases.count) plant diseases from JSON string")
                        return plantDiseases
                    } catch {
                        print("❌ Failed to decode JSON string: \(error)")
                    }
                }
            }
        }
        
        // If Data decoding fails, try JSON array
        if let jsonArray = response.data as? [[String: Any]] {
            print("✅ Got JSON array response with \(jsonArray.count) items")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let plantDiseases = try decoder.decode([PlantDisease].self, from: jsonData)
                print("✅ Successfully decoded \(plantDiseases.count) plant diseases from JSON array")
                return plantDiseases
            } catch {
                print("❌ Failed to decode JSON array: \(error)")
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
            }
        }
        
        print("❌ Could not decode response in any format")
        return []
    }
    
    // Get specific disease by ID
    func getDisease(by diseaseId: UUID) async throws -> Diseases {
        print("🔍 Fetching disease with ID: \(diseaseId)")
        let response = try await supabase.database
            .from("Diseases")
            .select()
            .eq("diseaseID", value: diseaseId.uuidString)
            .single()
            .execute()
        
        guard let jsonObject = response.data as? [String: Any] else {
            throw NSError(domain: "DataController", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
        let disease = try JSONDecoder().decode(Diseases.self, from: jsonData)
        print("✅ Successfully fetched disease with ID: \(diseaseId)")
        return disease
    }

    // MARK: - Disease Management
    
    func getAssociatedDiseases(for userPlantID: UUID) async throws -> [Diseases] {
        print("🔍 Fetching diseases for user plant: \(userPlantID)")
        
        // First get the disease IDs from UsersPlantDisease table
        let response = try await supabase
            .database
            .from("UsersPlantDisease")
            .select()
            .eq("usersPlantRelationID", value: userPlantID.uuidString)
            .execute()
            
        if let data = response.data as? Data {
            let userPlantDiseases = try JSONDecoder().decode([UsersPlantDisease].self, from: data)
            
            // Now fetch each disease
            var diseases: [Diseases] = []
            for userPlantDisease in userPlantDiseases {
                if let disease = try await getDiseaseDetails(by: userPlantDisease.diseaseID) {
                    diseases.append(disease)
                }
            }
            
            print("✅ Found \(diseases.count) diseases for user plant")
            return diseases
        }
        
        print("❌ No diseases found for user plant")
        return []
    }
    
    // Sync wrapper for getAssociatedDiseases
    func getAssociatedDiseasesSync(for userPlantID: UUID) -> [Diseases] {
        var diseases: [Diseases] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                diseases = try await getAssociatedDiseases(for: userPlantID)
            } catch {
                print("Error getting associated diseases: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return diseases
    }

    // MARK: - Disease Management
    
    func getDiseasesForUserPlants(userEmail: String) async throws -> [Diseases] {
        print("🔍 Fetching diseases for user's plants...")
        
        // 1. Get user's plants
        let userPlants = try await getUserPlants(for: userEmail)
        print("✅ Found \(userPlants.count) user plants")
        
        var allDiseases = Set<Diseases>() // Using Set to avoid duplicates
        
        // 2. For each user plant, get its possible diseases through PlantDisease table
        for userPlant in userPlants {
            if let plantID = userPlant.userplantID {
                print("🔍 Fetching diseases for plant: \(plantID)")
                
                // Get plant-disease relationships from PlantDisease table
                let response = try await supabase
                    .database
                    .from("PlantDisease")
                    .select()
                    .eq("plantID", value: plantID.uuidString)
                    .execute()
                
                if let data = response.data as? Data {
                    let plantDiseases = try JSONDecoder().decode([PlantDisease].self, from: data)
                    print("✅ Found \(plantDiseases.count) disease relationships for plant")
                    
                    // For each relationship, get the disease details
                    for plantDisease in plantDiseases {
                        let diseaseResponse = try await supabase
                            .database
                            .from("Diseases")
                            .select()
                            .eq("diseaseID", value: plantDisease.diseaseID.uuidString)
                            .execute()
                        
                        if let diseaseData = diseaseResponse.data as? Data {
                            if let diseases = try? JSONDecoder().decode([Diseases].self, from: diseaseData),
                               let disease = diseases.first {
                                allDiseases.insert(disease)
                                print("✅ Added disease: \(disease.diseaseName)")
                            }
                        }
                    }
                } else if let jsonArray = response.data as? [[String: Any]] {
                    print("✅ Found \(jsonArray.count) disease relationships for plant")
                    
                    for relationship in jsonArray {
                        if let diseaseIDString = relationship["diseaseID"] as? String,
                           let diseaseID = UUID(uuidString: diseaseIDString) {
                            
                            let diseaseResponse = try await supabase
                                .database
                                .from("Diseases")
                                .select()
                                .eq("diseaseID", value: diseaseID.uuidString)
                                .execute()
                            
                            if let diseaseJsonArray = diseaseResponse.data as? [[String: Any]],
                               let firstDisease = diseaseJsonArray.first,
                               let diseaseData = try? JSONSerialization.data(withJSONObject: firstDisease),
                               let disease = try? JSONDecoder().decode(Diseases.self, from: diseaseData) {
                                allDiseases.insert(disease)
                                print("✅ Added disease: \(disease.diseaseName)")
                            }
                        }
                    }
                }
            }
        }
        
        let diseases = Array(allDiseases)
        print("✅ Total unique diseases found: \(diseases.count)")
        return diseases
    }
    
    // Synchronous wrapper for getDiseasesForUserPlants
    func getDiseasesForUserPlantsSync(userEmail: String) -> [Diseases] {
        var diseases: [Diseases] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                diseases = try await getDiseasesForUserPlants(userEmail: userEmail)
            } catch {
                print("❌ Error getting diseases for user plants: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return diseases
    }

    // MARK: - Disease Management
    
    func getFertilizers(for diseaseID: UUID) async throws -> [Fertilizer] {
        print("🔍 Fetching fertilizers for disease ID: \(diseaseID)")
        let response = try await supabase
            .database
            .from("DiseaseFertilizer")
            .select()
            .eq("diseaseID", value: diseaseID.uuidString)
            .execute()
        var fertilizers: [Fertilizer] = []
        if let data = response.data as? Data {
            let diseaseFertilizers = try JSONDecoder().decode([DiseaseFertilizer].self, from: data)
            for df in diseaseFertilizers {
                let fertilizerId = df.fertilizerId
                let fertResponse = try await supabase
                    .database
                    .from("Fertilizer")
                    .select()
                    .eq("fertilizerId", value: fertilizerId.uuidString)
                    .single()
                    .execute()
                if let fertData = fertResponse.data as? Data,
                   let fertilizer = try? JSONDecoder().decode(Fertilizer.self, from: fertData) {
                    fertilizers.append(fertilizer)
                }
            }
        }
        print("✅ Found \(fertilizers.count) fertilizers for disease")
        return fertilizers
    }

    // MARK: - Image Storage Functions
    
    func uploadUserPlantImage(userPlantID: UUID, image: UIImage) async throws -> String {
        print("📸 Starting image upload for user plant: \(userPlantID)")
        
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw APIError(message: "Failed to convert image to data")
        }
        
        let fileName = "\(userPlantID.uuidString)_\(Date().timeIntervalSince1970).jpg"
        let filePath = "user_plant_images/\(fileName)"
        
        print("📤 Uploading image to path: \(filePath)")
        
        // Upload to Supabase Storage with correct bucket name
        try await supabase.storage
            .from("user.image")  // Using the correct bucket name
            .upload(
                path: filePath,
                file: imageData,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        print("✅ Image uploaded successfully")
        
        // Get the public URL from correct bucket
        let signedURL = try await supabase.storage
            .from("user.image")  // Using the correct bucket name
            .createSignedURL(
                path: filePath,
                expiresIn: 365 * 24 * 60 * 60 // 1 year in seconds
            )
        
        let publicURLString = signedURL.absoluteString
        print("🔗 Generated public URL: \(publicURLString)")
        
        return publicURLString
    }
    
    // Synchronous wrapper for uploadUserPlantImage
    func uploadUserPlantImageSync(userPlantID: UUID, image: UIImage) -> String? {
        var imageURL: String?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                imageURL = try await uploadUserPlantImage(userPlantID: userPlantID, image: image)
            } catch {
                print("❌ Error uploading image: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 30) // Longer timeout for image upload
        return imageURL
    }
    
    func deleteUserPlantImage(userPlantID: UUID) async throws {
        print("🗑 Deleting image for user plant: \(userPlantID)")
        
        // First get the current image URL
        let response = try await supabase.database
            .from("UserPlant")
            .select("userPlantImage")
            .eq("userPlantRelationID", value: userPlantID.uuidString)
            .single()
            .execute()
        
        if let data = response.data as? [String: Any],
           let imageURL = data["userPlantImage"] as? String,
           let urlComponents = URLComponents(string: imageURL),
           let path = urlComponents.path.components(separatedBy: "user.image/").last {  // Updated separator to match new bucket name
            
            // Delete from storage with correct bucket name
            try await supabase.storage
                .from("user.image")  // Changed bucket name to user.image
                .remove(paths: [path])
            
            print("✅ Deleted image from storage")
            
            // Create a properly typed update dictionary
            let updateDict: [String: Optional<String>] = ["userPlantImage": nil]
            
            // Clear the URL from the database
            try await supabase.database
                .from("UserPlant")
                .update(updateDict)
                .eq("userPlantRelationID", value: userPlantID.uuidString)
                .execute()
            
            print("✅ Cleared image URL from database")
        }
    }
    
    // Synchronous wrapper for deleteUserPlantImage
    func deleteUserPlantImageSync(userPlantID: UUID) {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await deleteUserPlantImage(userPlantID: userPlantID)
            } catch {
                print("❌ Error deleting image: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 10)
    }

    // MARK: - Session Management
    
    private func saveSession(_ session: Session) {
        print("\n=== Saving User Session ===")
        do {
            let sessionData = try JSONEncoder().encode(session)
            UserDefaults.standard.set(sessionData, forKey: "userSession")
            print("✅ Session saved successfully")
        } catch {
            print("❌ Failed to save session: \(error)")
        }
    }
    
    func signOut() async throws {
        print("\n=== Signing Out User ===")
        
        // Clear the Supabase session state
        await supaBaseController.shared.clearSession()
        
        // Clear stored session and user data
        UserDefaults.standard.removeObject(forKey: "userSession")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "tempPlantImageURL")
        UserDefaults.standard.removeObject(forKey: "tempPlantID")
        UserDefaults.standard.synchronize() // Force UserDefaults to save immediately
        
        print("✅ User signed out successfully")
        print("✅ All session data cleared")
        
        // Post notification that user signed out
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("UserSignedOut"), object: nil)
        }
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
