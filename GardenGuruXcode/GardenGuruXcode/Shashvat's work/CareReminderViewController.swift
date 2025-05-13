import UIKit

class CareReminderViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var careReminderCollectionView: UICollectionView!
    @IBOutlet weak var careReminderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var editButton: UIBarButtonItem?
    
    private let dataController = DataControllerGG.shared
    private let reminderTypes = ["Watering", "Fertilization", "Pruning"]
    
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
        guard let firstUser = dataController.getUserSync() else { return }
        guard let userPlants = dataController.getUserPlantsSync(for: firstUser.userEmail) else { return }
        
        reminders = []
        for userPlant in userPlants {
            if let plant = dataController.getPlantSync(by: userPlant.userplantID ?? UUID()),
               let reminder = dataController.getCareRemindersSync(for: userPlant.userPlantRelationID) {
                reminders.append((userPlant: userPlant, plant: plant, reminder: reminder))
            }
        }
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
            // Watering reminders
            if let waterDate = reminder.reminder.upcomingReminderForWater {
                if calendar.isDateInToday(waterDate) && !(reminder.reminder.isWateringCompleted ?? false) {
                    todayReminders[0].append(reminder)
                } else if waterDate > currentDate && !calendar.isDateInToday(waterDate) {
                    upcomingReminders[0].append(reminder)
                }
            }
            // Fertilizing reminders
            if let fertDate = reminder.reminder.upcomingReminderForFertilizers {
                if calendar.isDateInToday(fertDate) && !(reminder.reminder.isFertilizingCompleted ?? false) {
                    todayReminders[1].append(reminder)
                } else if fertDate > currentDate && !calendar.isDateInToday(fertDate) {
                    upcomingReminders[1].append(reminder)
                }
            }
            // Pruning reminders
            if let pruneDate = reminder.reminder.upcomingReminderForRepotted {
                if calendar.isDateInToday(pruneDate) && !(reminder.reminder.isRepottingCompleted ?? false) {
                    todayReminders[2].append(reminder)
                } else if pruneDate > currentDate && !calendar.isDateInToday(pruneDate) {
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
        
        // Update UI state
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
        reminders = []
        todayReminders = [[],[],[]]
        upcomingReminders = [[],[],[]]
        guard let firstUser = dataController.getUserSync() else { return }
        guard let userPlants = dataController.getUserPlantsSync(for: firstUser.userEmail) else { return }
        
        for userPlant in userPlants {
            if let plant = dataController.getPlantSync(by: userPlant.userplantID ?? UUID()),
               let reminder = dataController.getCareRemindersSync(for: userPlant.userPlantRelationID) {
                reminders.append((userPlant: userPlant, plant: plant, reminder: reminder))
            }
        }
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
                        case "Pruning":
                            if sectionIndex == 2 {
                                todayReminders[sectionIndex][index].reminder.isRepottingCompleted = isCompleted
                            }
                        default:
                            break
                        }
                    }
                }
            }
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
                        case "Pruning":
                            if sectionIndex == 2 {
                                upcomingReminders[sectionIndex][index].reminder.isRepottingCompleted = isCompleted
                            }
                        default:
                            break
                        }
                    }
                }
            }
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
                dataController.updateCareReminderStatusSync(
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
        let isCompleted: Bool
        let reminderType: String
        
        switch type {
        case 0:
            isCompleted = reminder.reminder.isWateringCompleted ?? false
            reminderType = "water"
        case 1:
            isCompleted = reminder.reminder.isFertilizingCompleted ?? false
            reminderType = "fertilizer"
        case 2:
            isCompleted = reminder.reminder.isRepottingCompleted ?? false
            reminderType = "repot"
        default:
            return
        }
        
        dataController.updateCareReminderStatusSync(
            userPlantID: reminder.userPlant.userPlantRelationID,
            type: reminderType,
            isCompleted: !isCompleted
        )
        // Don't call loadData() here as we're handling updates in refreshAfterStatusUpdate
    }
}

