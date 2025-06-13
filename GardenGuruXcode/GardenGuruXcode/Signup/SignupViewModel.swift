import Foundation

class SignupViewModel {
    var email = ""
    var password = ""
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
    
    func isValidPassword(_ password: String) -> Bool {
        // Check minimum length
        guard password.count >= 8 else {
            return false
        }
        
        // Define all required character sets
        let lowercaseSet = Set("abcdefghijklmnopqrstuvwxyz")
        let uppercaseSet = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let numberSet = Set("0123456789")
        let specialSet = Set("!@#$%^&*()_+-=[]{};':\"\\|<>?,./`~")
        
        // Convert password to character set for comparison
        let passwordChars = Set(password)
        
        // Check intersection with each required set
        let hasLowercase = !passwordChars.intersection(lowercaseSet).isEmpty
        let hasUppercase = !passwordChars.intersection(uppercaseSet).isEmpty
        let hasNumber = !passwordChars.intersection(numberSet).isEmpty
        let hasSpecial = !passwordChars.intersection(specialSet).isEmpty
        
        return hasLowercase && hasUppercase && hasNumber && hasSpecial
    }
    
    var passwordRequirementText: String {
        """
        Password must contain ALL of the following:
        • At least 8 characters total
        • At least one lowercase letter (a-z)
        • At least one uppercase letter (A-Z)
        • At least one number (0-9)
        • At least one special character
        """
    }
    
    @MainActor
    func checkEmailAndSendOTP() async {
        do {
            // Clean up the email and password
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Validate email and password
            guard isValidEmail(cleanEmail) else {
                onError?("Please enter a valid email address")
                return
            }
            
            guard isValidPassword(cleanPassword) else {
                onError?(passwordRequirementText)
                return
            }
            
            // Check if user exists
            let (userExists, _) = try await dataController.checkUserExists(email: cleanEmail)
            
            if userExists {
                onUserExists?()
                return
            }
            
            // Send verification email
            try await dataController.sendSignupVerificationEmail(email: cleanEmail, password: cleanPassword)
            
            // Store the email and password securely
            UserDefaults.standard.set(cleanEmail, forKey: "userEmail")
            KeychainManager.shared.save(cleanPassword, for: "tempPassword_\(cleanEmail)")
            
            onOTPSent?()
            
        } catch {
            if error.localizedDescription.contains("rate limit") {
                onError?("Please wait a moment before trying again")
            } else if error.localizedDescription.contains("Invalid email") {
                onError?("Please enter a valid email address")
            } else if error.localizedDescription.contains("Password should contain") {
                onError?(passwordRequirementText)
            } else {
                onError?(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func resendOTP() async {
        print("\n=== Resending OTP ===")
        do {
            print("📧 Attempting to resend OTP to: \(email)")
            try await dataController.resendVerificationEmail(email: email)
            print("✅ OTP resent successfully")
            onOTPSent?()
        } catch {
            print("❌ Error resending OTP: \(error)")
            if error.localizedDescription.contains("rate limit") {
                onError?("Please wait a moment before trying again")
            } else {
                onError?(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func verifyOTP() async {
        print("\n=== Verifying OTP ===")
        print("📧 Email: \(email)")
        print("🔑 OTP Length: \(otp.count)")
        
        do {
            print("🔍 Attempting OTP verification...")
            try await DataControllerGG.shared.verifyEmail(email: email, otp: otp)
            print("✅ OTP verified successfully")
            
            // Store verified status
            UserDefaults.standard.set(true, forKey: "emailVerified_\(email)")
            onSuccess?()
        } catch {
            print("❌ OTP verification failed: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            onError?(error.localizedDescription)
        }
    }
} 
