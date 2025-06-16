import Foundation

struct PreventionTip: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    let title: String?
    let message: String
    let imageUrl: String?
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case title
        case message
        case imageUrl = "image_url"
        case sortOrder = "sort_order"
    }
} 