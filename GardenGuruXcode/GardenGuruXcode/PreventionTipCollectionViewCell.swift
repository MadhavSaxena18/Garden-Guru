import UIKit
import SDWebImage

class PreventionTipCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let tipImageView = UIImageView()
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let textStackView = UIStackView()
    
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
        
        // Visual Effect View (Blur)
        visualEffectView.clipsToBounds = true
        visualEffectView.contentView.backgroundColor = .clear // Ensure blur is visible
        contentView.addSubview(visualEffectView)
        
        // Stack View for text
        textStackView.axis = .vertical
        textStackView.spacing = 4 // Increased spacing to add space between heading and text
        textStackView.distribution = .fill
        visualEffectView.contentView.addSubview(textStackView) // Add to blur view's contentView
        
        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1 // Limit title to a single line
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        textStackView.addArrangedSubview(titleLabel)
        
        // Message Label
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 2 // Limit message to two lines
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        messageLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        textStackView.addArrangedSubview(messageLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        tipImageView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Image View constraints (fills entire cell)
            tipImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tipImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tipImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tipImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Visual Effect View constraints (pinned to bottom with fixed height)
            visualEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            visualEffectView.heightAnchor.constraint(equalToConstant: 60), // Further reduced height for blur

            // Text Stack View constraints (horizontally padded and vertically centered within the blur view's contentView)
            textStackView.centerXAnchor.constraint(equalTo: visualEffectView.contentView.centerXAnchor),
            textStackView.centerYAnchor.constraint(equalTo: visualEffectView.contentView.centerYAnchor),
            textStackView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set preferredMaxLayoutWidth here after the cell's bounds are established
        let textWidth = bounds.width - 32 // Cell width - leading padding - trailing padding
        titleLabel.preferredMaxLayoutWidth = textWidth
        messageLabel.preferredMaxLayoutWidth = textWidth
        
        // Temporarily add background colors for debugging
        // titleLabel.backgroundColor = .red.withAlphaComponent(0.3)
        // messageLabel.backgroundColor = .blue.withAlphaComponent(0.3)
        // textStackView.backgroundColor = .green.withAlphaComponent(0.3)
        // visualEffectView.contentView.backgroundColor = .yellow.withAlphaComponent(0.3)
    }
    
    // MARK: - Configure
    func configure(with title: String, message: String, imageUrl: URL?) {
        titleLabel.text = title
        messageLabel.text = message
        
        // Set preferredMaxLayoutWidth here after the cell's bounds are established
        let textWidth = bounds.width - 32 // Cell width - leading padding - trailing padding
        titleLabel.preferredMaxLayoutWidth = textWidth
        messageLabel.preferredMaxLayoutWidth = textWidth
        
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
        messageLabel.text = nil
        
        // Remove temporary background colors on reuse
        // titleLabel.backgroundColor = nil
        // messageLabel.backgroundColor = nil
        // textStackView.backgroundColor = nil
        // visualEffectView.contentView.backgroundColor = nil
    }
} 
 