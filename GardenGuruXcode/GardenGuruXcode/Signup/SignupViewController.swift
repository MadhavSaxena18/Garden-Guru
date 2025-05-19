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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign Up"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create your account"
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
    
    private func createTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
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
        textField.isSecureTextEntry = isSecure
        textField.font = .systemFont(ofSize: 16)
        return textField
    }
    
    private lazy var emailTextField: UITextField = createTextField(placeholder: "Email")
    
    private lazy var passwordTextField: UITextField = createTextField(placeholder: "Password", isSecure: true)
    
    private lazy var confirmPasswordTextField: UITextField = createTextField(placeholder: "Confirm Password", isSecure: true)
    
    private lazy var otpTextField: UITextField = createTextField(placeholder: "Enter verification code")
    
    private let resendContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let resendLabel: UILabel = {
        let label = UILabel()
        label.text = "Didn't receive OTP?"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Resend", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(UIColor(hex: "284329"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "284329")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "--------------------- OR ---------------------"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signUpWithAppleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("Sign up with Apple", for: .normal)
        button.setImage(UIImage(systemName: "apple.logo"), for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 14
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let signInContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let signInLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account?"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(UIColor(hex: "284329"), for: .normal)
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
    
    // MARK: - Properties
    private var currentStep: SignupStep = .initial {
        didSet {
            updateUIForCurrentStep()
        }
    }
    
    private enum SignupStep {
        case initial
        case otp
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Configure email text field
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        
        // Configure OTP text field
        otpTextField.keyboardType = .numberPad
        otpTextField.isHidden = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(containerView)
        
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(confirmPasswordTextField)
        containerView.addSubview(otpTextField)
        containerView.addSubview(resendContainer)
        resendContainer.addSubview(resendLabel)
        resendContainer.addSubview(resendButton)
        containerView.addSubview(signupButton)
        signupButton.addSubview(loadingIndicator)
        
        contentView.addSubview(orLabel)
        contentView.addSubview(signUpWithAppleButton)
        contentView.addSubview(signInContainer)
        signInContainer.addSubview(signInLabel)
        signInContainer.addSubview(signInButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            containerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            otpTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            otpTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            otpTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            resendContainer.topAnchor.constraint(equalTo: otpTextField.bottomAnchor, constant: 8),
            resendContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            resendContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            resendContainer.heightAnchor.constraint(equalToConstant: 20),
            
            resendLabel.leadingAnchor.constraint(equalTo: resendContainer.leadingAnchor),
            resendLabel.centerYAnchor.constraint(equalTo: resendContainer.centerYAnchor),
            
            resendButton.leadingAnchor.constraint(equalTo: resendLabel.trailingAnchor, constant: 8),
            resendButton.centerYAnchor.constraint(equalTo: resendContainer.centerYAnchor),
            
            signupButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 24),
            signupButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            signupButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            signupButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: signupButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: signupButton.centerYAnchor),
            
            orLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24),
            orLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            signUpWithAppleButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 24),
            signUpWithAppleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signUpWithAppleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            signInContainer.topAnchor.constraint(equalTo: signUpWithAppleButton.bottomAnchor, constant: 24),
            signInContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            signInContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            signInContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            signInContainer.heightAnchor.constraint(equalToConstant: 44),
            
            signInLabel.centerYAnchor.constraint(equalTo: signInContainer.centerYAnchor),
            signInLabel.centerXAnchor.constraint(equalTo: signInContainer.centerXAnchor, constant: -30),
            
            signInButton.centerYAnchor.constraint(equalTo: signInContainer.centerYAnchor),
            signInButton.leadingAnchor.constraint(equalTo: signInLabel.trailingAnchor, constant: 4),
            signInButton.heightAnchor.constraint(equalToConstant: 44),
            signInButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }
    
    private func setupActions() {
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        signUpWithAppleButton.addTarget(self, action: #selector(appleSignUpTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onError = { [weak self] message in
            self?.hideLoadingIndicator()
            self?.showAlert(title: "Error", message: message)
        }
        
        viewModel.onUserExists = { [weak self] in
            self?.hideLoadingIndicator()
            self?.showAlert(
                title: "Account Exists",
                message: "An account with this email already exists. Would you like to login?",
                primaryButtonTitle: "Login",
                secondaryButtonTitle: "Cancel"
            ) { [weak self] in
                self?.dismiss(animated: true) // This will take user back to login screen
            }
        }
        
        viewModel.onOTPSent = { [weak self] in
            self?.hideLoadingIndicator()
            self?.currentStep = .otp
            self?.showAlert(title: "Success", message: "Verification code sent successfully!")
        }
        
        viewModel.onOTPVerified = { [weak self] in
            self?.hideLoadingIndicator()
            // Present the complete profile view controller
            let profileVC = CompleteProfileViewController()
            profileVC.modalPresentationStyle = .fullScreen
            self?.present(profileVC, animated: true)
        }
    }
    
    private func updateUIForCurrentStep() {
        UIView.animate(withDuration: 0.3) {
            switch self.currentStep {
            case .initial:
                self.emailTextField.isEnabled = true
                self.passwordTextField.isHidden = true
                self.confirmPasswordTextField.isHidden = true
                self.otpTextField.isHidden = true
                self.resendContainer.isHidden = true
                self.signupButton.setTitle("Continue", for: .normal)
                
            case .otp:
                self.emailTextField.isEnabled = false
                self.passwordTextField.isHidden = true
                self.confirmPasswordTextField.isHidden = true
                self.otpTextField.isHidden = false
                self.resendContainer.isHidden = false
                self.signupButton.setTitle("Verify", for: .normal)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func signupButtonTapped() {
        switch currentStep {
        case .initial:
            guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !email.isEmpty else {
                showAlert(title: "Error", message: "Please enter your email")
                return
            }
            
            showLoadingIndicator()
            viewModel.email = email
            Task {
                await viewModel.checkEmailAndSendOTP()
            }
            
        case .otp:
            guard let otp = otpTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !otp.isEmpty else {
                showAlert(title: "Error", message: "Please enter the verification code")
                return
            }
            
            showLoadingIndicator()
            viewModel.otp = otp
            Task {
                await viewModel.verifyOTP()
            }
        }
    }
    
    @objc private func resendButtonTapped() {
        showLoadingIndicator()
        Task {
            do {
                try await DataControllerGG.shared.resendVerificationEmail(email: viewModel.email)
                hideLoadingIndicator()
                showAlert(title: "Success", message: "OTP resent successfully!")
            } catch {
                hideLoadingIndicator()
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func signInButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func appleSignUpTapped() {
        showAlert(title: "Coming Soon", message: "Apple Sign Up will be available soon!")
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
        signupButton.setTitle("", for: .normal)
        signupButton.isEnabled = false
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        updateUIForCurrentStep()
        signupButton.isEnabled = true
    }
    
    private func showAlert(
        title: String,
        message: String,
        primaryButtonTitle: String? = nil,
        secondaryButtonTitle: String = "OK",
        primaryAction: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let primaryButtonTitle = primaryButtonTitle {
            let primaryButton = UIAlertAction(title: primaryButtonTitle, style: .default) { _ in
                primaryAction?()
            }
            alert.addAction(primaryButton)
        }
        
        let secondaryButton = UIAlertAction(title: secondaryButtonTitle, style: .cancel)
        alert.addAction(secondaryButton)
        
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
