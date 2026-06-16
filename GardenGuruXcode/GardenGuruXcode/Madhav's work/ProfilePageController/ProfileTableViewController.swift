//
//  ProfileTableViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 13/01/25.
//

import UIKit
import PhotosUI

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!  // Add outlet for logout button
    

    private var userData: userInfo?
    private let dataController = DataControllerGG.shared
    private let locationManager = LocationManager()
    private let weatherService = WeatherService()
    private var isEditingProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadUserData()
        
        // Update UI for login state first before adding delete button
        updateUIForLoginState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Always reload user data when view appears (handles user switching)
        loadUserData()
        
        // Update UI based on login state
        updateUIForLoginState()
        
        tableView.reloadData()
        
        // Load saved profile image if exists
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: imageData) {
            profileImageView.image = savedImage
        }
    }
    
    private func updateUIForLoginState() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        print("DEBUG: updateUIForLoginState - isLoggedIn: \(isLoggedIn)")
        
        if isLoggedIn {
            // User is logged in - show delete button and "Sign Out" text
            if tableView.tableFooterView == nil {
                addDeleteAccountButton()
            }
            
            // Update logout button for logged-in user
            if let button = logoutButton {
                button.setTitle("Sign Out", for: .normal)
                button.setTitleColor(.systemRed, for: .normal)
                button.tintColor = .systemRed
                print("DEBUG: Set button to 'Sign Out' (red)")
            } else {
                print("DEBUG: logoutButton outlet is nil!")
            }
        } else {
            // Guest user - hide delete button and show "Sign In" text
            tableView.tableFooterView = nil
            
            // Update button for guest user
            if let button = logoutButton {
                button.setTitle("Sign In", for: .normal)
                button.setTitleColor(.systemBlue, for: .normal)
                button.tintColor = .systemBlue
                print("DEBUG: Set button to 'Sign In' (blue)")
            } else {
                print("DEBUG: logoutButton outlet is nil!")
            }
            
            // Update profile info for guest
            userNameLabel?.text = "Guest"
            emailLabel?.text = "Sign in to save your plants"
            emailLabel?.textColor = .systemGray
        }
        
        // Force layout update
        logoutButton?.setNeedsLayout()
        logoutButton?.layoutIfNeeded()
        
        // Reload table to update UI
        tableView.reloadData()
    }
    
    private func setupUI() {
        // Configure profile image view
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Configure edit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
    }
    
    private func loadUserData() {
        print("[DEBUG] loadUserData called")
        
        // Clear previous data first
        userNameLabel.text = "Loading..."
        emailLabel.text = ""
        userLocationLabel.text = ""
        
        // Fetch fresh user data from database
        if let user = DataControllerGG.shared.getUserSync() {
            userData = user
            // Show userName, or default to "User" if empty
            userNameLabel.text = user.userName.isEmpty ? "User" : user.userName
            print("[DEBUG] Loaded user: \(user.userName)")
        } else {
            print("[DEBUG] No user data found")
            userNameLabel.text = "User"
        }
        
        // Handle email display - check for Apple private relay emails
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            print("[DEBUG] User email: \(userEmail)")
            if isApplePrivateRelayEmail(userEmail) {
                // Show friendly placeholder for Apple private relay emails
                emailLabel.text = "Apple ID (Private)"
                emailLabel.textColor = .systemGray
            } else {
                emailLabel.text = userEmail
                emailLabel.textColor = .label
            }
        }

        func fetchLocationAndWeatherWithRetry(retryCount: Int = 0) {
            Task {
                print("[DEBUG] Entered Task in loadUserData")
                do {
                    let location = try await locationManager.requestLocation()
                    print("Fetched location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    let weather = try await weatherService.fetchWeather(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                    print("Fetched weather name: \(String(describing: weather.name))")
                    await MainActor.run {
                        userLocationLabel.text = weather.name
                    }
                } catch {
                    print("[DEBUG] Error fetching location/weather: \(error)")
                    if let nsError = error as NSError?, nsError.domain == "Location request already in progress", retryCount < 3 {
                        print("[DEBUG] Retrying location request in 0.5s...")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            fetchLocationAndWeatherWithRetry(retryCount: retryCount + 1)
                        }
                    } else if let user = userData {
                        print("Fallback to user location: \(String(describing: user.location))")
                        await MainActor.run {
                            userLocationLabel.text = user.location ?? "Unknown"
                        }
                    }
                }
            }
        }

        fetchLocationAndWeatherWithRetry()
    }
    
    // Helper function to detect Apple private relay emails
    private func isApplePrivateRelayEmail(_ email: String) -> Bool {
        return email.contains("@privaterelay.appleid.com") || 
               email.contains("@icloud.com") && email.count > 30 // Long random iCloud emails
    }
    
    @objc private func editButtonTapped() {
        // Show alert to edit name
        let alert = UIAlertController(
            title: "Edit Name",
            message: "Enter your display name",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = self.userNameLabel.text == "User" ? "" : self.userNameLabel.text
            textField.placeholder = "Your name"
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty else {
                return
            }
            
            // Update UI immediately
            self.userNameLabel.text = newName
            
            // Update in database
            self.updateUserName(newName)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func profileImageTapped() {
        let alertController = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - Image Picker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            profileImageView.image = image
            uploadProfileImage(image)
        }
    }
    
    // MARK: - PHPicker Delegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
            DispatchQueue.main.async {
                if let image = reading as? UIImage {
                    self?.profileImageView.image = image
                    self?.uploadProfileImage(image)
                }
            }
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
    }
    
    private func updateUserName(_ newUsername: String) {
        // Update locally
        userData?.userName = newUsername
        UserDefaults.standard.set(newUsername, forKey: "userName")
        
        // Update in Supabase
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            Task {
                do {
                    // Update the userName in UserTable
                    try await dataController.updateUsername(email: email, newUsername: newUsername)
                    print("✅ Successfully updated userName in Supabase")
                    
                    // Refresh local user data
                    if let updatedUser = try await dataController.initializeUser(email: email) {
                        userData = updatedUser
                        print("✅ Successfully refreshed user data: \(updatedUser.userName)")
                    }
                } catch {
                    print("❌ Error updating userName in Supabase: \(error)")
                    // Show error alert to user
                    DispatchQueue.main.async { [weak self] in
                        let alert = UIAlertController(
                            title: "Update Failed",
                            message: "Failed to update name. Please try again.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Logout / Sign In
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if isLoggedIn {
            // User is logged in - show logout confirmation
            let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
                self?.performLogout()
            })
            
            present(alert, animated: true)
        } else {
            // Guest user - redirect to login
            redirectToLogin()
        }
    }
    
    private func performLogout() {
        // Clear all user data
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "displayName")
        UserDefaults.standard.removeObject(forKey: "profileImage")
        
        // Clear UI
        userNameLabel.text = "Guest"
        emailLabel.text = "Sign in to save your plants"
        userLocationLabel.text = ""
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        
        // Update UI for guest mode
        updateUIForLoginState()
        
        // Show success message
        let alert = UIAlertController(title: "Signed Out", message: "You have been signed out successfully. You can continue browsing as a guest.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func redirectToLogin() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showLoginScreen()
        }
    }
    
    // MARK: - Delete Account
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        // First confirmation alert - following Apple HIG
        let confirmAlert = UIAlertController(
            title: "Delete Account?",
            message: "This will permanently delete your account and all associated data, including:\n\n• Saved plants\n• Care reminders\n• Community posts\n• Profile and settings\n\nThis action cannot be undone.",
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.showFinalDeleteConfirmation()
        })
        
        present(confirmAlert, animated: true)
    }
    
    private func showFinalDeleteConfirmation() {
        // Second confirmation with type-to-confirm
        let finalAlert = UIAlertController(
            title: "Confirm Deletion",
            message: "To confirm, type DELETE in the field below.",
            preferredStyle: .alert
        )
        
        finalAlert.addTextField { textField in
            textField.placeholder = "Type DELETE"
            textField.autocapitalizationType = .allCharacters
            textField.autocorrectionType = .no
        }
        
        finalAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        finalAlert.addAction(UIAlertAction(title: "Delete Account", style: .destructive) { [weak self] _ in
            guard let self = self,
                  let textField = finalAlert.textFields?.first,
                  let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  text.uppercased() == "DELETE" else {
                // Show error if text doesn't match
                self?.showAlert(title: "Verification Failed", message: "Please type DELETE to confirm account deletion.")
                return
            }
            
            // Proceed with deletion
            self.performAccountDeletion()
        })
        
        present(finalAlert, animated: true)
    }
    
    private func performAccountDeletion() {
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {
            showAlert(title: "Error", message: "Unable to verify account. Please try logging out and back in.")
            return
        }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(
            title: "Deleting Account",
            message: "\n\nPlease wait while we delete your account...",
            preferredStyle: .alert
        )
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        loadingAlert.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: loadingAlert.view.topAnchor, constant: 80)
        ])
        
        present(loadingAlert, animated: true)
        
        // Perform deletion
        Task {
            do {
                try await dataController.deleteUserAccount(userEmail: userEmail)
                
                // Dismiss loading alert
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        // Show success message
                        let successAlert = UIAlertController(
                            title: "Account Deleted",
                            message: "Your account has been permanently deleted.",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            // Return to login screen
                            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                sceneDelegate.showLoginScreen()
                            }
                        })
                        self.present(successAlert, animated: true)
                    }
                }
            } catch {
                print("❌ Error deleting account: \(error)")
                
                // Dismiss loading and show error
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert(
                            title: "Unable to Delete Account",
                            message: "An error occurred while deleting your account. Please try again or contact support if the problem persists."
                        )
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Add Delete Account Button
    
    private func addDeleteAccountButton() {
        // Create footer view with delete button - following Apple HIG
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        footerView.backgroundColor = .clear
        
        // Create delete button with professional styling
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete Account", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 17)
        deleteButton.backgroundColor = .secondarySystemGroupedBackground
        deleteButton.layer.cornerRadius = 10
        deleteButton.addTarget(self, action: #selector(deleteAccountButtonTapped(_:)), for: .touchUpInside)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            deleteButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24),
            deleteButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        tableView.tableFooterView = footerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped Section: \(indexPath.section), Row: \(indexPath.row)")

        if indexPath.section == 1 && indexPath.row == 5 {
            let savedVC = SavedItemsViewController(style: .plain)
            navigationController?.pushViewController(savedVC, animated: true)
        }
    }
}

// MARK: - UITextField Delegate

extension ProfileTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

    

