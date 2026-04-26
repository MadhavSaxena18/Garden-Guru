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
        selectionStyle = .none
        
        // Configure background card view (outer card)
        backgroundCardView.backgroundColor = .white
        backgroundCardView.layer.cornerRadius = 16
        backgroundCardView.clipsToBounds = true
        backgroundCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundCardView)
        
        // Configure title label
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure content label
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentLabel.numberOfLines = 0
        contentLabel.backgroundColor = .clear
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure collapsible content container (inner view)
        collapsibleContentContainer.backgroundColor = .clear
        collapsibleContentContainer.translatesAutoresizingMaskIntoConstraints = false
        collapsibleContentContainer.addSubview(contentLabel)
        
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(collapsibleContentContainer)
        
        backgroundCardView.addSubview(stackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Background Card View constraints
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            backgroundCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Stack View constraints (pinned inside backgroundCardView)
            stackView.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: -16),
            
            // Content Label constraints (pinned inside collapsibleContentContainer)
            contentLabel.topAnchor.constraint(equalTo: collapsibleContentContainer.topAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: collapsibleContentContainer.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: collapsibleContentContainer.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: collapsibleContentContainer.bottomAnchor)
        ])
    }
    
    func configure(with disease: Diseases?, section: String, showHeader: Bool = true) {
        guard let disease = disease else {
            contentLabel.text = "No information available"
            return
        }
        
        switch section {
        case "Symptoms":
            contentLabel.text = disease.diseaseSymptoms?.isEmpty == false ? disease.diseaseSymptoms : "No symptoms information available"
        case "Causes":
            contentLabel.text = "(Add more causes info if available)"
        case "Vitamins Required":
            contentLabel.text = disease.diseaseVitaminsRequired?.isEmpty == false ? disease.diseaseVitaminsRequired : "No vitamins information available"
        case "Treatment":
            contentLabel.text = "(Add more treatment info if available)"
        case "Cure":
            contentLabel.text = disease.diseaseCure?.isEmpty == false ? disease.diseaseCure : "No cure information available"
        case "Fertilizers":
            contentLabel.text = disease.diseaseFertilizers?.isEmpty == false ? disease.diseaseFertilizers : "No fertilizers information available"
        case "Prevention":
            var preventionText = ""
            if let measures = disease.diseasePreventiveMeasures, !measures.isEmpty {
                preventionText += measures
            }
            contentLabel.text = preventionText.isEmpty ? "No prevention information available" : preventionText
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
