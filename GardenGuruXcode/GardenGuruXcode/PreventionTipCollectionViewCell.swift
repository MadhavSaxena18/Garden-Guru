import UIKit
import SDWebImage

class PreventionTipCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let tipImageView = UIImageView()
    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let textStackView = UIStackView()
    private let textContainerView = UIView()
    private let bottomOverlayLayer = CAGradientLayer()
    
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
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.15
        layer.masksToBounds = false
        
        // Image View - takes full card
        tipImageView.contentMode = .scaleAspectFill
        tipImageView.clipsToBounds = true
        contentView.addSubview(tipImageView)
        
        // Gradient overlay for text readability
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.78).cgColor
        ]
        gradientLayer.locations = [0.45, 1.0]
        tipImageView.layer.addSublayer(gradientLayer)
        
        // Stack View for text - positioned at bottom
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.distribution = .fill
        
        // Professional and simple: smooth bottom fade under text, no boxed card feel.
        textContainerView.backgroundColor = .clear
        textContainerView.layer.cornerRadius = 0
        textContainerView.layer.masksToBounds = true
        contentView.addSubview(textContainerView)
        bottomOverlayLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.24).cgColor
        ]
        bottomOverlayLayer.locations = [0.0, 1.0]
        textContainerView.layer.insertSublayer(bottomOverlayLayer, at: 0)
        textContainerView.addSubview(textStackView)
        
        // Title Label - single line
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleLabel.layer.shadowRadius = 2
        titleLabel.layer.shadowOpacity = 0.35
        textStackView.addArrangedSubview(titleLabel)
        
        // Message Label - only 2 lines with ellipsis
        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = .white.withAlphaComponent(0.95)
        messageLabel.numberOfLines = 2
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.layer.shadowColor = UIColor.black.cgColor
        messageLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        messageLabel.layer.shadowRadius = 2
        messageLabel.layer.shadowOpacity = 0.32
        textStackView.addArrangedSubview(messageLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        tipImageView.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Image View constraints (fills entire cell)
            tipImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tipImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tipImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tipImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Text container constraints
            textContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Text stack constraints inside container
            textStackView.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: 20),
            textStackView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 20),
            textStackView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -20),
            textStackView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -18)
        ])
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient frame to match image view
        gradientLayer.frame = tipImageView.bounds
        bottomOverlayLayer.frame = textContainerView.bounds
    }
    
    // MARK: - Configure
    func configure(with title: String, message: String, imageUrl: URL?) {
        titleLabel.text = title
        messageLabel.text = message
        
        // Clean and load image using SDWebImage
        if let urlString = imageUrl?.absoluteString, let cleanUrlString = urlString.replacingOccurrences(of: "//01", with: "/01").replacingOccurrences(of: "//", with: "/").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let finalImageUrl = URL(string: cleanUrlString) {
            print("Attempting to load image from URL: \(finalImageUrl.absoluteString)")
            tipImageView.sd_setImage(with: finalImageUrl, placeholderImage: UIImage(systemName: "photo"))
        } else {
            print("Image URL is nil or malformed for title: \(title)")
            tipImageView.image = UIImage(systemName: "photo")
        }
    }
    
    // MARK: - Reuse Preparation
    override func prepareForReuse() {
        super.prepareForReuse()
        tipImageView.sd_cancelCurrentImageLoad()
        tipImageView.image = nil
        titleLabel.text = nil
        messageLabel.text = nil
    }
}
