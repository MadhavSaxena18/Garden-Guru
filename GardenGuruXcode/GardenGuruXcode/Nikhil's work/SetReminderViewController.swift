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
        label.text = DiagnosisViewController.plantNameLabel.text
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
        button.addTarget(self, action: #selector(setReminderButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    let dataController: DataControllerGG = DataControllerGG()
    
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
           if navigationController == nil {
               print("Navigation controller is not embedded!")
           }
    }
    
    // Navigation Bar Setup
//    private func setupNavigationBar() {
//        title = "Set Reminder"
//
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Cancel",
//            style: .plain,
//            target: self,
//            action: #selector(didTapCancel)
//        )
//    }
    private func setupNavigationBar() {
        // Set the title
        title = "Set Reminder"
        
                
        // Configure the navigation bar appearance
        //navigationController?.navigationBar.isTranslucent = false
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
        
        // Optionally, you can customize the back button if you want to show a custom icon or text
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )
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
        print("Hello")
//        guard let firstUser = dataController.getUsers().first,
 //             let plantName = plantNameLabel.text,
//              let plant = dataController.getPlantbyName(by: plantName),
//              let nickname = locationLabel.text else {
//            return
//        }
        
        guard let firstUser = dataController.getUsers().first else {
            print("Error: No users found.")
            return
        }

        guard let plantName = DiagnosisViewController.plantNameLabel.text else {
            print("Error: Plant name is empty.")
            return
        }
       
        print("Debug: Retrieved plant name - '\(plantName)'")
        


        guard let plant = dataController.getPlantbyName(by: plantName) else {
            print("Error: No plant found with name \(plantName).")
            return
        }

        guard let nickname = locationLabel.text, !nickname.isEmpty else {
            print("Error: Nickname is empty.")
            return
        }

        // Now you have `firstUser`, `plantName`, `plant`, and `nickname` safely unwrapped

        print("inside setreminder")
        let newUserPlant = UserPlant(
            userId: firstUser.userId,
            userplantID: plant.plantID,
            userPlantNickName: nickname,
            lastWatered: Date(),
            lastFertilized: Date(),
            lastRepotted: Date(),
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        // Add the plant to user's space
        dataController.addUserPlant(newUserPlant)
        
//        print(dataController.userPlant.count)
        
        let alert = UIAlertController(
            title: "Success!",
            message: "\(plantName) added successfully",
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

    func configure(plantName: String, nickname: String) {
        plantNameLabel.text = plantName  // Plant name in bold (already styled in the label setup)
        locationLabel.text = nickname    // Nickname below in gray (already styled in the label setup)
    }
}
