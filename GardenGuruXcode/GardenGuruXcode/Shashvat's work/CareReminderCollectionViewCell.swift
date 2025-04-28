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
    
    
    func configure(with reminder: CareReminder_,
                  isUpcoming: Bool,
                  isTomorrow: Bool,
                  shouldEnableCheckbox: Bool) {
        
        // Set plant image (using a placeholder since CareReminder_ doesn't have plant info)
        careReminderPlantImageView.image = UIImage(named: "placeholder_plant")
        
        // Set plant name and nickname (using placeholders since CareReminder_ doesn't have plant info)
        plantNameCareReminderLabel.text = "Plant Care Reminder"
        nickNameCareReminderLabel.text = "Care Task"
        
        // Enable/disable checkbox based on parameter
        checkBoxCareReminderButton.isEnabled = shouldEnableCheckbox
        
        // Set checkbox state based on completion status
        let isCompleted: Bool
        if let wateringCompleted = reminder.isWateringCompleted {
            isCompleted = wateringCompleted
        } else if let fertilizingCompleted = reminder.isFertilizingCompleted {
            isCompleted = fertilizingCompleted
        } else if let repottingCompleted = reminder.isRepottingCompleted {
            isCompleted = repottingCompleted
        } else {
            isCompleted = false
        }
        
        checkBoxCareReminderButton.isSelected = isCompleted
        
        // Set due date
        let dueDate: Date
        if let fertilizingDate = reminder.upcomingReminderForFertilizers {
            dueDate = fertilizingDate
        } else if let repottingDate = reminder.upcomingReminderForRepotted {
            dueDate = repottingDate
        } else {
            dueDate = reminder.upcomingReminderForWater
        }
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dueDateCareReminder.text = dateFormatter.string(from: dueDate)
        
        // Update UI based on completion status
        updateUIForCompletionStatus(isCompleted)
    }
    
    private func updateUIForCompletionStatus(_ isCompleted: Bool) {
        // Update visual appearance based on completion status
        checkBoxCareReminderButton.isSelected = isCompleted
        // Add any additional UI updates here
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    @IBAction func checkBoxCareReminderButtonTapped(_ sender: Any) {
        onCheckboxToggle?()
    }
    
}
