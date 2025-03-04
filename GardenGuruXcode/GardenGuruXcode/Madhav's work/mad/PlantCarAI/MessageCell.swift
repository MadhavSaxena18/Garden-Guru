//
//  MessageCell.swift
//  ReadBuddyAi
//
//  Created by Deepanshu-Maliyan-Mac on 16/01/25.

import UIKit


class MessageCell: UITableViewCell {
    static let identifier = "MessageCell"
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15 // For 30x30 image size
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // ... existing init code ...
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
    }

    required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
    }
    
    
    private func setupUI() {
            backgroundColor = .clear
            selectionStyle = .none
            
            contentView.addSubview(profileImageView)
            contentView.addSubview(bubbleView)
            bubbleView.addSubview(messageLabel)
            
            // Base constraints that are common for both user and bot messages
            NSLayoutConstraint.activate([
                profileImageView.widthAnchor.constraint(equalToConstant: 30),
                profileImageView.heightAnchor.constraint(equalToConstant: 30),
                profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7),
                
                messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
                messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
                messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
                messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            ])
        }
        
        private var userConstraints: [NSLayoutConstraint] = []
        private var botConstraints: [NSLayoutConstraint] = []
        
        func configure(with message: Message) {
            messageLabel.text = message.content
            
            // Remove previous constraints
            NSLayoutConstraint.deactivate(userConstraints)
            NSLayoutConstraint.deactivate(botConstraints)
            
            if message.isUser {
                // User message (right side)
                bubbleView.backgroundColor = .systemBlue
                messageLabel.textColor = .white
                profileImageView.image = UIImage(systemName: "person.circle.fill")
                profileImageView.tintColor = .systemBlue
                
                userConstraints = [
                    profileImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                    bubbleView.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -8)
                ]
                NSLayoutConstraint.activate(userConstraints)
                
            } else {
                // Bot message (left side)
                bubbleView.backgroundColor = .systemGray5
                messageLabel.textColor = .black
                profileImageView.image = UIImage(systemName: "brain.head.profile")
                profileImageView.tintColor = .systemGray
                
                botConstraints = [
                    profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                    bubbleView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8)
                ]
                NSLayoutConstraint.activate(botConstraints)
            }
            
            layoutIfNeeded()
        }
    }

