//
//  CareReminderCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit

class CareReminderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var careReminderPlantImageView: UIImageView!
    @IBOutlet weak var plantNameCareReminderLabel: UILabel!
    @IBOutlet weak var nickNameCareReminderLabel: UILabel!
  
    @IBOutlet weak var dueDateCareReminder: UILabel!
    @IBOutlet weak var checkBoxCareReminderButton: UIButton!
    
    var onCheckboxToggle: (() -> Void)?
    
    
    func configure(with reminderData: (userPlant: UserPlant, plant: Plant, reminder: CareReminder_), 
                  isCompleted: Bool, 
                  dueDate: Date, 
                  isUpcoming: Bool,
                  isTomorrow: Bool,
                  shouldEnableCheckbox: Bool) {
        careReminderPlantImageView.image = UIImage(named: reminderData.plant.plantImage[0])
        plantNameCareReminderLabel.text = reminderData.plant.plantName
        nickNameCareReminderLabel.text = reminderData.userPlant.userPlantNickName
        
        // Enable/disable checkbox based on parameter
        checkBoxCareReminderButton.isEnabled = shouldEnableCheckbox
        checkBoxCareReminderButton.alpha = shouldEnableCheckbox ? 1.0 : 0.5
        
        // Update checkbox image
        let checkBoxImage = isCompleted ? 
            UIImage(systemName: "checkmark.square.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal) :
            UIImage(systemName: "square")
        checkBoxCareReminderButton.setImage(checkBoxImage, for: .normal)
        
        // Update due date label
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if isUpcoming {
            if isTomorrow {
                dueDateCareReminder.text = "Due Tomorrow"
            } else {
                dueDateCareReminder.text = "Due: \(formatter.string(from: dueDate))"
            }
            dueDateCareReminder.textColor = .black
        } else {
            if isCompleted {
                dueDateCareReminder.text = "Completed"
                dueDateCareReminder.textColor = UIColor(hex: "004E05") // Dark green color
            } else {
                dueDateCareReminder.text = "Due Today"
                dueDateCareReminder.textColor = .black
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    @IBAction func checkBoxCareReminderButtonTapped(_ sender: Any) {
        onCheckboxToggle?()
    }
    
}
