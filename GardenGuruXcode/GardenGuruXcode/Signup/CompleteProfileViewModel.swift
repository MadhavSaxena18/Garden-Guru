import Foundation

class CompleteProfileViewModel {
    var name = ""
    var age = ""
    var gender = ""
    var password = ""
    var confirmPassword = ""
    
    var onError: ((String) -> Void)?
    var onSuccess: (() -> Void)?
    
    private let dataController = DataControllerGG.shared
    
    func isValidPassword(_ password: String) -> Bool {
        // Check minimum length
        guard password.count >= 8 else { return false }
        
        // Check for uppercase letter
        guard password.range(of: "[A-Z]", options: .regularExpression) != nil else { return false }
        
        // Check for lowercase letter
        guard password.range(of: "[a-z]", options: .regularExpression) != nil else { return false }
        
        // Check for number
        guard password.range(of: "[0-9]", options: .regularExpression) != nil else { return false }
        
        // Check for special character
        guard password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil else { return false }
        
        return true
    }
    
    var passwordRequirementText: String {
        """
        Password must contain:
        • At least 8 characters
        • One uppercase letter
        • One lowercase letter
        • One number
        • One special character
        """
    }
    
    @MainActor
    func completeRegistration() async {
        do {
            // Validate all fields
            guard !name.isEmpty else {
                onError?("Please enter your name")
                return
            }
            
            guard let ageInt = Int(age), ageInt > 0 else {
                onError?("Please enter a valid age")
                return
            }
            
            guard !gender.isEmpty else {
                onError?("Please select your gender")
                return
            }
            
            guard isValidPassword(password) else {
                onError?(passwordRequirementText)
                return
            }
            
            guard password == confirmPassword else {
                onError?("Passwords do not match")
                return
            }
            
            // Get email from UserDefaults
            guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
                onError?("Email not found. Please try signing up again.")
                return
            }
            
            // Complete the registration
            try await dataController.completeSignup(
                email: email,
                password: password,
                userName: name
            )
            
            // Save additional user data
            try await dataController.saveUserProfile(userData: [
                "email": email,
                "name": name,
                "age": String(ageInt),
                "gender": gender
            ])
            
            onSuccess?()
            
        } catch {
            onError?(error.localizedDescription)
        }
    }
} 