import UIKit
import SDWebImage

class FertilizerDetailViewController: UIViewController {
    // Add this property at the top with other properties
    var isPresentedModally = true
    var fertilizer: Fertilizer?
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var applicationMethodTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Application Method"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var applicationMethodLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var frequencyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Application Frequency"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var frequencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var warningsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Warning Signs"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var warningsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var alternativesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Alternative Fertilizers"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var alternativesStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        configureFertilizerData()
        view.backgroundColor = UIColor(hex: "#EBF4EB")
    }
    
    private func setupNavigationBar() {
        if isPresentedModally {
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissViewController))
            doneButton.tintColor = .systemBlue
            navigationItem.leftBarButtonItem = doneButton
        }
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor(hex: "284329")]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [headerImageView, titleLabel, typeLabel, descriptionLabel,
         applicationMethodTitleLabel, applicationMethodLabel,
         frequencyTitleLabel, frequencyLabel,
         warningsTitleLabel, warningsStackView,
         alternativesTitleLabel, alternativesStackView].forEach { contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            applicationMethodTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            applicationMethodTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            applicationMethodTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            applicationMethodLabel.topAnchor.constraint(equalTo: applicationMethodTitleLabel.bottomAnchor, constant: 8),
            applicationMethodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            applicationMethodLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            frequencyTitleLabel.topAnchor.constraint(equalTo: applicationMethodLabel.bottomAnchor, constant: 24),
            frequencyTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            frequencyTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            frequencyLabel.topAnchor.constraint(equalTo: frequencyTitleLabel.bottomAnchor, constant: 8),
            frequencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            frequencyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            warningsTitleLabel.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor, constant: 24),
            warningsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            warningsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            warningsStackView.topAnchor.constraint(equalTo: warningsTitleLabel.bottomAnchor, constant: 8),
            warningsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            warningsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            alternativesTitleLabel.topAnchor.constraint(equalTo: warningsStackView.bottomAnchor, constant: 24),
            alternativesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            alternativesTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            alternativesStackView.topAnchor.constraint(equalTo: alternativesTitleLabel.bottomAnchor, constant: 8),
            alternativesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            alternativesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            alternativesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureFertilizerData() {
        guard let fertilizer = fertilizer else { return }
        
        // Configure image
        if let urlString = fertilizer.fertilizerImage?.trimmingCharacters(in: .whitespacesAndNewlines),
           let url = URL(string: urlString) {
            headerImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "fertilizer_placeholder"))
        } else {
            // Fallback to a placeholder if image not found
            headerImageView.image = UIImage(named: "fertilizer_placeholder")
            headerImageView.backgroundColor = .systemGray5
            print("Could not load fertilizer image")
        }
        
        titleLabel.text = fertilizer.fertilizerName
        descriptionLabel.text = fertilizer.fertilizerDescription ?? "No description available"
        
        // Show and fill type
        if let type = fertilizer.fertilizerType, !type.isEmpty {
            typeLabel.text = "Type: \(type)"
            typeLabel.isHidden = false
        } else {
            typeLabel.isHidden = true
        }
        // Show and fill application method
        if let method = fertilizer.applicationMethod, !method.isEmpty {
            applicationMethodLabel.text = method
            applicationMethodTitleLabel.isHidden = false
            applicationMethodLabel.isHidden = false
        } else {
            applicationMethodTitleLabel.isHidden = true
            applicationMethodLabel.isHidden = true
        }
        // Show and fill frequency
        if let freq = fertilizer.applicationFrequency, !freq.isEmpty {
            frequencyLabel.text = freq
            frequencyTitleLabel.isHidden = false
            frequencyLabel.isHidden = false
        } else {
            frequencyTitleLabel.isHidden = true
            frequencyLabel.isHidden = true
        }
        // Show and fill warning signs
        if let warnings = fertilizer.warningSigns, !warnings.isEmpty {
            warningsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for warning in warnings {
                let label = UILabel()
                label.font = .systemFont(ofSize: 16)
                label.textColor = .label
                label.text = "• " + warning
                warningsStackView.addArrangedSubview(label)
            }
            warningsTitleLabel.isHidden = false
            warningsStackView.isHidden = false
        } else {
            warningsTitleLabel.isHidden = true
            warningsStackView.isHidden = true
        }
        // Show and fill alternative fertilizers
        if let alternatives = fertilizer.alternativeFertilizers, !alternatives.isEmpty {
            alternativesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for alt in alternatives {
                let label = UILabel()
                label.font = .systemFont(ofSize: 16)
                label.textColor = .label
                label.text = "• " + alt
                alternativesStackView.addArrangedSubview(label)
            }
            alternativesTitleLabel.isHidden = false
            alternativesStackView.isHidden = false
        } else {
            alternativesTitleLabel.isHidden = true
            alternativesStackView.isHidden = true
        }
    }
}
