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
        profileImageView.isUserInteractionEnabled = false
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Configure edit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
    }
    
    private func loadUserData() {
        // Get user data and update username
        if let user = DataControllerGG.shared.getUserSync() {
            userData = user
            userNameLabel.text = user.userName
        }
        
        // Update email from UserDefaults
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            emailLabel.text = userEmail
        }
        
        // Get location and update location label
        Task {
            do {
                let location = try await locationManager.requestLocation()
                let weather = try await weatherService.fetchWeather(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                // Update UI on main thread
                await MainActor.run {
                    userLocationLabel.text = weather.name
                }
            } catch {
                print("Error fetching location/weather: \(error)")
                // Fallback to stored location from DataController
                if let user = userData {
                    userLocationLabel.text = user.location
                }
            }
        }
    }
    
    @objc private func editButtonTapped() {
        isEditingProfile.toggle()
        
        if isEditingProfile {
            navigationItem.rightBarButtonItem?.title = "Done"
            profileImageView.isUserInteractionEnabled = true
            
            // Make username editable
            let textField = UITextField(frame: userNameLabel.frame)
            textField.text = userNameLabel.text
            textField.tag = 100
            textField.borderStyle = .roundedRect
            textField.delegate = self
            userNameLabel.superview?.addSubview(textField)
            userNameLabel.isHidden = true
        } else {
            navigationItem.rightBarButtonItem?.title = "Edit"
            profileImageView.isUserInteractionEnabled = false
            
            // Save changes
            if let textField = view.viewWithTag(100) as? UITextField {
                userNameLabel.text = textField.text
                textField.removeFromSuperview()
                userNameLabel.isHidden = false
                
                // Update user data
                if let newUsername = textField.text {
                    updateUserName(newUsername)
                }
            }
        }
    }
    
    @objc private func profileImageTapped() {
        guard isEditingProfile else { return }
        
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
                    // Update the username in UserTable
                    try await dataController.updateUsername(email: email, newUsername: newUsername)
                    print("✅ Successfully updated username in Supabase")
                    
                    // Refresh local user data
                    if let updatedUser = try await dataController.initializeUser(email: email) {
                        userData = updatedUser
                        print("✅ Successfully refreshed user data: \(updatedUser.userName)")
                    }
                } catch {
                    print("❌ Error updating username in Supabase: \(error)")
                    // Show error alert to user
                    DispatchQueue.main.async { [weak self] in
                        let alert = UIAlertController(
                            title: "Update Failed",
                            message: "Failed to update username. Please try again.",
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
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "userEmail")
            
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

    

