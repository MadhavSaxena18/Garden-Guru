//
//  ReminderCell.swift
//  GardenGuruXcode
//
//  Created by Nikhil Gupta on 21/01/25.


import Foundation
import UIKit

class ReminderCell: UITableViewCell {
    
    private let cardView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    private let timePicker = UIDatePicker()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.tintColor = .systemGreen
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        timePicker.datePickerMode = .time
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.isHidden = true
        
        contentView.addSubview(cardView)
        cardView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(toggleSwitch)
        cardView.addSubview(timePicker)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            timePicker.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            timePicker.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }
    
    func configure(title: String, subtitle: String, iconName: String, isTimePicker: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
      // iconImageView.image = UIImage(systemName: iconName)
        iconImageView.image = UIImage(named: iconName)
        
        toggleSwitch.isHidden = isTimePicker
        timePicker.isHidden = !isTimePicker
    }
}


