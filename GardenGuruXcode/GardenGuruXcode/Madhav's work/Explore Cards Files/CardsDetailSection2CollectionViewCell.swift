import UIKit

class CardsDetailSection2CollectionViewCell: UICollectionViewCell {
    private var mainStackView: UIStackView!
    private var expandedSections: Set<String> = []
    private var currentPlant: Plant?
    private var currentDisease: Diseases?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupModernLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupModernLayout()
    }
    
    private func setupModernLayout() {
        // Create main stack view
        mainStackView = UIStackView()
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func createSection(title: String, content: String, sectionId: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.08
        container.tag = sectionId.hashValue
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#1A1A1A")
        
        let contentLabel = UILabel()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        contentLabel.textColor = UIColor(hex: "#4A4A4A")
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.tag = 999 // Tag to find content label
        
        let isExpanded = expandedSections.contains(sectionId)
        
        if isExpanded {
            contentLabel.numberOfLines = 0
            contentLabel.text = content
        } else {
            contentLabel.numberOfLines = 3
            contentLabel.text = content
        }
        
        container.addSubview(titleLabel)
        container.addSubview(contentLabel)
        
        // Check if content needs "Read more" button
        let needsReadMore = content.count > 100
        
        if needsReadMore {
            let readMoreButton = UIButton(type: .system)
            readMoreButton.translatesAutoresizingMaskIntoConstraints = false
            readMoreButton.setTitle(isExpanded ? "Show less ∧" : "Read more ∨", for: .normal)
            readMoreButton.setTitleColor(UIColor(hex: "#2D5F3F"), for: .normal)
            readMoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            readMoreButton.contentHorizontalAlignment = .left
            readMoreButton.tag = 888 // Tag to identify button
            readMoreButton.addTarget(self, action: #selector(readMoreTapped(_:)), for: .touchUpInside)
            
            // Store section ID in button's accessibilityIdentifier
            readMoreButton.accessibilityIdentifier = sectionId
            
            container.addSubview(readMoreButton)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                
                contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                
                readMoreButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
                readMoreButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                readMoreButton.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
                readMoreButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
                readMoreButton.heightAnchor.constraint(equalToConstant: 20)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                
                contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                contentLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
            ])
        }
        
        return container
    }
    
    @objc private func readMoreTapped(_ sender: UIButton) {
        guard let sectionId = sender.accessibilityIdentifier else { return }
        
        // Toggle expanded state
        if expandedSections.contains(sectionId) {
            expandedSections.remove(sectionId)
        } else {
            expandedSections.insert(sectionId)
        }
        
        // Recreate the sections with updated state
        UIView.animate(withDuration: 0.3) {
            if let plant = self.currentPlant {
                self.updateCardSection2(with: plant)
            } else if let disease = self.currentDisease {
                self.updateCardSection2WithDisease(with: disease)
            }
        }
    }
    
    private func createCareGuideSection(plant: Plant) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.08
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Care Guide"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#1A1A1A")
        
        container.addSubview(titleLabel)
        
        let careItems: [(String, String, String)] = [
            ("drop.fill", "Water", "Every \(plant.waterFrequency ?? 0) days"),
            ("sun.max.fill", "Light", "Partial to full sunlight"),
            ("leaf.fill", "Soil", "Well-drained, rich soil"),
            ("scissors", "Maintenance", "Prune old stems regularly")
        ]
        
        var previousView: UIView = titleLabel
        
        for (iconName, title, detail) in careItems {
            let itemView = createCareItem(iconName: iconName, title: title, detail: detail)
            container.addSubview(itemView)
            
            NSLayoutConstraint.activate([
                itemView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 12),
                itemView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                itemView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                itemView.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            previousView = itemView
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            previousView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createCareItem(iconName: String, title: String, detail: String) -> UIView {
        let itemView = UIView()
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = UIColor(hex: "#2D5F3F")
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(hex: "#1A1A1A")
        
        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.text = detail
        detailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = UIColor(hex: "#666666")
        detailLabel.textAlignment = .right
        
        let chevron = UIImageView()
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = UIColor(hex: "#CCCCCC")
        chevron.contentMode = .scaleAspectFit
        
        itemView.addSubview(iconImageView)
        itemView.addSubview(titleLabel)
        itemView.addSubview(detailLabel)
        itemView.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: itemView.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
            
            chevron.trailingAnchor.constraint(equalTo: itemView.trailingAnchor),
            chevron.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 12),
            
            detailLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            detailLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
            detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
        
        return itemView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure proper layout
        mainStackView.layoutIfNeeded()
    }
    
    func updateCardSection2(with plant: Plant?) {
        guard let plant = plant else {
            print("Error: Plant data is nil")
            return
        }

        // Store current plant
        self.currentPlant = plant
        self.currentDisease = nil

        // Clear previous content
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Overview section
        let description = plant.plantDescription ?? "No description available"
        let overviewSection = createSection(title: "Overview", content: description, sectionId: "overview")
        mainStackView.addArrangedSubview(overviewSection)
        
        // Care Guide section
        let careSection = createCareGuideSection(plant: plant)
        mainStackView.addArrangedSubview(careSection)
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func updateCardSection2WithDisease(with disease: Diseases?) {
        guard let disease = disease else {
            return
        }

        // Store current disease
        self.currentDisease = disease
        self.currentPlant = nil

        // Clear previous content
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Symptoms section
        let symptomsText = disease.diseaseSymptoms ?? "Not specified"
        let symptomsSection = createSection(title: "Symptoms", content: symptomsText, sectionId: "symptoms")
        mainStackView.addArrangedSubview(symptomsSection)
        
        // Cure section
        let cureText = disease.diseaseCure ?? "Not specified"
        let cureSection = createSection(title: "Treatment", content: cureText, sectionId: "treatment")
        mainStackView.addArrangedSubview(cureSection)
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}
