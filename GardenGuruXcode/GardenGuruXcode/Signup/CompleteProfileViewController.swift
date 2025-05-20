import UIKit

extension Notification.Name {
    static let userDidCompleteProfile = Notification.Name("userDidCompleteProfile")
}

class CompleteProfileViewController: UIViewController {
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 20) / 2 // 2 cells per row with 20pt total spacing
        return CGSize(width: width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    private let viewModel = CompleteProfileViewModel()
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Complete Your Profile"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Help us personalize your experience"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let successView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
//    private let successCheckmarkView: UIImageView = {
//        let imageView = UIImage(named: "GG1")
//        imageView.tintColor = UIColor(hex: "284329")
//        imageView.alpha = 0
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
    private let successCheckmarkView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "GG1")) // <- Correct usage
        imageView.tintColor = UIColor(hex: "284329") // Optional: use only if logo is template image
        imageView.alpha = 0
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    
//    private let successLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Welcome to Garden Guru! "
//        label.font = .systemFont(ofSize: 24, weight: .bold)
//        label.textAlignment = .center
//        label.alpha = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    private let successLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        let title = "Welcome to Garden Guru! \n"
        let subtitle = "Your garden journey starts here. Let’s grow! "

        let fullText = title + subtitle

        let attributedString = NSMutableAttributedString(string: fullText)

        // Title styling
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ], range: NSRange(location: 0, length: title.count))

        // Subtitle styling
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ], range: NSRange(location: title.count, length: subtitle.count))

        label.attributedText = attributedString
        return label
    }()

    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: "F5F9F5")
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: "E0E0E0").cgColor
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.font = .systemFont(ofSize: 16)
        return textField
    }
    
    private lazy var nameTextField: UITextField = {
        let textField = createTextField(placeholder: "Full Name")
        return textField
    }()
    
    private lazy var ageTextField: UITextField = {
        let textField = createTextField(placeholder: "Age")
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "Gender"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var genderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Gender", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(hex: "F5F9F5")
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private var plantPreferencesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Plant Preferences", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(hex: "F5F9F5")
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let plantPreferencesLabel: UILabel = {
        let label = UILabel()
        label.text = "Plant Preferences"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(hex: "284329")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor(hex: "284329").cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Properties
    private let plantCategories = [
        "Indoor Plants",
        "Outdoor Plants",
        "Succulents",
        "Herbs",
        "Vegetables",
        "Flowers",
        "Fruit Trees",
        "Bonsai"
    ]
    private let genderOptions = ["Male", "Female", "Other"]
    private var selectedGender: String?
    private var selectedPlantPreferences: Set<String> = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Create buttons using the new helper method
        genderButton = createButton(title: "Select Gender")
        plantPreferencesButton = createButton(title: "Select Plant Preferences")
        
        // Update continue button appearance
        continueButton.backgroundColor = UIColor(hex: "284329")
        continueButton.layer.cornerRadius = 25
        continueButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        
        // Add shadow to continue button
        continueButton.layer.shadowColor = UIColor(hex: "284329").cgColor
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        continueButton.layer.shadowRadius = 8
        continueButton.layer.shadowOpacity = 0.3
        
        // Setup container padding
        containerView.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(containerView)
        contentView.addSubview(successView)
        
        containerView.addSubview(nameTextField)
        containerView.addSubview(ageTextField)
        containerView.addSubview(genderLabel)
        containerView.addSubview(genderButton)
        containerView.addSubview(plantPreferencesLabel)
        containerView.addSubview(plantPreferencesButton)
        containerView.addSubview(continueButton)
        continueButton.addSubview(loadingIndicator)
        
        successView.addSubview(successCheckmarkView)
        successView.addSubview(successLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Setup button actions
        genderButton.addTarget(self, action: #selector(showGenderPicker), for: .touchUpInside)
        plantPreferencesButton.addTarget(self, action: #selector(showPlantPreferencesPicker), for: .touchUpInside)
        
        // Update text field appearance
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Full Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
        ageTextField.attributedPlaceholder = NSAttributedString(
            string: "Age",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
        
        // Update label appearances
        genderLabel.font = .systemFont(ofSize: 16, weight: .medium)
        plantPreferencesLabel.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    private func setupConstraints() {
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            containerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            ageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            ageTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            ageTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            genderLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 20),
            genderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            genderButton.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            genderButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            plantPreferencesLabel.topAnchor.constraint(equalTo: genderButton.bottomAnchor, constant: 20),
            plantPreferencesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            plantPreferencesButton.topAnchor.constraint(equalTo: plantPreferencesLabel.bottomAnchor, constant: 8),
            plantPreferencesButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            plantPreferencesButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            continueButton.topAnchor.constraint(equalTo: plantPreferencesButton.bottomAnchor, constant: 32),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),
            
            successView.topAnchor.constraint(equalTo: view.topAnchor),
            successView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            successView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            successView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            successCheckmarkView.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            successCheckmarkView.centerYAnchor.constraint(equalTo: successView.centerYAnchor, constant: -40),
            successCheckmarkView.widthAnchor.constraint(equalToConstant: 120),
            successCheckmarkView.heightAnchor.constraint(equalToConstant: 120),
            
            successLabel.topAnchor.constraint(equalTo: successCheckmarkView.bottomAnchor, constant: 24),
            successLabel.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 32),
            successLabel.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -32),
        ])
    }
    
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            self.showAlert(title: "Error", message: message)
        }
        
        viewModel.onSuccess = { [weak self] in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            self.showSuccessAnimation()
        }
    }
    
    // MARK: - Actions
    @objc private func showGenderPicker() {
        let alertController = UIAlertController(title: "Select Gender", message: nil, preferredStyle: .actionSheet)
        
        for gender in genderOptions {
            let action = UIAlertAction(title: gender, style: .default) { [weak self] _ in
                self?.selectedGender = gender
                self?.genderButton.setTitle(gender, for: .normal)
                self?.genderButton.setTitleColor(.darkGray, for: .normal)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        // For iPad support
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = genderButton
            popoverController.sourceRect = genderButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    @objc private func showPlantPreferencesPicker() {
        let alert = UIAlertController(title: "Select Plant Preferences", message: nil, preferredStyle: .actionSheet)
        
        for category in plantCategories {
            let isSelected = selectedPlantPreferences.contains(category)
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                if isSelected {
                    self?.selectedPlantPreferences.remove(category)
                } else {
                    self?.selectedPlantPreferences.insert(category)
                }
                self?.updatePlantPreferencesButtonTitle()
            }
            // Add checkmark for selected items
            if isSelected {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel))
        
        // For iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = plantPreferencesButton
            popover.sourceRect = plantPreferencesButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func updatePlantPreferencesButtonTitle() {
        if selectedPlantPreferences.isEmpty {
            plantPreferencesButton.setTitle("Select Plant Preferences", for: .normal)
        } else {
            plantPreferencesButton.setTitle("\(selectedPlantPreferences.count) preferences selected", for: .normal)
        }
    }
    
    @objc private func continueButtonTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let ageText = ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let selectedGender = selectedGender,
              !name.isEmpty, !ageText.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        guard let age = Int(ageText) else {
            showAlert(title: "Error", message: "Please enter a valid age")
            return
        }
        
        let selectedPreferences = Array(selectedPlantPreferences)
        guard !selectedPreferences.isEmpty else {
            showAlert(title: "Error", message: "Please select at least one plant preference")
            return
        }
        
        showLoadingIndicator()
        viewModel.completeProfile(name: name,
                                age: age,
                                gender: selectedGender.lowercased(),
                                plantPreferences: selectedPreferences)
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
        continueButton.setTitle("", for: .normal)
        continueButton.isEnabled = false
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        continueButton.setTitle("Continue", for: .normal)
        continueButton.isEnabled = true
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAnimation() {
        // Prepare initial state
        successView.alpha = 1
        successCheckmarkView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        successCheckmarkView.alpha = 0
        successLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        successLabel.alpha = 0
        
        // Fade out the form
        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 0
            self.titleLabel.alpha = 0
            self.subtitleLabel.alpha = 0
        }
        
        // Animate checkmark
        UIView.animate(withDuration: 0.5,
                      delay: 0.3,
                      usingSpringWithDamping: 0.6,
                      initialSpringVelocity: 0.8,
                      options: [],
                      animations: {
            self.successCheckmarkView.alpha = 1
            self.successCheckmarkView.transform = .identity
        })
        
        // Animate success label
        UIView.animate(withDuration: 0.5,
                      delay: 0.5,
                      usingSpringWithDamping: 0.8,
                      initialSpringVelocity: 0.5,
                      options: [],
                      animations: {
            self.successLabel.alpha = 1
            self.successLabel.transform = .identity
        }) { _ in
            // Wait for 2 seconds then navigate to login
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.successView.alpha = 0
                }) { _ in
                    // Post notification and dismiss
                    NotificationCenter.default.post(name: .userDidCompleteProfile, object: nil)
                    self.view.window?.rootViewController?.dismiss(animated: true)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func validateForm() -> Bool {
        // ... existing code ...
        return true
    }
    
    private func showError(_ message: String) {
        // ... existing code ...
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(hex: "F5F9F5")
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: "E0E0E0").cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
}
