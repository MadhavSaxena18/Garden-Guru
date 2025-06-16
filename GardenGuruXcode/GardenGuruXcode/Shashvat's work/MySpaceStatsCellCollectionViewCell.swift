import UIKit

protocol MySpaceStatsCellDelegate: AnyObject {
    func didTapStat(category: String)
}

class MySpaceStatsCell: UICollectionViewCell {
    weak var delegate: MySpaceStatsCellDelegate?
    var selectedCategory: String = "All"
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "284329")
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Overview"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gridContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let leftStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let rightStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var statViewsRefs: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        containerView.addSubview(gridContainer)
        gridContainer.addSubview(leftStackView)
        gridContainer.addSubview(rightStackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            gridContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            gridContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            gridContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            gridContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            leftStackView.topAnchor.constraint(equalTo: gridContainer.topAnchor),
            leftStackView.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor),
            leftStackView.bottomAnchor.constraint(equalTo: gridContainer.bottomAnchor),
            leftStackView.widthAnchor.constraint(equalTo: gridContainer.widthAnchor, multiplier: 0.48),
            
            rightStackView.topAnchor.constraint(equalTo: gridContainer.topAnchor),
            rightStackView.trailingAnchor.constraint(equalTo: gridContainer.trailingAnchor),
            rightStackView.bottomAnchor.constraint(equalTo: gridContainer.bottomAnchor),
            rightStackView.widthAnchor.constraint(equalTo: gridContainer.widthAnchor, multiplier: 0.48)
        ])
        
        // Update stack view spacing
        leftStackView.spacing = 12
        rightStackView.spacing = 12
    }
    
    private func createStatView(title: String, value: Int, icon: String, isTotal: Bool = false, isSelected: Bool = false) -> UIView {
        let container = UIView()
        if isSelected {
            container.backgroundColor = UIColor(hex: "D0F5D8")
            container.layer.borderColor = UIColor(hex: "284329").cgColor
            container.layer.borderWidth = 2
        } else {
            container.backgroundColor = UIColor(hex: "F5F9F5")
            container.layer.borderColor = UIColor(hex: "284329").withAlphaComponent(0.1).cgColor
            container.layer.borderWidth = 1
        }
        container.layer.cornerRadius = 15
        
        // Main vertical stack view
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.alignment = .leading
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Top row container for icon and value
        let topRowStack = UIStackView()
        topRowStack.axis = .horizontal
        topRowStack.spacing = 12
        topRowStack.alignment = .center
        
        // Icon container
        let iconContainer = UIView()
        iconContainer.backgroundColor = isSelected ? UIColor(hex: "284329") : UIColor(hex: "284329").withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImage = UIImageView()
        iconImage.tintColor = isSelected ? .white : UIColor(hex: "284329")
        iconImage.image = UIImage(systemName: icon)
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = "\(value)"
        valueLabel.font = isSelected ? .systemFont(ofSize: 24, weight: .bold) : .systemFont(ofSize: 24, weight: .regular)
        valueLabel.textColor = UIColor(hex: "284329")
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = isSelected ? .systemFont(ofSize: 13, weight: .bold) : .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = isSelected ? UIColor(hex: "284329") : UIColor(hex: "284329").withAlphaComponent(0.8)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        // Add icon to its container
        iconContainer.addSubview(iconImage)
        
        // Add elements to top row stack
        topRowStack.addArrangedSubview(iconContainer)
        topRowStack.addArrangedSubview(valueLabel)
        
        // Add elements to main stack
        mainStack.addArrangedSubview(topRowStack)
        mainStack.addArrangedSubview(titleLabel)
        
        // Add main stack to container
        container.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            // Main stack constraints
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            // Icon container constraints
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            
            // Icon image constraints
            iconImage.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImage.heightAnchor.constraint(equalToConstant: 18),
            iconImage.widthAnchor.constraint(equalToConstant: 18),
            
            // Make top row stack take full width
            topRowStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            
            // Make title label take full width
            titleLabel.widthAnchor.constraint(equalTo: mainStack.widthAnchor)
        ])
        
        return container
    }
    
    func configure(with stats: [String: Int], selectedCategory: String) {
        self.selectedCategory = selectedCategory
        leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        statViewsRefs.removeAll()
        let statViews = [
            ("Total Plants", stats["Total Plants"] ?? 0, "leaf.fill", true, "All"),
            ("Ornamental Plants", stats["Ornamental"] ?? 0, "tree.fill", false, "Ornamental"),
            ("Flowering Plants", stats["Flowering"] ?? 0, "camera.macro", false, "Flowering"),
            ("Medicinal Plants", stats["Medicinal"] ?? 0, "cross.case.fill", false, "Medicinal")
        ]
        for (index, statData) in statViews.enumerated() {
            let isSelected = selectedCategory == statData.4
            let statView = createStatView(title: statData.0, value: statData.1, icon: statData.2, isTotal: statData.3, isSelected: isSelected)
            statView.isUserInteractionEnabled = true
            statView.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleStatTap(_:)))
            statView.addGestureRecognizer(tap)
            statViewsRefs.append(statView)
            if index % 2 == 0 {
                leftStackView.addArrangedSubview(statView)
            } else {
                rightStackView.addArrangedSubview(statView)
            }
        }
    }
    
    @objc private func handleStatTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let categories = ["All", "Ornamental", "Flowering", "Medicinal"]
        let idx = view.tag
        let category = categories[idx]
        delegate?.didTapStat(category: category)
    }
}
