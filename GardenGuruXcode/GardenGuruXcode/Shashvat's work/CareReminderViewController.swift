//
//  CareReminderViewController.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit

class CareReminderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
  
    
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
           var filteredReminders: [CareReminder] = []
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
           
           return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ReminderType.allCases.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MySpaceHeaderCollectionReusableView", for: indexPath) as! CareReminderCollectionReusableView
            header.headerLabel.text = CareReminderData.careReminderSectionHeaderNames[indexPath.section]
            header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
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
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(20))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                       
           
            section.boundarySupplementaryItems = [header]
            
            return section
            
        }
        return layout
    }

    
    
    
    func generateSection1Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(290))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
       
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        group.interItemSpacing = .fixed(15)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
       
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

      
    }
    

    

}
