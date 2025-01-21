////
////  SetReminderViewController.swift
////  GardenGuruXcode
////
////  Created by Nikhil Gupta on 17/01/25.
////
//
//import UIKit
//
//class SetReminderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    // TableView
//    private let tableView = UITableView(frame: .zero, style: .grouped)
//    
//    // Data for the rows
//    private let reminders = [
//        ("Watering", "Every week", "drop.fill", false),
//        ("Fertiliser", "Once in a month", "leaf", false),
//        ("Repotting", "Every year", "arrow.triangle.2.circlepath", false),
//        ("Set Time", "Default time: 5:00 pm", "clock", true)
//    ]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = UIColor(hex: "#E8F3E9") // Background for overall view
//        setupNavigationBar()
//        setupTableView()
//    }
//    
//    // Navigation Bar Setup
//    private func setupNavigationBar() {
//        title = "Set Reminder"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Cancel",
//            style: .plain,
//            target: self,
//            action: #selector(didTapCancel)
//        )
//    }
//    
//    // TableView Setup
//    private func setupTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.separatorStyle = .none
//        tableView.backgroundColor = UIColor.clear
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.register(ReminderCardCell.self, forCellReuseIdentifier: "ReminderCardCell")
//        
//        view.addSubview(tableView)
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//    
//    // Cancel Button Action
//    @objc private func didTapCancel() {
//        dismiss(animated: true, completion: nil)
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
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCardCell", for: indexPath) as! ReminderCardCell
//        let reminder = reminders[indexPath.row]
//        cell.configure(title: reminder.0, subtitle: reminder.1, iconName: reminder.2, isTimePicker: reminder.3)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 120 // Card height
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
//
//// MARK: - Custom UITableViewCell
//class ReminderCardCell: UITableViewCell {
//    
//    private let cardView = UIView()
//    private let iconImageView = UIImageView()
//    private let titleLabel = UILabel()
//    private let subtitleLabel = UILabel()
//    private let toggleSwitch = UISwitch()
//    private let timePicker = UIDatePicker()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupCell() {
//        backgroundColor = .clear // Ensure the background is clear
//        selectionStyle = .none
//        
//        // Card View
//        cardView.backgroundColor = .white
//        cardView.layer.cornerRadius = 12
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.1
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        cardView.layer.shadowRadius = 4
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Icon
//        iconImageView.contentMode = .scaleAspectFit
//        iconImageView.tintColor = .systemGreen
//        iconImageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Title Label
//        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Subtitle Label
//        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
//        subtitleLabel.textColor = .gray
//        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Toggle Switch
//        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Time Picker
//        timePicker.datePickerMode = .time
//        timePicker.translatesAutoresizingMaskIntoConstraints = false
//        timePicker.isHidden = true // Default hidden
//        
//        // Add Subviews
//        contentView.addSubview(cardView)
//        cardView.addSubview(iconImageView)
//        cardView.addSubview(titleLabel)
//        cardView.addSubview(subtitleLabel)
//        cardView.addSubview(toggleSwitch)
//        cardView.addSubview(timePicker)
//        
//        // Layout Constraints
//        NSLayoutConstraint.activate([
//            // Card View Constraints
//            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            
//            // Icon Constraints
//            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
//            iconImageView.widthAnchor.constraint(equalToConstant: 40),
//            iconImageView.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Title Label Constraints
//            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
//            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
//            
//            // Subtitle Label Constraints
//            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            
//            // Toggle Switch Constraints
//            toggleSwitch.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            toggleSwitch.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
//            
//            // Time Picker Constraints
//            timePicker.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            timePicker.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
//        ])
//    }
//    
//    func configure(title: String, subtitle: String, iconName: String, isTimePicker: Bool) {
//        titleLabel.text = title
//        subtitleLabel.text = subtitle
//        iconImageView.image = UIImage(systemName: iconName)
//        
//        // Toggle visibility of switch and time picker
//        toggleSwitch.isHidden = isTimePicker
//        timePicker.isHidden = !isTimePicker
//    }
//}
//
import UIKit

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
        button.addTarget(SetReminderViewController.self, action: #selector(didTapSetReminder), for: .touchUpInside)
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
    }
    
    // Navigation Bar Setup
    private func setupNavigationBar() {
        title = "Set Reminder"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cancel",
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
            plantNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            plantNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Location Label
            locationLabel.topAnchor.constraint(equalTo: plantNameLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: plantNameLabel.leadingAnchor),
            
            // TableView
            tableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
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
    @objc private func didTapSetReminder() {
        print("Set Reminder button tapped!")
      
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

