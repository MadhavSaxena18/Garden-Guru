//
//  SetReminderViewController.swift
//  GardenGuruXcode
//
//  Created by Nikhil Gupta on 17/01/25.
//

import UIKit
import UserNotifications

class SetReminderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // TableView
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    // Labels
    private let plantNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     let locationLabel: UILabel = {
        let label = UILabel()
        // label.text = "Near Sofa"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Set Reminder Button
    private let setReminderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set Reminder", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let dataController: DataControllerGG = DataControllerGG.shared
    
    // Data for the rows
    private let reminders = [
        ("Watering", "Every week", "water", false),
        ("Fertiliser", "Once in a month", "fertilizer", false),
        ("Repotting", "Every year", "repot", false),
        ("Set Time", "Default time: 5:00 pm", "clock1", true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#EBF4EB") // Background for overall view
        setupNavigationBar()
        setupViews()
        
        // Add this line to ensure the button action is connected
        setReminderButton.addTarget(self, action: #selector(setReminderButtonTapped), for: .touchUpInside)
        
        if navigationController == nil {
            print("Navigation controller is not embedded!")
        }
    }
    
    // Navigation Bar Setup
    private func setupNavigationBar() {
        // Set the title
        title = "Set Reminder"
        
        // Configure the navigation bar appearance
        navigationController?.navigationBar.barTintColor = UIColor.systemGreen
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        // Add a custom "Cancel" button to the right side
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    // Setup Views
    private func setupViews() {
        // Add subviews
        view.addSubview(plantNameLabel)
        view.addSubview(locationLabel)
        view.addSubview(tableView)
        view.addSubview(setReminderButton)
        
        // TableView Setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReminderCell.self, forCellReuseIdentifier: "ReminderCell")
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            // Plant Name Label
            plantNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            plantNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Location Label
            locationLabel.topAnchor.constraint(equalTo: plantNameLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: plantNameLabel.leadingAnchor),
            
            // TableView
            tableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: setReminderButton.topAnchor, constant: -16),
            
            // SetReminder Button
            setReminderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            setReminderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            setReminderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            setReminderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Cancel Button
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func setReminderButtonTapped() {
        print("\n=== Set Reminder Button Tapped ===")
        print("Current plant name: '\(plantNameLabel.text ?? "nil")'")
        print("Current nickname: '\(locationLabel.text ?? "nil")'")
        
        // Add this to test if the button is actually responding
        print("Button tapped!")
        
        guard let plantName = plantNameLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let nickname = locationLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !plantName.isEmpty,
              !nickname.isEmpty else {
            print("❌ Invalid plant name or nickname")
            print("Plant name: '\(plantNameLabel.text ?? "nil")'")
            print("Nickname: '\(locationLabel.text ?? "nil")'")
            return
        }
        
        print("\n=== Adding New Plant ===")
        print("Looking for plant: '\(plantName)'")
        
        guard let existingPlant = dataController.getPlantbyName(by: plantName) else {
            print("❌ Plant not found in database")
            print("Available plants:")
            dataController.getPlants().forEach { plant in
                print("- \(plant.plantName)")
            }
            
            // Show error alert to user
            let alert = UIAlertController(
                title: "Error",
                message: "Could not find plant '\(plantName)' in database",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        print("✅ Found existing plant:")
        print("- Name: \(existingPlant.plantName)")
        print("- ID: \(existingPlant.plantID)")
        
        // Create new UserPlant
        let newUserPlant = UserPlant(
            userId: dataController.getUsers().first?.userId ?? UUID(),
            userplantID: existingPlant.plantID,
            userPlantNickName: nickname,
            lastWatered: Date(),
            lastFertilized: Date(),
            lastRepotted: Date(),
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        // Get switch states and create reminder
        var isWateringEnabled = false
        var isFertilizingEnabled = false
        var isRepottingEnabled = false
        
        for index in 0..<reminders.count {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ReminderCell {
                switch index {
                case 0: // Watering
                    isWateringEnabled = cell.isReminderEnabled
                case 1: // Fertilizing
                    isFertilizingEnabled = cell.isReminderEnabled
                case 2: // Repotting
                    isRepottingEnabled = cell.isReminderEnabled
                default:
                    break
                }
            }
        }
        
        // Calculate reminder dates based on enabled switches
        let nextWaterDate = isWateringEnabled ? 
            Calendar.current.date(byAdding: .day, value: existingPlant.waterFrequency, to: Date()) : nil
        let nextFertilizerDate = isFertilizingEnabled ? 
            Calendar.current.date(byAdding: .day, value: existingPlant.fertilizerFrequency, to: Date()) : nil
        let nextRepottingDate = isRepottingEnabled ? 
            Calendar.current.date(byAdding: .day, value: existingPlant.repottingFrequency, to: Date()) : nil
        
        // Create reminder with only enabled reminders
        let reminder = CareReminder_(
            upcomingReminderForWater: nextWaterDate ?? Date.distantFuture,
            upcomingReminderForFertilizers: nextFertilizerDate ?? Date.distantFuture,
            upcomingReminderForRepotted: nextRepottingDate ?? Date.distantFuture,
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        // Add to DataController with the reminder
        dataController.addUserPlant(newUserPlant, with: reminder)
        print("✅ Added plant to DataController")
        
        // Post notification with reminder settings
        NotificationCenter.default.post(
            name: NSNotification.Name("NewPlantAdded"),
            object: nil,
            userInfo: [
                "userPlant": newUserPlant,
                "plant": existingPlant,
                "reminder": reminder,
                "enabledReminders": [
                    "watering": isWateringEnabled,
                    "fertilizing": isFertilizingEnabled,
                    "repotting": isRepottingEnabled
                ]
            ]
        )
        
        // Show success alert and dismiss
        let alert = UIAlertController(
            title: "Success!",
            message: "Plant '\(existingPlant.plantName)' added with nickname '\(nickname)'",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                if let tabBarController = self?.view.window?.rootViewController as? UITabBarController {
                    tabBarController.selectedIndex = 0 // Switch to MySpace tab
                }
            }
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        let reminder = reminders[indexPath.row]
        cell.configure(title: reminder.0, subtitle: reminder.1, iconName: reminder.2, isTimePicker: reminder.3)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 // Card height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Add public method to set plant name
    func configure(plantName: String?, nickname: String?) {
        print("\n=== Configuring SetReminderViewController ===")
        if let plantName = plantName {
            self.plantNameLabel.text = plantName
            print("Setting plant name to: '\(plantName)'")
        } else {
            print("❌ No plant name provided to SetReminderViewController")
        }
        if let nickname = nickname {
            self.locationLabel.text = nickname
            print("Setting nickname to: '\(nickname)'")
        } else {
            print("❌ No nickname provided to SetReminderViewController")
        }
    }
}
