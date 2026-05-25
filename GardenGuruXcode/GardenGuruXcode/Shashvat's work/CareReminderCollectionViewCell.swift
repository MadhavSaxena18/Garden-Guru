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
    
    private var checkBoxButton: UIButton!
    var onCheckboxToggle: (() -> Void)?
    private var isCheckboxEnabled = false
    
    // Expose checkbox for animation purposes
    var checkbox: UIButton? {
        return checkBoxButton
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCheckboxButton()
    }
    
    private func setupCheckboxButton() {
        // Remove existing button if any
        checkBoxButton?.removeFromSuperview()
        
        // Create button
        checkBoxButton = UIButton(type: .custom)
        checkBoxButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkBoxButton)
        
        // Configure button appearance
        checkBoxButton.backgroundColor = .clear
        checkBoxButton.tintColor = .systemGreen
        checkBoxButton.contentMode = .center
        checkBoxButton.layer.zPosition = 999
        
        // Add constraints for button
        NSLayoutConstraint.activate([
            checkBoxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBoxButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkBoxButton.widthAnchor.constraint(equalToConstant: 30),
            checkBoxButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Configure touch handling
        checkBoxButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        checkBoxButton.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        checkBoxButton.addTarget(self, action: #selector(buttonTouchUpOutside(_:)), for: .touchUpOutside)
    }
    
    func configure(with reminderData: (userPlant: UserPlant, plant: Plant, reminder: CareReminder_),
                isCompleted: Bool,
                dueDate: Date?,
                isUpcoming: Bool,
                isTomorrow: Bool,
                shouldEnableCheckbox: Bool) {
        
        // Reset cell state (animation will handle the transition)
        self.alpha = 1.0
        self.transform = .identity
        
        // Prefer userPlantImage if available, else fallback to plantImage
        if let userImageUrlString = reminderData.userPlant.userPlantImage, !userImageUrlString.isEmpty,
           let userImageUrl = URL(string: userImageUrlString) {
            careReminderPlantImageView.sd_setImage(with: userImageUrl, placeholderImage: UIImage(named: "placeholder_plant"))
        } else if let plantImageUrlString = reminderData.plant.plantImage, !plantImageUrlString.isEmpty,
                  let plantImageUrl = URL(string: plantImageUrlString) {
            careReminderPlantImageView.sd_setImage(with: plantImageUrl, placeholderImage: UIImage(named: "placeholder_plant"))
        } else {
            careReminderPlantImageView.image = UIImage(named: "placeholder_plant")
        }
        
        // Configure plant name and nickname
        plantNameCareReminderLabel.text = reminderData.plant.plantName
        nickNameCareReminderLabel.text = reminderData.userPlant.userPlantNickName ?? reminderData.plant.plantName
        
        // Hide checkbox for upcoming reminders
        checkBoxButton.isHidden = isUpcoming
        
        // Configure checkbox state and appearance only if not hidden
        if !isUpcoming {
            isCheckboxEnabled = shouldEnableCheckbox
            checkBoxButton.isEnabled = shouldEnableCheckbox
            checkBoxButton.isUserInteractionEnabled = shouldEnableCheckbox
            checkBoxButton.alpha = shouldEnableCheckbox ? 1.0 : 0.5
            
            // Configure checkbox image with proper sizing
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .medium)
            let checkBoxImage = isCompleted ? 
                UIImage(systemName: "checkmark.square.fill", withConfiguration: config)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal) :
                UIImage(systemName: "square", withConfiguration: config)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            
            checkBoxButton.setImage(checkBoxImage, for: .normal)
            checkBoxButton.isExclusiveTouch = true
        }
        
        // Configure due date label with appropriate color and text
        configureDueDate(dueDate: dueDate, isCompleted: isCompleted, isUpcoming: isUpcoming, isTomorrow: isTomorrow)
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        guard isCheckboxEnabled else { return }
        
        // Bounce animation on touch
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        })
    }
    
    @objc private func buttonTouchUpInside(_ sender: UIButton) {
        guard isCheckboxEnabled else { return }
        
        // Spring back with bounce
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            sender.transform = .identity
        })
        
        // Trigger the callback
        onCheckboxToggle?()
    }
    
    @objc private func buttonTouchUpOutside(_ sender: UIButton) {
        guard isCheckboxEnabled else { return }
        
        // Return to normal if touch moved outside
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            sender.transform = .identity
        })
    }
    
    private func configureDueDate(dueDate: Date?, isCompleted: Bool, isUpcoming: Bool, isTomorrow: Bool) {
        guard let dueDate = dueDate else {
            dueDateCareReminder.text = "No upcoming reminder"
            dueDateCareReminder.textColor = .gray
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDateStart = calendar.startOfDay(for: dueDate)
        
        if isUpcoming {
            if isTomorrow {
                dueDateCareReminder.text = "Due Tomorrow"
                dueDateCareReminder.textColor = .systemOrange
            } else {
                let daysUntil = calendar.dateComponents([.day], from: today, to: dueDateStart).day ?? 0
                if daysUntil <= 7 {
                    dueDateCareReminder.text = "Due in \(daysUntil) day\(daysUntil == 1 ? "" : "s")"
                    dueDateCareReminder.textColor = .systemOrange
                } else {
                    dueDateCareReminder.text = "Due: \(formatter.string(from: dueDate))"
                    dueDateCareReminder.textColor = .systemBlue
                }
            }
        } else {
            if isCompleted {
                dueDateCareReminder.text = "Completed Today"
                dueDateCareReminder.textColor = UIColor(hex: "004E05") // Dark green color
            } else {
                // Calculate how many days overdue
                let daysOverdue = calendar.dateComponents([.day], from: dueDateStart, to: today).day ?? 0
                
                if daysOverdue == 0 {
                    dueDateCareReminder.text = "Due Today"
                    dueDateCareReminder.textColor = .systemOrange
                } else if daysOverdue == 1 {
                    dueDateCareReminder.text = "Due Yesterday"
                    dueDateCareReminder.textColor = .systemRed
                } else {
                    dueDateCareReminder.text = "Due \(daysOverdue) days ago"
                    dueDateCareReminder.textColor = .systemRed
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkBoxButton.transform = .identity
        
        // Reset alpha and transform for cell reuse
        self.alpha = 1.0
        self.transform = .identity
        
        // Remove any lingering whisper labels
        for subview in self.subviews {
            if subview is UILabel && subview != plantNameCareReminderLabel && subview != nickNameCareReminderLabel && subview != dueDateCareReminder {
                subview.removeFromSuperview()
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let buttonFrame = checkBoxButton?.frame,
           buttonFrame.contains(point) {
            return checkBoxButton
        }
        return super.hitTest(point, with: event)
    }
}
