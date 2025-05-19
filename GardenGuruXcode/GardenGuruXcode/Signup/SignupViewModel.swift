import Foundation

class SignupViewModel {
    var email = ""
    var otp = ""
    
    var onError: ((String) -> Void)?
    var onSuccess: (() -> Void)?
    var onOTPSent: (() -> Void)?
    var onOTPVerified: (() -> Void)?
    var onUserExists: (() -> Void)?
    
    private let dataController = DataControllerGG.shared
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    @MainActor
    func checkEmailAndSendOTP() async {
        do {
            // Clean up the email
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            // First validate email format
            guard isValidEmail(cleanEmail) else {
                onError?("Please enter a valid email address")
                return
            }
            
            // Check if user exists
            let userExists = try await dataController.checkUserExists(email: cleanEmail)
            if userExists {
                onUserExists?()
                return
            }
            
            // Send verification email
            try await dataController.sendSignupVerificationEmail(email: cleanEmail)
            
            // Store the email in UserDefaults for later use
            UserDefaults.standard.set(cleanEmail, forKey: "userEmail")
            onOTPSent?()
            
        } catch {
            if error.localizedDescription.contains("rate limit") {
                onError?("Please wait a moment before trying again")
            } else if error.localizedDescription.contains("Invalid email") {
                onError?("Please enter a valid email address")
            } else {
                onError?(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func resendOTP() async {
        do {
            try await dataController.resendVerificationEmail(email: email)
            onOTPSent?()
        } catch {
            if error.localizedDescription.contains("rate limit") {
                onError?("Please wait a moment before trying again")
            } else {
                onError?(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func verifyOTP() async {
        do {
            try await dataController.verifyEmail(email: email, otp: otp)
            onOTPVerified?()
        } catch {
            onError?("Invalid verification code")
        }
    }
} 
