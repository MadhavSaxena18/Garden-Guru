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
    
    
    func configure(with reminderData: (userPlant: UserPlant, plant: Plant, reminder: CareReminder_)) {
        careReminderPlantImageView.image = UIImage(named: reminderData.plant.plantImage[0])
        plantNameCareReminderLabel.text = reminderData.plant.plantName
        nickNameCareReminderLabel.text = reminderData.userPlant.userPlantNickName
        let checkBoxImage = reminderData.reminder.isWateringCompleted ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
        checkBoxCareReminderButton.setImage(checkBoxImage, for: .normal)
        dueDateCareReminder.isHidden = !reminderData.reminder.isWateringCompleted
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
