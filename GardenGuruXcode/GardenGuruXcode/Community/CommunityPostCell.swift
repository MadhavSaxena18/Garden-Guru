//
//  CommunityPostCell.swift
//  GardenGuruXcode
//
//  Created by Garden Guru Team
//

import UIKit
import SDWebImage

class CommunityPostCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CommunityPostCell"
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = UIColor(hex: "284329")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(hex: "284329")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = UIColor(hex: "F5F9F5")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let plantNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(hex: "284329")
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(hex: "666666")
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(avatarImageView)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(timestampLabel)
        containerView.addSubview(postImageView)
        containerView.addSubview(plantNameLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // Avatar
            avatarImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // User Name
            userNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            userNameLabel.trailingAnchor.constraint(equalTo: timestampLabel.leadingAnchor, constant: -8),
            
            // Timestamp
            timestampLabel.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // Post Image
            postImageView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            postImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            postImageView.heightAnchor.constraint(equalToConstant: 300),
            
            // Plant Name
            plantNameLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 12),
            plantNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            plantNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: plantNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with post: CommunityPost) {
        // Set user name
        userNameLabel.text = post.userName ?? "Garden Guru User"
        
        // Set timestamp
        timestampLabel.text = post.relativeTimeString()
        
        // Set plant name
        plantNameLabel.text = post.plantName
        
        // Set description
        descriptionLabel.text = post.description
        
        // Load post image
        if let imageURL = URL(string: post.imageURL) {
            postImageView.sd_setImage(
                with: imageURL,
                placeholderImage: UIImage(named: "plant_placeholder"),
                options: [.progressiveLoad, .retryFailed]
            )
        }
        
        // Set avatar (use initials if no image)
        setAvatarInitials(for: post.userName ?? "GG")
    }
    
    private func setAvatarInitials(for name: String) {
        // Create initials from name
        let initials = name.components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0).uppercased() }
            .joined()
        
        // Create image with initials
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Draw background
        UIColor(hex: "284329").setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        
        // Draw initials
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.white
        ]
        
        let textSize = initials.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        initials.draw(in: textRect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        avatarImageView.image = image
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.sd_cancelCurrentImageLoad()
        postImageView.image = nil
        avatarImageView.image = nil
        userNameLabel.text = nil
        timestampLabel.text = nil
        plantNameLabel.text = nil
        descriptionLabel.text = nil
    }
}
