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
    
    
    func configure(with reminderData: CareReminder) {
        careReminderPlantImageView.image = UIImage(named: reminderData.plantImageName)
        plantNameCareReminderLabel.text = reminderData.plantName
        nickNameCareReminderLabel.text = reminderData.nickname
        let checkBoxImage = reminderData.isCompleted ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
        checkBoxCareReminderButton.setImage(checkBoxImage, for: .normal)
        dueDateCareReminder.isHidden = !reminderData.isCompleted
//        if isUpcoming {
//                   let formatter = DateFormatter()
//                   formatter.dateStyle = .medium
//            dueDateCareReminder.text = "Due: \(formatter.string(from: reminder.dueDate))"
//            dueDateCareReminder.isHidden = false
//               } else {
//                   dueDateCareReminder.isHidden = true
//               }
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    @IBAction func checkBoxCareReminderButtonTapped(_ sender: Any) {
        onCheckboxToggle?()
    }
    
}
