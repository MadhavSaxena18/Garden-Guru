import UIKit
import AuthenticationServices

extension Notification.Name {
    static let userDidCompleteProfile1 = Notification.Name("userDidCompleteProfile")
    static let showMainApp = Notification.Name("showMainApp")
}

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
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "GG1"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    
    private let signUpWithGoogleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Sign up with Google", for: .normal)
        button.setImage(UIImage(named: "google2"), for: .normal)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
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
    
    // Add password validation properties
//    private let passwordRequirements = """
//    Password must contain:
//    • At least 8 characters
//    • One uppercase letter
//    • One lowercase letter
//    • One number
//    • One special character
//    """
//    
    private func isValidPassword(_ password: String) -> Bool {
        // Check minimum length
        guard password.count >= 8 else { return false }
        
        // Check for uppercase letter
        guard password.range(of: "[A-Z]", options: .regularExpression) != nil else { return false }
        
        // Check for lowercase letter
        guard password.range(of: "[a-z]", options: .regularExpression) != nil else { return false }
        
        // Check for number
        guard password.range(of: "[0-9]", options: .regularExpression) != nil else { return false }
        
        // Check for special character
        guard password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil else { return false }
        
        return true
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
        
        // Debug button setup
        signUpWithAppleButton.addAction(UIAction { [weak self] _ in
            print("Apple button tapped in Signup")
        }, for: .touchUpInside)
        
        // Verify button properties
        print("📱 Button Setup Verification:")
        print("Apple Button isEnabled: \(signUpWithAppleButton.isEnabled)")
        print("Apple Button isUserInteractionEnabled: \(signUpWithAppleButton.isUserInteractionEnabled)")
        print("Apple Button frame: \(signUpWithAppleButton.frame)")
        print("Apple Button superview: \(String(describing: signUpWithAppleButton.superview))")
        
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set background color for the entire view
        view.backgroundColor = .white
        
        // Extend content under top safe area
        additionalSafeAreaInsets = .zero
        edgesForExtendedLayout = .all
        
        // Add notification observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileCompletion),
            name: .userDidCompleteProfile1,
            object: nil
        )
        
        // Add text field delegates
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleProfileCompletion() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true) {
                // Post notification to show main app
                NotificationCenter.default.post(name: .showMainApp, object: nil)
            }
        }
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
        
        contentView.addSubview(logoImageView)
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
        contentView.addSubview(signUpWithGoogleButton)
        contentView.addSubview(signUpWithAppleButton)
        contentView.addSubview(signInContainer)
        signInContainer.addSubview(signInLabel)
        signInContainer.addSubview(signInButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
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
            signUpWithAppleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            signUpWithAppleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            signUpWithGoogleButton.topAnchor.constraint(equalTo: signUpWithAppleButton.bottomAnchor, constant: 16),
            signUpWithGoogleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            signUpWithGoogleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            signInContainer.topAnchor.constraint(equalTo: signUpWithGoogleButton.bottomAnchor, constant: 24),
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
        signUpWithGoogleButton.addTarget(self, action: #selector(googleSignUpTapped), for: .touchUpInside)
        
        // Add debug print to verify button setup
        print("🔘 Setup Actions - Buttons connected:")
        print("✓ Sign Up Button")
        print("✓ Resend Button")
        print("✓ Sign In Button")
        print("✓ Apple Sign Up Button")
        print("✓ Google Sign Up Button")
    }
    
    private func setupBindings() {
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.showAlert(title: "Error", message: message)
            }
        }
        
        viewModel.onUserExists = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                self.showAlert(
                    title: "Account Exists",
                    message: "An account with this email already exists. Would you like to login?",
                    primaryButtonTitle: "Login",
                    secondaryButtonTitle: "Cancel"
                ) { [weak self] _ in
                    self?.dismiss(animated: true) // This will take user back to login screen
                } secondaryAction: { [weak self] _ in
                    self?.resetForm() // Use the improved resetForm method
                }
            }
        }
        
        viewModel.onOTPSent = { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.currentStep = .otp
                self?.showAlert(title: "Success", message: "Verification code sent successfully!")
            }
        }
        
        viewModel.onSuccess = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                let completeProfileVC = CompleteProfileViewController()
                completeProfileVC.modalPresentationStyle = .fullScreen
                self.present(completeProfileVC, animated: true)
            }
        }
    }
    
    private func updateUIForCurrentStep() {
        // Ensure we're on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.updateUIForCurrentStep()
            }
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            switch self.currentStep {
            case .initial:
                self.emailTextField.isEnabled = true
                self.passwordTextField.isHidden = false
                self.confirmPasswordTextField.isHidden = false
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
            
            // Reset any validation styling
            [self.emailTextField, self.passwordTextField, self.confirmPasswordTextField, self.otpTextField].forEach { textField in
                textField.layer.borderWidth = 0
                textField.layer.borderColor = nil
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func resetForm() {
        // Clear all text fields
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
        otpTextField.text = ""
        
        // Reset text field borders
        [emailTextField, passwordTextField, confirmPasswordTextField, otpTextField].forEach { textField in
            textField.layer.borderWidth = 0
            textField.layer.borderColor = nil
        }
        
        // Reset step and update UI
        currentStep = .initial
        
        // Ensure UI update happens on main thread
        DispatchQueue.main.async {
            self.updateUIForCurrentStep()
            self.view.layoutIfNeeded() // Force layout update
        }
    }
    
    private func showAlert(title: String, message: String, primaryButtonTitle: String = "OK", secondaryButtonTitle: String? = nil, primaryAction: ((UIAlertAction) -> Void)? = nil, secondaryAction: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let primaryButton = UIAlertAction(title: primaryButtonTitle, style: .default, handler: primaryAction)
        alert.addAction(primaryButton)
        
        if let secondaryTitle = secondaryButtonTitle {
            let secondaryButton = UIAlertAction(title: secondaryTitle, style: .cancel, handler: secondaryAction)
            alert.addAction(secondaryButton)
        }
        
        present(alert, animated: true)
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
            
            // Validate email format
            guard viewModel.isValidEmail(email) else {
                showAlert(title: "Error", message: "Please enter a valid email address")
                return
            }
            
            // Validate password
            guard let password = passwordTextField.text,
                  !password.isEmpty else {
                showAlert(title: "Error", message: "Please enter a password")
                return
            }
            
            // Validate confirm password
            guard let confirmPassword = confirmPasswordTextField.text,
                  !confirmPassword.isEmpty else {
                showAlert(title: "Error", message: "Please confirm your password")
                return
            }
            
            guard password == confirmPassword else {
                showAlert(title: "Error", message: "Passwords do not match")
                return
            }
            
            // Store email and password temporarily
            UserDefaults.standard.set(email, forKey: "userEmail")
            KeychainManager.shared.save(password, for: "tempPassword_\(email)")
            
            showLoadingIndicator()
            viewModel.email = email
            viewModel.password = password
            Task {
                do {
                    // First create auth user
                    let (authResponse, _) = try await DataControllerGG.shared.signUp(
                        email: email,
                        password: password,
                        userName: email.components(separatedBy: "@")[0] // Use email prefix as initial username
                    )
                    
                    if let session = authResponse.session, session.accessToken != nil {
                        // Create user in UserTable
                        let userName = email.components(separatedBy: "@")[0]
                        try await DataControllerGG.shared.createUser(
                            email: email,
                            userName: userName,
                            location: "North India"
                        )
                        
                        print("✅ User created in both Auth and UserTable")
                        
                        // Store login state
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(email, forKey: "userEmail")
                        
                        hideLoadingIndicator()
                        // Show complete profile screen
                        let completeProfileVC = CompleteProfileViewController()
                        completeProfileVC.modalPresentationStyle = .fullScreen
                        present(completeProfileVC, animated: true)
                    } else {
                        throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to create user - no valid session"])
                    }
                } catch {
                    hideLoadingIndicator()
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
            
        case .otp:
            guard let otp = otpTextField.text, !otp.isEmpty else {
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
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc private func googleSignUpTapped() {
        showAlert(title: "Coming Soon", message: "Google Sign Up will be available soon!")
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
}

// MARK: - ASAuthorizationControllerDelegate
extension SignupViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // Store the user identifier
            UserDefaults.standard.set(userIdentifier, forKey: "appleUserIdentifier")
            
            // Get the identity token
            guard let identityToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: identityToken, encoding: .utf8) else {
                showAlert(title: "Error", message: "Could not get identity token")
                return
            }
            
            // Sign in with Supabase using Apple token
            Task {
                do {
                    showLoadingIndicator()
                    let (session, userData) = try await DataControllerGG.shared.signInWithApple(idToken: idTokenString)
                    
                    // Check if we have a valid session
                    if session.accessToken != nil {
                        // Get user email - first try Apple credential, then session
                        let userEmail = email ?? session.user.email
                        
                        // Create user name from Apple credential
                        var finalUserName = ""
                        if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                            finalUserName = "\(givenName) \(familyName)"
                        } else if let givenName = fullName?.givenName {
                            finalUserName = givenName
                        } else if let familyName = fullName?.familyName {
                            finalUserName = familyName
                        } else {
                            // If no name provided, use email prefix
                            if let emailPrefix = userEmail?.components(separatedBy: "@").first {
                                finalUserName = emailPrefix
                            } else {
                                finalUserName = "User_\(userIdentifier.prefix(8))"  // Fallback username
                            }
                        }
                        
                        print("📝 User Data:")
                        print("Email: \(userEmail ?? "No email")")
                        print("Name: \(finalUserName)")
                        
                        // If user data doesn't exist, create new user profile
                        if userData == nil {
                            // Create user in UserTable with all available data
                            try await DataControllerGG.shared.createUser(
                                email: userEmail ?? "",
                                userName: finalUserName,
                                location: "North India"
                            )
                            
                            // Try to save additional profile data
                            try await DataControllerGG.shared.saveUserProfile(userData: [
                                "id": userIdentifier,
                                "user_email": userEmail ?? "",
                                "userName": finalUserName,
                                "user_name": finalUserName,
                                "location": "North India",
                                "reminderAllowed": true,
                                "age": 0,
                                "gender": "",
                                "plant_preferences": []
                            ])
                            
                            print("✅ User profile created in UserTable with full data")
                        } else {
                            // Update existing user's data if needed
                            try await DataControllerGG.shared.saveUserProfile(userData: [
                                "user_email": userEmail ?? "",
                                "userName": finalUserName,
                                "user_name": finalUserName
                            ])
                            print("✅ Updated existing user profile with Apple data")
                        }
                        
                        // Store login state
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(userEmail ?? "", forKey: "userEmail")
                        
                        hideLoadingIndicator()
                        NotificationCenter.default.post(name: .showMainApp, object: nil)
                    } else {
                        throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid session"])
                    }
                } catch {
                    hideLoadingIndicator()
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension SignupViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
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

// Add UITextFieldDelegate methods
extension SignupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Ensure we're on main thread for UI updates
        DispatchQueue.main.async {
            if textField == self.passwordTextField || textField == self.confirmPasswordTextField {
                // Get the updated text
                let currentText = (textField.text ?? "") as NSString
                let updatedText = currentText.replacingCharacters(in: range, with: string)
                
                // If it's the password field, check strength as user types
                if textField == self.passwordTextField && !updatedText.isEmpty {
                    if !self.isValidPassword(updatedText) {
                        textField.layer.borderColor = UIColor.systemRed.cgColor
                        textField.layer.borderWidth = 1
                    } else {
                        textField.layer.borderColor = UIColor.systemGreen.cgColor
                        textField.layer.borderWidth = 1
                    }
                }
                
                // If it's the confirm password field, check if it matches
                if textField == self.confirmPasswordTextField && !updatedText.isEmpty {
                    if updatedText != self.passwordTextField.text {
                        textField.layer.borderColor = UIColor.systemRed.cgColor
                        textField.layer.borderWidth = 1
                    } else {
                        textField.layer.borderColor = UIColor.systemGreen.cgColor
                        textField.layer.borderWidth = 1
                    }
                }
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Reset border when field loses focus if it's empty
        if textField.text?.isEmpty ?? true {
            textField.layer.borderWidth = 0
            textField.layer.borderColor = nil
        }
    }
} 
