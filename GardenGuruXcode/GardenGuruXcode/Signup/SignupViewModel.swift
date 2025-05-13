import Foundation
import SwiftUI

@MainActor
class SignupViewModel: ObservableObject {
    @Published var userName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var location = ""
    @Published var reminderAllowed = true
    
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    
    private let dataController = DataControllerGG.shared
    
    var isFormValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmail(email) &&
        password.count >= 6 &&
        password == confirmPassword &&
        !location.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func signUp() async {
        do {
            // First, create the auth user in Supabase
            let session = try await dataController.supabase.auth.signUp(
                email: email,
                password: password
            )
            
            guard session.user != nil else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])
            }
            
            // Then create the user in UserTable
            let user = try await dataController.createUser(
                email: email,
                userName: userName,
                location: location
            )
            
            // Store the email in UserDefaults
            UserDefaults.standard.set(email, forKey: "userEmail")
            
            // Show success message
            showSuccess = true
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
} 