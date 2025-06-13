import UIKit

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "GG11")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
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
        label.text = "Garden Guru"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(hex: "284329")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email or Phone"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: "F5F9F5")
        textField.layer.cornerRadius = 12
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: "F5F9F5")
        textField.layer.cornerRadius = 12
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let showPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(UIColor(hex: "284329"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "284329")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "--------------------- OR ---------------------"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.backgroundColor = UIColor(hex: "F5F9F5")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signInWithAppleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("Sign in with Apple", for: .normal)
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
    
    private let signInWithGoogleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Sign in with Google", for: .normal)
        button.setImage(UIImage(named: "google2"), for: .normal)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let signUpContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "New here? "
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(UIColor(hex: "284329"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.isEnabled = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "F5F9F5")
        
        // Add scroll view and content view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Disable scrolling since we don't need it for login screen
        scrollView.isScrollEnabled = false
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        
        // Add subviews
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(containerView)
        
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(showPasswordButton)
        containerView.addSubview(forgotPasswordButton)
        containerView.addSubview(loginButton)
        loginButton.addSubview(loadingIndicator)
        
        contentView.addSubview(orLabel)
        contentView.addSubview(signInWithAppleButton)
        contentView.addSubview(signInWithGoogleButton)
        
        contentView.addSubview(signUpContainer)
        signUpContainer.addSubview(signUpLabel)
        signUpContainer.addSubview(signUpButton)
        
        // Make sure signUpContainer and its contents are user interaction enabled
        signUpContainer.isUserInteractionEnabled = true
        signUpLabel.isUserInteractionEnabled = true
        signUpButton.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            // Update scroll view constraints to use safe area
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Fix content view to be exactly the size of the scroll view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            logoImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            containerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emailTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            showPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -16),
            showPasswordButton.widthAnchor.constraint(equalToConstant: 24),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 24),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            
            orLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24),
            orLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            signInWithAppleButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 24),
            signInWithAppleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            signInWithGoogleButton.topAnchor.constraint(equalTo: signInWithAppleButton.bottomAnchor, constant: 16),
            signInWithGoogleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            signInWithGoogleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            signUpContainer.topAnchor.constraint(equalTo: signInWithGoogleButton.bottomAnchor, constant: 24),
            signUpContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            signUpContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            signUpContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            signUpContainer.heightAnchor.constraint(equalToConstant: 44),
            
            signUpLabel.centerYAnchor.constraint(equalTo: signUpContainer.centerYAnchor),
            signUpLabel.centerXAnchor.constraint(equalTo: signUpContainer.centerXAnchor, constant: -30),
            
            signUpButton.centerYAnchor.constraint(equalTo: signUpContainer.centerYAnchor),
            signUpButton.leadingAnchor.constraint(equalTo: signUpLabel.trailingAnchor, constant: 4),
            signUpButton.heightAnchor.constraint(equalToConstant: 44),
            signUpButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        // Remove any divider views
        dividerView.removeFromSuperview()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        // Print statement to verify setup
        print("Setting up actions...")
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        
        // Add target with debug print
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        print("Sign up button target added")
        
        // Add text field delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        showPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
   
    
    @objc private func forgotPasswordButtonTapped() {
        let forgotPasswordVC = ForgotPasswordViewController()
        let navigationController = UINavigationController(rootViewController: forgotPasswordVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.prefersLargeTitles = false
        
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "F5F9F5")
        appearance.shadowColor = nil // Remove the shadow line
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        
        present(navigationController, animated: true)
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text,
              !email.isEmpty, !password.isEmpty else {
            showAlert(message: "Please enter both email and password")
            return
        }
        
        print("🔑 Attempting login with email: \(email)")
        
        // Start loading
        loadingIndicator.startAnimating()
        loginButton.setTitle("", for: .normal)
        loginButton.isEnabled = false
        
        Task {
            do {
                print("📡 Starting authentication...")
                let (session, userData) = try await dataController.signIn(email: email, password: password)
                
                if session.user != nil {
                    print("✅ User authenticated successfully")
                    
                    // Store credentials securely
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    KeychainManager.shared.save(password, for: "userPassword_\(email)")
                    
                    if userData == nil {
                        print("⚠️ Warning: User authenticated but no profile data found")
                    }
                    
                    // Show success and navigate
                    await MainActor.run { [weak self] in
                        self?.hideLoadingIndicator()
                        self?.showSuccessAndNavigate()
                    }
                } else {
                    throw NSError(domain: "LoginError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
                }
            } catch let error as NSError {
                print("❌ Login error: \(error)")
                
                await MainActor.run { [weak self] in
                    self?.hideLoadingIndicator()
                    
                    if error.domain == NSURLErrorDomain {
                        self?.showAlert(message: "Network error. Please check your connection and try again.")
                    } else if error.localizedDescription.contains("Invalid login credentials") {
                        self?.showAlert(message: "Invalid email or password")
                    } else {
                        self?.showAlert(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        loginButton.setTitle("Sign In", for: .normal)
        loginButton.isEnabled = true
    }
    
    private func showSuccessAndNavigate() {
        // Show success alert
        let alert = UIAlertController(title: "Success", message: "Login successful!", preferredStyle: .alert)
        present(alert, animated: true)
        
        // Dismiss alert after 1 second and navigate
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            alert.dismiss(animated: true) {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                    tabBarController.modalPresentationStyle = .fullScreen
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        UIView.transition(with: window,
                                      duration: 0.3,
                                      options: .transitionCrossDissolve,
                                      animations: {
                            window.rootViewController = tabBarController
                        })
                        window.makeKeyAndVisible()
                    }
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func signUpButtonTapped() {
        // Add visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.signUpButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.signUpButton.transform = CGAffineTransform.identity
            }
        }

        let signupVC = SignupViewController()
        let navigationController = UINavigationController(rootViewController: signupVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        // Configure navigation bar appearance to match your theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "F5F9F5")
        appearance.shadowColor = nil // Remove the shadow line
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        
        present(navigationController, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Add animation for focus
        UIView.animate(withDuration: 0.3) {
            textField.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor(hex: "284329").cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Remove animation when losing focus
        UIView.animate(withDuration: 0.3) {
            textField.transform = .identity
            textField.layer.borderWidth = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginButtonTapped()
        }
        return true
    }
} 
