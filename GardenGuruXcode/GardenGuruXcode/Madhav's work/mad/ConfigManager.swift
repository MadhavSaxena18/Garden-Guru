//
//  ConfigManager.swift
//  ReadBuddyAi
//
//  Created by Deepanshu-Maliyan-Mac on 16/01/25.
//

import Foundation
enum ConfigError: Error {
    case missingKey
    case invalidPlist
}

class ConfigManager {
    static let shared = ConfigManager()
    
    private init() {}
    
    func getGeminiAPIKey() throws -> String {
        guard let path = Bundle.main.path(forResource: "AiGenerative", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            throw ConfigError.invalidPlist
        }
        
        guard let apiKey = dict["API_KEY"] as? String else {
            throw ConfigError.missingKey
        }
        
        return apiKey
    }

}
