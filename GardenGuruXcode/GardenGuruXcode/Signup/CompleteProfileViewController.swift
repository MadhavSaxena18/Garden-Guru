import UIKit

class CompleteProfileViewController: UIViewController {
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
    
    private lazy var genderSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Male", "Female", "Other"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor(hex: "F5F9F5")
        control.selectedSegmentTintColor = UIColor(hex: "284329")
        control.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
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
        containerView.addSubview(genderSegmentedControl)
        containerView.addSubview(plantPreferencesLabel)
        containerView.addSubview(plantPreferencesCollectionView)
        containerView.addSubview(continueButton)
        continueButton.addSubview(loadingIndicator)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
            
            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            plantPreferencesLabel.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 24),
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
            self?.showAlert(title: "Error", message: message)
            self?.hideLoadingIndicator()
        }
        
        viewModel.onSuccess = { [weak self] in
            self?.hideLoadingIndicator()
            // Navigate to main app
            NotificationCenter.default.post(name: .userDidCompleteProfile, object: nil)
        }
    }
    
    // MARK: - Actions
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func continueButtonTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let ageText = ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty, !ageText.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        guard let age = Int(ageText) else {
            showAlert(title: "Error", message: "Please enter a valid age")
            return
        }
        
        let selectedPreferences = plantPreferencesCollectionView.indexPathsForSelectedItems?.map { plantCategories[$0.item] } ?? []
        guard !selectedPreferences.isEmpty else {
            showAlert(title: "Error", message: "Please select at least one plant preference")
            return
        }
        
        let gender = ["male", "female", "other"][genderSegmentedControl.selectedSegmentIndex]
        
        showLoadingIndicator()
        viewModel.completeProfile(name: name,
                                age: age,
                                gender: gender,
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

// MARK: - UICollectionView DataSource & Delegate
extension CompleteProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantPreferenceCell", for: indexPath) as! PlantPreferenceCell
        cell.configure(with: plantCategories[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 20) / 2
        return CGSize(width: width, height: 44)
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let userDidCompleteProfile = Notification.Name("userDidCompleteProfile")
} 
