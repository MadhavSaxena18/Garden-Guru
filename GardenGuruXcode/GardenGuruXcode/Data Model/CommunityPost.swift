//
//  CommunityPost.swift
//  GardenGuruXcode
//
//  Created by Garden Guru Team
//

import Foundation

// MARK: - CommunityPost Model

struct CommunityPost: Codable, Hashable, Identifiable {
    let postID: UUID
    let userID: UUID
    let plantName: String
    let description: String
    let imageURL: String
    let createdAt: Date
    let updatedAt: Date?
    
    // Computed properties for user info (fetched separately)
    var userName: String?
    var userEmail: String?
    
    // Identifiable conformance
    var id: UUID { postID }
    
    enum CodingKeys: String, CodingKey {
        case postID
        case userID
        case plantName
        case description
        case imageURL
        case createdAt
        case updatedAt
    }
    
    // MARK: - Initializers
    
    init(postID: UUID = UUID(),
         userID: UUID,
         plantName: String,
         description: String,
         imageURL: String,
         createdAt: Date = Date(),
         updatedAt: Date? = nil,
         userName: String? = nil,
         userEmail: String? = nil) {
        self.postID = postID
        self.userID = userID
        self.plantName = plantName
        self.description = description
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userName = userName
        self.userEmail = userEmail
    }
    
    // MARK: - Decodable
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID decoding for postID
        if let uuidString = try? container.decode(String.self, forKey: .postID) {
            postID = UUID(uuidString: uuidString) ?? UUID()
        } else {
            postID = UUID()
        }
        
        // Handle UUID decoding for userID
        if let uuidString = try? container.decode(String.self, forKey: .userID) {
            userID = UUID(uuidString: uuidString) ?? UUID()
        } else {
            userID = UUID()
        }
        
        // Decode required string fields
        plantName = try container.decode(String.self, forKey: .plantName)
        description = try container.decode(String.self, forKey: .description)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        
        // Handle date decoding with multiple format support
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        // Decode createdAt
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            if let date = iso8601Formatter.date(from: dateString) {
                createdAt = date
            } else if let date = simpleDateFormatter.date(from: dateString) {
                createdAt = date
            } else {
                print("⚠️ Could not parse createdAt date: \(dateString)")
                createdAt = Date()
            }
        } else {
            createdAt = Date()
        }
        
        // Decode updatedAt (optional)
        if let dateString = try? container.decode(String.self, forKey: .updatedAt) {
            if let date = iso8601Formatter.date(from: dateString) {
                updatedAt = date
            } else if let date = simpleDateFormatter.date(from: dateString) {
                updatedAt = date
            } else {
                print("⚠️ Could not parse updatedAt date: \(dateString)")
                updatedAt = nil
            }
        } else {
            updatedAt = nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns a relative time string (e.g., "2 hours ago", "Just now")
    func relativeTimeString() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: createdAt, to: now)
        
        if let year = components.year, year > 0 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        }
        
        if let month = components.month, month > 0 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        }
        
        if let day = components.day, day > 0 {
            if day >= 7 {
                let weeks = day / 7
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            }
            return day == 1 ? "1 day ago" : "\(day) days ago"
        }
        
        if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        
        if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        
        return "Just now"
    }
    
    /// Returns formatted date string (e.g., "Jan 15, 2025")
    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: createdAt)
    }
}

// MARK: - Date Extension for Relative Time

extension Date {
    /// Returns a relative time string from this date to now
    func relativeTimeString() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: now)
        
        if let year = components.year, year > 0 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        }
        
        if let month = components.month, month > 0 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        }
        
        if let day = components.day, day > 0 {
            if day >= 7 {
                let weeks = day / 7
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            }
            return day == 1 ? "1 day ago" : "\(day) days ago"
        }
        
        if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        
        if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        
        return "Just now"
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let communityPostCreated = Notification.Name("CommunityPostCreated")
    static let communityPostDeleted = Notification.Name("CommunityPostDeleted")
}
