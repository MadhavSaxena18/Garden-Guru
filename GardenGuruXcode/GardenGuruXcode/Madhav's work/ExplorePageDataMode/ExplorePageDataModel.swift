//
//  ExplorePageDataModel.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import Foundation
import UIKit

// MARK: - Discover Segment Models
struct DataOfSection1InDicoverSegment {
    var image: String
    var plantName: String
    var plantDescription: String
    var plantID: UUID
    var waterFrequency: Int64?
    var fertilizerFrequency: Int64?
    var repottingFrequency: Int64?
    var pruningFrequency: Int64?
    var favourableSeason: Season?
    var category: Category?
    
    init(from plant: Plant) {
        self.image = plant.imageURLs.first ?? ""
        self.plantName = plant.plantName
        self.plantDescription = plant.plantDescription ?? ""
        self.plantID = plant.plantID
        self.waterFrequency = plant.waterFrequency
        self.fertilizerFrequency = plant.fertilizerFrequency
        self.repottingFrequency = plant.repottingFrequency
        self.pruningFrequency = plant.pruningFrequency
        self.favourableSeason = plant.favourableSeason
        self.category = plant.category_new
    }
}

struct DataOfSection2InDiscoverSegment {
    var image: String  // Changed to String to match database schema
    var diseaseName: String
    var diseaseID: UUID
    var diseaseSymptoms: String?
    var diseaseCure: String?
    var diseaseSeason: Season?
    
    init(from disease: Diseases) {
        self.image = disease.diseaseImage ?? ""
        self.diseaseName = disease.diseaseName
        self.diseaseID = disease.diseaseID
        self.diseaseSymptoms = disease.diseaseSymptoms
        self.diseaseCure = disease.diseaseCure
        self.diseaseSeason = disease.diseaseSeason
    }
}

// MARK: - For My Plant Segment Models
struct DataOfSection1InforMyPlantSegment {
    var image: String
    var diseaseName: String
    var diseaseID: UUID
    var detectedDate: Date?
    
    init(from userDisease: UsersPlantDisease, disease: Diseases) {
        self.image = disease.diseaseImage ?? ""
        self.diseaseName = disease.diseaseName
        self.diseaseID = disease.diseaseID
        self.detectedDate = userDisease.detectedDate
    }
}

struct DataOfSection2InforMyPlantSegment {
    var image: String
    var fertilizerName: String
    var fertilizerDescription: String?
    var fertilizerID: UUID
    
    init(from fertilizer: Fertilizer) {
        self.image = fertilizer.fertilizerImage ?? ""
        self.fertilizerName = fertilizer.fertilizerName
        self.fertilizerDescription = fertilizer.fertilizerDescription
        self.fertilizerID = fertilizer.fertilizerId
    }
}

// MARK: - Card Detail Models
struct CardDetailsSection1 {
    var plantImage: String
    var waterFrequency: Int64?
    var fertilizerFrequency: Int64?
    var repottingFrequency: Int64?
    var pruningFrequency: Int64?
    
    init(from plant: Plant) {
        self.plantImage = plant.plantImage ?? ""
        self.waterFrequency = plant.waterFrequency
        self.fertilizerFrequency = plant.fertilizerFrequency
        self.repottingFrequency = plant.repottingFrequency
        self.pruningFrequency = plant.pruningFrequency
    }
}

struct CardDetailsSection2 {
    var plantName: String
    var botanicalName: String?
    var description: String?
    
    init(from plant: Plant) {
        self.plantName = plant.plantName
        self.botanicalName = plant.plantBotanicalName
        self.description = plant.plantDescription
    }
}

struct CardDetailsSection3{
    var plantImage: UIImage
}

class ExploreScreen{
    private static let dataController = DataControllerGG.shared
    
    static var headerData: [String] = ["Current Season Plants", "Common Issues", "Care Tip of the Day"]
    static var headerForInMyPlantSegment: [String] = ["Common Issues in your Plant", "Common fertilizer"]
    
    // MARK: - Data Fetching Methods
    static func fetchDiscoverSegmentData() async throws -> (plants: [DataOfSection1InDicoverSegment], diseases: [DataOfSection2InDiscoverSegment]) {
        print("🔄 Starting to fetch discover segment data...")
        let plants = try await dataController.getPlants()
        print("✅ Fetched \(plants.count) plants")
        
        let diseases = try await dataController.getDiseases(for: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
        print("✅ Fetched \(diseases.count) diseases")
        
        let plantModels = plants.map { DataOfSection1InDicoverSegment(from: $0) }
        let diseaseModels = diseases.map { DataOfSection2InDiscoverSegment(from: $0) }
        
        print("📊 Discover segment data prepared:")
        print("   - Plant models: \(plantModels.count)")
        print("   - Disease models: \(diseaseModels.count)")
        
        return (plantModels, diseaseModels)
    }
    
    static func fetchForMyPlantSegmentData(userEmail: String) async throws -> (userDiseases: [DataOfSection1InforMyPlantSegment], fertilizers: [DataOfSection2InforMyPlantSegment]) {
        print("🔄 Starting to fetch 'For My Plant' segment data...")
        print("📧 User email: \(userEmail)")
        
        // First get the user's plants
        let userPlants = try await dataController.getUserPlants(for: userEmail)
        print("✅ Fetched \(userPlants.count) user plants")
        
        // Get all diseases for these plants through PlantDisease relationship
        var userDiseases: [DataOfSection1InforMyPlantSegment] = []
        
        for userPlant in userPlants {
            guard let plantID = userPlant.userplantID else {
                print("⚠️ No plant ID for user plant: \(userPlant.userPlantNickName ?? "unnamed")")
                continue
            }
            
            print("🌱 Processing plant: \(userPlant.userPlantNickName ?? "Unnamed") with ID: \(plantID)")
            
            // Get diseases through PlantDisease relationship
            let diseases = try await dataController.getDiseases(for: plantID)
            print("   - Found \(diseases.count) diseases for this plant")
            
            for disease in diseases {
                let userDisease = UsersPlantDisease(
                    usersPlantDisease: UUID(),
                    usersPlantRelationID: userPlant.userPlantRelationID,
                    diseaseID: disease.diseaseID,
                    detectedDate: Date()
                )
                userDiseases.append(DataOfSection1InforMyPlantSegment(from: userDisease, disease: disease))
            }
        }
        // Sort userDiseases by diseaseName for static order
        userDiseases.sort { $0.diseaseName.localizedCaseInsensitiveCompare($1.diseaseName) == .orderedAscending }
        
        // Get fertilizers
        print("🌱 Fetching fertilizers...")
        let fertilizers = try await dataController.getCommonFertilizers()
        print("✅ Fetched \(fertilizers.count) fertilizers")
        let fertilizerModels = fertilizers.map { DataOfSection2InforMyPlantSegment(from: $0) }
        
        print("📊 'For My Plant' segment data prepared:")
        print("   - User diseases: \(userDiseases.count)")
        print("   - Fertilizer models: \(fertilizerModels.count)")
        
        return (userDiseases, fertilizerModels)
    }
    
    static func fetchCardDetails(for plantID: UUID) async throws -> (section1: CardDetailsSection1, section2: CardDetailsSection2) {
        let plant = try await dataController.getPlant(by: plantID)
        return (CardDetailsSection1(from: plant!), CardDetailsSection2(from: plant!))
    }
}
    
