import UIKit
import SDWebImage

class PreventionTipCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let tipImageView = UIImageView()
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let titleLabel = UILabel()
    
    static let reuseIdentifier = "PreventionTipCollectionViewCell"
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        // Clear existing subviews if any (important for programmatic setup in reusable cells)
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Card styling
        contentView.layer.cornerRadius = 11
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        
        // Image View
        tipImageView.contentMode = .scaleAspectFill
        tipImageView.clipsToBounds = true
        contentView.addSubview(tipImageView)
        
        // Visual Effect View (Blur) - reduced height since only showing title
        visualEffectView.clipsToBounds = true
        visualEffectView.contentView.backgroundColor = .clear // Ensure blur is visible
        contentView.addSubview(visualEffectView)
        
        // Title Label - add directly to blur view's content view
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18) // Increased font size for better visibility
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        visualEffectView.contentView.addSubview(titleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        tipImageView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Image View constraints (fills entire cell)
            tipImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tipImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tipImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tipImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Visual Effect View constraints (pinned to bottom with reduced height for title only)
            visualEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            visualEffectView.heightAnchor.constraint(equalToConstant: 40), // Reduced from 60 to 40 since only showing title

            // Title Label constraints (centered in blur view with padding)
            titleLabel.centerXAnchor.constraint(equalTo: visualEffectView.contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: visualEffectView.contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: visualEffectView.contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: visualEffectView.contentView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set preferredMaxLayoutWidth for title
        let textWidth = bounds.width - 32 // Cell width - leading padding - trailing padding
        titleLabel.preferredMaxLayoutWidth = textWidth
    }
    
    // MARK: - Configure
    func configure(with title: String, message: String, imageUrl: URL?) {
        titleLabel.text = title
        // Message is no longer displayed in the cell - only shown on detail page
        
        // Set preferredMaxLayoutWidth for title
        let textWidth = bounds.width - 32 // Cell width - leading padding - trailing padding
        titleLabel.preferredMaxLayoutWidth = textWidth
        
        // Clean and load image using SDWebImage
        if let urlString = imageUrl?.absoluteString, let cleanUrlString = urlString.replacingOccurrences(of: "//01", with: "/01").replacingOccurrences(of: "//", with: "/").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let finalImageUrl = URL(string: cleanUrlString) {
            print("Attempting to load image from URL: \(finalImageUrl.absoluteString)")
            tipImageView.sd_setImage(with: finalImageUrl, placeholderImage: UIImage(systemName: "photo")) // Using system symbol as placeholder
        } else {
            print("Image URL is nil or malformed for title: \(title)")
            tipImageView.image = UIImage(systemName: "photo") // Show placeholder if URL is nil or invalid
        }
    }
    
    // MARK: - Reuse Preparation
    override func prepareForReuse() {
        super.prepareForReuse()
        tipImageView.sd_cancelCurrentImageLoad() // Cancel ongoing image loads
        tipImageView.image = nil
        titleLabel.text = nil
        // Message label is no longer used
    }
} 
 