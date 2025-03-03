import UIKit

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
        
        if let url = URL(string: fertilizer.fertilizerImage) {
            // Load image from URL (you might want to use an image loading library)
            // For now, we'll use a placeholder
            headerImageView.backgroundColor = .systemGray5
        }
        
        titleLabel.text = fertilizer.fertilizerName
        typeLabel.text = "Type: \(fertilizer.type)"
        descriptionLabel.text = fertilizer.fertilizerDescription
        applicationMethodLabel.text = fertilizer.applicationMethod
        frequencyLabel.text = fertilizer.applicationFrequency
        
        // Configure warning signs
        warningsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        fertilizer.warningSigns.forEach { warning in
            let label = UILabel()
            label.text = "• \(warning)"
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16)
            warningsStackView.addArrangedSubview(label)
        }
        
        // Configure alternatives
        alternativesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        fertilizer.alternativeFertilizers.forEach { alternative in
            let label = UILabel()
            label.text = "• \(alternative)"
            label.font = .systemFont(ofSize: 16)
            alternativesStackView.addArrangedSubview(label)
        }
    }
}