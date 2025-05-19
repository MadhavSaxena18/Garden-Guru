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
    
    @MainActor
    func checkEmailAndSendOTP() async {
        print("\n=== Starting Email Check and OTP Process ===")
        do {
            // Clean up the email
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            print("📧 Processing email: \(cleanEmail)")
            
            // First validate email format
            guard isValidEmail(cleanEmail) else {
                print("❌ Invalid email format")
                onError?("Please enter a valid email address")
                return
            }
            print("✅ Email format is valid")
            
            // Check if user exists
            print("🔍 Checking if user exists...")
            let (userExists, _) = try await dataController.checkUserExists(email: cleanEmail)
            print("📝 User exists check result: \(userExists)")
            
            if userExists {
                print("⚠️ User already exists, showing login prompt")
                onUserExists?()
                return
            }
            
            // Send verification email
            print("📧 Sending verification email...")
            try await dataController.sendSignupVerificationEmail(email: cleanEmail)
            
            // Store the email and password in UserDefaults
            print("💾 Storing credentials temporarily")
            UserDefaults.standard.set(cleanEmail, forKey: "userEmail")
            UserDefaults.standard.set(password, forKey: "tempPassword")
            
            print("✅ OTP sent successfully")
            onOTPSent?()
            
        } catch {
            print("❌ Error in checkEmailAndSendOTP: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            
            if error.localizedDescription.contains("rate limit") {
                print("⚠️ Rate limit exceeded")
                onError?("Please wait a moment before trying again")
            } else if error.localizedDescription.contains("Invalid email") {
                print("❌ Invalid email format caught in error")
                onError?("Please enter a valid email address")
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
            onSuccess?()
        } catch {
            print("❌ OTP verification failed: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            onError?(error.localizedDescription)
        }
    }
} 
