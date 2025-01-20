//
//  CareReminderViewController.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit

class CareReminderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var filteredReminders: [CareReminder] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let reminderTypeForSection = ReminderType.allCases[section]
          
          // Initialize a counter for the number of matching reminders
          var count = 0
          
          // Loop through all reminders
        for reminder in CareReminderData.reminders {
              // Check if the reminder matches the type and is not completed
              if reminder.type == reminderTypeForSection && !reminder.isCompleted {
                  count += 1 // Increment the counter if the conditions are met
              }
          }
          
          // Return the final count
          return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareReminderCell", for: indexPath) as? CareReminderCollectionViewCell else {
               fatalError("Unable to dequeue CareReminderCell")
           }
           
           // Get the reminder type for the current section
           let type = ReminderType.allCases[indexPath.section]
           
           // Manually collect reminders for this type and not completed
          
        for reminder in CareReminderData.reminders {
               if reminder.type == type && !reminder.isCompleted {
                   filteredReminders.append(reminder)
               }
           }
           
           // Get the reminder for the current item
          let reminder = filteredReminders[indexPath.item]
      
           // Configure the cell with the reminder
           cell.configure(with: reminder)
           
           // Handle checkbox toggle action
           cell.onCheckboxToggle = { [weak self] in
               guard let self = self else { return }
               
               // Find the index of the reminder in the original array
               if let index = CareReminderData.reminders.firstIndex(where: { $0.id == reminder.id }) {
                   CareReminderData.reminders[index].isCompleted = true // Mark as completed
                   self.careReminderCollectionView.reloadData() // Reload the collection view
               }
           }
        cell.layer.cornerRadius = 18
           return cell
        
        
//        let reminder = filteredReminders[indexPath.item]
//        let isUpcoming = careReminderSegmentedControl.selectedSegmentIndex == 1
//
//           cell.configure(with: reminder, isUpcoming: isUpcoming)
//
//           cell.onCheckboxToggle = { [weak self] in
//               guard let self = self else { return }
//               if let index = CareReminderData.reminders.firstIndex(where: { $0.id == reminder.id }) {
//                   CareReminderData.reminders[index].isCompleted = true // Mark as completed
//                   self.filteredReminders.removeAll { $0.id == reminder.id } // Remove from filtered reminders
//                   self.careReminderCollectionView.reloadData() // Reload the collection view
//               }
//           }
//
//           return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ReminderType.allCases.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CareReminderCollectionReusableView", for: indexPath) as! CareReminderCollectionReusableView
            header.headerLabel.text = CareReminderData.careReminderSectionHeaderNames[indexPath.section]
            header.headerLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            header.headerLabel.textColor = UIColor(hex: "284329")
            
        

            return header
        }
        
       print("Supplementary item is not a error")
        return UICollectionReusableView()
    }
    
    
    
    
    func generateLayout()->UICollectionViewCompositionalLayout{
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in let section: NSCollectionLayoutSection
            switch sectionIndex {
            case 0:
                section = self.generateSection1Layout()
            case 1:
                section = self.generateSection1Layout()
           
            default:
                print("error")
                return nil
                
            }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(70))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                       
           
            section.boundarySupplementaryItems = [header]
            
            return section
            
        }
        return layout
    }

    
    
    
    func generateSection1Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.2))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
       
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

    func markAllAsCompleted() {
        for index in CareReminderData.reminders.indices {
            CareReminderData.reminders[index].isCompleted = true
        }
        careReminderCollectionView.reloadData()
    }

    
    
    

    @IBOutlet weak var careReminderCollectionView: UICollectionView!
    @IBOutlet weak var careReminderSegmentedControl: UISegmentedControl!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib1 = UINib(nibName: "CareReminderCollectionViewCell", bundle: nil)
        careReminderCollectionView.register(nib1, forCellWithReuseIdentifier: "CareReminderCell")
        careReminderCollectionView.register(CareReminderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CareReminderCollectionReusableView")
        careReminderCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        careReminderCollectionView.dataSource = self
        careReminderCollectionView.delegate = self
       
        careReminderSegmentedControl.selectedSegmentIndex = 0
        filteredReminders = CareReminderData.reminders.filter {
            Calendar.current.isDateInToday($0.dueDate) && !$0.isCompleted
         
        }
        

      
    }
    

    @IBAction func editButtonCareReminderTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Edit", message: "Choose an action", preferredStyle: .actionSheet)
            
//            // Option 1: Delete all completed reminders
//            alert.addAction(UIAlertAction(title: "Delete Completed Reminders", style: .destructive, handler: { _ in
//                self.deleteCompletedReminders()
//            }))
            
            // Option 2: Mark all reminders as completed
            alert.addAction(UIAlertAction(title: "Mark All as Completed", style: .default, handler: { _ in
                self.markAllAsCompleted()
            }))
            
            // Cancel option
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // Present the alert
            present(alert, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func didChangeSegmentCareReminder(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            case 0: // Today's Reminders
                filteredReminders = CareReminderData.reminders.filter {
                    Calendar.current.isDateInToday($0.dueDate) && !$0.isCompleted
                }
            case 1: // Upcoming Reminders
                filteredReminders = CareReminderData.reminders.filter {
                    $0.dueDate > Date() && !$0.isCompleted
                }
            default:
                break
            }
        careReminderCollectionView.reloadData()
        
    }
    

}
