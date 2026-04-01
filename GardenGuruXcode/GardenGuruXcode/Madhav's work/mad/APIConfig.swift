struct APIConfig {
    // MARK: - API Keys
    static var geminiAPIKey: String {
        return ConfigManager.shared.getAPIKey(for: "GEMINI_API_KEY") ?? ""
    }
    
    // MARK: - API Endpoints
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta"
    // Use the correct model name for v1beta API (from Google AI Studio cURL quickstart)
    static let geminiModel = "gemini-flash-latest"
    
    // MARK: - Configuration
    static let isProduction = false  // Set to true for production builds
    
    // MARK: - Helper Methods
    static func validateConfiguration() -> Bool {
        return !geminiAPIKey.isEmpty
    }
}
