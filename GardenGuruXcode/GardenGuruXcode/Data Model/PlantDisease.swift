import Foundation

struct PlantDisease: Codable, Hashable {
    var plantDiseaseID: UUID
    var plantID: UUID //FK FOR PLANT
    var diseaseID: UUID //FK FOR DISEASE
    
    enum CodingKeys: String, CodingKey {
        case plantDiseaseID
        case plantID
        case diseaseID
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID decoding
        if let uuidString = try? container.decode(String.self, forKey: .plantDiseaseID) {
            plantDiseaseID = UUID(uuidString: uuidString) ?? UUID()
        } else {
            plantDiseaseID = UUID()
        }
        
        // Decode plantID
        if let plantIDString = try? container.decode(String.self, forKey: .plantID) {
            plantID = UUID(uuidString: plantIDString) ?? UUID()
        } else {
            plantID = UUID()
        }
        
        // Decode diseaseID
        if let diseaseIDString = try? container.decode(String.self, forKey: .diseaseID) {
            diseaseID = UUID(uuidString: diseaseIDString) ?? UUID()
        } else {
            diseaseID = UUID()
        }
    }
} 