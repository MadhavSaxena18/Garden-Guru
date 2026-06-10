//
//  ThemeManager.swift
//  GardenGuruXcode
//
//  Dark Mode Support
//

import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    private init() {}
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Color
        static let primary = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "3A5A3B") // Lighter green for dark mode
                : UIColor(hex: "284329") // Original green for light mode
        }
        
        // Background Colors
        static let background = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemBackground
                : UIColor.white
        }
        
        static let secondaryBackground = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.secondarySystemBackground
                : UIColor(hex: "F5F9F5")
        }
        
        static let cardBackground = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.secondarySystemBackground
                : UIColor.white
        }
        
        // Text Colors
        static let primaryText = UIColor.label
        static let secondaryText = UIColor.secondaryLabel
        static let tertiaryText = UIColor.tertiaryLabel
        
        // Border Colors
        static let border = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.separator
                : UIColor.systemGray4
        }
        
        // Shadow Colors
        static let shadow = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.3)
                : UIColor.black.withAlphaComponent(0.1)
        }
    }
    
    // MARK: - Apply Theme to View
    func applyTheme(to view: UIView) {
        view.backgroundColor = Colors.background
    }
    
    // MARK: - Card Style
    func styleCard(_ view: UIView, cornerRadius: CGFloat = 16) {
        view.backgroundColor = Colors.cardBackground
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = Colors.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 1.0
    }
    
    // MARK: - Button Style
    func stylePrimaryButton(_ button: UIButton) {
        button.backgroundColor = Colors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
    }
    
    func styleSecondaryButton(_ button: UIButton) {
        button.backgroundColor = Colors.secondaryBackground
        button.setTitleColor(Colors.primary, for: .normal)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.border.cgColor
    }
    
    // MARK: - TextField Style
    func styleTextField(_ textField: UITextField) {
        textField.backgroundColor = Colors.secondaryBackground
        textField.textColor = Colors.primaryText
        textField.layer.cornerRadius = 12
    }
}
