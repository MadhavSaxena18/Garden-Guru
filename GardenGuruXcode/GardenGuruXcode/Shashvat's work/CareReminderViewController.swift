
import UIKit

class CareReminderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    var filteredReminders: [CareReminder] = []
    @IBOutlet weak var careReminderCollectionView: UICollectionView!
    @IBOutlet weak var careReminderSegmentedControl: UISegmentedControl!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupSegmentedControl()
        
        // Load initial reminders (Today's Reminders by default)
        filterReminders()
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
        switch careReminderSegmentedControl.selectedSegmentIndex {
        case 0: // Today's Reminders
            filteredReminders = CareReminderData.reminders.filter {
                Calendar.current.isDateInToday($0.dueDate)
            }
        case 1: // Upcoming Reminders
            filteredReminders = CareReminderData.reminders.filter {
                $0.dueDate > Date() 
            }
        default:
            filteredReminders = []
            break
        }
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
//        for index in CareReminderData.reminders.indices {
//            CareReminderData.reminders[index].isCompleted = true
//        }
//        filterReminders()
        
//        switch careReminderSegmentedControl.selectedSegmentIndex {
//           case 0: // Today's Reminders
//               CareReminderData.reminders = CareReminderData.reminders.map {
//                   if Calendar.current.isDateInToday($0.dueDate) {
//                       var updatedReminder = $0
//                       updatedReminder.isCompleted = true
//                       return updatedReminder
//                   }
//                   return $0
//               }
//           case 1: // Upcoming Reminders
//               CareReminderData.reminders = CareReminderData.reminders.map {
//                   if $0.dueDate > Date() {
//                       var updatedReminder = $0
//                       updatedReminder.isCompleted = true
//                       return updatedReminder
//                   }
//                   return $0
//               }
//           default:
//               break
//           }
        for reminder in filteredReminders {
                if let index = CareReminderData.reminders.firstIndex(where: { $0.id == reminder.id }) {
                    CareReminderData.reminders[index].isCompleted = true
                }
            }
           
           // Refresh the filtered reminders and update the collection view
           filterReminders()
    }
    
    // MARK: - Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ReminderType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = ReminderType.allCases[section]
        return filteredReminders.filter { $0.type == type }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareReminderCell",
            for: indexPath
        ) as? CareReminderCollectionViewCell else {
            fatalError("Unable to dequeue CareReminderCell")
        }
        
//         Get the reminders for the current section
        let type = ReminderType.allCases[indexPath.section]
        let remindersForType = filteredReminders.filter { $0.type == type }
        let reminder = remindersForType[indexPath.item]
//        let reminder = filteredReminders[indexPath.item]
        // Configure the cell
        cell.configure(with: reminder)
        
        // Handle checkbox toggle action
        cell.onCheckboxToggle = { [weak self] in
            guard let self = self else { return }
            
            // Find the index of the reminder in the original array
            if let index = CareReminderData.reminders.firstIndex(where: { $0.id == reminder.id }) {
                CareReminderData.reminders[index].isCompleted.toggle() // Mark as completed
                self.filterReminders() // Reload filtered reminders
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
            
            header.headerLabel.text = CareReminderData.careReminderSectionHeaderNames[indexPath.section]
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

    
//    func deleteCompletedReminders() {
//        CareReminderData.reminders.removeAll { $0.isCompleted }
//        careReminderCollectionView.reloadData()
//    }

//    func markAllAsCompleted() {
//        for index in CareReminderData.reminders.indices {
//            CareReminderData.reminders[index].isCompleted = true
//        }
//        careReminderCollectionView.reloadData()
//    }

    
    
    

//    @IBOutlet weak var careReminderCollectionView: UICollectionView!
//    @IBOutlet weak var careReminderSegmentedControl: UISegmentedControl!
//    
//   
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let nib1 = UINib(nibName: "CareReminderCollectionViewCell", bundle: nil)
////        print(careReminderCollectionView == nil ? "careReminderCollectionView is nil" : "careReminderCollectionView is initialized")
//        
//        careReminderCollectionView.register(nib1, forCellWithReuseIdentifier: "CareReminderCell")
//        careReminderCollectionView.register(CareReminderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CareReminderCollectionReusableView")
//        careReminderCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
//        careReminderCollectionView.dataSource = self
//        careReminderCollectionView.delegate = self
//       
//        careReminderSegmentedControl.selectedSegmentIndex = 0
//        filteredReminders = CareReminderData.reminders.filter {
//            Calendar.current.isDateInToday($0.dueDate) && !$0.isCompleted
//         
//        }
//        
//
//      
//    }
//    
//
//    @IBAction func editButtonCareReminderTapped(_ sender: UIBarButtonItem) {
//        
//        let alert = UIAlertController(title: "Edit", message: "Choose an action", preferredStyle: .actionSheet)
//            
////            // Option 1: Delete all completed reminders
////            alert.addAction(UIAlertAction(title: "Delete Completed Reminders", style: .destructive, handler: { _ in
////                self.deleteCompletedReminders()
////            }))
//            
//            // Option 2: Mark all reminders as completed
//            alert.addAction(UIAlertAction(title: "Mark All as Completed", style: .default, handler: { _ in
//                self.markAllAsCompleted()
//            }))
//            
//            // Cancel option
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            
//            // Present the alert
//            present(alert, animated: true, completion: nil)
//        
//    }
//    
//    
//    
//    @IBAction func didChangeSegmentCareReminder(_ sender: UISegmentedControl) {
//        
//        switch sender.selectedSegmentIndex {
//            case 0: // Today's Reminders
//                filteredReminders = CareReminderData.reminders.filter {
//                    Calendar.current.isDateInToday($0.dueDate) && !$0.isCompleted
//                }
//            case 1: // Upcoming Reminders
//                filteredReminders = CareReminderData.reminders.filter {
//                    $0.dueDate > Date() && !$0.isCompleted
//                }
//            default:
//                break
//            }
//        careReminderCollectionView.reloadData()
//        
//    }
//    
//
//
//}
//
