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
    
    // Prevent multiple simultaneous checkbox toggles
    private var isProcessingToggle = false
    
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
        
        // Don't reload if we already have data - just refresh the display
        if !reminders.isEmpty {
            sortReminders()
            careReminderCollectionView.reloadData()
            
            // Update UI visibility
            let hasReminders = careReminderSegmentedControl.selectedSegmentIndex == 0 ?
                !todayReminders.allSatisfy({ $0.isEmpty }) :
                !upcomingReminders.allSatisfy({ $0.isEmpty })
            
            noRemindersView.isHidden = hasReminders
            careReminderCollectionView.isHidden = !hasReminders
        }
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
        
        // Get email directly from UserDefaults
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {
            print("❌ No user email found in UserDefaults")
            return
        }
        print("✅ Using email: \(userEmail)")
        
        // Load reminders using the sync wrapper
        print("📞 Calling getUserPlantsWithDetailsSync...")
        reminders = dataController.getUserPlantsWithDetailsSync(for: userEmail)
        print("📱 Loaded \(reminders.count) reminders")
        
        if reminders.isEmpty {
            print("⚠️ WARNING: No reminders loaded!")
            print("🔍 Checking if user has plants...")
            
            // Debug: Try to get basic plant info
            if let plants = dataController.getUserPlantsWithBasicDetailsSync(for: userEmail) {
                print("📊 User has \(plants.count) plants")
                for (index, plantData) in plants.enumerated() {
                    print("  Plant \(index + 1): \(plantData.plant.plantName) - \(plantData.userPlant.userPlantNickName ?? "No nickname")")
                }
            } else {
                print("❌ Could not load basic plant details")
            }
        } else {
            print("✅ Successfully loaded reminders:")
            for (index, reminder) in reminders.enumerated() {
                print("  \(index + 1). \(reminder.plant.plantName) - Water: \(reminder.reminder.wateringEnabled), Fert: \(reminder.reminder.fertilizerEnabled), Repot: \(reminder.reminder.repottingEnabled)")
            }
        }
        
        sortReminders()
        careReminderCollectionView.reloadData()
    }
    
    private func sortReminders() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        print("\n🔍 Sorting \(reminders.count) reminders (Current date: \(currentDate))")
        
        // Clear existing arrays
        todayReminders = [[],[],[]]
        upcomingReminders = [[],[],[]]
        
        for reminder in reminders {
            // Watering reminders - only if enabled
            if reminder.reminder.wateringEnabled {
                // Use the last completed date, or default to a very old date if nil
                let lastCompletedDate = reminder.reminder.last_water_completed_date ?? calendar.date(byAdding: .year, value: -1, to: currentDate)!
                let waterFreq = max(reminder.plant.waterFrequency ?? 7, 1)
                let completionFlag = reminder.reminder.isWateringCompleted ?? false
                
                // Calculate the next due date based on last completed date
                if let nextDueDate = calendar.date(byAdding: .day, value: Int(waterFreq), to: lastCompletedDate) {
                    let startOfToday = calendar.startOfDay(for: currentDate)
                    let startOfDueDate = calendar.startOfDay(for: nextDueDate)
                    
                    // A task is only "completed" if the next due date is in the future
                    // If the next due date has passed, the task is overdue (new cycle started)
                    let isCompletedForCurrentCycle = completionFlag && (startOfDueDate > startOfToday)
                    
                    // Debug: Print calculation details for all watering tasks
                    let daysUntilDue = calendar.dateComponents([.day], from: startOfToday, to: startOfDueDate).day ?? 0
                    print("💧 \(reminder.plant.plantName): lastCompleted=\(lastCompletedDate), freq=\(waterFreq)d, nextDue=\(nextDueDate), daysUntil=\(daysUntilDue), flag=\(completionFlag), actuallyCompleted=\(isCompletedForCurrentCycle)")
                    
                    // If due date is today or in the past (overdue), show in today's reminders
                    // BUT: Don't show completed tasks in today's list (they disappear after completion)
                    if startOfDueDate <= startOfToday {
                        if !isCompletedForCurrentCycle {
                            todayReminders[0].append(reminder)
                            print("  ✅ Added to TODAY (overdue by \(-daysUntilDue) days)")
                        } else {
                            print("  ⏭ Skipped (completed for current cycle)")
                        }
                    } else {
                        upcomingReminders[0].append(reminder)
                        print("  📅 Added to UPCOMING (in \(daysUntilDue) days)")
                    }
                }
            }
            
            // Fertilizing reminders - only if enabled
            if reminder.reminder.fertilizerEnabled {
                let lastCompletedDate = reminder.reminder.last_fertilizer_completed_date ?? calendar.date(byAdding: .year, value: -1, to: currentDate)!
                let fertFreq = max(reminder.plant.fertilizerFrequency ?? 30, 1)
                let completionFlag = reminder.reminder.isFertilizingCompleted ?? false
                
                // Calculate the next due date based on last completed date
                if let nextDueDate = calendar.date(byAdding: .day, value: Int(fertFreq), to: lastCompletedDate) {
                    let startOfToday = calendar.startOfDay(for: currentDate)
                    let startOfDueDate = calendar.startOfDay(for: nextDueDate)
                    
                    // A task is only "completed" if the next due date is in the future
                    let isCompletedForCurrentCycle = completionFlag && (startOfDueDate > startOfToday)
                    
                    if startOfDueDate <= startOfToday {
                        if !isCompletedForCurrentCycle {
                            todayReminders[1].append(reminder)
                        }
                    } else {
                        upcomingReminders[1].append(reminder)
                    }
                }
            }
            
            // Repotting reminders - only if enabled
            if reminder.reminder.repottingEnabled {
                let lastCompletedDate = reminder.reminder.last_repot_completed_date ?? calendar.date(byAdding: .year, value: -1, to: currentDate)!
                let repotFreq = max(reminder.plant.repottingFrequency ?? 365, 1)
                let completionFlag = reminder.reminder.isRepottingCompleted ?? false
                
                // Calculate the next due date based on last completed date
                if let nextDueDate = calendar.date(byAdding: .day, value: Int(repotFreq), to: lastCompletedDate) {
                    let startOfToday = calendar.startOfDay(for: currentDate)
                    let startOfDueDate = calendar.startOfDay(for: nextDueDate)
                    
                    // A task is only "completed" if the next due date is in the future
                    let isCompletedForCurrentCycle = completionFlag && (startOfDueDate > startOfToday)
                    
                    if startOfDueDate <= startOfToday {
                        if !isCompletedForCurrentCycle {
                            todayReminders[2].append(reminder)
                        }
                    } else {
                        upcomingReminders[2].append(reminder)
                    }
                }
            }
        }
        
        // Sort reminders by date within each section
        for i in 0..<3 {
            // Sort today's reminders by how overdue (oldest due date first)
            todayReminders[i].sort { first, second in
                let date1: Date?
                let date2: Date?
                
                switch i {
                case 0:
                    if let lastCompleted1 = first.reminder.last_water_completed_date,
                       let freq1 = first.plant.waterFrequency {
                        date1 = calendar.date(byAdding: .day, value: Int(freq1), to: lastCompleted1)
                    } else {
                        date1 = nil
                    }
                    if let lastCompleted2 = second.reminder.last_water_completed_date,
                       let freq2 = second.plant.waterFrequency {
                        date2 = calendar.date(byAdding: .day, value: Int(freq2), to: lastCompleted2)
                    } else {
                        date2 = nil
                    }
                case 1:
                    if let lastCompleted1 = first.reminder.last_fertilizer_completed_date,
                       let freq1 = first.plant.fertilizerFrequency {
                        date1 = calendar.date(byAdding: .day, value: Int(freq1), to: lastCompleted1)
                    } else {
                        date1 = nil
                    }
                    if let lastCompleted2 = second.reminder.last_fertilizer_completed_date,
                       let freq2 = second.plant.fertilizerFrequency {
                        date2 = calendar.date(byAdding: .day, value: Int(freq2), to: lastCompleted2)
                    } else {
                        date2 = nil
                    }
                case 2:
                    if let lastCompleted1 = first.reminder.last_repot_completed_date,
                       let freq1 = first.plant.repottingFrequency {
                        date1 = calendar.date(byAdding: .day, value: Int(freq1), to: lastCompleted1)
                    } else {
                        date1 = nil
                    }
                    if let lastCompleted2 = second.reminder.last_repot_completed_date,
                       let freq2 = second.plant.repottingFrequency {
                        date2 = calendar.date(byAdding: .day, value: Int(freq2), to: lastCompleted2)
                    } else {
                        date2 = nil
                    }
                default:
                    return false
                }
                
                guard let d1 = date1, let d2 = date2 else { return false }
                return d1 < d2  // Oldest (most overdue) first
            }
            
            // Sort upcoming reminders by next due date (soonest first)
            upcomingReminders[i].sort { first, second in
                let date1: Date?
                let date2: Date?
                
                switch i {
                case 0:
                    if let lastCompleted1 = first.reminder.last_water_completed_date,
                       let freq1 = first.plant.waterFrequency {
                        date1 = calendar.date(byAdding: .day, value: Int(freq1), to: lastCompleted1)
                    } else {
                        date1 = nil
                    }
                    if let lastCompleted2 = second.reminder.last_water_completed_date,
                       let freq2 = second.plant.waterFrequency {
                        date2 = calendar.date(byAdding: .day, value: Int(freq2), to: lastCompleted2)
                    } else {
                        date2 = nil
                    }
                case 1:
                    if let lastCompleted1 = first.reminder.last_fertilizer_completed_date,
                       let freq1 = first.plant.fertilizerFrequency {
                        date1 = calendar.date(byAdding: .day, value: Int(freq1), to: lastCompleted1)
                    } else {
                        date1 = nil
                    }
                    if let lastCompleted2 = second.reminder.last_fertilizer_completed_date,
                       let freq2 = second.plant.fertilizerFrequency {
                        date2 = calendar.date(byAdding: .day, value: Int(freq2), to: lastCompleted2)
                    } else {
                        date2 = nil
                    }
                case 2:
                    if let lastCompleted1 = first.reminder.last_repot_completed_date,
                       let freq1 = first.plant.repottingFrequency {
                        date1 = calendar.date(byAdding: .day, value: Int(freq1), to: lastCompleted1)
                    } else {
                        date1 = nil
                    }
                    if let lastCompleted2 = second.reminder.last_repot_completed_date,
                       let freq2 = second.plant.repottingFrequency {
                        date2 = calendar.date(byAdding: .day, value: Int(freq2), to: lastCompleted2)
                    } else {
                        date2 = nil
                    }
                default:
                    return false
                }
                
                guard let d1 = date1, let d2 = date2 else { return false }
                return d1 < d2  // Soonest first
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
        print("\n=== Changing Care Reminder Segment ===")
        print("Selected segment: \(sender.selectedSegmentIndex)")
        
        // Update the no reminders message based on selected segment
        if let label = noRemindersView.viewWithTag(100) as? UILabel {
            label.text = sender.selectedSegmentIndex == 0 ? "Relax!! No work today" : "No upcoming reminders"
        }
        
        // Sort reminders to ensure they're in the correct sections
        sortReminders()
        
        // Update UI visibility based on whether there are any reminders in the current view
        let hasReminders = sender.selectedSegmentIndex == 0 ?
            !todayReminders.allSatisfy({ $0.isEmpty }) :
            !upcomingReminders.allSatisfy({ $0.isEmpty })
        
        print("Has reminders: \(hasReminders)")
        
        noRemindersView.isHidden = hasReminders
        careReminderCollectionView.isHidden = !hasReminders
        
        // Update the collection view
        DispatchQueue.main.async { [weak self] in
            self?.careReminderCollectionView.reloadData()
        }
        
        updateEditButtonVisibility()
        print("=== Care Reminder Segment Changed ===\n")
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
        // Reload data when a plant is deleted
        reminders = []
        todayReminders = [[],[],[]]
        upcomingReminders = [[],[],[]]
        
        loadData()
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
        section.interGroupSpacing = 12  // Premium whitespace
        return section
    }
    private func updateEditButtonVisibility() {
        editButton?.isEnabled = careReminderSegmentedControl.selectedSegmentIndex == 0
    }
    private func markAllTodayRemindersAsCompleted() {
        print("\n=== Marking All Today's Reminders as Completed ===")
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
                
                print("Updating reminder for plant: \(reminder.plant.plantName)")
                print("Type: \(reminderType)")
                
                // Update the database
                dataController.updateCareReminderWithDetailsSync(
                    userPlantID: reminder.userPlant.userPlantRelationID,
                    type: reminderType,
                    isCompleted: true
                )
                
                // Update the reminder in the main array
                for (index, r) in self.reminders.enumerated() {
                    if r.userPlant.userPlantRelationID == reminder.userPlant.userPlantRelationID {
                        switch type {
                        case 0:
                            self.reminders[index].reminder.isWateringCompleted = true
                        case 1:
                            self.reminders[index].reminder.isFertilizingCompleted = true
                        case 2:
                            self.reminders[index].reminder.isRepottingCompleted = true
                        default:
                            break
                        }
                    }
                }
            }
        }
        
        // Update the UI without reloading data
        DispatchQueue.main.async { [weak self] in
            self?.careReminderCollectionView.reloadData()
        }
        
        print("=== All Today's Reminders Marked as Completed ===\n")
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
        let calendar = Calendar.current
        let currentDate = Date()
        
        switch sectionType {
        case 0:
            // Calculate if task is completed for the CURRENT cycle
            let flagCompleted = reminder.reminder.isWateringCompleted ?? false
            let lastCompletedDate = reminder.reminder.last_water_completed_date ?? currentDate
            let waterFreq = max(reminder.plant.waterFrequency ?? 7, 1)
            
            // Calculate the ACTUAL due date from last completed + frequency
            if let actualDueDate = calendar.date(byAdding: .day, value: Int(waterFreq), to: lastCompletedDate) {
                let startOfToday = calendar.startOfDay(for: currentDate)
                let startOfDueDate = calendar.startOfDay(for: actualDueDate)
                
                // Only show as completed if the flag is true AND we haven't reached the next due date yet
                isCompleted = flagCompleted && startOfDueDate > startOfToday
                dueDate = actualDueDate  // Use the calculated due date, not the stored one
            } else {
                isCompleted = false
                dueDate = reminder.reminder.upcomingReminderForWater
            }
            
        case 1:
            // Calculate if task is completed for the CURRENT cycle
            let flagCompleted = reminder.reminder.isFertilizingCompleted ?? false
            let lastCompletedDate = reminder.reminder.last_fertilizer_completed_date ?? currentDate
            let fertFreq = max(reminder.plant.fertilizerFrequency ?? 30, 1)
            
            // Calculate the ACTUAL due date from last completed + frequency
            if let actualDueDate = calendar.date(byAdding: .day, value: Int(fertFreq), to: lastCompletedDate) {
                let startOfToday = calendar.startOfDay(for: currentDate)
                let startOfDueDate = calendar.startOfDay(for: actualDueDate)
                
                // Only show as completed if the flag is true AND we haven't reached the next due date yet
                isCompleted = flagCompleted && startOfDueDate > startOfToday
                dueDate = actualDueDate  // Use the calculated due date, not the stored one
            } else {
                isCompleted = false
                dueDate = reminder.reminder.upcomingReminderForFertilizers
            }
            
        case 2:
            // Calculate if task is completed for the CURRENT cycle
            let flagCompleted = reminder.reminder.isRepottingCompleted ?? false
            let lastCompletedDate = reminder.reminder.last_repot_completed_date ?? currentDate
            let repotFreq = max(reminder.plant.repottingFrequency ?? 365, 1)
            
            // Calculate the ACTUAL due date from last completed + frequency
            if let actualDueDate = calendar.date(byAdding: .day, value: Int(repotFreq), to: lastCompletedDate) {
                let startOfToday = calendar.startOfDay(for: currentDate)
                let startOfDueDate = calendar.startOfDay(for: actualDueDate)
                
                // Only show as completed if the flag is true AND we haven't reached the next due date yet
                isCompleted = flagCompleted && startOfDueDate > startOfToday
                dueDate = actualDueDate  // Use the calculated due date, not the stored one
            } else {
                isCompleted = false
                dueDate = reminder.reminder.upcomingReminderForRepotted
            }
            
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
                self?.handleCheckboxToggle(for: reminder, type: sectionType, at: indexPath)
            }
        }
        
        // Premium depth and polish
        cell.layer.cornerRadius = 18
        cell.layer.cornerCurve = .continuous  // iOS premium curve
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.06
        cell.layer.shadowRadius = 18
        cell.layer.shadowOffset = CGSize(width: 0, height: 10)
        cell.layer.masksToBounds = false
        
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
    private func handleCheckboxToggle(for reminder: (userPlant: UserPlant, plant: Plant, reminder: CareReminder_), type: Int, at indexPath: IndexPath) {
        print("\n🎯 === Checkbox Toggle Started ===")
        print("Plant: \(reminder.plant.plantName)")
        
        // Prevent multiple simultaneous toggles
        guard !isProcessingToggle else {
            print("⚠️ Already processing, ignoring tap")
            return
        }
        
        isProcessingToggle = true
        
        // Haptic feedback for tactile response
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        let isCompleted: Bool
        let reminderType: String
        
        switch type {
        case 0:
            isCompleted = reminder.reminder.isWateringCompleted ?? false
            reminderType = "water"
            print("💧 Watering task - Currently: \(isCompleted ? "completed" : "incomplete")")
        case 1:
            isCompleted = reminder.reminder.isFertilizingCompleted ?? false
            reminderType = "fertilizer"
            print("🌱 Fertilizer task - Currently: \(isCompleted ? "completed" : "incomplete")")
        case 2:
            isCompleted = reminder.reminder.isRepottingCompleted ?? false
            reminderType = "repot"
            print("🪴 Repotting task - Currently: \(isCompleted ? "completed" : "incomplete")")
        default:
            isProcessingToggle = false
            return
        }
        
        // Update database in background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            print("📝 Updating database...")
            self.dataController.updateCareReminderWithDetailsSync(
                userPlantID: reminder.userPlant.userPlantRelationID,
                type: reminderType,
                isCompleted: !isCompleted
            )
            print("✅ Database updated")
            
            // Success haptic feedback
            DispatchQueue.main.async {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
            }
        }
        
        // PREMIUM: Animate cell AND delete simultaneously
        if let cell = careReminderCollectionView.cellForItem(at: indexPath) {
            print("✅ Cell found, starting premium animation")
            
            // Start custom animation on cell content
            animateCheckboxToggle(cell: cell, isCompleting: !isCompleted)
            
            // Ensure layout is stable before batch updates
            UIView.performWithoutAnimation {
                self.careReminderCollectionView.layoutIfNeeded()
            }
            
            // Get section count before deletion
            let sectionCountBefore = self.numberOfSections(in: self.careReminderCollectionView)
            
            // CRITICAL: Delete item DURING animation (not after)
            // UICollectionView handles layout animation automatically
            self.careReminderCollectionView.performBatchUpdates({
                // Remove from data source FIRST
                let currentReminders = self.careReminderSegmentedControl.selectedSegmentIndex == 0 ? self.todayReminders : self.upcomingReminders
                let nonEmptySections = currentReminders.enumerated().filter { !$0.element.isEmpty }
                let sectionType = nonEmptySections[indexPath.section].offset
                
                if self.careReminderSegmentedControl.selectedSegmentIndex == 0 {
                    self.todayReminders[sectionType].removeAll {
                        $0.userPlant.userPlantRelationID == reminder.userPlant.userPlantRelationID
                    }
                } else {
                    self.upcomingReminders[sectionType].removeAll {
                        $0.userPlant.userPlantRelationID == reminder.userPlant.userPlantRelationID
                    }
                }
                
                // Check if section became empty
                let currentArray = self.careReminderSegmentedControl.selectedSegmentIndex == 0
                    ? self.todayReminders[sectionType]
                    : self.upcomingReminders[sectionType]
                
                let sectionCountAfter = self.numberOfSections(in: self.careReminderCollectionView)
                
                // CRITICAL: Delete section if empty, otherwise delete item
                if currentArray.isEmpty && sectionCountAfter < sectionCountBefore {
                    // Section became empty - delete entire section
                    self.careReminderCollectionView.deleteSections(IndexSet(integer: indexPath.section))
                    print("🗑️ Deleted entire section \(indexPath.section)")
                } else {
                    // Section still has items - delete only this item
                    self.careReminderCollectionView.deleteItems(at: [indexPath])
                    print("🗑️ Deleted item at \(indexPath)")
                }
                
            }, completion: { finished in
                print("✅ Premium animation completed: \(finished)")
                
                // Update UI visibility
                let hasReminders = self.careReminderSegmentedControl.selectedSegmentIndex == 0 ?
                    !self.todayReminders.allSatisfy({ $0.isEmpty }) :
                    !self.upcomingReminders.allSatisfy({ $0.isEmpty })
                
                self.noRemindersView.isHidden = hasReminders
                self.careReminderCollectionView.isHidden = !hasReminders
                
                self.isProcessingToggle = false
            })
        } else {
            print("⚠️ Cell not visible")
            isProcessingToggle = false
        }
    }
    
    private func animateCheckboxToggle(cell: UICollectionViewCell, isCompleting: Bool) {
        guard let reminderCell = cell as? CareReminderCollectionViewCell else { return }
        
        if isCompleting {
            // Premium completion animation
            print("🎬 Starting premium completion animation")
            
            // Step 0: Touch compression (makes tap feel physical)
            UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseOut, animations: {
                cell.contentView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            })
            
            // Step 1: Checkbox pop with spring (delightful bounce)
            if let checkbox = reminderCell.checkbox {
                UIView.animate(
                    withDuration: 0.28,
                    delay: 0.08,
                    usingSpringWithDamping: 0.45,
                    initialSpringVelocity: 3,
                    options: .curveEaseOut,
                    animations: {
                        checkbox.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                    }) { _ in
                        UIView.animate(withDuration: 0.15) {
                            checkbox.transform = .identity
                        }
                    }
            }
            
            // Step 2: Create premium "Completed" pill with blur background
            let blurEffect = UIBlurEffect(style: .systemThinMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.layer.cornerRadius = 14
            blurView.layer.cornerCurve = .continuous
            blurView.clipsToBounds = true
            blurView.alpha = 0
            blurView.tag = 9999
            
            // Create checkmark icon
            let checkmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            checkmark.tintColor = UIColor(hex: "004E05")
            checkmark.translatesAutoresizingMaskIntoConstraints = false
            
            // Create label inside blur
            let completedLabel = UILabel()
            completedLabel.text = "Completed"
            completedLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            completedLabel.textColor = UIColor(hex: "004E05")
            completedLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Add to blur view
            blurView.contentView.addSubview(checkmark)
            blurView.contentView.addSubview(completedLabel)
            
            // Position blur view
            blurView.frame = CGRect(
                x: cell.contentView.bounds.width - 130,
                y: cell.contentView.bounds.height / 2 - 16,
                width: 110,
                height: 32
            )
            
            // Layout constraints
            NSLayoutConstraint.activate([
                checkmark.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 8),
                checkmark.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),
                checkmark.widthAnchor.constraint(equalToConstant: 16),
                checkmark.heightAnchor.constraint(equalToConstant: 16),
                
                completedLabel.leadingAnchor.constraint(equalTo: checkmark.trailingAnchor, constant: 4),
                completedLabel.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),
                completedLabel.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -8)
            ])
            
            cell.contentView.addSubview(blurView)
            
            // Fade in the completed pill (with micro delay for anticipation)
            UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseIn, animations: {
                blurView.alpha = 1.0
            })
            
            // Step 3: Premium exit animation - animate contentView ONLY (not whole cell)
            // This allows UICollectionView to handle cell frame while we control content
            UIView.animate(
                withDuration: 1.2,  // Slower, more elegant exit (was 0.55)
                delay: 0.3,  // Longer anticipation (was 0.18)
                usingSpringWithDamping: 0.82,  // Softer spring
                initialSpringVelocity: 0.6,
                options: [.curveEaseInOut, .allowUserInteraction],
                animations: {
                    // Soft glide left with tiny upward lift and subtle rotation
                    cell.contentView.transform = CGAffineTransform(translationX: -80, y: -4)
                        .rotated(by: -.pi / 80)
                        .scaledBy(x: 0.97, y: 0.97)
                    
                    // Don't fully fade (premium apps rarely do)
                    cell.contentView.alpha = 0.25
                    
                    // Lift shadow during exit (depth effect)
                    cell.layer.shadowOpacity = 0.18
                    cell.layer.shadowRadius = 24
                    
                    // Fade the pill
                    blurView.alpha = 0
                },
                completion: { finished in
                    print("✅ Premium animation completed: \(finished)")
                    blurView.removeFromSuperview()
                }
            )
            
        } else {
            // Uncompleting: Quick fade back in
            print("🔄 Starting uncompletion animation")
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.82,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut],
                animations: {
                    cell.contentView.transform = .identity
                    cell.contentView.alpha = 1.0
                }
            )
        }
    }
}