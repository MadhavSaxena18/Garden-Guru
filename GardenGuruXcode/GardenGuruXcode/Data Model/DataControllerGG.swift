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
import UserNotifications

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
    let lastWatered: String?  // ISO8601 date string
    let lastFertilized: String?  // ISO8601 date string
    let lastRepotted: String?  // ISO8601 date string
}

//// Add this struct near other model definitions
//struct CareReminderUpdate: Encodable {
//    var upcomingReminderForWater: String?
//    var upcomingReminderForFertilizers: String?
//    var upcomingReminderForRepotted: String?
//    var isWateringCompleted: Bool?
//    var isFertilizingCompleted: Bool?
//    var isRepottingCompleted: Bool?
//    var last_water_completed_date: String?
//    var last_fertilizer_completed_date: String?
//    var last_repot_completed_date: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case upcomingReminderForWater
//        case upcomingReminderForFertilizers
//        case upcomingReminderForRepotted
//        case isWateringCompleted
//        case isFertilizingCompleted
//        case isRepottingCompleted
//        case last_water_completed_date
//        case last_fertilizer_completed_date
//        case last_repot_completed_date
//    }
//}

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
    
    // Restore session from UserDefaults
    func restoreSession() async throws {
        print("\n=== Restoring User Session ===")
        
        guard let sessionData = UserDefaults.standard.data(forKey: "userSession") else {
            print("⚠️ No saved session found")
            return
        }
        
        do {
            let session = try JSONDecoder().decode(Session.self, from: sessionData)
            print("📦 Session decoded from UserDefaults")
            
            // Restore the session to Supabase client
            try await supabase.auth.setSession(accessToken: session.accessToken, refreshToken: session.refreshToken)
            print("✅ Session restored to Supabase client")
            
            // Refresh session if needed (Supabase handles expiry automatically)
            let currentSession = try await supabase.auth.session
            saveSession(currentSession)
            print("✅ Session refreshed and saved")
        } catch {
            print("❌ Failed to restore session: \(error)")
            // Clear invalid session
            UserDefaults.standard.removeObject(forKey: "userSession")
            throw error
        }
    }
    
    // MARK: - User Functions
    
    func getUser() async throws -> userInfo? {
        
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
        let response = try await supabase
            .database
            .from("Plant")
            .select()
            .eq("plantID", value: plantID.uuidString)
            .execute()
        
        if let jsonData = response.data as? Data {
            let plants = try JSONDecoder().decode([Plant].self, from: jsonData)
            return plants.first
        }
        print("❌ Failed to decode plant data")
        return nil
    }
    
    func getUserPlants(for userEmail: String) async throws -> [UserPlant] {
        // First get the user's ID from UserTable
        let userResponse = try await supabase
            .database
            .from("UserTable")
            .select()
            .eq("user_email", value: userEmail)
            .execute()
        
        // Try to decode the user data
        var userIdString: String?
        
        if let data = userResponse.data as? Data {
            do {
                let users = try JSONDecoder().decode([userInfo].self, from: data)
                if let firstUser = users.first {
                    userIdString = firstUser.id
                }
            } catch {
                print("❌ Error decoding user data: \(error)")
                
                // Try parsing as JSON array if direct decoding fails
                if let jsonString = String(data: data, encoding: .utf8),
                   let jsonData = jsonString.data(using: .utf8),
                   let users = try? JSONDecoder().decode([userInfo].self, from: jsonData),
                   let user = users.first {
                    userIdString = user.id
                }
            }
        } else if let jsonArray = userResponse.data as? [[String: Any]],
                  let firstUser = jsonArray.first,
                  let id = firstUser["id"] as? String {
            userIdString = id
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
        
        if let data = response.data as? Data {
            do {
                var userPlants = try JSONDecoder().decode([UserPlant].self, from: data)
                
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
        // First get the care reminder link
        let linkResponse = try await supabase
            .database
            .from("CareReminderOfUserPlant")
            .select("careReminderId")
            .eq("userPlantRelationID", value: userPlantID.uuidString)
            .execute()
        
        // Handle Data response
        guard let data = linkResponse.data as? Data,
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        // Parse the JSON string
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
              let firstLink = jsonArray.first,
              let careReminderId = firstLink["careReminderId"] as? String else {
            return nil
        }
        
        // Then get the actual care reminder
        let reminderResponse = try await supabase
            .database
            .from("CareReminder_")
            .select()
            .eq("careReminderID", value: careReminderId)
            .execute()
        
        // Handle reminder Data response
        guard let reminderData = reminderResponse.data as? Data,
              let reminderString = String(data: reminderData, encoding: .utf8) else {
            return nil
        }
        
        // Parse the reminder JSON
        if let reminderJsonData = reminderString.data(using: .utf8) {
            do {
                let reminders = try JSONDecoder().decode([CareReminder_].self, from: reminderJsonData)
                return reminders.first
            } catch {
                print("❌ Failed to decode reminder: \(error)")
            }
        }
        
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
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let currentDate = Date()
        
        switch type.lowercased() {
        case "water":
            update.isWateringCompleted = isCompleted
            if isCompleted {
                // Set the completion timestamp
                update.last_water_completed_date = dateFormatter.string(from: currentDate)
                if let waterFreq = userPlant.plant.waterFrequency {
                    // Set next water date based on frequency
                    if let nextDate = Calendar.current.date(byAdding: .day, value: Int(waterFreq), to: currentDate) {
                        update.upcomingReminderForWater = dateFormatter.string(from: nextDate)
                    }
                }
            } else {
                // Reset the upcoming reminder date back to the last completion date
                if let lastDate = reminder.last_water_completed_date {
                    update.upcomingReminderForWater = dateFormatter.string(from: lastDate)
                }
            }
        case "fertilizer":
            update.isFertilizingCompleted = isCompleted
            if isCompleted {
                // Set the completion timestamp
                update.last_fertilizer_completed_date = dateFormatter.string(from: currentDate)
                if let fertFreq = userPlant.plant.fertilizerFrequency {
                    // Set next fertilizer date based on frequency
                    if let nextDate = Calendar.current.date(byAdding: .day, value: Int(fertFreq), to: currentDate) {
                        update.upcomingReminderForFertilizers = dateFormatter.string(from: nextDate)
                    }
                }
            } else {
                // Reset the upcoming reminder date back to the last completion date
                if let lastDate = reminder.last_fertilizer_completed_date {
                    update.upcomingReminderForFertilizers = dateFormatter.string(from: lastDate)
                }
            }
        case "repot":
            update.isRepottingCompleted = isCompleted
            if isCompleted {
                // Set the completion timestamp
                update.last_repot_completed_date = dateFormatter.string(from: currentDate)
                if let repotFreq = userPlant.plant.repottingFrequency {
                    // Set next repotting date based on frequency
                    if let nextDate = Calendar.current.date(byAdding: .day, value: Int(repotFreq), to: currentDate) {
                        update.upcomingReminderForRepotted = dateFormatter.string(from: nextDate)
                    }
                }
            } else {
                // Reset the upcoming reminder date back to the last completion date
                if let lastDate = reminder.last_repot_completed_date {
                    update.upcomingReminderForRepotted = dateFormatter.string(from: lastDate)
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
        let response = try await supabase
            .database
            .from("Plant")
            .select()
            .execute()
        
        if let data = response.data as? Data {
            print("✅ Successfully got Data response")
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let plants = try decoder.decode([Plant].self, from: data)
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
        // First get the plant-disease relationships
        let plantDiseasesResponse = try await supabase
            .database
            .from("PlantDisease")
            .select()
            .eq("plantID", value: plantID.uuidString)
            .execute()
        
        var diseases: [Diseases] = []
        
        if let jsonObject = plantDiseasesResponse.data as? [[String: Any]] {
            
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
        let response = try await supabase
            .database
            .from("Diseases")
            .select()
            .execute()
        
        if let jsonData = response.data as? Data {
            print("✅ Successfully got Data response")
            do {
                let diseases = try JSONDecoder().decode([Diseases].self, from: jsonData)
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
        let response = try await supabase
            .database
            .from("Fertilizer")
            .select()
            .execute()
        
        // First try to decode as Data
        if let data = response.data as? Data {
            print("✅ Got Data response, attempting to decode...")
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let fertilizers = try decoder.decode([Fertilizer].self, from: data)
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
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let userPlantRecord = UserPlantInsert(
            userPlantRelationID: userPlant.userPlantRelationID.uuidString,
            userId: userPlant.userId.uuidString,
            userplantID: userPlant.userplantID?.uuidString ?? "",
            userPlantImage: imageURL,
            userPlantNickName: userPlant.userPlantNickName,
            lastWatered: userPlant.lastWatered.map { dateFormatter.string(from: $0) },
            lastFertilized: userPlant.lastFertilized.map { dateFormatter.string(from: $0) },
            lastRepotted: userPlant.lastRepotted.map { dateFormatter.string(from: $0) }
        )
        
        try await supabase
            .database
            .from("UserPlant")
            .insert(userPlantRecord)
            .execute()
        
        print("✅ User plant added successfully with image URL and initial dates")
        
        // Clear the temporary image URL from UserDefaults
        UserDefaults.standard.removeObject(forKey: "tempPlantImageURL")
        UserDefaults.standard.removeObject(forKey: "tempPlantID")
    }
    
    // Synchronous wrapper for addUserPlant with result
    func addUserPlantSync(userPlant: UserPlant) -> Result<Void, Error> {
        var result: Result<Void, Error> = .failure(NSError(domain: "Timeout", code: -1, userInfo: nil))
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await addUserPlant(userPlant: userPlant)
                result = .success(())
                print("✅ Successfully added user plant")
            } catch {
                print("❌ Error adding user plant: \(error)")
                print("❌ Error details: \(error.localizedDescription)")
                result = .failure(error)
            }
            semaphore.signal()
        }
        
        let timeoutResult = semaphore.wait(timeout: .now() + 10) // Increased timeout to 10 seconds
        if timeoutResult == .timedOut {
            print("❌ Timeout waiting for plant to be added")
            return .failure(NSError(domain: "AddPlant", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request timed out. Please check your internet connection."]))
        }
        
        return result
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
        let userPlants = try await getUserPlants(for: userId)
        var result: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []
        
        for userPlant in userPlants {
            if let plantId = userPlant.userplantID {
                if let plant = try await getPlant(by: plantId) {
                    if let reminder = try await getCareReminders(for: userPlant.userPlantRelationID) {
                        result.append((userPlant: userPlant, plant: plant, reminder: reminder))
                    }
                } else {
                    print("❌ Plant not found for ID: \(plantId)")
                }
            }
        }
        
        return result
    }
    
    // Synchronous wrapper for getUserPlantsWithDetails
    func getUserPlantsWithDetailsSync(for userId: String) -> [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] {
        
        var result: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                result = try await getUserPlantsWithDetails(for: userId)
                print("✅ Async call completed with \(result.count) results")
            } catch {
                print("❌ Error getting user plants with details: \(error)")
            }
            semaphore.signal()
        }
        
        let timeoutResult = semaphore.wait(timeout: .now() + 10)  // Increased timeout to 10 seconds
        if timeoutResult == .timedOut {
            print("⏱️ WARNING: Semaphore timed out after 10 seconds!")
        } else {
            print("✅ Semaphore signaled successfully")
        }
        
        print("📊 Returning \(result.count) results")
        return result
    }
    
    // Function to get user plants with basic details
    func getUserPlantsWithBasicDetails(for userEmail: String) async throws -> [(userPlant: UserPlant, plant: Plant)] {
        let userPlants = try await getUserPlants(for: userEmail)
        var result: [(userPlant: UserPlant, plant: Plant)] = []
        
        for userPlant in userPlants {
            if let plantID = userPlant.userplantID {
                if let plant = try await getPlant(by: plantID) {
                    result.append((userPlant: userPlant, plant: plant))
                }
            }
        }
        
        return result
    }
    
    // Synchronous wrapper for getUserPlantsWithBasicDetails
    func getUserPlantsWithBasicDetailsSync(for userEmail: String) -> [(userPlant: UserPlant, plant: Plant)]? {
        var result: [(userPlant: UserPlant, plant: Plant)]?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                result = try await getUserPlantsWithBasicDetails(for: userEmail)
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
        print("🆔 UserPlantID: \(userPlantID)")
        print("📝 Type: \(type)")
        print("✅ Is Completed: \(isCompleted)")
        
        // Get the current reminder to check its dates
        guard let currentReminder = try await getCareReminders(for: userPlantID) else {
            print("❌ No reminder found")
            throw APIError(message: "No reminder found")
        }
        
        // Get the plant details to know the frequency
        let userPlants = try await getUserPlantsWithBasicDetails(for: UserDefaults.standard.string(forKey: "userEmail") ?? "")
        guard let userPlant = userPlants.first(where: { $0.userPlant.userPlantRelationID == userPlantID }) else {
            print("❌ Plant not found")
            throw APIError(message: "Plant not found")
        }
        
        print("✅ Found plant: \(userPlant.plant.plantName)")
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let currentDate = Date()
        
        var update = CareReminderUpdate()
        
        switch type.lowercased() {
        case "water":
            update.isWateringCompleted = isCompleted
            if isCompleted {
                // Set the completion date to now
                update.last_water_completed_date = dateFormatter.string(from: currentDate)
                
                // Calculate next reminder date based on plant's watering frequency
                if let waterFreq = userPlant.plant.waterFrequency {
                    let nextDate = Calendar.current.date(byAdding: .day, value: Int(waterFreq), to: currentDate)
                    update.upcomingReminderForWater = dateFormatter.string(from: nextDate ?? currentDate)
                    print("💧 Next water date set to: \(update.upcomingReminderForWater ?? "nil")")
                }
            } else {
                // UNCOMPLETING: Set upcoming date to today so user can complete it again
                update.upcomingReminderForWater = dateFormatter.string(from: currentDate)
                print("💧 Reset water date to TODAY (uncompleted): \(update.upcomingReminderForWater ?? "nil")")
            }
            
        case "fertilizer":
            update.isFertilizingCompleted = isCompleted
            if isCompleted {
                // Set the completion date to now
                update.last_fertilizer_completed_date = dateFormatter.string(from: currentDate)
                
                // Calculate next reminder date based on plant's fertilizing frequency
                if let fertilizerFreq = userPlant.plant.fertilizerFrequency {
                    let nextDate = Calendar.current.date(byAdding: .day, value: Int(fertilizerFreq), to: currentDate)
                    update.upcomingReminderForFertilizers = dateFormatter.string(from: nextDate ?? currentDate)
                    print("🌱 Next fertilizer date set to: \(update.upcomingReminderForFertilizers ?? "nil")")
                }
            } else {
                // UNCOMPLETING: Set upcoming date to today so user can complete it again
                update.upcomingReminderForFertilizers = dateFormatter.string(from: currentDate)
                print("🌱 Reset fertilizer date to TODAY (uncompleted): \(update.upcomingReminderForFertilizers ?? "nil")")
            }
            
        case "repot":
            update.isRepottingCompleted = isCompleted
            if isCompleted {
                // Set the completion date to now
                update.last_repot_completed_date = dateFormatter.string(from: currentDate)
                
                // Calculate next reminder date based on plant's repotting frequency
                if let repottingFreq = userPlant.plant.repottingFrequency {
                    let nextDate = Calendar.current.date(byAdding: .day, value: Int(repottingFreq), to: currentDate)
                    update.upcomingReminderForRepotted = dateFormatter.string(from: nextDate ?? currentDate)
                    print("🪴 Next repot date set to: \(update.upcomingReminderForRepotted ?? "nil")")
                }
            } else {
                // UNCOMPLETING: Set upcoming date to today so user can complete it again
                update.upcomingReminderForRepotted = dateFormatter.string(from: currentDate)
                print("🪴 Reset repot date to TODAY (uncompleted): \(update.upcomingReminderForRepotted ?? "nil")")
            }
            
        default:
            print("❌ Invalid reminder type: \(type)")
            throw APIError(message: "Invalid reminder type")
        }
        print("📝 Update details:")
        if let waterDate = update.upcomingReminderForWater { print("💧 Water date: \(waterDate)") }
        if let fertilizerDate = update.upcomingReminderForFertilizers { print("🌱 Fertilizer date: \(fertilizerDate)") }
        if let repotDate = update.upcomingReminderForRepotted { print("🪴 Repot date: \(repotDate)") }
        
        // Update the reminder
        try await supabase
            .database
            .from("CareReminder_")
            .update(update)
            .eq("careReminderID", value: currentReminder.careReminderID.uuidString)
            .execute()
        
        // Schedule notifications for the updated reminder
        // First, get the updated reminder
        if let updatedReminder = try await getCareReminders(for: userPlantID) {
            updateReminders(for: updatedReminder, plant: userPlant.plant, nickname: userPlant.userPlant.userPlantNickName)
        }
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
    
    // Function to update overdue reminders - sets upcoming date to today
    func updateOverdueReminder(userPlantID: UUID, type: String) async throws {
        // Get the current reminder
        guard let currentReminder = try await getCareReminders(for: userPlantID) else {
            print("❌ No reminder found")
            throw APIError(message: "No reminder found")
        }
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let today = Date()
        let todayString = dateFormatter.string(from: today)
        
        var update = CareReminderUpdate()
        
        switch type.lowercased() {
        case "water":
            // Only update if not completed
            if !(currentReminder.isWateringCompleted ?? false) {
                update.upcomingReminderForWater = todayString
                print("💧 Updated water reminder to today: \(todayString)")
            }
        case "fertilizer":
            if !(currentReminder.isFertilizingCompleted ?? false) {
                update.upcomingReminderForFertilizers = todayString
                print("🌱 Updated fertilizer reminder to today: \(todayString)")
            }
        case "repot":
            if !(currentReminder.isRepottingCompleted ?? false) {
                update.upcomingReminderForRepotted = todayString
                print("🪴 Updated repotting reminder to today: \(todayString)")
            }
        default:
            print("❌ Invalid type: \(type)")
            return
        }
        
        // Update the database
        try await supabase
            .database
            .from("CareReminder_")
            .update(update)
            .eq("careReminderID", value: currentReminder.careReminderID.uuidString)
            .execute()
        
        print("✅ Overdue reminder updated in database")
    }
    
    // Synchronous wrapper for updateOverdueReminder
    func updateOverdueReminderSync(userPlantID: UUID, type: String) {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                try await updateOverdueReminder(userPlantID: userPlantID, type: type)
            } catch {
                print("❌ Error updating overdue reminder: \(error)")
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
    
//    // Add this struct near other model definitions
//    private struct CareReminderInsert: Encodable {
//        let careReminderID: String
//        let upcomingReminderForWater: String
//        let upcomingReminderForFertilizers: String?
//        let upcomingReminderForRepotted: String?
//        let isWateringCompleted: Bool
//        let isFertilizingCompleted: Bool
//        let isRepottingCompleted: Bool
//        let last_water_completed_date: String?
//        let last_fertilizer_completed_date: String?
//        let last_repot_completed_date: String?
//        let wateringEnabled: Bool
//        let fertilizerEnabled: Bool
//        let repottingEnabled: Bool
//
//        enum CodingKeys: String, CodingKey {
//            case careReminderID
//            case upcomingReminderForWater
//            case upcomingReminderForFertilizers
//            case upcomingReminderForRepotted
//            case isWateringCompleted
//            case isFertilizingCompleted
//            case isRepottingCompleted
//            case last_water_completed_date
//            case last_fertilizer_completed_date
//            case last_repot_completed_date
//            case wateringEnabled
//            case fertilizerEnabled
//            case repottingEnabled
//        }
//    }
    
    // Synchronous wrapper for addCareReminder
    func addCareReminderSync(userPlantID: UUID, reminderAllowed: Bool, isWateringEnabled: Bool = false, isFertilizingEnabled: Bool = false, isRepottingEnabled: Bool = false) {
        print("\n=== Adding Care Reminder (Sync) ===")
        print("🆔 UserPlantID: \(userPlantID)")
        print("✅ Reminder Allowed: \(reminderAllowed)")
        print("💧 Water Enabled: \(isWateringEnabled)")
        print("🌱 Fertilizer Enabled: \(isFertilizingEnabled)")
        print("🪴 Repotting Enabled: \(isRepottingEnabled)")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let currentDate = dateFormatter.string(from: Date())
                print("📅 Current Date: \(currentDate)")
                
                // Create a properly typed care reminder
                let careReminder = CareReminderInsert(
                    careReminderID: userPlantID.uuidString,
                    upcomingReminderForWater: isWateringEnabled ? currentDate : nil,
                    upcomingReminderForFertilizers: isFertilizingEnabled ? currentDate : nil,
                    upcomingReminderForRepotted: isRepottingEnabled ? currentDate : nil,
                    isWateringCompleted: false,  // Always start as not completed
                    isFertilizingCompleted: false,  // Always start as not completed
                    isRepottingCompleted: false,  // Always start as not completed
                    last_water_completed_date: currentDate,
                    last_fertilizer_completed_date: currentDate,
                    last_repot_completed_date: currentDate,
                    wateringEnabled: isWateringEnabled,
                    fertilizerEnabled: isFertilizingEnabled,
                    repottingEnabled: isRepottingEnabled
                )
                
                print("\n📝 Preparing to insert care reminder:")
                print("🆔 Care Reminder ID: \(careReminder.careReminderID)")
                print("💧 Water Next Date: \(careReminder.upcomingReminderForWater ?? "nil")")
                print("🌱 Fertilizer Next Date: \(String(describing: careReminder.upcomingReminderForFertilizers))")
                // Insert the care reminder with all fields
                let reminderResponse = try await supabase
                    .database
                    .from("CareReminder_")
                    .insert(careReminder)
                    .execute()
                
                // Create the linking record in CareReminderOfUserPlant
                let linkingRecord = CareReminderLinkInsert(
                    careReminderOfUserPlantID: UUID().uuidString,
                    userPlantRelationID: userPlantID.uuidString,
                    careReminderId: userPlantID.uuidString
                )
                
                let linkResponse = try await supabase
                    .database
                    .from("CareReminderOfUserPlant")
                    .insert(linkingRecord)
                    .execute()
                
            } catch let error as PostgrestError {
                print("\n❌ Postgrest Error adding care reminder:")
                print("Error message: \(error.message)")
                print("Status code: \(error.code)")
            } catch {
                print("\n❌ Unexpected error adding care reminder:")
                print("Error: \(error)")
                print("Error description: \(error.localizedDescription)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
    }
    
    // Add this struct for the linking record
    private struct CareReminderLinkInsert: Encodable {
        let careReminderOfUserPlantID: String
        let userPlantRelationID: String
        let careReminderId: String
    }
    
    // MARK: - User Management
    
    func initializeUser(email: String) async throws -> userInfo? {
        print("\n=== Initializing User ===")
        print("📧 Email: \(email)")
        
        // Check UserTable for existing user data
        do {
            let response = try await supabase
                .database
                .from("UserTable")
                .select()
                .eq("user_email", value: email)
                .execute()
            
            // Try to decode the response data
            if let data = response.data as? Data {
                do {
                    let users = try JSONDecoder().decode([userInfo].self, from: data)
                    if let user = users.first {
                        print("✅ Found existing user: \(user.userName)")
                        return user
                    }
                } catch {
                    print("❌ Error decoding user data: \(error)")
                    
                    // Try parsing as JSON array if direct decoding fails
                    if let jsonString = String(data: data, encoding: .utf8),
                       let jsonData = jsonString.data(using: .utf8),
                       let users = try? JSONDecoder().decode([userInfo].self, from: jsonData),
                       let user = users.first {
                        print("✅ Found existing user (alt): \(user.userName)")
                        return user
                    }
                }
            } else if let jsonArray = response.data as? [[String: Any]] {
                if !jsonArray.isEmpty {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonArray[0])
                        let user = try JSONDecoder().decode(userInfo.self, from: jsonData)
                        print("✅ Found existing user (json): \(user.userName)")
                        return user
                    } catch {
                        print("❌ Error decoding user data: \(error)")
                    }
                }
            }
            
            // CRITICAL FIX: User not found - create them automatically!
            print("⚠️ No existing user found - creating new user in UserTable...")
            
            // Extract username from email (before @)
            let defaultUsername = email.components(separatedBy: "@").first ?? "User"
            
            // Create the user
            let newUser = try await createUser(
                email: email,
                userName: defaultUsername,
                location: "North India"
            )
            
            print("✅ Created new user in UserTable: \(newUser.userName)")
            return newUser
            
        } catch {
            print("❌ Error in initializeUser: \(error)")
            
            // If there's an error, try to create user anyway (might be first-time setup)
            do {
                print("🔄 Attempting to create user after error...")
                let defaultUsername = email.components(separatedBy: "@").first ?? "User"
                let newUser = try await createUser(
                    email: email,
                    userName: defaultUsername,
                    location: "North India"
                )
                print("✅ Successfully created user after recovery")
                return newUser
            } catch let createError {
                print("❌ Failed to create user: \(createError)")
                return nil
            }
        }
    }
    
    // Synchronous wrapper for getting user
    func getUserSync() -> userInfo? {
        var user: userInfo?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                if let storedEmail = UserDefaults.standard.string(forKey: "userEmail") {
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
        
        // After successful authentication, fetch or create user data in UserTable
        let (exists, userData) = try await checkUserExists(email: email)
        
        if let userData = userData {
            print("✅ User data found in UserTable")
            return (session, userData)
        } else if exists {
            // User exists in Auth but not in UserTable, create entry
            print("⚠️ User exists in Auth but not in UserTable, creating entry")
            let newUserData = try await createUser(
                email: email,
                userName: email.components(separatedBy: "@")[0], // Use email prefix as default username
                location: "North India" // Default location
            )
            print("✅ Created user data in UserTable")
            return (session, newUserData)
        }
        
        
        // Post notification that user signed in
        NotificationCenter.default.post(name: Notification.Name("UserSignedIn"), object: nil)
        
        return (session, userData)
        
    }
    
    // Add this function after the signIn function
    func signUp(email: String, password: String, userName: String) async throws -> (AuthResponse, userInfo?) {
        print("\n=== Signing Up New User ===")
        print("🔑 Attempting to sign up with email: \(email)")
        print("📝 Password length: \(password.count)")
        
        do {
            // First create the auth user in Supabase
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password
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
        } catch let error as AuthError {
            print("❌ Auth Error: \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ Signup Error: \(error.localizedDescription)")
            if error.localizedDescription.contains("Password should contain") {
                print("🔐 Password validation failed at Supabase level")
                print("🔐 Attempted password length: \(password.count)")
                print("🔐 Password requirements from Supabase: at least one character of each: abcdefghijklmnopqrstuvwxyz, ABCDEFGHIJKLMNOPQRSTUVWXYZ, 0123456789, !@#$%^&*()_+-=[]{};':")
            }
            throw error
        }
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
            
            // Convert Data to JSON
            if let data = response.data as? Data,
               let jsonString = String(data: data, encoding: .utf8) {
                
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
            }
        } catch {
            print("❌ Error fetching users: \(error)")
        }
    }
    
    // Function to get disease by name with better error handling
    func getDiseaseByName(name: String) async throws -> Diseases? {
        // Clean up the disease name
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let response = try await supabase
            .database
            .from("Diseases")
            .select()
            .execute()
        
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
    
    // Add method to update display name
    func updateDisplayName(email: String, newDisplayName: String) async throws {
        print("🔄 Updating display name for email: \(email)")
        try await supabase
            .database
            .from("UserTable")
            .update(["Display name": newDisplayName])
            .eq("user_email", value: email)
            .execute()
        print("✅ Display name updated successfully in Supabase")
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
                return plantDiseases
            } catch {
                print("❌ Failed to decode Data response: \(error)")
                // If direct decoding fails, try parsing as JSON string
                if let jsonString = String(data: data, encoding: .utf8),
                   let jsonData = jsonString.data(using: .utf8) {
                    do {
                        let plantDiseases = try JSONDecoder().decode([PlantDisease].self, from: jsonData)
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
            
            return diseases
        }
        
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
    func checkUserExists(email: String) async throws -> (exists: Bool, userData: userInfo?) {
        print("\n=== Checking User Existence ===")
        print("🔍 Checking email: \(email)")
        
        // Clean and validate email
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        print("📧 Cleaned email: \(cleanEmail)")
        
        guard cleanEmail.contains("@") && cleanEmail.contains(".") else {
            print("❌ Invalid email format")
            throw AuthError.invalidCredentials
        }
        
        do {
            // Check UserTable first
            print("🔍 Step 1: Checking UserTable...")
            let response = try await supabase
                .database
                .from("UserTable")
                .select()
                .eq("user_email", value: cleanEmail)
                .execute()
            
            print("📝 UserTable response type: \(type(of: response.data))")
            if let jsonData = response.data as? Data {
                print("📝 UserTable response (Data): \(String(data: jsonData, encoding: .utf8) ?? "nil")")
                if let users = try? JSONDecoder().decode([userInfo].self, from: jsonData),
                   let user = users.first {
                    print("✅ User found in UserTable with data")
                    return (true, user)
                }
            } else if let jsonObject = response.data as? [[String: Any]], !jsonObject.isEmpty {
                print("✅ User found in UserTable")
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject[0]),
                   let user = try? JSONDecoder().decode(userInfo.self, from: jsonData) {
                    return (true, user)
                }
                return (true, nil)
            }
            
            // If not found in UserTable, check auth table
            print("\n🔍 Step 2: Checking Auth table...")
            do {
                print("📝 Attempting to get user by email: \(cleanEmail)")
                // Try to sign in with invalid password to check if user exists
                try await supabase.auth.signIn(
                    email: cleanEmail,
                    password: UUID().uuidString // Random invalid password
                )
                // If we get here without error, something went wrong
                print("⚠️ Unexpected successful sign in with random password")
                return (true, nil)
            } catch let error {
                print("📝 Auth check response: \(error.localizedDescription)")
                
                // Check error message for specific cases
                let errorMessage = error.localizedDescription.lowercased()
                if errorMessage.contains("invalid login credentials") {
                    // "Invalid login credentials" actually means user doesn't exist in this case
                    print("✅ User does not exist in Auth table (invalid credentials)")
                    return (false, nil)
                } else if errorMessage.contains("user not found") ||
                            errorMessage.contains("invalid user") ||
                            errorMessage.contains("no user found") {
                    print("✅ User does not exist in Auth table")
                    return (false, nil)
                }
                
                // For any other error, log it and assume user doesn't exist
                print("⚠️ Unexpected auth error: \(error)")
                print("⚠️ Assuming user doesn't exist to allow signup attempt")
                return (false, nil)
            }
        } catch {
            print("❌ Error checking user existence: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    // MARK: - Email Verification and Signup
    
    func sendSignupVerificationEmail(email: String, password: String) async throws {
        print("\n=== Sending Signup Verification Email ===")
        print("📧 Sending to: \(email)")
        print("🔐 Using provided password length: \(password.count)")
        
        // Create account with email verification enabled
        try await supabase.auth.signUp(
            email: email,
            password: password
        )
        print("✅ Verification email sent")
    }
    
    func resendVerificationEmail(email: String) async throws {
        print("\n=== Resending Verification Email ===")
        print("📧 Resending to: \(email)")
        
        try await supabase.auth.resend(
            email: email,
            type: .signup,
            emailRedirectTo: nil,
            captchaToken: nil
        )
    }
    
    func verifyEmail(email: String, otp: String) async throws {
        print("\n=== Verifying Email ===")
        print("📧 Verifying email: \(email)")
        
        try await supabase.auth.verifyOTP(
            email: email,
            token: otp,
            type: .signup
        )
        print("✅ Email verified")
    }
    
    func completeSignup(email: String, password: String, userName: String) async throws {
        print("\n=== Completing User Signup ===")
        print("📧 Creating user with email: \(email)")
        
        do {
            // First create the auth user
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            let userId = authResponse.user.id.uuidString
            print("✅ Auth user created successfully with ID: \(userId)")
            
            // Then create the user in UserTable
            let userTableData = UserTableInsert(
                id: userId, // Use the string ID from auth
                user_email: email,
                userName: userName,
                location: "North India", // Default location
                reminderAllowed: true    // Default setting
            )
            
            try await supabase
                .database
                .from("UserTable")
                .insert(userTableData)
                .execute()
            
            print("✅ User created in UserTable")
            
            // Store the email for future use
            UserDefaults.standard.set(email, forKey: "userEmail")
            
        } catch {
            print("❌ Error completing signup: \(error)")
            throw error
        }
    }
    
    // Add this struct near the top of the file with other model definitions
    private struct UserProfileUpdate: Encodable {
        let userName: String?
        let age: Int?
        let gender: String?
        let plant_preferences: [String]?
        
        init(from userData: [String: Any]) {
            self.userName = userData["full_name"] as? String
            self.age = userData["age"] as? Int
            self.gender = userData["gender"] as? String
            self.plant_preferences = userData["plant_preferences"] as? [String]
        }
    }
    
    func saveUserProfile(userData: [String: Any]) async throws {
        guard let email = userData["email"] as? String else {
            throw NSError(domain: "DataController", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email is required"])
        }
        
        // Create a properly typed update struct
        let updateData = UserProfileUpdate(from: userData)
        
        do {
            // First check if user exists
            let (exists, _) = try await checkUserExists(email: email)
            
            if exists {
                // User exists, update their profile
                try await supabase
                    .database
                    .from("UserTable")
                    .update(updateData)
                    .eq("user_email", value: email)
                    .execute()
                
                print("✅ Successfully updated existing user profile")
            } else {
                // User doesn't exist, create new profile
                let userTableData = UserTableInsert(
                    id: UUID().uuidString,
                    user_email: email,
                    userName: updateData.userName ?? email.components(separatedBy: "@")[0],
                    location: "North India",
                    reminderAllowed: true
                )
                
                try await supabase
                    .database
                    .from("UserTable")
                    .insert(userTableData)
                    .execute()
                
                // Now update with additional profile data
                try await supabase
                    .database
                    .from("UserTable")
                    .update(updateData)
                    .eq("user_email", value: email)
                    .execute()
                
                print("✅ Successfully created and updated new user profile")
            }
        } catch {
            print("❌ Error in saveUserProfile: \(error)")
            throw error
            
        }
    }
    
    
    // Helper struct for decoding nested JSON response
    private struct UserPlantWithDetails: Codable {
        let userPlant: UserPlant
        let plant: Plant
        let careReminder: CareReminder_
    }
    
    // Add synchronous wrappers in extension
    
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
    
    func saveUserItem(userId: UUID, itemId: UUID, itemType: String) async throws {
            // Construct the record to insert
            let saveRecord: [String: String] = [
                "userId": userId.uuidString,
                "itemId": itemId.uuidString,
                "itemType": itemType
            ]
            
            // Perform the insert operation
            try await supabase
                .database
                .from("UserSavedItem")
                .insert(saveRecord)
                .execute()
        }
    
    func unsaveUserItem(userId: UUID, itemId: UUID, itemType: String) async throws {
            // Perform the delete operation with a compound match condition
            try await supabase
                .database
                .from("UserSavedItem")
                .delete()
                .eq("userId", value: userId.uuidString)
                .eq("itemId", value: itemId.uuidString)
                .eq("itemType", value: itemType)
                .execute()
        }
    
    func getCurrentUserIdSync() -> UUID? {
        if let user = getUserSync() {
            return UUID(uuidString: user.id)
        }
        return nil
    }
    func isItemSaved(userId: UUID, itemId: UUID, itemType: String) async throws -> Bool {
        // Perform a query for all matching saved items (typically only 1 or 0)
        let response = try await supabase
            .database
            .from("UserSavedItem")
            .select()
            .eq("userId", value: userId.uuidString)
            .eq("itemId", value: itemId.uuidString)
            .eq("itemType", value: itemType)
            .execute()

        // Attempt to decode the response data as an array of dictionaries
        if let data = response.data as? Data {
            do {
                if let results = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    return !results.isEmpty // True if at least one saved item exists
                }
            } catch {
                print("Failed to parse saved item check: \(error)")
            }
        }
        return false // No match found
    }

    func getSavedItems(for userId: UUID) async throws -> [(itemType: String, item: Any)] {
        let response = try await supabase
            .database
            .from("UserSavedItem")
            .select()
            .eq("userId", value: userId.uuidString)
            .execute()

        guard let data = response.data as? Data else { return [] }

        let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

        var results: [(String, Any)] = []

        for record in jsonArray {
            guard let type = record["itemType"] as? String,
                  let itemIdStr = record["itemId"] as? String,
                  let itemId = UUID(uuidString: itemIdStr) else { continue }

            switch type {
            case "plant":
                if let plant = try await getPlant(by: itemId) {
                    results.append(("plant", plant))
                }
            case "disease":
                if let disease = try await getDiseaseDetails(by: itemId) {
                    results.append(("disease", disease))
                }
            default:
                continue
            }
        }

        return results
    }
    
    func getSavedItemsSync(for userId: UUID) -> [(itemType: String, item: Any)] {
        var result: [(itemType: String, item: Any)] = []
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                result = try await getSavedItems(for: userId)
            } catch {
                print("❌ Error getting saved items: \(error)")
            }
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 5)
        return result
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
    

    func getCareTipOfTheDay() async throws -> CareTip? {
        let weekday = Calendar.current.component(.weekday, from: Date()) // 1 = Sunday
        let dayIndex = (weekday + 5) % 7 // Map Monday = 0, Sunday = 6

        let response = try await supabase
            .database
            .from("CareTips")
            .select()
            .eq("dayIndex", value: dayIndex)
            .limit(1)
            .execute()

        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ" // Ensure this format handles fractional seconds
        decoder.dateDecodingStrategy = .formatted(formatter)

        let tips = try decoder.decode([CareTip].self, from: response.data)
        return tips.first
    }




    // MARK: - Push Notification Methods
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error)")
                completion(false)
                return
            }
            
            print("✅ Notification permission granted: \(granted)")
            completion(granted)
            
            // Register for remote notifications on main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func scheduleReminder(for plant: Plant, nickname: String?, type: String, dueDate: Date) {
        print("\n=== Scheduling Reminder ===")
        print("🌿 Plant: \(plant.plantName)")
        print("📅 Due Date: \(dueDate)")
        print("📝 Type: \(type)")
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.badge = 1
        
        let plantName = nickname ?? plant.plantName
        
        // Create two notifications: one for initial setup and one for the due date
        let initialContent = UNMutableNotificationContent()
        initialContent.sound = .default
        initialContent.badge = 1
        
        // Set up initial notification content
        switch type {
        case "water":
            initialContent.title = "Plant Added - Watering Schedule"
            initialContent.body = "Your \(plantName) will need watering on \(formatDate(dueDate))"
            content.title = "Watering Time! 💧"
            content.body = "Your \(plantName) needs watering."
        case "fertilizer":
            initialContent.title = "Plant Added - Fertilizer Schedule"
            initialContent.body = "Your \(plantName) will need fertilizer on \(formatDate(dueDate))"
            content.title = "Fertilizer Time! 🌱"
            content.body = "Your \(plantName) needs some nutrients today."
        case "repot":
            initialContent.title = "Plant Added - Repotting Schedule"
            initialContent.body = "Your \(plantName) will need repotting on \(formatDate(dueDate))"
            content.title = "Repotting Time! 🪴"
            content.body = "Your \(plantName) has outgrown its pot and needs repotting."
        default:
            print("❌ Invalid reminder type: \(type)")
            return
        }
        
        // Remove any existing notifications for this plant and type
        let identifier = "\(plant.plantID.uuidString)_\(type)_\(dueDate.timeIntervalSince1970)"
        let initialIdentifier = "\(plant.plantID.uuidString)_\(type)_initial"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier, initialIdentifier])
        
        // Schedule initial notification for 1 minute from now
        let initialTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let initialRequest = UNNotificationRequest(identifier: initialIdentifier, content: initialContent, trigger: initialTrigger)
        
        // Schedule the initial notification
        UNUserNotificationCenter.current().add(initialRequest) { error in
            if let error = error {
                print("❌ Error scheduling initial notification: \(error)")
            } else {
                print("✅ Initial notification scheduled")
            }
        }
        
        // Only schedule due date notification if the due date is in the future
        let calendar = Calendar.current
        if dueDate > Date() {
            // Set notification for 8 AM on the due date
            var components = calendar.dateComponents([.year, .month, .day], from: dueDate)
            components.hour = 8
            components.minute = 0
            components.second = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Create the request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling due date notification: \(error)")
                } else {
                    print("✅ Due date notification scheduled for \(dueDate)")
                }
            }
        } else {
            print("⏭ Skipping due date notification for past date: \(dueDate)")
        }
        
        print("=== Reminder Scheduling Complete ===\n")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func updateReminders(for reminder: CareReminder_, plant: Plant, nickname: String?) {
        print("\n=== Updating Reminders ===")
        
        // Remove existing notifications for this plant
        let identifiers = [
            "\(reminder.careReminderID.uuidString)_water",
            "\(reminder.careReminderID.uuidString)_fertilizer",
            "\(reminder.careReminderID.uuidString)_repot"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑 Removed existing notifications")
        
        // Only schedule notifications if they're enabled
        if reminder.wateringEnabled, let waterDate = reminder.upcomingReminderForWater {
            print("💧 Scheduling water reminder (enabled)")
            scheduleReminder(for: plant, nickname: nickname, type: "water", dueDate: waterDate)
        } else {
            print("💧 Water reminders disabled or no date")
        }
        
        if reminder.fertilizerEnabled, let fertilizerDate = reminder.upcomingReminderForFertilizers {
            print("🌱 Scheduling fertilizer reminder (enabled)")
            scheduleReminder(for: plant, nickname: nickname, type: "fertilizer", dueDate: fertilizerDate)
        } else {
            print("🌱 Fertilizer reminders disabled or no date")
        }
        
        if reminder.repottingEnabled, let repotDate = reminder.upcomingReminderForRepotted {
            print("🪴 Scheduling repot reminder (enabled)")
            scheduleReminder(for: plant, nickname: nickname, type: "repot", dueDate: repotDate)
        } else {
            print("🪴 Repot reminders disabled or no date")
        }
        
        // Verify all scheduled notifications
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("\n📋 All pending notifications (\(requests.count) total):")
            for request in requests {
                print("- ID: \(request.identifier)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("  Next trigger: \(trigger.nextTriggerDate() ?? Date())")
                }
            }
        }
        
        print("=== Reminder Update Complete ===\n")
    }
    
    func scheduleNotification(for plant: Plant, type: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Garden Guru - \(plant.plantName) needs care!"
        
        switch type {
        case "watering":
            content.body = "Time to water your \(plant.plantName)! 💧"
        case "fertilizer":
            content.body = "Time to fertilize your \(plant.plantName)! 🌱"
        case "repotting":
            content.body = "Time to repot your \(plant.plantName)! 🪴"
        default:
            content.body = "Your \(plant.plantName) needs attention!"
        }
        
        content.sound = .default
        content.badge = 1
        content.threadIdentifier = "garden_guru_\(plant.plantID)"
        content.categoryIdentifier = "GARDEN_REMINDER"
        
        // Add user info for handling the notification
        content.userInfo = [
            "plantId": plant.plantID,
            "reminderType": type,
            "dueDate": date.timeIntervalSince1970
        ]
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let identifier = "\(type)_\(plant.plantID)_\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Successfully scheduled \(type) notification for \(plant.plantName) at \(date)")
            }
        }
    }
    
    func getPreventionTips() async throws -> [PreventionTip] {
        print("🔍 Fetching all prevention tips...")
        let response = try await supabase
            .database
            .from("prevention_tips")
            .select()
            .order("sort_order", ascending: true)
            .execute()
        
        guard let jsonData = response.data as? Data else {
            print("❌ No data received for prevention tips.")
            return []
        }
        
        print("📡 Raw prevention tips response: \(jsonData.count) bytes")
        do {
            let decoder = JSONDecoder()
            
            // Use a standard DateFormatter for precise ISO8601 decoding with fractional seconds
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ" // Handles up to 6 fractional seconds
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure timezone is handled consistently
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            let tips = try decoder.decode([PreventionTip].self, from: jsonData)
            return tips
        } catch {
            print("❌ Decoding error for prevention tips: \(error)")
            throw error
        }
    }

    func signInWithApple(idToken: String) async throws -> (Session, userInfo?) {
        print("\n=== Signing In with Apple ===")
        
        // Sign in with Supabase using Apple token
        let session = try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken
            )
        )
        
        print("✅ Apple authentication successful")
        
        // Save the session
        saveSession(session)
        
        // Get the user's email from the session
        guard let email = session.user.email else {
            throw AuthError.noAuthenticatedUser
        }
        
        // Store the email for future use
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        // After successful authentication, fetch user data
        print("🔍 Fetching user data from UserTable")
        let userData = try await initializeUser(email: email)
        
        // Post notification that user signed in
        NotificationCenter.default.post(name: Notification.Name("UserSignedIn"), object: nil)
        
        return (session, userData)
    }
    
    func signInWithGoogle(idToken: String, nonce: String) async throws -> (Session, userInfo?) {
        print("\n=== Signing In with Google ===")
        print("📱 ID Token received: \(idToken.prefix(20))...")
        print("🔐 Nonce: \(nonce)")
        
        do {
            // Sign in with Supabase using Google token with nonce
            print("🔐 Authenticating with Supabase...")
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken,
                    nonce: nonce
                )
            )
            
            print("✅ Google authentication successful")
            print("   User ID: \(session.user.id)")
            print("   Email: \(session.user.email ?? "N/A")")
            
            // Save the session
            saveSession(session)
            
            // Get the user's email from the session
            guard let email = session.user.email else {
                print("❌ No email found in session")
                throw AuthError.noAuthenticatedUser
            }
            
            // Store the email for future use
            UserDefaults.standard.set(email, forKey: "userEmail")
            
            // After successful authentication, fetch user data
            print("🔍 Fetching user data from UserTable")
            let userData = try await initializeUser(email: email)
            
            // Post notification that user signed in
            NotificationCenter.default.post(name: Notification.Name("UserSignedIn"), object: nil)
            
            print("✅ Google Sign In Complete")
            return (session, userData)
            
        } catch {
            print("❌ Google Sign In Failed")
            print("   Error: \(error)")
            print("   Description: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
            }
            throw error
        }
    }
    
    // Simplified version without nonce - let Supabase handle it
    func signInWithGoogleToken(idToken: String) async throws -> (Session, userInfo?) {
        print("\n=== Signing In with Google (Token Only) ===")
        print("📱 ID Token received: \(idToken.prefix(20))...")
        
        do {
            // Sign in with Supabase using Google token - no nonce
            print("🔐 Authenticating with Supabase...")
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken
                )
            )
            
            print("✅ Google authentication successful")
            print("   User ID: \(session.user.id)")
            print("   Email: \(session.user.email ?? "N/A")")
            
            // Save the session
            saveSession(session)
            
            // Get the user's email from the session
            guard let email = session.user.email else {
                print("❌ No email found in session")
                throw AuthError.noAuthenticatedUser
            }
            
            // Store the email for future use
            UserDefaults.standard.set(email, forKey: "userEmail")
            
            // After successful authentication, fetch user data
            print("🔍 Fetching user data from UserTable")
            let userData = try await initializeUser(email: email)
            
            // Post notification that user signed in
            NotificationCenter.default.post(name: Notification.Name("UserSignedIn"), object: nil)
            
            print("✅ Google Sign In Complete")
            return (session, userData)
            
        } catch {
            print("❌ Google Sign In Failed")
            print("   Error: \(error)")
            print("   Description: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
            }
            throw error
        }
    }
    
    // MARK: - Community Functions
    
    /// Fetches community posts from Supabase with pagination support
    /// - Parameters:
    ///   - limit: Maximum number of posts to fetch (default: 20)
    ///   - offset: Number of posts to skip for pagination (default: 0)
    /// - Returns: Array of CommunityPost objects sorted by creation date (newest first)
    func fetchCommunityPosts(limit: Int = 20, offset: Int = 0) async throws -> [CommunityPost] {
        print("\n=== Fetching Community Posts ===")
        print("📊 Limit: \(limit), Offset: \(offset)")
        
        let response = try await supabase
            .database
            .from("CommunityPost")
            .select()
            .order("createdAt", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
        
        print("📡 Raw community posts response: \(String(describing: response.data))")
        
        guard let jsonData = response.data as? Data else {
            print("❌ No data received for community posts")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            var posts = try decoder.decode([CommunityPost].self, from: jsonData)
            
            // Fetch user info for each post
            for i in 0..<posts.count {
                if let user = try? await getUserForPost(userID: posts[i].userID) {
                    posts[i].userName = user.userName
                    posts[i].userEmail = user.userEmail
                }
            }
            
            return posts
        } catch {
            print("❌ Error decoding community posts: \(error)")
            throw error
        }
    }
    
    /// Creates a new community post with image upload
    /// - Parameters:
    ///   - plantName: Name of the plant (2-50 characters)
    ///   - description: Post description (10-500 characters)
    ///   - image: UIImage to upload
    /// - Returns: Created CommunityPost object
    func createCommunityPost(plantName: String, description: String, image: UIImage) async throws -> CommunityPost {
        print("\n=== Creating Community Post ===")
        print("🌱 Plant Name: \(plantName)")
        print("📝 Description: \(description)")
        
        // Validate input
        guard plantName.count >= 2 && plantName.count <= 50 else {
            print("❌ Invalid plant name length: \(plantName.count)")
            throw CommunityError.invalidInput("Plant name must be between 2 and 50 characters")
        }
        
        guard description.count >= 10 && description.count <= 500 else {
            print("❌ Invalid description length: \(description.count)")
            throw CommunityError.invalidInput("Description must be between 10 and 500 characters")
        }
        
        // Get current user
        print("🔍 Getting current user...")
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {
            print("❌ No user email in UserDefaults")
            throw CommunityError.unauthorized
        }
        print("📧 User email: \(userEmail)")
        
        guard let user = try await initializeUser(email: userEmail) else {
            print("❌ Could not initialize user")
            throw CommunityError.unauthorized
        }
        print("✅ User found: \(user.userName) (ID: \(user.id))")
        
        guard let userID = UUID(uuidString: user.id) else {
            print("❌ Invalid user ID format: \(user.id)")
            throw CommunityError.unauthorized
        }
        print("✅ User ID parsed: \(userID)")
        
        // Generate post ID
        let postID = UUID()
        print("🆔 Generated post ID: \(postID)")
        
        // Upload image first
        print("📤 Uploading image...")
        let imageURL = try await uploadPostImage(postID: postID, image: image)
        print("✅ Image uploaded: \(imageURL)")
        
        // Create post record using encodable struct
        struct PostInsert: Encodable {
            let postID: String
            let userID: String
            let plantName: String
            let description: String
            let imageURL: String
        }
        
        let postData = PostInsert(
            postID: postID.uuidString,
            userID: userID.uuidString,
            plantName: plantName,
            description: description,
            imageURL: imageURL
        )
        
        print("📡 Inserting post into database...")
        let response = try await supabase
            .database
            .from("CommunityPost")
            .insert(postData)
            .select()
            .execute()
        
        guard let jsonData = response.data as? Data else {
            throw CommunityError.postCreationFailed
        }
        
        let decoder = JSONDecoder()
        var posts = try decoder.decode([CommunityPost].self, from: jsonData)
        
        guard var post = posts.first else {
            throw CommunityError.postCreationFailed
        }
        
        // Add user info
        post.userName = user.userName
        post.userEmail = user.userEmail
        
        print("✅ Community post created successfully")
        
        // Post notification
        NotificationCenter.default.post(name: .communityPostCreated, object: post)
        
        return post
    }
    
    /// Uploads a post image to Supabase Storage
    /// - Parameters:
    ///   - postID: UUID of the post
    ///   - image: UIImage to upload
    /// - Returns: Public URL of the uploaded image
    func uploadPostImage(postID: UUID, image: UIImage) async throws -> String {
        print("\n=== Uploading Post Image ===")
        
        // Compress and resize image
        guard let compressedImage = compressImage(image, maxSizeInMB: 2, maxWidth: 1080) else {
            throw CommunityError.imageUploadFailed
        }
        
        guard let imageData = compressedImage.jpegData(compressionQuality: 0.8) else {
            throw CommunityError.imageUploadFailed
        }
        
        print("📊 Image size: \(Double(imageData.count) / 1_000_000) MB")
        
        // Get current user ID for folder structure
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail"),
              let user = try await initializeUser(email: userEmail) else {
            throw CommunityError.unauthorized
        }
        
        // Create file path: userID/postID.jpg
        let fileName = "\(user.id)/\(postID.uuidString).jpg"
        
        print("📤 Uploading to: community-posts/\(fileName)")
        
        // Upload to Supabase Storage
        let uploadResponse = try await supabase.storage
            .from("community-posts")
            .upload(
                path: fileName,
                file: imageData,
                options: FileOptions(
                    contentType: "image/jpeg",
                    upsert: true
                )
            )
        
        // Get public URL
        let publicURL = try supabase.storage
            .from("community-posts")
            .getPublicURL(path: fileName)
        
        print("✅ Image uploaded successfully: \(publicURL)")
        return publicURL.absoluteString
    }
    
    /// Deletes a community post and its associated image
    /// - Parameter postID: UUID of the post to delete
    func deleteCommunityPost(postID: UUID) async throws {
        print("\n=== Deleting Community Post ===")
        print("🗑️ Post ID: \(postID)")
        
        // Get the post first to retrieve image URL
        let response = try await supabase
            .database
            .from("CommunityPost")
            .select()
            .eq("postID", value: postID.uuidString)
            .execute()
        
        guard let jsonData = response.data as? Data else {
            throw CommunityError.fetchFailed
        }
        
        let decoder = JSONDecoder()
        let posts = try decoder.decode([CommunityPost].self, from: jsonData)
        
        guard let post = posts.first else {
            print("⚠️ Post not found")
            return
        }
        
        // Extract file path from URL
        if let url = URL(string: post.imageURL),
           let pathComponents = url.pathComponents.dropFirst(5).joined(separator: "/") as String? {
            // Delete image from storage
            print("🗑️ Deleting image: \(pathComponents)")
            try await supabase.storage
                .from("community-posts")
                .remove(paths: [pathComponents])
        }
        
        // Delete post from database
        print("🗑️ Deleting post from database...")
        try await supabase
            .database
            .from("CommunityPost")
            .delete()
            .eq("postID", value: postID.uuidString)
            .execute()
        
        print("✅ Community post deleted successfully")
        
        // Post notification
        NotificationCenter.default.post(name: .communityPostDeleted, object: postID)
    }
    
    /// Fetches user information for a post
    /// - Parameter userID: UUID of the user
    /// - Returns: userInfo object or nil if not found
    func getUserForPost(userID: UUID) async throws -> userInfo? {
        let response = try await supabase
            .database
            .from("UserTable")
            .select()
            .eq("id", value: userID.uuidString)
            .execute()
        
        guard let jsonData = response.data as? Data else {
            return nil
        }
        
        let decoder = JSONDecoder()
        let users = try decoder.decode([userInfo].self, from: jsonData)
        return users.first
    }
    
    /// Compresses an image to a maximum size while maintaining aspect ratio
    /// - Parameters:
    ///   - image: Original UIImage
    ///   - maxSizeInMB: Maximum file size in megabytes
    ///   - maxWidth: Maximum width in pixels
    /// - Returns: Compressed UIImage or nil if compression fails
    private func compressImage(_ image: UIImage, maxSizeInMB: Double, maxWidth: CGFloat) -> UIImage? {
        // Resize if needed
        var resizedImage = image
        if image.size.width > maxWidth {
            let ratio = maxWidth / image.size.width
            let newHeight = image.size.height * ratio
            let newSize = CGSize(width: maxWidth, height: newHeight)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }
        
        // Compress to target size
        let maxSizeInBytes = maxSizeInMB * 1_000_000
        var compression: CGFloat = 0.8
        var imageData = resizedImage.jpegData(compressionQuality: compression)
        
        while let data = imageData, Double(data.count) > maxSizeInBytes && compression > 0.1 {
            compression -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compression)
        }
        
        guard let finalData = imageData else { return nil }
        return UIImage(data: finalData)
    }
}

// MARK: - Community Error Types

enum CommunityError: Error {
    case networkUnavailable
    case imageUploadFailed
    case postCreationFailed
    case fetchFailed
    case invalidInput(String)
    case unauthorized
    
    var localizedDescription: String {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Please check your network."
        case .imageUploadFailed:
            return "Failed to upload image. Please try again."
        case .postCreationFailed:
            return "Failed to create post. Please try again."
        case .fetchFailed:
            return "Failed to load posts. Pull to refresh."
        case .invalidInput(let message):
            return message
        case .unauthorized:
            return "You must be logged in to perform this action."
        }
    }
}

