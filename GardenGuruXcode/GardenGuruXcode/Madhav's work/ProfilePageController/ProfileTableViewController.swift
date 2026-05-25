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
    

    private var userData: userInfo?
    private let dataController = DataControllerGG.shared
    private let locationManager = LocationManager()
    private let weatherService = WeatherService()
    private var isEditingProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Always reload user data when view appears (handles user switching)
        loadUserData()
        
        tableView.reloadData()
        
        // Load saved profile image if exists
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: imageData) {
            profileImageView.image = savedImage
        }
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
    
    // MARK: - Logout
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            // Clear all user data
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "userEmail")
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "displayName")
            UserDefaults.standard.removeObject(forKey: "profileImage")
            
            // Clear UI
            self?.userNameLabel.text = "User"
            self?.emailLabel.text = ""
            self?.userLocationLabel.text = ""
            self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let loginVC = LoginViewController()
                let window = sceneDelegate.window
                window?.rootViewController = loginVC
                window?.makeKeyAndVisible()
            }
        
        })
        
        present(alert, animated: true)
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

    

