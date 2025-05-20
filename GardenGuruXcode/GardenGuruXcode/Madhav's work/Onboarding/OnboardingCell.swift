import UIKit

class OnboardingCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(hex: "284329")
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(hex: "284329")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
//    func configure(with slide: OnboardingSlide) {
//        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .medium)
//        imageView.image = UIImage(systemName: slide.image, withConfiguration: config)
//        titleLabel.text = slide.title
//        descriptionLabel.text = slide.description
//    }
    
    func configure(with slide: OnboardingSlide) {
        if let image = UIImage(named: slide.image) {
            // Use regular image asset
            imageView.image = image
            imageView.tintColor = nil // remove tint for normal images
            imageView.contentMode = .scaleAspectFit
        } else {
            // Try system symbol
            let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .medium)
            imageView.image = UIImage(systemName: slide.image, withConfiguration: config)
            imageView.tintColor = UIColor(hex: "284329") // your tint color for SF symbols
            imageView.contentMode = .scaleAspectFit
        }
        
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
    }
}
