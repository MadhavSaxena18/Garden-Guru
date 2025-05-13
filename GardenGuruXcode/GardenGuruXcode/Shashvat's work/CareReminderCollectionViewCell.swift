//
//  CareReminderCollectionViewCell.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit
import SDWebImage

class CareReminderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var careReminderPlantImageView: UIImageView!
    @IBOutlet weak var plantNameCareReminderLabel: UILabel!
    @IBOutlet weak var nickNameCareReminderLabel: UILabel!
  
    @IBOutlet weak var dueDateCareReminder: UILabel!
    @IBOutlet weak var checkBoxCareReminderButton: UIButton!
    
    var onCheckboxToggle: (() -> Void)?
    
    func configure(with reminderData: (userPlant: UserPlant, plant: Plant, reminder: CareReminder_), 
                  isCompleted: Bool, 
                  dueDate: Date?, 
                  isUpcoming: Bool,
                  isTomorrow: Bool,
                  shouldEnableCheckbox: Bool) {
        // Configure plant image
        if let imageUrlString = reminderData.plant.plantImage,
           let imageUrl = URL(string: imageUrlString) {
            careReminderPlantImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder_plant"))
        } else {
            careReminderPlantImageView.image = UIImage(named: "placeholder_plant")
        }
        
        // Configure plant name and nickname
        plantNameCareReminderLabel.text = reminderData.plant.plantName
        nickNameCareReminderLabel.text = reminderData.userPlant.userPlantNickName ?? reminderData.plant.plantName
        
        // Configure checkbox state
        checkBoxCareReminderButton.isEnabled = shouldEnableCheckbox
        checkBoxCareReminderButton.alpha = shouldEnableCheckbox ? 1.0 : 0.5
        
        let checkBoxImage = isCompleted ? 
            UIImage(systemName: "checkmark.square.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal) :
            UIImage(systemName: "square")
        checkBoxCareReminderButton.setImage(checkBoxImage, for: .normal)
        
        // Configure due date label
        configureDueDate(dueDate: dueDate, isCompleted: isCompleted, isUpcoming: isUpcoming, isTomorrow: isTomorrow)
    }
    
    private func configureDueDate(dueDate: Date?, isCompleted: Bool, isUpcoming: Bool, isTomorrow: Bool) {
        guard let dueDate = dueDate else {
            dueDateCareReminder.text = "Not scheduled"
            dueDateCareReminder.textColor = .gray
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if isUpcoming {
            if isTomorrow {
                dueDateCareReminder.text = "Due Tomorrow"
                dueDateCareReminder.textColor = .systemOrange
            } else {
                dueDateCareReminder.text = "Due: \(formatter.string(from: dueDate))"
                dueDateCareReminder.textColor = .systemBlue
            }
        } else {
            if isCompleted {
                dueDateCareReminder.text = "Completed"
                dueDateCareReminder.textColor = UIColor(hex: "004E05") // Dark green color
            } else {
                dueDateCareReminder.text = "Due Today"
                dueDateCareReminder.textColor = .systemRed
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
