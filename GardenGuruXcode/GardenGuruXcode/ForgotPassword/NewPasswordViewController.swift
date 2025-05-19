import UIKit

class NewPasswordViewController: UIViewController {
    
    private let email: String
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create New Password"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(hex: "284329")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your new password must be different from previous passwords"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "New Password"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: "F5F9F5")
        textField.layer.cornerRadius = 12
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: "F5F9F5")
        textField.layer.cornerRadius = 12
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "284329")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let dataController = DataControllerGG.shared
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupNavigation()
    }
    
    private func setupNavigation() {
        title = "Create New Password"
        navigationController?.navigationBar.tintColor = UIColor(hex: "284329")
        
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "F5F9F5")
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(confirmPasswordTextField)
        containerView.addSubview(resetButton)
        resetButton.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            passwordTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            resetButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 24),
            resetButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            resetButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: resetButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: resetButton.centerYAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        resetButton.addTarget(self, action: #selector(updatePasswordButtonTapped), for: .touchUpInside)
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    @objc private func updatePasswordButtonTapped() {
        // Validate passwords match
        guard let newPassword = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              !newPassword.isEmpty,
              !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        guard newPassword == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        // Show loading indicator
        showLoadingIndicator()
        
        Task {
            do {
                try await DataControllerGG.shared.updatePassword(newPassword: newPassword)
                await MainActor.run {
                    hideLoadingIndicator()
                    showSuccessAlert()
                }
            } catch {
                await MainActor.run {
                    hideLoadingIndicator()
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
        resetButton.setTitle("", for: .normal)
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        resetButton.setTitle("Reset Password", for: .normal)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Password has been reset successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Dismiss all presented view controllers and return to login
            self.view.window?.rootViewController?.dismiss(animated: true)
        })
        self.present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension NewPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            updatePasswordButtonTapped()
        }
        return true
    }
} 
