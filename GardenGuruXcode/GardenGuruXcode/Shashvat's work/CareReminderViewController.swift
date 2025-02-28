import UIKit

class CareReminderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let dataController = DataControllerGG()
    private var reminders: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []
    private var filteredReminders: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []
    
    // MARK: - Properties
    @IBOutlet weak var careReminderCollectionView: UICollectionView!
    @IBOutlet weak var careReminderSegmentedControl: UISegmentedControl!
    
    private let reminderTypes = ["Watering", "Fertilization", "Pruning"]
    
    // Add a no reminders view
    private lazy var noRemindersView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Relax!! No work today"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor(hex: "284329")
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.isHidden = true
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observer for plant deletion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshAfterPlantDeletion),
            name: NSNotification.Name("PlantDeleted"),
            object: nil
        )
        
        // Add no reminders view
        view.addSubview(noRemindersView)
        NSLayoutConstraint.activate([
            noRemindersView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noRemindersView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noRemindersView.topAnchor.constraint(equalTo: careReminderSegmentedControl.bottomAnchor),
            noRemindersView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Get the first user's reminders using the getter function
        if let firstUser = dataController.getUsers().first {
            reminders = dataController.getCareReminders(for: firstUser.userId)
        }
        
        setupCollectionView()
        setupSegmentedControl()
        filterReminders()
    }
    
    @objc private func refreshAfterPlantDeletion() {
        // Get the first user's reminders using the getter function
        if let firstUser = dataController.getUsers().first {
            reminders = dataController.getCareReminders(for: firstUser.userId)
        }
        filterReminders()
        careReminderCollectionView.reloadData()
    }
    
    deinit {
        // Remove observer when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupCollectionView() {
        let nib = UINib(nibName: "CareReminderCollectionViewCell", bundle: nil)
        careReminderCollectionView.register(nib, forCellWithReuseIdentifier: "CareReminderCell")
        
        careReminderCollectionView.register(
            CareReminderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "CareReminderCollectionReusableView"
        )
        
        careReminderCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        careReminderCollectionView.dataSource = self
        careReminderCollectionView.delegate = self
    }
    
    private func setupSegmentedControl() {
        careReminderSegmentedControl.selectedSegmentIndex = 0
    }
    
    // MARK: - Filtering Logic
    private func filterReminders() {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // First verify we have valid reminders
        guard !reminders.isEmpty else {
            print("No reminders available")
            noRemindersView.isHidden = false
            careReminderCollectionView.isHidden = true
            return
        }
        
        switch careReminderSegmentedControl.selectedSegmentIndex {
        case 0: // Today's Reminders
            filteredReminders = reminders.filter { reminder in
                calendar.isDateInToday(reminder.reminder.upcomingReminderForWater) ||
                calendar.isDateInToday(reminder.reminder.upcomingReminderForFertilizers) ||
                calendar.isDateInToday(reminder.reminder.upcomingReminderForRepotted)
            }
        case 1: // Upcoming Reminders
            filteredReminders = reminders.filter { reminder in
                let wateringIsUpcoming = reminder.reminder.upcomingReminderForWater > currentDate && !calendar.isDateInToday(reminder.reminder.upcomingReminderForWater)
                let fertilizingIsUpcoming = reminder.reminder.upcomingReminderForFertilizers > currentDate && !calendar.isDateInToday(reminder.reminder.upcomingReminderForFertilizers)
                let repottingIsUpcoming = reminder.reminder.upcomingReminderForRepotted > currentDate && !calendar.isDateInToday(reminder.reminder.upcomingReminderForRepotted)
                
                return wateringIsUpcoming || fertilizingIsUpcoming || repottingIsUpcoming
            }
        default:
            filteredReminders = []
        }
        
        print("Filtered \(reminders.count) reminders to \(filteredReminders.count) reminders")
        
        // Show/hide no reminders view based on filtered results
        let hasReminders = !filteredReminders.isEmpty
        noRemindersView.isHidden = hasReminders
        careReminderCollectionView.isHidden = !hasReminders
        
        careReminderCollectionView.reloadData()
    }
    
    // MARK: - Segmented Control Action
    @IBAction func didChangeSegmentCareReminder(_ sender: UISegmentedControl) {
        filterReminders()
    }
    
    // MARK: - Edit Button Action
    @IBAction func editButtonCareReminderTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Edit", message: "Choose an action", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Mark All as Completed", style: .default, handler: { _ in
            self.markAllAsCompleted()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func markAllAsCompleted() {
        let currentDate = Date()
        for reminder in filteredReminders {
            dataController.updateCareReminderStatus(
                for: reminder.userPlant.userPlantRelationID,
                reminderType: "Watering",
                isCompleted: true,
                currentDate: currentDate
            )
            dataController.updateCareReminderStatus(
                for: reminder.userPlant.userPlantRelationID,
                reminderType: "Fertilization",
                isCompleted: true,
                currentDate: currentDate
            )
            dataController.updateCareReminderStatus(
                for: reminder.userPlant.userPlantRelationID,
                reminderType: "Pruning",
                isCompleted: true,
                currentDate: currentDate
            )
        }
        
        // Refresh reminders after updating
        if let firstUser = dataController.getUsers().first {
            reminders = dataController.getCareReminders(for: firstUser.userId)
        }
        filterReminders()
    }
    
    // MARK: - Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Return 0 if there are no reminders
        if filteredReminders.isEmpty {
            return 0
        }
        return reminderTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let remindersForType = filteredReminders.filter { reminder in
            switch section {
            case 0: // Watering
                if careReminderSegmentedControl.selectedSegmentIndex == 0 {
                    return calendar.isDateInToday(reminder.reminder.upcomingReminderForWater)
                } else {
                    return reminder.reminder.upcomingReminderForWater > currentDate && !calendar.isDateInToday(reminder.reminder.upcomingReminderForWater)
                }
            case 1: // Fertilizing
                if careReminderSegmentedControl.selectedSegmentIndex == 0 {
                    return calendar.isDateInToday(reminder.reminder.upcomingReminderForFertilizers)
                } else {
                    return reminder.reminder.upcomingReminderForFertilizers > currentDate && !calendar.isDateInToday(reminder.reminder.upcomingReminderForFertilizers)
                }
            case 2: // Pruning
                if careReminderSegmentedControl.selectedSegmentIndex == 0 {
                    return calendar.isDateInToday(reminder.reminder.upcomingReminderForRepotted)
                } else {
                    return reminder.reminder.upcomingReminderForRepotted > currentDate && !calendar.isDateInToday(reminder.reminder.upcomingReminderForRepotted)
                }
            default:
                return false
            }
        }
        print("Section \(section) has \(remindersForType.count) reminders")
        return remindersForType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareReminderCell",
            for: indexPath
        ) as? CareReminderCollectionViewCell else {
            fatalError("Unable to dequeue CareReminderCell")
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        let remindersForType = filteredReminders.filter { reminder in
            switch indexPath.section {
            case 0: // Watering
                if careReminderSegmentedControl.selectedSegmentIndex == 0 {
                    return calendar.isDateInToday(reminder.reminder.upcomingReminderForWater)
                } else {
                    return reminder.reminder.upcomingReminderForWater > currentDate && !calendar.isDateInToday(reminder.reminder.upcomingReminderForWater)
                }
            case 1: // Fertilizing
                if careReminderSegmentedControl.selectedSegmentIndex == 0 {
                    return calendar.isDateInToday(reminder.reminder.upcomingReminderForFertilizers)
                } else {
                    return reminder.reminder.upcomingReminderForFertilizers > currentDate && !calendar.isDateInToday(reminder.reminder.upcomingReminderForFertilizers)
                }
            case 2: // Pruning
                if careReminderSegmentedControl.selectedSegmentIndex == 0 {
                    return calendar.isDateInToday(reminder.reminder.upcomingReminderForRepotted)
                } else {
                    return reminder.reminder.upcomingReminderForRepotted > currentDate && !calendar.isDateInToday(reminder.reminder.upcomingReminderForRepotted)
                }
            default:
                return false
            }
        }
        
        guard indexPath.item < remindersForType.count else {
            return cell
        }
        
        let reminder = remindersForType[indexPath.item]
        
        // Get the appropriate date and completion status
        let dueDate: Date
        let isCompleted: Bool
        switch indexPath.section {
        case 0:
            dueDate = reminder.reminder.upcomingReminderForWater
            isCompleted = reminder.reminder.isWateringCompleted
        case 1:
            dueDate = reminder.reminder.upcomingReminderForFertilizers
            isCompleted = reminder.reminder.isFertilizingCompleted
        case 2:
            dueDate = reminder.reminder.upcomingReminderForRepotted
            isCompleted = reminder.reminder.isRepottingCompleted
        default:
            dueDate = Date()
            isCompleted = false
        }
        
        // Configure cell
        cell.plantNameCareReminderLabel.text = reminder.plant.plantName
        cell.nickNameCareReminderLabel.text = reminder.userPlant.userPlantNickName
        cell.careReminderPlantImageView.image = UIImage(named: reminder.plant.plantImage[0])
        cell.dueDateCareReminder.text = isCompleted ? "Completed" : "Due: \(formatDate(dueDate))"
        cell.dueDateCareReminder.isHidden = false
        cell.checkBoxCareReminderButton.setImage(
            UIImage(systemName: isCompleted ? "checkmark.square.fill" : "square"),
            for: .normal
        )
        
        cell.onCheckboxToggle = { [weak self] in
            guard let self = self else { return }
            let currentDate = Date()
            
            // Toggle the completion status
            let newCompletionStatus = !isCompleted
            
            // Update the status
            self.dataController.updateCareReminderStatus(
                for: reminder.userPlant.userPlantRelationID,
                reminderType: self.reminderTypes[indexPath.section],
                isCompleted: newCompletionStatus,
                currentDate: currentDate
            )
            
            // Update UI immediately
            cell.checkBoxCareReminderButton.setImage(
                UIImage(systemName: newCompletionStatus ? "checkmark.square.fill" : "square"),
                for: .normal
            )
            cell.dueDateCareReminder.text = newCompletionStatus ? "Completed" : "Due: \(self.formatDate(dueDate))"
            
            // Refresh data after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let firstUser = self.dataController.getUsers().first {
                    self.reminders = self.dataController.getCareReminders(for: firstUser.userId)
                    self.filterReminders()
                }
            }
        }
        
        cell.layer.cornerRadius = 18
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "CareReminderCollectionReusableView",
                for: indexPath
            ) as! CareReminderCollectionReusableView
            
            header.headerLabel.text = reminderTypes[indexPath.section]
            header.headerLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            header.headerLabel.textColor = UIColor(hex: "284329")
            
            return header
        }
        return UICollectionReusableView()
    }
    
    // MARK: - Collection View Layout
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            let section = self.generateSectionLayout()
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .absolute(70)
            )
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems = [header]
            return section
        }
    }
    
    private func generateSectionLayout() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.95),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.2)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        group.interItemSpacing = .fixed(50)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        return section
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
//    @IBAction  func unwindToCareReminder( segue: UIStoryboardSegue) {
//
//    }
//
    // Add viewWillAppear to refresh data when view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("CareReminder viewWillAppear - Refreshing data")
        refreshData()
    }
    
    // Add a new method to refresh data
    private func refreshData() {
        if let firstUser = dataController.getUsers().first {
            reminders = dataController.getCareReminders(for: firstUser.userId)
            print("Loaded \(reminders.count) reminders")
            
            // Debug print each reminder
            reminders.forEach { reminder in
                print("Reminder for plant: \(reminder.plant.plantName)")
                print("- Plant ID: \(reminder.userPlant.userplantID)")
                print("- Next water: \(reminder.reminder.upcomingReminderForWater)")
            }
            
            filterReminders()
        }
    }
    
    // Update the unwind segue to refresh data
    @IBAction func unwindToCareReminder(segue: UIStoryboardSegue) {
        print("Unwinding to care reminder - Refreshing data")
        refreshData()
    }
}

