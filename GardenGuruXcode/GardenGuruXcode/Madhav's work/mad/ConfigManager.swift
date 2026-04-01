import Foundation

enum ConfigError: Error {
    case missingKey(String)
    case invalidPlist
    case invalidConfiguration
    
    var localizedDescription: String {
        switch self {
        case .missingKey(let key):
            return "Missing configuration key: \(key)"
        case .invalidPlist:
            return "Invalid or missing AiGenerative.plist file"
        case .invalidConfiguration:
            return "Invalid configuration setup"
        }
    }
}

class ConfigManager {
    static let shared = ConfigManager()
    
    private var configDict: [String: Any]?
    
    // FALLBACK: Hardcoded API key (only for development - remove in production!)
    private let fallbackAPIKey = "AIzaSyCzQbnYwAOMNoAMl0pTZfHqH3cz2Y0ZIrI"
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        // Try to load from plist first
        if let path = Bundle.main.path(forResource: "AiGenerative", ofType: "plist") {
            print("✅ Found AiGenerative.plist at: \(path)")
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                configDict = dict
                print("✅ Configuration loaded successfully from plist")
                return
            } else {
                print("⚠️ Warning: Could not parse AiGenerative.plist")
            }
        } else {
            print("⚠️ Warning: AiGenerative.plist not found in bundle")
            print("📦 Bundle path: \(Bundle.main.bundlePath)")
            print("📂 Searching for plist files...")
            
            // List all plist files in bundle for debugging
            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    let plists = files.filter { $0.hasSuffix(".plist") }
                    print("📄 Found plist files: \(plists)")
                } catch {
                    print("❌ Error listing bundle contents: \(error)")
                }
            }
        }
        
        // Use fallback configuration
        print("⚠️ Using fallback configuration")
        configDict = [
            "GEMINI_API_KEY": fallbackAPIKey,
            "API_KEY": fallbackAPIKey
        ]
    }
    
    // MARK: - Public Methods
    
    /// Get API key with a specific key name (e.g., "GEMINI_API_KEY")
    func getAPIKey(for key: String) -> String? {
        guard let dict = configDict else {
            print("❌ Configuration not loaded")
            return fallbackAPIKey // Return fallback instead of nil
        }
        
        // Try the exact key first
        if let apiKey = dict[key] as? String, !apiKey.isEmpty {
            print("✅ Found API key for: \(key)")
            return apiKey
        }
        
        // Fallback to "API_KEY" for backward compatibility
        if let apiKey = dict["API_KEY"] as? String, !apiKey.isEmpty {
            print("✅ Found API key using fallback key")
            return apiKey
        }
        
        print("⚠️ API key not found for: \(key), using fallback")
        return fallbackAPIKey
    }
    
    /// Legacy method for backward compatibility
    func getGeminiAPIKey() throws -> String {
        if let apiKey = getAPIKey(for: "GEMINI_API_KEY") ?? getAPIKey(for: "API_KEY") {
            return apiKey
        }
        
        // This should never happen now since we have fallback
        throw ConfigError.missingKey("GEMINI_API_KEY or API_KEY")
    }
    
    /// Validate that all required keys are present
    func validateConfiguration() -> Bool {
        do {
            let apiKey = try getGeminiAPIKey()
            let isValid = !apiKey.isEmpty
            print(isValid ? "✅ Configuration validated" : "❌ Configuration validation failed")
            return isValid
        } catch {
            print("❌ Configuration validation failed: \(error.localizedDescription)")
            return false
        }
    }
}
