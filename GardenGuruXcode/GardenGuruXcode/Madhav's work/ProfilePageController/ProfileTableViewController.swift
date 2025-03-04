//
//  ProfileTableViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 13/01/25.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    private var userData: userInfo?
    private let dataController = DataControllerGG()
    private let locationManager = LocationManager()
    private let weatherService = WeatherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get user data and update username
        if let user = dataController.getUser() {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // Add this method to your ProfileTableViewController
    // Remove the duplicate empty action
    // @IBAction func logOutButtonTapped(_ sender: UIButton) {
    // }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        // Show confirmation alert
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            // Clear login state
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "userEmail")
            
            // Present login screen
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let loginVC = LoginViewController()
                let window = sceneDelegate.window
                window?.rootViewController = loginVC
                window?.makeKeyAndVisible()
            }
        })
        
        present(alert, animated: true)
    }
}

    

