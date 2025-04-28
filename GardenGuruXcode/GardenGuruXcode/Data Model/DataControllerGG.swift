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
        
        guard let jsonObject = userResponse.data as? [[String: Any]],
              let firstUser = jsonObject.first,
              let userIdString = firstUser["id"] as? String else {
            print("❌ Could not find user ID for email: \(userEmail)")
            return []
        }
        
        print("📍 Found user ID: \(userIdString)")
        
        // Now get the user's plants using the correct ID
        let response = try await supabase
            .database
            .from("UserPlant")
            .select()
            .eq("userId", value: userIdString)
            .execute()
        
        print("📡 Raw user plants response: \(String(describing: response.data))")
        
        if let jsonObject = response.data as? [[String: Any]] {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
            let userPlants = try JSONDecoder().decode([UserPlant].self, from: jsonData)
            print("✅ Decoded user plants count: \(userPlants.count)")
            return userPlants
        }
        
        print("❌ Failed to decode user plants data")
        return []
    }
    
    // MARK: - Care Reminder Functions
    
    func getCareReminders(for userPlantID: UUID) async throws -> CareReminder_? {
        let response = try await supabase
            .database
            .from("CareReminder")
            .select()
            .eq("careReminderID", value: userPlantID.uuidString)
            .single()
            .execute()
        
        if let jsonData = response.data as? Data {
            return try JSONDecoder().decode(CareReminder_.self, from: jsonData)
        }
        return nil
    }
    
    func updateCareReminderStatus(userPlantID: UUID, type: String, isCompleted: Bool) async throws {
        var updateData: [String: Bool] = [:]
        switch type.lowercased() {
        case "water":
            updateData["isWateringCompleted"] = isCompleted
        case "fertilizer":
            updateData["isFertilizingCompleted"] = isCompleted
        case "repot":
            updateData["isRepottingCompleted"] = isCompleted
        default:
            break
        }
        
        try await supabase
            .database
            .from("CareReminder")
            .update(updateData)
            .eq("careReminderID", value: userPlantID.uuidString)
            .execute()
    }
    
    func deleteUserPlant(userPlantID: UUID) async throws {
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
        let userPlants = try await getUserPlants(for: userId)
        var result: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []
        
        for userPlant in userPlants {
            if let plant = try await getPlant(by: userPlant.userplantID!) {
                let reminder = try await getCareReminders(for: userPlant.userPlantRelationID)
                if let existingReminder = reminder {
                    result.append((userPlant: userPlant, plant: plant, reminder: existingReminder))
                } else {
                    // Create new reminder if it doesn't exist
                    try await addCareReminder(userPlantID: userPlant.userPlantRelationID, reminderAllowed: true)
                    if let newReminder = try await getCareReminders(for: userPlant.userPlantRelationID) {
                        result.append((userPlant: userPlant, plant: plant, reminder: newReminder))
                    }
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
        
        var result: [(userPlant: UserPlant, plant: Plant)] = []
        
        for userPlant in userPlants {
            print("🌿 Looking up plant for userPlant ID: \(userPlant.userplantID)")
            if let plant = try await getPlant(by: userPlant.userplantID!) {
                print("✅ Found plant: \(plant.plantName)")
                result.append((userPlant: userPlant, plant: plant))
            } else {
                print("⚠️ No plant found for ID: \(userPlant.userplantID)")
            }
        }
        
        print("✅ Final result count: \(result.count) plants with details")
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
                print("Error getting user plants with basic details: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return result
    }
    
    // Function to update care reminder with all details
    func updateCareReminderWithDetails(userPlantID: UUID, type: String, isCompleted: Bool) async throws {
        // First update the status
        try await updateCareReminderStatus(userPlantID: userPlantID, type: type, isCompleted: isCompleted)
        
        // Then update the reminder dates based on type
        let nextReminderDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let nextReminderString = ISO8601DateFormatter().string(from: nextReminderDate)
        
        // Create update data with proper type
        let updateData: [String: String]
        switch type.lowercased() {
        case "water":
            updateData = ["upcomingReminderForWater": nextReminderString]
        case "fertilizer":
            updateData = ["upcomingReminderForFertilizers": nextReminderString]
        case "repot":
            updateData = ["upcomingReminderForRepotted": nextReminderString]
        default:
            return
        }
        
        try await supabase
            .database
            .from("CareReminder")
            .update(updateData)
            .eq("careReminderID", value: userPlantID.uuidString)
            .execute()
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
        let currentDate = ISO8601DateFormatter().string(from: Date())
        let careReminder: [String: String] = [
            "careReminderID": userPlantID.uuidString,
            "upcomingReminderForWater": currentDate,
            "upcomingReminderForFertilizers": currentDate,
            "upcomingReminderForRepotted": currentDate
        ]
        
        // First insert the basic reminder data
        try await supabase
            .database
            .from("CareReminder")
            .insert(careReminder)
            .execute()
            
        // Then update the boolean fields separately
        let booleanData: [String: Bool] = [
            "isWateringCompleted": false,
            "isFertilizingCompleted": false,
            "isRepottingCompleted": false
        ]
        
        try await supabase
            .database
            .from("CareReminder")
            .update(booleanData)
            .eq("careReminderID", value: userPlantID.uuidString)
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
    
    // Add this struct near the top of the file, after other model definitions
    private struct UserTableInsert: Encodable {
        let id: String
        let user_email: String
        let userName: String
        let location: String
        let reminderAllowed: Bool
    }
    
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

    // MARK: - Auth Errors

    enum AuthError: LocalizedError {
        case noAuthenticatedUser
        case invalidCredentials
        case networkError
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .noAuthenticatedUser:
                return "No authenticated user found"
            case .invalidCredentials:
                return "Invalid email or password"
            case .networkError:
                return "Network error during authentication"
            case .unknown(let error):
                return "Unknown error: \(error.localizedDescription)"
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
