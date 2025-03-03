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
    private func setupNavigationBar() {
        // Set the title
        title = "Set Reminder"
        
        // Configure the navigation bar appearance
        if let navigationBar = navigationController?.navigationBar {
            // Set background color
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            
            // Configure title text attributes with default color
            appearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
            ]
            
            // Apply appearance to all navigation bar states
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            
            // Use default tint color
            navigationBar.tintColor = nil
        }
        
        // Add cancel button
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )
        navigationItem.leftBarButtonItem = cancelButton
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
        // Dismiss and switch to MySpace tab
        dismiss(animated: true) {
            if let tabBarController = self.view.window?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 0 // Switch to MySpace tab
            }
        }
    }

   
    @objc func setReminderButtonTapped() {
        let alert = UIAlertController(
            title: "Success!",
            message: "Reminders set successfully",
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
