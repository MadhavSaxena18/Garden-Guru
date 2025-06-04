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
    private var debugView: UIView? // For debugging touch area
    var onCheckboxToggle: (() -> Void)?
    private var isCheckboxEnabled = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("\n=== Setting up Care Reminder Cell ===")
        setupCheckboxButton()
        
        // Debug: Add tap gesture to cell
        let cellTap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        self.addGestureRecognizer(cellTap)
    }
    
    private func setupCheckboxButton() {
        // Remove existing button if any
        checkBoxButton?.removeFromSuperview()
        debugView?.removeFromSuperview()
        
        // Create button
        checkBoxButton = UIButton(type: .custom)
        checkBoxButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkBoxButton)
        
        // Configure button appearance
        checkBoxButton.backgroundColor = .clear
        checkBoxButton.tintColor = .systemGreen
        checkBoxButton.contentMode = .center
        
        // Make sure the button is above other views
        checkBoxButton.layer.zPosition = 999
        
        // Add constraints for button
        NSLayoutConstraint.activate([
            // Button constraints
            checkBoxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBoxButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkBoxButton.widthAnchor.constraint(equalToConstant: 30),
            checkBoxButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Configure touch handling
        checkBoxButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        checkBoxButton.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        checkBoxButton.addTarget(self, action: #selector(buttonTouchUpOutside(_:)), for: .touchUpOutside)
        
        print("✅ Checkbox button setup complete")
    }
    
    @objc private func cellTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        print("📱 Cell tapped at: \(location)")
        
        if let buttonFrame = checkBoxButton?.frame {
            print("🔲 Button frame: \(buttonFrame)")
            if buttonFrame.contains(location) {
                print("✅ Tap was within button bounds")
            } else {
                print("❌ Tap was outside button bounds")
            }
        }
    }
    
    func configure(with reminderData: (userPlant: UserPlant, plant: Plant, reminder: CareReminder_), 
                  isCompleted: Bool, 
                  dueDate: Date?, 
                  isUpcoming: Bool,
                  isTomorrow: Bool,
                  shouldEnableCheckbox: Bool) {
        
        print("\n=== Configuring Care Reminder Cell ===")
        print("Plant: \(reminderData.plant.plantName)")
        print("Is Completed: \(isCompleted)")
        print("Should Enable Checkbox: \(shouldEnableCheckbox)")
        
        if let imageUrlString = reminderData.plant.plantImage,
           let imageUrl = URL(string: imageUrlString) {
            careReminderPlantImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder_plant"))
        } else {
            careReminderPlantImageView.image = UIImage(named: "placeholder_plant")
        }
        
        // Configure plant name and nickname
        plantNameCareReminderLabel.text = reminderData.plant.plantName
        nickNameCareReminderLabel.text = reminderData.userPlant.userPlantNickName ?? reminderData.plant.plantName
        
        // Configure checkbox state and appearance
        isCheckboxEnabled = shouldEnableCheckbox
        checkBoxButton.isEnabled = shouldEnableCheckbox
        checkBoxButton.isUserInteractionEnabled = shouldEnableCheckbox
        checkBoxButton.alpha = shouldEnableCheckbox ? 1.0 : 0.5

        // Hide checkbox if in Upcoming section
        checkBoxButton.isHidden = isUpcoming
        
        // Configure checkbox image with proper sizing
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .medium)
        let checkBoxImage = isCompleted ? 
            UIImage(systemName: "checkmark.square.fill", withConfiguration: config)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal) :
            UIImage(systemName: "square", withConfiguration: config)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        
        checkBoxButton.setImage(checkBoxImage, for: .normal)
        
        // Ensure the button is properly configured for touch
        checkBoxButton.isExclusiveTouch = true
        
        print("Checkbox state:")
        print("- Enabled: \(checkBoxButton.isEnabled)")
        print("- User Interaction: \(checkBoxButton.isUserInteractionEnabled)")
        print("- Alpha: \(checkBoxButton.alpha)")
        print("- Image: \(isCompleted ? "checkmark.square.fill" : "square")")
        print("- Frame: \(checkBoxButton.frame)")
        
        // Configure due date label with appropriate color and text
        configureDueDate(dueDate: dueDate, isCompleted: isCompleted, isUpcoming: isUpcoming, isTomorrow: isTomorrow)
        
        print("=== Cell Configuration Complete ===\n")
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        print("👆 Button touch down")
        guard isCheckboxEnabled else { 
            print("❌ Button is disabled")
            return 
        }
        
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUpInside(_ sender: UIButton) {
        print("✅ Button touch up inside")
        guard isCheckboxEnabled else { 
            print("❌ Button is disabled")
            return 
        }
        
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
        onCheckboxToggle?()
    }
    
    @objc private func buttonTouchUpOutside(_ sender: UIButton) {
        print("❌ Button touch up outside")
        guard isCheckboxEnabled else { return }
        
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    private func configureDueDate(dueDate: Date?, isCompleted: Bool, isUpcoming: Bool, isTomorrow: Bool) {
        guard let dueDate = dueDate else {
            dueDateCareReminder.text = "No upcoming reminder"
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkBoxButton.transform = .identity
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("🎯 Hit test at point: \(point)")
        if let buttonFrame = checkBoxButton?.frame,
           buttonFrame.contains(point) {
            print("✅ Hit test found button")
            return checkBoxButton
        }
        return super.hitTest(point, with: event)
    }
}
