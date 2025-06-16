import UIKit

class DiseaseDetailTableViewCell: UITableViewCell {
    // Remove @IBOutlets
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let backgroundCardView = UIView()
    private let collapsibleContentContainer = UIView()
    private let stackView = UIStackView()
    
    var isExpanded: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.collapsibleContentContainer.isHidden = !self.isExpanded
                self.superview?.layoutIfNeeded()
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // No longer loading from XIB, but keeping for required initializer
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        // Configure background card view (outer card)
        backgroundCardView.backgroundColor = .white
        backgroundCardView.layer.cornerRadius = 12
        backgroundCardView.clipsToBounds = true
        backgroundCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundCardView)
        
        // Configure title label
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2E7D32") // Dark green color
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure content label
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.textColor = .darkGray
        contentLabel.numberOfLines = 0
        contentLabel.backgroundColor = .clear
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure collapsible content container (inner view)
        collapsibleContentContainer.backgroundColor = .white // Set initial background (can be transparent grey later)
        collapsibleContentContainer.layer.cornerRadius = 12
        collapsibleContentContainer.clipsToBounds = true
        collapsibleContentContainer.translatesAutoresizingMaskIntoConstraints = false
        collapsibleContentContainer.addSubview(contentLabel)
        
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(collapsibleContentContainer)
        
        backgroundCardView.addSubview(stackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Background Card View constraints
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            backgroundCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Stack View constraints (pinned inside backgroundCardView)
            stackView.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: -20),
            
            // Content Label constraints (pinned inside collapsibleContentContainer)
            contentLabel.topAnchor.constraint(equalTo: collapsibleContentContainer.topAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: collapsibleContentContainer.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: collapsibleContentContainer.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: collapsibleContentContainer.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with disease: Diseases?, section: String, showHeader: Bool = true) {
        // Unsafe unwrapping is fine here because setupUI() ensures they are initialized
        // The guards are for the passed `disease` object.
        guard let disease = disease else {
            titleLabel.text = section
            contentLabel.text = "No information available"
            return
        }
        
        // Hide or show the title label based on showHeader parameter
        titleLabel.isHidden = !showHeader
        
        // isExpanded property handles the collapsibleContentContainer visibility automatically
        
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
