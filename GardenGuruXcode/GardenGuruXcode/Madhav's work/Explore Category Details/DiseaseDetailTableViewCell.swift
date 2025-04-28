import UIKit

class DiseaseDetailTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var backgroundCardView: UIView!
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(hex: "#2E7D32")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var isExpanded: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.contentLabel.alpha = self.isExpanded ? 1.0 : 0.0
                self.chevronImageView.transform = self.isExpanded ? 
                    CGAffineTransform(rotationAngle: .pi/2) :
                    CGAffineTransform(rotationAngle: 0)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        // Configure background card view
        backgroundCardView.backgroundColor = .white
        backgroundCardView.layer.cornerRadius = 12
        backgroundCardView.clipsToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        backgroundCardView.layer.shadowOpacity = 0.1
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundCardView.layer.shadowRadius = 4
        
        // Configure title label
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2E7D32") // Dark green color
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        
        // Configure content label
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.textColor = .darkGray
        contentLabel.numberOfLines = 0
        contentLabel.backgroundColor = .clear
        
        // Setup chevron
        chevronImageView.image = UIImage(systemName: "chevron.right")
        backgroundCardView.addSubview(chevronImageView)
        
        // Add padding to content
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundCardView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backgroundCardView)
        backgroundCardView.addSubview(titleLabel)
        backgroundCardView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            backgroundCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            chevronImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 20),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: -16)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        backgroundCardView.addGestureRecognizer(tapGesture)
        backgroundCardView.isUserInteractionEnabled = true
    }
    
    @objc private func cellTapped() {
        isExpanded.toggle()
    }
    
    func configure(with disease: Diseases?, section: String) {
        guard let disease = disease else {
            titleLabel.text = section
            contentLabel.text = "No information available"
            return
        }
        
        titleLabel.text = section
        
        switch section {
        case "Symptoms":
            contentLabel.text = disease.diseaseSymptoms?.isEmpty == false ? disease.diseaseSymptoms : "No symptoms information available"
            
        case "Treatment":
            contentLabel.text = disease.diseaseCure?.isEmpty == false ? disease.diseaseCure : "No treatment information available"
            
        case "Prevention":
            contentLabel.text = disease.diseaseFertilizers?.isEmpty == false ? disease.diseaseFertilizers : "No prevention information available"
            
        default:
            contentLabel.text = "Information not available"
        }
        
        // Update shadow path for performance
        layoutIfNeeded()
        backgroundCardView.layer.shadowPath = UIBezierPath(roundedRect: backgroundCardView.bounds, cornerRadius: backgroundCardView.layer.cornerRadius).cgPath
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update shadow for dark mode changes
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        }
    }
} 