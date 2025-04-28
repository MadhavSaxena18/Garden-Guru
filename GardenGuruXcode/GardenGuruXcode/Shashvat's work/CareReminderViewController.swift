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
        guard let firstUser = dataController.getUsers().first else { return }
        reminders = dataController.getCareReminders(for: firstUser.userId)
        sortReminders()
        careReminderCollectionView.reloadData()
    }
    
    private func sortReminders() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Clear existing arrays
        todayReminders = [[],[],[]]
        upcomingReminders = [[],[],[]]
        
        for reminder in reminders {
            // Only add watering reminders if not disabled (not set to distantFuture)
            if reminder.reminder.upcomingReminderForWater != Date.distantFuture {
                if calendar.isDateInToday(reminder.reminder.upcomingReminderForWater) {
                    todayReminders[0].append(reminder)
                } else if reminder.reminder.upcomingReminderForWater > currentDate {
                    upcomingReminders[0].append(reminder)
                }
            }
            
            // Only add fertilizing reminders if not disabled
            if reminder.reminder.upcomingReminderForFertilizers != Date.distantFuture {
                if calendar.isDateInToday(reminder.reminder.upcomingReminderForFertilizers) {
                    todayReminders[1].append(reminder)
                } else if reminder.reminder.upcomingReminderForFertilizers > currentDate {
                    upcomingReminders[1].append(reminder)
                }
            }
            
            // Only add repotting reminders if not disabled
            if reminder.reminder.upcomingReminderForRepotted != Date.distantFuture {
                if calendar.isDateInToday(reminder.reminder.upcomingReminderForRepotted) {
                    todayReminders[2].append(reminder)
                } else if reminder.reminder.upcomingReminderForRepotted > currentDate {
                    upcomingReminders[2].append(reminder)
                }
            }
        }
        
        // Sort reminders by date within each section
        for i in 0..<3 {
            todayReminders[i].sort { first, second in
                switch i {
                case 0:
                    return first.reminder.upcomingReminderForWater < second.reminder.upcomingReminderForWater
                case 1:
                    return first.reminder.upcomingReminderForFertilizers < second.reminder.upcomingReminderForFertilizers
                case 2:
                    return first.reminder.upcomingReminderForRepotted < second.reminder.upcomingReminderForRepotted
                default:
                    return false
                }
            }
            
            upcomingReminders[i].sort { first, second in
                switch i {
                case 0:
                    return first.reminder.upcomingReminderForWater < second.reminder.upcomingReminderForWater
                case 1:
                    return first.reminder.upcomingReminderForFertilizers < second.reminder.upcomingReminderForFertilizers
                case 2:
                    return first.reminder.upcomingReminderForRepotted < second.reminder.upcomingReminderForRepotted
                default:
                    return false
                }
            }
        }
        
        // Update no reminders view
        let hasReminders = careReminderSegmentedControl.selectedSegmentIndex == 0 ?
            todayReminders.contains(where: { !$0.isEmpty }) :
            upcomingReminders.contains(where: { !$0.isEmpty })
        
        noRemindersView.isHidden = hasReminders
        careReminderCollectionView.isHidden = !hasReminders
    }
    
    // MARK: - Actions
    @IBAction func didChangeSegmentCareReminder(_ sender: UISegmentedControl) {
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
        // Clear current data
        reminders = []
        todayReminders = [[],[],[]]
        upcomingReminders = [[],[],[]]
        
        // Reload data from scratch
        guard let firstUser = dataController.getUsers().first else { return }
        reminders = dataController.getCareReminders(for: firstUser.userId)
        
        // Resort and refresh UI
        sortReminders()
        
        DispatchQueue.main.async { [weak self] in
            self?.careReminderCollectionView.reloadData()
            
            // Update visibility of no reminders view
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
            
            // Update today's reminders
            for sectionIndex in 0..<todayReminders.count {
                for (index, reminder) in todayReminders[sectionIndex].enumerated() {
                    if reminder.reminder.careReminderID == reminderId {
                        switch reminderType {
                        case "Watering":
                            if sectionIndex == 0 {
                                todayReminders[sectionIndex][index].reminder.isWateringCompleted = isCompleted
                            }
                        case "Fertilization":
                            if sectionIndex == 1 {
                                todayReminders[sectionIndex][index].reminder.isFertilizingCompleted = isCompleted
                            }
                        case "Repotting":
                            if sectionIndex == 2 {
                                todayReminders[sectionIndex][index].reminder.isRepottingCompleted = isCompleted
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
            // Update upcoming reminders
            for sectionIndex in 0..<upcomingReminders.count {
                for (index, reminder) in upcomingReminders[sectionIndex].enumerated() {
                    if reminder.reminder.careReminderID == reminderId {
                        switch reminderType {
                        case "Watering":
                            if sectionIndex == 0 {
                                upcomingReminders[sectionIndex][index].reminder.isWateringCompleted = isCompleted
                            }
                        case "Fertilization":
                            if sectionIndex == 1 {
                                upcomingReminders[sectionIndex][index].reminder.isFertilizingCompleted = isCompleted
                            }
                        case "Repotting":
                            if sectionIndex == 2 {
                                upcomingReminders[sectionIndex][index].reminder.isRepottingCompleted = isCompleted
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
            // Update the main reminders array
            for (index, reminder) in reminders.enumerated() {
                if reminder.reminder.careReminderID == reminderId {
                    switch reminderType {
                    case "Watering":
                        reminders[index].reminder.isWateringCompleted = isCompleted
                    case "Fertilization":
                        reminders[index].reminder.isFertilizingCompleted = isCompleted
                    case "Repotting":
                        reminders[index].reminder.isRepottingCompleted = isCompleted
                    default:
                        break
                    }
                }
            }
            
            // Reload the collection view
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
                    reminderType = "Watering"
                case 1:
                    reminderType = "Fertilization"
                case 2:
                    reminderType = "Repotting"
                default:
                    continue
                }
                
                dataController.updateCareReminderStatus(
                    for: reminder.userPlant.userPlantRelationID,
                    reminderType: reminderType,
                    isCompleted: true,
                    currentDate: currentDate
                )
            }
        }
        
        loadData()
    }
    
    // Make sure to remove observer when view controller is deallocated
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
        let dueDate: Date
        
        // Only show completion state for today's reminders
        let isToday = careReminderSegmentedControl.selectedSegmentIndex == 0
        
        switch sectionType {
        case 0:
            isCompleted = reminder.reminder.isWateringCompleted
            dueDate = reminder.reminder.upcomingReminderForWater
        case 1:
            isCompleted = reminder.reminder.isFertilizingCompleted
            dueDate = reminder.reminder.upcomingReminderForFertilizers
        case 2:
            isCompleted = reminder.reminder.isRepottingCompleted
            dueDate = reminder.reminder.upcomingReminderForRepotted
        default:
            isCompleted = false
            dueDate = Date()
        }
        
        // Check if the reminder is for tomorrow
        let isTomorrow = Calendar.current.isDateInTomorrow(dueDate)
        let isInToday = Calendar.current.isDateInToday(dueDate)
        
        // Enable checkbox for today's reminders regardless of completion status
        let shouldEnableCheckbox = isInToday || (isTomorrow && !isToday)
        
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
        let currentDate = Date()
        let isCompleted: Bool
        
        switch type {
        case 0:
            isCompleted = reminder.reminder.isWateringCompleted
            dataController.updateCareReminderStatus(
                for: reminder.userPlant.userPlantRelationID,
                reminderType: "Watering",
                isCompleted: !isCompleted,
                currentDate: currentDate
            )
        case 1:
            isCompleted = reminder.reminder.isFertilizingCompleted
            dataController.updateCareReminderStatus(
                for: reminder.userPlant.userPlantRelationID,
                reminderType: "Fertilization",
                isCompleted: !isCompleted,
                currentDate: currentDate
            )
        case 2:
            isCompleted = reminder.reminder.isRepottingCompleted
            dataController.updateCareReminderStatus(
                for: reminder.userPlant.userPlantRelationID,
                reminderType: "Repotting",
                isCompleted: !isCompleted,
                currentDate: currentDate
            )
        default:
            return
        }
        
        // Don't call loadData() here as we're handling updates in refreshAfterStatusUpdate
    }
}

