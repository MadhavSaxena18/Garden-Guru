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
  
    @IBOutlet weak var checkBoxCareReminderButton: UIButton!
    
    var onCheckboxToggle: (() -> Void)?
    
    
    func configure(with reminder: CareReminder) {
        careReminderPlantImageView.image = UIImage(named: reminder.plantImageName)
        plantNameCareReminderLabel.text = reminder.plantName
        nickNameCareReminderLabel.text = reminder.nickname
        
        checkBoxCareReminderButton.setImage(UIImage(systemName: reminder.isCompleted ? "checkmark.square.fill" : "square"), for: .normal)
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func checkBoxCareReminderButtonTapped(_ sender: Any) {
        onCheckboxToggle?()
    }
    
}
