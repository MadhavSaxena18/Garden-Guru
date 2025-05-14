import UIKit

class DiseaseDetailTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var backgroundCardView: UIView!
    
    var isExpanded: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.contentLabel.alpha = self.isExpanded ? 1.0 : 0.0
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
        backgroundCardView.clipsToBounds = true
        
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
            
            titleLabel.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -16),
            
            contentLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: -16)
        ])
        
        // Store constraints for later activation/deactivation
        contentLabelTopToTitleConstraint = contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        contentLabelTopToBackgroundConstraint = contentLabel.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 16)
        
        // Initially activate the default constraint
        contentLabelTopToTitleConstraint?.isActive = true
    }
    
    private var contentLabelTopToTitleConstraint: NSLayoutConstraint?
    private var contentLabelTopToBackgroundConstraint: NSLayoutConstraint?
    
    func configure(with disease: Diseases?, section: String, showHeader: Bool = true) {
        guard let disease = disease else {
            titleLabel.text = section
            contentLabel.text = "No information available"
            return
        }
        
        // Hide or show the title label based on showHeader parameter
        titleLabel.isHidden = !showHeader
        
        // Update constraints based on showHeader
        contentLabelTopToTitleConstraint?.isActive = showHeader
        contentLabelTopToBackgroundConstraint?.isActive = !showHeader
        
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
        
        layoutIfNeeded()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update shadow for dark mode changes
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        }
    }
} 