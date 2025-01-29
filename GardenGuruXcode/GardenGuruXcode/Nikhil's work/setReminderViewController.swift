
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
        label.text = "Plant Name"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Near Sofa"
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
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.systemGreen
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
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
            
            // Set Reminder Button
            setReminderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            setReminderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            setReminderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            setReminderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Cancel Button Action
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // Set Reminder Button Action
//    @objc private func setReminderButtonTapped() {
//        print("Set Reminder button tapped!")
////        performSegue(withIdentifier: "ShowCareReminder", sender: self)
//        let reminderController = CareReminderViewController()
//       
//        let navigationController = UINavigationController(rootViewController: reminderController)
//        navigationController.pushViewController(reminderController, animated: true)
//        self.show(reminderController, sender: self)
//        
//       
//        print("set reminder")
//        
//        
//    }
   

    @objc  func setReminderButtonTapped() {
        print("Set Reminder button tapped!")
        let storyboard = UIStoryboard(name: "mySpaceTab", bundle: nil)
        let careVC = storyboard.instantiateViewController(withIdentifier: "CareReminderViewController")
        navigationController?.pushViewController(careVC, animated: true)
     //   performSegue(withIdentifier: "unwindToCareReminder", sender: Any?.self)
        
        
        
        
//        // Create the CareReminderViewController instance
//        let reminderController = DiagnosisViewController()
//                print("ppppp")
//                // Navigate to the CareReminderViewController
//                if let navigationController = self.navigationController {
//                    print(",,,,")
//                    // Use the existing navigation controller to push the view controller
//                    navigationController.pushViewController(reminderController, animated: true)
//                } else {
//                    print("pppp,,")
//        
//                    // If there's no navigation controller, present it modally
//                    self.present(reminderController, animated: true, completion: nil)
//                 // self.navigationController?.pushViewController(reminderController, animated: true)
//                    // show(reminderController, sender: self)
//                }
        //
        //        print("Set reminder")
        //    }
        
        //        let storyboard = UIStoryboard(name: "setRemainder" , bundle: nil)
        //
        //        let VC = storyboard.instantiateViewController(withIdentifier: "CareReminderViewController") as! CareReminderViewController
        //
        //            //  self.present(VC, animated: true, completion: nil)
        //            navigationController?.pushViewController(VC, animated: true)
        //        }
        //        tabBarController?.selectedIndex = 2
        //            print("pppppp")
        //            // Access the navigation controller of the target tab
        //        if let targetNavController = tabBarController!.viewControllers?[2] as? UINavigationController {
        //            print("hhhhhh")
        //                // Create the view controller you want to push
        //            let targetViewController = CareReminderViewController()
        //            print(".......")
        ////            targetNavController.pushViewController(targetViewController, animated: true)
        //            navigationController?.pushViewController(targetViewController, animated: true)
        //            }
        
        
        //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //            if segue.identifier == "ShowCareReminder" {
        //                // You can pass data here if needed:
        //                let destinationVC = segue.destination as! CareReminderViewController
        //                destinationVC.title = "Care Reminders"
        //            }
        //        }
        //
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
}
//
//
//  SetReminderViewController.swift
//  GardenGuruXcode
//
//  Created by Nikhil Gupta on 17/01/25.
//

//import UIKit
//import UserNotifications
//
//class SetReminderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    // TableView
//    private let tableView = UITableView(frame: .zero, style: .grouped)
//    
//    // Labels
//    private let plantNameLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Plant Name"
//        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let locationLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Near Sofa"
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .gray
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    // Set Reminder Button
//    private let setReminderButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Set Reminder", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        button.backgroundColor = UIColor.systemGreen
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(setReminderButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    // Data for the rows
//    private let reminders = [
//        ("Watering", "Every week", "water", false),
//        ("Fertilizer", "Once a month", "fertilizer", false),
//        ("Repotting", "Every year", "repot", false),
//        ("Set Time", "Default time: 5:00 pm", "clock1", true)
//    ]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor(hex: "#EBF4EB")
//        setupNavigationBar()
//        setupViews()
//    }
//    
//    // MARK: - Navigation Bar Setup
//    private func setupNavigationBar() {
//        title = "Set Reminder"
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = UIColor.systemGreen
//        navigationController?.navigationBar.tintColor = .white
//        navigationController?.navigationBar.titleTextAttributes = [
//            NSAttributedString.Key.foregroundColor: UIColor.white
//        ]
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Cancel",
//            style: .plain,
//            target: self,
//            action: #selector(didTapCancel)
//        )
//    }
//    
//    // MARK: - Setup Views
//    private func setupViews() {
//        view.addSubview(plantNameLabel)
//        view.addSubview(locationLabel)
//        view.addSubview(tableView)
//        view.addSubview(setReminderButton)
//        
//        // TableView Setup
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.separatorStyle = .none
//        tableView.backgroundColor = .clear
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.register(ReminderCell.self, forCellReuseIdentifier: "ReminderCell")
//        
//        // Layout Constraints
//        NSLayoutConstraint.activate([
//            plantNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
//            plantNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            
//            locationLabel.topAnchor.constraint(equalTo: plantNameLabel.bottomAnchor, constant: 4),
//            locationLabel.leadingAnchor.constraint(equalTo: plantNameLabel.leadingAnchor),
//            
//            tableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 30),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: setReminderButton.topAnchor, constant: -16),
//            
//            setReminderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            setReminderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            setReminderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
//            setReminderButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//    
//    // MARK: - Button Actions
//    @objc private func didTapCancel() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    @objc private func setReminderButtonTapped() {
//        print("Set Reminder button tapped!")
//        
//        // Schedule the notification
//        let content = UNMutableNotificationContent()
//        content.title = "Care Reminder"
//        content.body = "It's time to take care of your plants!"
//        content.sound = .default
//        
//        // Trigger for 5 seconds from now
//        let triggerDate = Calendar.current.date(byAdding: .second, value: 5, to: Date())!
//        let trigger = UNCalendarNotificationTrigger(
//            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate),
//            repeats: false
//        )
//        
//        // Notification request
//        let request = UNNotificationRequest(identifier: "CareReminderNotification", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error.localizedDescription)")
//            } else {
//                print("Reminder set for \(triggerDate)")
//            }
//        }
//        
//        // Navigate to CareReminderViewController
//        let reminderController = CareReminderViewController()
//        navigationController?.pushViewController(reminderController, animated: true)
//    }
//    
//    // MARK: - UITableViewDataSource
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return reminders.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
//        let reminder = reminders[indexPath.row]
//        cell.configure(title: reminder.0, subtitle: reminder.1, iconName: reminder.2, isTimePicker: reminder.3)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 120
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
