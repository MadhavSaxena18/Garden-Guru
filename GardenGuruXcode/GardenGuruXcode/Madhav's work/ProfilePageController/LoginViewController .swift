import UIKit
import AuthenticationServices
import GoogleSignIn

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
        view.backgroundColor = ThemeManager.Colors.background
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
        label.textColor = ThemeManager.Colors.primary
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
        button.setTitleColor(ThemeManager.Colors.primary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = ThemeManager.Colors.primary
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
        button.backgroundColor = ThemeManager.Colors.background
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
        button.setTitleColor(ThemeManager.Colors.primary, for: .normal)
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
        addSkipButton()
        
        // Debug button setup
        signInWithAppleButton.addAction(UIAction { [weak self] _ in
            print("Apple button tapped in Login")
        }, for: .touchUpInside)
        
        // Verify button properties
        print("📱 Button Setup Verification:")
        print("Apple Button isEnabled: \(signInWithAppleButton.isEnabled)")
        print("Apple Button isUserInteractionEnabled: \(signInWithAppleButton.isUserInteractionEnabled)")
        print("Apple Button frame: \(signInWithAppleButton.frame)")
        print("Apple Button superview: \(String(describing: signInWithAppleButton.superview))")
    }
    
    private func addSkipButton() {
        // Add Skip button to navigation bar
        let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skipButtonTapped))
        skipButton.tintColor = ThemeManager.Colors.primary
        navigationItem.rightBarButtonItem = skipButton
    }
    
    @objc private func skipButtonTapped() {
        // Navigate to main app as guest
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            tabBarController.modalPresentationStyle = .fullScreen
            
            // Make sure guest mode is set
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            
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
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        signInWithAppleButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        signInWithGoogleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        
        // Add debug print to verify button setup
        print("🔘 Setup Actions - Buttons connected:")
        print("✓ Login Button")
        print("✓ Show Password Button")
        print("✓ Forgot Password Button")
        print("✓ Sign Up Button")
        print("✓ Apple Sign In Button")
        print("✓ Google Sign In Button")
        
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

    @objc private func appleSignInTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @objc private func googleSignInTapped() {
        // Check if Google Sign In is configured
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
              !clientID.contains("YOUR_GOOGLE_CLIENT_ID") else {
            let alert = UIAlertController(
                title: "Setup Required",
                message: "Google Sign In needs to be configured.\n\nPlease replace 'YOUR_GOOGLE_CLIENT_ID' in Info.plist with your actual Google Client ID.\n\nFor now, please use:\n• Email & Password\n• Sign in with Apple",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Generate a random nonce for security
        let nonce = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        print("🔐 Generated nonce: \(nonce)")
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Sign in with nonce parameter
        GIDSignIn.sharedInstance.signIn(withPresenting: self, hint: nil, additionalScopes: nil) { [weak self, nonce] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleGoogleSignInError(error)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.showAlert(message: "Failed to get user information from Google")
                return
            }
            
            print("✅ Google Sign In successful")
            
            // Sign in with Supabase - DON'T pass nonce, let Supabase handle validation
            Task {
                do {
                    self.loadingIndicator.startAnimating()
                    print("🔐 Attempting Supabase authentication with Google token")
                    
                    // Try without nonce first - Supabase will extract it from the ID token
                    let (session, userData) = try await self.dataController.signInWithGoogleToken(idToken: idToken)
                    
                    if session.accessToken != nil {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(user.profile?.email, forKey: "userEmail")
                        
                        if userData == nil {
                            print("⚠️ Warning: User authenticated but no profile data found")
                        }
                        
                        await MainActor.run {
                            self.hideLoadingIndicator()
                            self.showSuccessAndNavigate()
                        }
                    } else {
                        throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid session"])
                    }
                } catch {
                    print("❌ Google Sign In Error: \(error)")
                    print("   Error Description: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("   Domain: \(nsError.domain)")
                        print("   Code: \(nsError.code)")
                        print("   User Info: \(nsError.userInfo)")
                    }
                    
                    await MainActor.run {
                        self.hideLoadingIndicator()
                        
                        // Show more specific error message
                        var errorMessage = "Failed to sign in with Google. Please try again."
                        
                        if error.localizedDescription.contains("already registered") {
                            errorMessage = "This Google account is already registered. Please use Apple Sign In or Email/Password."
                        } else if error.localizedDescription.contains("network") || error.localizedDescription.contains("connection") {
                            errorMessage = "Network error. Please check your connection and try again."
                        } else if error.localizedDescription.contains("Google provider") || error.localizedDescription.contains("provider") {
                            errorMessage = "Google Sign In is temporarily unavailable. Please try:\n• Email & Password\n• Sign in with Apple"
                        }
                        
                        self.showAlert(message: errorMessage)
                    }
                }
            }
        }
    }
    
    private func handleGoogleSignInError(_ error: Error) {
        let nsError = error as NSError
        var errorMessage = "Failed to sign in with Google. Please try again."
        
        // Check for specific Google Sign In errors
        if nsError.domain == "com.google.GIDSignIn" {
            switch nsError.code {
            case -1: // Cancelled
                return // User cancelled - don't show error
            case -2: // No keychain
                errorMessage = "Keychain error. Please check your device settings."
            case -4: // No internet
                errorMessage = "No internet connection. Please check your network."
            case -5: // Sign in failed
                errorMessage = "Sign in failed. Please try again."
            default:
                errorMessage = "Failed to sign in with Google. Please try again."
            }
        }
        
        print("❌ Google Sign In Error: \(error.localizedDescription)")
        print("   Domain: \(nsError.domain)")
        print("   Code: \(nsError.code)")
        
        showAlert(message: errorMessage)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Add animation for focus
        UIView.animate(withDuration: 0.3) {
            textField.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            textField.layer.borderWidth = 1
            textField.layer.borderColor = ThemeManager.Colors.primary.cgColor
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

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            
            // Get the identity token
            guard let identityToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: identityToken, encoding: .utf8) else {
                showAlert(message: "Could not get identity token")
                return
            }
            
            // Sign in with Supabase using Apple token
            Task {
                do {
                    loadingIndicator.startAnimating()
                    let (session, userData) = try await dataController.signInWithApple(idToken: idTokenString)
                    
                    if session.accessToken != nil {
                        // Store login state
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(userIdentifier, forKey: "appleUserIdentifier")
                        
                        if userData == nil {
                            print("⚠️ Warning: User authenticated but no profile data found")
                        }
                        
                        await MainActor.run { [weak self] in
                            self?.hideLoadingIndicator()
                            self?.showSuccessAndNavigate()
                        }
                    } else {
                        throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid session"])
                    }
                } catch {
                    await MainActor.run { [weak self] in
                        self?.hideLoadingIndicator()
                        self?.showAlert(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Convert error to NSError to check error codes
        let nsError = error as NSError
        
        // Provide user-friendly error messages
        var errorMessage = "Failed to sign in with Apple. Please try again."
        
        // Check for specific Apple Sign In errors
        if let asError = error as? ASAuthorizationError {
            switch asError.code {
            case .canceled:
                // User cancelled - don't show error
                return
            case .unknown:
                errorMessage = "An unknown error occurred. Please try again."
            case .invalidResponse:
                errorMessage = "Invalid response from Apple. Please try again."
            case .notHandled:
                errorMessage = "Sign in could not be handled. Please try again."
            case .failed:
                errorMessage = "Sign in failed. Please try again."
            case .notInteractive:
                errorMessage = "This feature is not available. Please use email login."
            @unknown default:
                errorMessage = "Failed to sign in with Apple. Please try again."
            }
        }
        // Check for authorization error 1001
        else if nsError.domain == "com.apple.AuthenticationServices.AuthorizationError" && nsError.code == 1001 {
            errorMessage = "Apple Sign In is temporarily unavailable. Please try again later or use email login."
        }
        
        print("❌ Apple Sign In Error: \(error.localizedDescription)")
        print("   Domain: \(nsError.domain)")
        print("   Code: \(nsError.code)")
        
        showAlert(message: errorMessage)
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
} 
