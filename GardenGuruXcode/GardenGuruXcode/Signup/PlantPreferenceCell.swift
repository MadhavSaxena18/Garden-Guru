import UIKit

class PlantPreferenceCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(hex: "F5F9F5")
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "E0E0E0").cgColor
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func updateAppearance() {
        UIView.animate(withDuration: 0.2) {
            if self.isSelected {
                self.backgroundColor = UIColor(hex: "284329")
                self.titleLabel.textColor = .white
                self.layer.borderColor = UIColor(hex: "284329").cgColor
            } else {
                self.backgroundColor = UIColor(hex: "F5F9F5")
                self.titleLabel.textColor = .darkGray
                self.layer.borderColor = UIColor(hex: "E0E0E0").cgColor
            }
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        updateAppearance()
    }
} 