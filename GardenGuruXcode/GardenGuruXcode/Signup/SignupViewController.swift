import UIKit

class SignupViewController: UIViewController {
    private let viewModel = SignupViewModel()
    
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
    
    private let formContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private func createTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.isSecureTextEntry = isSecure
        return textField
    }
    
    private lazy var nameTextField: UITextField = createTextField(placeholder: "Full Name")
    private lazy var emailTextField: UITextField = createTextField(placeholder: "Email")
    private lazy var passwordTextField: UITextField = createTextField(placeholder: "Password", isSecure: true)
    private lazy var confirmPasswordTextField: UITextField = createTextField(placeholder: "Confirm Password", isSecure: true)
    
   
    
    private let passwordRequirementsLabel: UILabel = {
        let label = UILabel()
        label.text = "Password must contain:"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let requirementsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private func createRequirementLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = "• " + text
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }
    
  
    
    
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor(hex: "284329")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationItem.title = "Sign Up"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        let backButton = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = UIColor(hex: "284329")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(formContainer)
        formContainer.addSubview(stackView)
        
        // Add password requirements
        requirementsStackView.addArrangedSubview(passwordRequirementsLabel)
        requirementsStackView.addArrangedSubview(createRequirementLabel(text: "At least 8 characters"))
        requirementsStackView.addArrangedSubview(createRequirementLabel(text: "One uppercase letter"))
        requirementsStackView.addArrangedSubview(createRequirementLabel(text: "One lowercase letter"))
        requirementsStackView.addArrangedSubview(createRequirementLabel(text: "One number"))
        requirementsStackView.addArrangedSubview(createRequirementLabel(text: "One special character"))
        
        // Setup reminders container
        
        
        // Add all elements to stack view
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(confirmPasswordTextField)
        stackView.addArrangedSubview(requirementsStackView)
     
        stackView.addArrangedSubview(signupButton)
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
            
            formContainer.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            formContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            formContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: formContainer.bottomAnchor, constant: -20),
            
        
        ])
    }
    
    private func setupActions() {
       
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupBindings() {
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Error", message: message)
            self?.signupButton.setTitle("Sign Up", for: .normal)
        }
        
        viewModel.onSuccess = { [weak self] in
            self?.showAlert(title: "Success", message: "Account created successfully!") { _ in
                self?.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
  
    
    @objc private func signupButtonTapped() {
        viewModel.userName = nameTextField.text ?? ""
        viewModel.email = emailTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        viewModel.confirmPassword = confirmPasswordTextField.text ?? ""
    
        
        Task {
            await viewModel.signUp()
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.userName = nameTextField.text ?? ""
        viewModel.email = emailTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        viewModel.confirmPassword = confirmPasswordTextField.text ?? ""
        
        updateValidationStatus()
        
        signupButton.isEnabled = viewModel.isFormValid
        signupButton.backgroundColor = viewModel.isFormValid ? UIColor(hex: "284329") : .systemGray
    }
    
    private func updateValidationStatus() {
        let password = passwordTextField.text ?? ""
        
        if password.isEmpty {
            passwordRequirementsLabel.text = ""
        } else if viewModel.isValidPassword(password) {
            passwordRequirementsLabel.text = "Password is valid!"
            passwordRequirementsLabel.textColor = .systemGreen
        } else {
            passwordRequirementsLabel.text = "Password must be at least 8 characters long and include a mix of letters, numbers, and special characters."
            passwordRequirementsLabel.textColor = .systemRed
        }
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
}

// MARK: - LocationPickerDelegate

//extension SignupViewController: LocationPickerDelegate {
//    func locationPicker(_ picker: LocationPickerViewController, didSelect location: String) {
//        viewModel.location = location
//        locationButton.setTitle(location, for: .normal)
//        signupButton.isEnabled = viewModel.isFormValid
//        signupButton.backgroundColor = viewModel.isFormValid ? UIColor(hex: "284329") : .systemGray
//    }
//}

// MARK: - UIColor Extension
//extension UIColor {
//    convenience init(hex: String) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//        
//        var rgb: UInt64 = 0
//        
//        Scanner(string: hexSanitized).scanHexInt64(&rgb)
//        
//        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//        let blue = CGFloat(rgb & 0x0000FF) / 255.0
//        
//        self.init(red: red, green: green, blue: blue, alpha: 1.0)
//    }
//} 
