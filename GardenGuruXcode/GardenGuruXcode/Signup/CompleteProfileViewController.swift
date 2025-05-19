import UIKit

extension Notification.Name {
    static let userDidCompleteProfile = Notification.Name("userDidCompleteProfile")
}

class CompleteProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantPreferenceCell", for: indexPath) as? PlantPreferenceCell else {
            return UICollectionViewCell()
        }
        
        let category = plantCategories[indexPath.item]
        cell.configure(with: category)
        cell.isSelected = selectedPlantPreferences.contains(category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = plantCategories[indexPath.item]
        selectedPlantPreferences.insert(category)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let category = plantCategories[indexPath.item]
        selectedPlantPreferences.remove(category)
    }
    
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
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Help us personalize your experience"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: "F5F9F5")
        textField.layer.cornerRadius = 12
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
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genderButton: UIButton = {
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
    
    private let plantPreferencesLabel: UILabel = {
        let label = UILabel()
        label.text = "Plant Preferences"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plantPreferencesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "284329")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
        "Bonsai",
        "Air Plants"
    ]
    private let genderOptions = ["Male", "Female", "Other"]
    private var selectedGender: String?
    private var selectedPlantPreferences: Set<String> = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupConstraints()
        setupActions()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(containerView)
        
        containerView.addSubview(nameTextField)
        containerView.addSubview(ageTextField)
        containerView.addSubview(genderLabel)
        containerView.addSubview(genderButton)
        containerView.addSubview(plantPreferencesLabel)
        containerView.addSubview(plantPreferencesCollectionView)
        containerView.addSubview(continueButton)
        continueButton.addSubview(loadingIndicator)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Setup gender button action
        genderButton.addTarget(self, action: #selector(showGenderPicker), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        plantPreferencesCollectionView.delegate = self
        plantPreferencesCollectionView.dataSource = self
        plantPreferencesCollectionView.register(PlantPreferenceCell.self, forCellWithReuseIdentifier: "PlantPreferenceCell")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            containerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            ageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            ageTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            ageTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            genderLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 16),
            genderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            genderButton.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            genderButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            plantPreferencesLabel.topAnchor.constraint(equalTo: genderButton.bottomAnchor, constant: 24),
            plantPreferencesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            plantPreferencesCollectionView.topAnchor.constraint(equalTo: plantPreferencesLabel.bottomAnchor, constant: 8),
            plantPreferencesCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            plantPreferencesCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            plantPreferencesCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            continueButton.topAnchor.constraint(equalTo: plantPreferencesCollectionView.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor)
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
            
            // Post notification on main thread
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .userDidCompleteProfile,
                    object: nil
                )
            }
        }
    }
    
    // MARK: - Actions
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
    
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
}
