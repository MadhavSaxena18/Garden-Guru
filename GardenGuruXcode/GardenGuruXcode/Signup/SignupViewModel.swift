import Foundation

class SignupViewModel {
    var userName = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    
    var onError: ((String) -> Void)?
    var onSuccess: (() -> Void)?
    
    private let dataController = DataControllerGG.shared
    
    var isFormValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmail(email) &&
        isValidPassword(password) &&
        password == confirmPassword
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
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
    func signUp() async {
        do {
            // First, create the auth user in Supabase with the provided name
            let response = try await dataController.signUp(
                email: email,
                password: password,
                userName: userName
            )
            
            // Check if we have either a session or user data
            if response.0.session != nil || response.1 != nil {
                // Store the email in UserDefaults
                UserDefaults.standard.set(email, forKey: "userEmail")
                
                // Show success message
                onSuccess?()
            } else {
                onError?("Failed to create user")
            }
            
        } catch {
            onError?(error.localizedDescription)
        }
    }
} 