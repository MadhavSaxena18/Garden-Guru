import UIKit

class CareReminderViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var careReminderCollectionView: UICollectionView!
    @IBOutlet weak var careReminderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var editButton: UIBarButtonItem?
    
    private let dataController = DataControllerGG.shared
    private let reminderTypes = ["Watering", "Fertilization", "Repotting"]
    
    private var reminders: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []
    private var todayReminders: [[(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)]] = [[],[],[]]
    private var upcomingReminders: [[(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)]] = [[],[],[]]
    
    private lazy var noRemindersView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Relax!! No work today"  // This will be updated dynamically
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor(hex: "284329")
        label.tag = 100  // Add tag to reference the label later
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.isHidden = true
        return view
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add edit button programmatically if it doesn't exist
        let editButton = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonCareReminderTapped(_:))
        )
        navigationItem.rightBarButtonItem = editButton
        self.editButton = editButton
        
        setupUI()
        setupCollectionView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshAfterPlantDeletion(Notification(name: NSNotification.Name("PlantDeleted")))
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        navigationController?.navigationBar.tintColor = UIColor(hex: "004E05")
        
        view.addSubview(noRemindersView)
        // Set initial text based on selected segment
        if let label = noRemindersView.viewWithTag(100) as? UILabel {
            label.text = careReminderSegmentedControl.selectedSegmentIndex == 0 ? "Relax!! No work today" : "No upcoming reminders"
        }
        
        NSLayoutConstraint.activate([
            noRemindersView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noRemindersView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noRemindersView.topAnchor.constraint(equalTo: careReminderSegmentedControl.bottomAnchor),
            noRemindersView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshAfterPlantDeletion(_:)),
            name: NSNotification.Name("PlantDeleted"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshAfterStatusUpdate(_:)),
            name: NSNotification.Name("ReminderStatusUpdated"),
            object: nil
        )
        
        updateEditButtonVisibility()
    }
    
    private func setupCollectionView() {
        careReminderCollectionView.register(
            UINib(nibName: "CareReminderCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "CareReminderCell"
        )
        
        careReminderCollectionView.register(
            CareReminderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "CareReminderCollectionReusableView"
        )
        
        careReminderCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
        careReminderCollectionView.dataSource = self
        careReminderCollectionView.delegate = self
    }
    
    // MARK: - Data Loading
    private func loadData() {
        print("\n=== Loading Care Reminder Data ===")
        
        // Clear existing data first
        reminders = []
        todayReminders = [[],[],[]]
        upcomingReminders = [[],[],[]]
        
        guard let firstUser = dataController.getUserSync() else {
            print("❌ No user found")
            return
        }
        print("✅ Found user: \(firstUser.userEmail)")
        
        // Load reminders only once using the sync wrapper
        reminders = dataController.getUserPlantsWithDetailsSync(for: firstUser.userEmail!)
        print("📱 Loaded \(reminders.count) reminders")
        
        sortReminders()
        careReminderCollectionView.reloadData()
    }
    
    private func sortReminders() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        print("\n=== Sorting Reminders ===")
        print("Current Date: \(currentDate)")
        print("Total reminders to sort: \(reminders.count)")
        
        // Clear existing arrays
        todayReminders = [[],[],[]]
        upcomingReminders = [[],[],[]]
        
        for reminder in reminders {
            print("\nProcessing reminder for plant: \(reminder.plant.plantName)")
            
            // Watering reminders - only if enabled
            if reminder.reminder.wateringEnabled, let waterDate = reminder.reminder.upcomingReminderForWater {
                print("Water date: \(waterDate)")
                print("Is water date today? \(calendar.isDateInToday(waterDate))")
                print("Is water date > current? \(waterDate > currentDate)")
                if calendar.isDateInToday(waterDate) {
                    print("- Water reminder is for today")
                    todayReminders[0].append(reminder)
                } else if waterDate > currentDate {
                    print("- Water reminder is upcoming")
                    upcomingReminders[0].append(reminder)
                }
            }
            
            // Fertilizing reminders - only if enabled
            if reminder.reminder.fertilizerEnabled, let fertDate = reminder.reminder.upcomingReminderForFertilizers {
                print("Fertilizer date: \(fertDate)")
                print("Is fertilizer date today? \(calendar.isDateInToday(fertDate))")
                print("Is fertilizer date > current? \(fertDate > currentDate)")
                if calendar.isDateInToday(fertDate) {
                    print("- Fertilizer reminder is for today")
                    todayReminders[1].append(reminder)
                } else if fertDate > currentDate {
                    print("- Fertilizer reminder is upcoming")
                    upcomingReminders[1].append(reminder)
                }
            }
            
            // Repotting reminders - only if enabled
            if reminder.reminder.repottingEnabled, let repotDate = reminder.reminder.upcomingReminderForRepotted {
                print("Repotting date: \(repotDate)")
                print("Is repotting date today? \(calendar.isDateInToday(repotDate))")
                print("Is repotting date > current? \(repotDate > currentDate)")
                if calendar.isDateInToday(repotDate) {
                    print("- Repotting reminder is for today")
                    todayReminders[2].append(reminder)
                } else if repotDate > currentDate {
                    print("- Repotting reminder is upcoming")
                    upcomingReminders[2].append(reminder)
                }
            }
        }
        
        // Sort reminders by date within each section
        for i in 0..<3 {
            todayReminders[i].sort { first, second in
                let date1: Date?
                let date2: Date?
                
                switch i {
                case 0:
                    date1 = first.reminder.upcomingReminderForWater
                    date2 = second.reminder.upcomingReminderForWater
                case 1:
                    date1 = first.reminder.upcomingReminderForFertilizers
                    date2 = second.reminder.upcomingReminderForFertilizers
                case 2:
                    date1 = first.reminder.upcomingReminderForRepotted
                    date2 = second.reminder.upcomingReminderForRepotted
                default:
                    return false
                }
                
                guard let d1 = date1, let d2 = date2 else { return false }
                return d1 < d2
            }
            
            upcomingReminders[i].sort { first, second in
                let date1: Date?
                let date2: Date?
                
                switch i {
                case 0:
                    date1 = first.reminder.upcomingReminderForWater
                    date2 = second.reminder.upcomingReminderForWater
                case 1:
                    date1 = first.reminder.upcomingReminderForFertilizers
                    date2 = second.reminder.upcomingReminderForFertilizers
                case 2:
                    date1 = first.reminder.upcomingReminderForRepotted
                    date2 = second.reminder.upcomingReminderForRepotted
                default:
                    return false
                }
                
                guard let d1 = date1, let d2 = date2 else { return false }
                return d1 < d2
            }
        }
        
        // Print summary
        print("\n=== Reminder Sort Summary ===")
        print("Today's reminders:")
        print("- Watering: \(todayReminders[0].count)")
        print("- Fertilizing: \(todayReminders[1].count)")
        print("- Pruning: \(todayReminders[2].count)")
        print("\nUpcoming reminders:")
        print("- Watering: \(upcomingReminders[0].count)")
        print("- Fertilizing: \(upcomingReminders[1].count)")
        print("- Pruning: \(upcomingReminders[2].count)")
        
        // Update UI visibility based on whether there are any reminders in the current view
        let hasReminders = careReminderSegmentedControl.selectedSegmentIndex == 0 ?
            !todayReminders.allSatisfy({ $0.isEmpty }) :
            !upcomingReminders.allSatisfy({ $0.isEmpty })
        
        print("\nUI Visibility:")
        print("Has reminders: \(hasReminders)")
        print("Selected segment: \(careReminderSegmentedControl.selectedSegmentIndex)")
        
        noRemindersView.isHidden = hasReminders
        careReminderCollectionView.isHidden = !hasReminders
    }
    // MARK: - Actions
    @IBAction func didChangeSegmentCareReminder(_ sender: UISegmentedControl) {
        // Update the no reminders message based on selected segment
        if let label = noRemindersView.viewWithTag(100) as? UILabel {
            label.text = sender.selectedSegmentIndex == 0 ? "Relax!! No work today" : "No upcoming reminders"
        }
        
        sortReminders()
        updateEditButtonVisibility()
        careReminderCollectionView.reloadData()
    }
    
    @IBAction func editButtonCareReminderTapped(_ sender: UIBarButtonItem) {
        guard careReminderSegmentedControl.selectedSegmentIndex == 0 else { return }
        let alert = UIAlertController(title: "Edit Today's Reminders", message: "Choose an action", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Mark All as Completed", style: .default, handler: { [weak self] _ in
            self?.markAllTodayRemindersAsCompleted()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func refreshAfterPlantDeletion(_ notification: Notification) {
        reminders = []
        todayReminders = [[],[],[]]
        upcomingReminders = [[],[],[]]
        guard let firstUser = dataController.getUserSync() else { return }

        // Only load reminders once, do not append in a loop
        reminders = dataController.getUserPlantsWithDetailsSync(for: firstUser.userEmail!)
        
        sortReminders()
        DispatchQueue.main.async { [weak self] in
            self?.careReminderCollectionView.reloadData()
            let hasReminders = self?.careReminderSegmentedControl.selectedSegmentIndex == 0 ?
                self?.todayReminders.contains(where: { !$0.isEmpty }) ?? false :
                self?.upcomingReminders.contains(where: { !$0.isEmpty }) ?? false
            self?.noRemindersView.isHidden = hasReminders
            self?.careReminderCollectionView.isHidden = !hasReminders
        }
    }
    
    @objc private func refreshAfterStatusUpdate(_ notification: Notification) {
        if let reminderId = notification.userInfo?["reminderId"] as? UUID,
           let reminderType = notification.userInfo?["reminderType"] as? String,
           let isCompleted = notification.userInfo?["isCompleted"] as? Bool {
            
            // Update the reminder in the main array
            for (index, reminder) in reminders.enumerated() {
                if reminder.reminder.careReminderID == reminderId {
                    switch reminderType {
                    case "Watering":
                        reminders[index].reminder.isWateringCompleted = isCompleted
                    case "Fertilization":
                        reminders[index].reminder.isFertilizingCompleted = isCompleted
                    case "Pruning":
                        reminders[index].reminder.isRepottingCompleted = isCompleted
                    default:
                        break
                    }
                }
            }
            
            // Re-sort reminders to update the sections
            sortReminders()
            careReminderCollectionView.reloadData()
        }
    }
    // MARK: - Layout
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) -> NSCollectionLayoutSection? in
            let section = self?.generateSectionLayout()
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .absolute(70)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section?.boundarySupplementaryItems = [header]
            return section
        }
    }
    private func generateSectionLayout() -> NSCollectionLayoutSection {
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
        section.interGroupSpacing = 5
        return section
    }
    private func updateEditButtonVisibility() {
        editButton?.isEnabled = careReminderSegmentedControl.selectedSegmentIndex == 0
    }
    private func markAllTodayRemindersAsCompleted() {
        let currentDate = Date()
        for (type, reminders) in todayReminders.enumerated() {
            for reminder in reminders {
                let reminderType: String
                switch type {
                case 0:
                    reminderType = "water"
                case 1:
                    reminderType = "fertilizer"
                case 2:
                    reminderType = "repot"
                default:
                    continue
                }
                dataController.updateCareReminderWithDetailsSync(
                    userPlantID: reminder.userPlant.userPlantRelationID,
                    type: reminderType,
                    isCompleted: true
                )
            }
        }
        loadData()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
// MARK: - UICollectionView DataSource & Delegate
extension CareReminderViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let currentReminders = careReminderSegmentedControl.selectedSegmentIndex == 0 ? todayReminders : upcomingReminders
        return currentReminders.filter { !$0.isEmpty }.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentReminders = careReminderSegmentedControl.selectedSegmentIndex == 0 ? todayReminders : upcomingReminders
        let nonEmptySections = currentReminders.enumerated().filter { !$0.element.isEmpty }
        guard section < nonEmptySections.count else { return 0 }
        return nonEmptySections[section].element.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareReminderCell",
            for: indexPath
        ) as? CareReminderCollectionViewCell else {
            fatalError("Unable to dequeue CareReminderCell")
        }
        
        let currentReminders = careReminderSegmentedControl.selectedSegmentIndex == 0 ? todayReminders : upcomingReminders
        let nonEmptySections = currentReminders.enumerated().filter { !$0.element.isEmpty }
        let sectionType = nonEmptySections[indexPath.section].offset
        let reminder = nonEmptySections[indexPath.section].element[indexPath.item]
        
        let isCompleted: Bool
        let dueDate: Date?
        
        switch sectionType {
        case 0:
            isCompleted = reminder.reminder.isWateringCompleted ?? false
            dueDate = reminder.reminder.upcomingReminderForWater
        case 1:
            isCompleted = reminder.reminder.isFertilizingCompleted ?? false
            dueDate = reminder.reminder.upcomingReminderForFertilizers
        case 2:
            isCompleted = reminder.reminder.isRepottingCompleted ?? false
            dueDate = reminder.reminder.upcomingReminderForRepotted
        default:
            isCompleted = false
            dueDate = nil
        }
        
        let isToday = careReminderSegmentedControl.selectedSegmentIndex == 0
        let isTomorrow = dueDate.map { Calendar.current.isDateInTomorrow($0) } ?? false
        let isInToday = dueDate.map { Calendar.current.isDateInToday($0) } ?? false
        
        // Always enable checkbox for today's tasks, regardless of completion status
        let shouldEnableCheckbox = isToday || (isTomorrow && !isToday)
        
        cell.configure(
            with: reminder,
            isCompleted: isCompleted,
            dueDate: dueDate,
            isUpcoming: careReminderSegmentedControl.selectedSegmentIndex == 1,
            isTomorrow: isTomorrow,
            shouldEnableCheckbox: shouldEnableCheckbox
        )
        
        cell.onCheckboxToggle = { [weak self] in
            if shouldEnableCheckbox {
                self?.handleCheckboxToggle(for: reminder, type: sectionType)
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
            let currentReminders = careReminderSegmentedControl.selectedSegmentIndex == 0 ? todayReminders : upcomingReminders
            let nonEmptySections = currentReminders.enumerated().filter { !$0.element.isEmpty }
            let sectionType = nonEmptySections[indexPath.section].offset
            header.headerLabel.text = reminderTypes[sectionType]
            header.headerLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            header.headerLabel.textColor = UIColor(hex: "284329")
            return header
        }
        return UICollectionReusableView()
    }
    private func handleCheckboxToggle(for reminder: (userPlant: UserPlant, plant: Plant, reminder: CareReminder_), type: Int) {
        print("\n=== Handling Checkbox Toggle ===")
        print("Plant: \(reminder.plant.plantName)")
        print("Type: \(type)")
        
        let isCompleted: Bool
        let reminderType: String
        
        switch type {
        case 0:
            isCompleted = reminder.reminder.isWateringCompleted ?? false
            reminderType = "water"
            print("Water reminder - Current state: \(isCompleted)")
        case 1:
            isCompleted = reminder.reminder.isFertilizingCompleted ?? false
            reminderType = "fertilizer"
            print("Fertilizer reminder - Current state: \(isCompleted)")
        case 2:
            isCompleted = reminder.reminder.isRepottingCompleted ?? false
            reminderType = "repot"
            print("Repot reminder - Current state: \(isCompleted)")
        default:
            print("❌ Invalid reminder type: \(type)")
            return
        }
        
        print("Toggling state from \(isCompleted) to \(!isCompleted)")
        
        // Store the current date of the reminder before updating
        let currentReminderDate: Date?
        switch type {
        case 0:
            currentReminderDate = reminder.reminder.upcomingReminderForWater
        case 1:
            currentReminderDate = reminder.reminder.upcomingReminderForFertilizers
        case 2:
            currentReminderDate = reminder.reminder.upcomingReminderForRepotted
        default:
            currentReminderDate = nil
        }
        
        if let currentDate = currentReminderDate {
            print("Current reminder date: \(currentDate)")
        }
        
        // Update the database
        print("📝 Updating database...")
        dataController.updateCareReminderWithDetailsSync(
            userPlantID: reminder.userPlant.userPlantRelationID,
            type: reminderType,
            isCompleted: !isCompleted
        )
        print("✅ Database updated")
        
        // Post notification to trigger UI update
        print("📢 Posting notification...")
        NotificationCenter.default.post(
            name: NSNotification.Name("ReminderStatusUpdated"),
            object: nil,
            userInfo: [
                "reminderId": reminder.reminder.careReminderID,
                "reminderType": reminderType.capitalized,
                "isCompleted": !isCompleted
            ]
        )
        print("✅ Notification posted")
        // If this is a today's reminder, ensure it stays in today's section
               if let reminderDate = currentReminderDate,
                  Calendar.current.isDateInToday(reminderDate) {
                   print("📅 Today's reminder - reloading data...")
                   // Force a reload without changing the reminder's date
                   DispatchQueue.main.async { [weak self] in
                       self?.loadData()
                   }
               } else {
                   print("📅 Not today's reminder - normal reload")
                   loadData()
        
        }
        print("=== Checkbox Toggle Handling Complete ===\n")
    }
}

