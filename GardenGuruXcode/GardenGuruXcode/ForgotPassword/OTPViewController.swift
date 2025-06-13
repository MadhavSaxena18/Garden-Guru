import UIKit

class OTPViewController: UIViewController {
    
    private let email: String
    
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
    
    private let otpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "password")
        imageView.contentMode = .scaleAspectFit
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
        label.text = "Enter Verification Code"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(hex: "284329")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let otpStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var otpTextFields: [UITextField] = []
    
    private let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "284329")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resendContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let resendLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't receive the OTP?"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RESEND OTP", for: .normal)
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
        setupOTPFields()
        updateSubtitle()
    }
    
    private func setupNavigation() {
        title = "Verification"
        navigationController?.navigationBar.tintColor = UIColor(hex: "284329")
    }
    
    private func updateSubtitle() {
        let maskedEmail = email.replacingOccurrences(of: "(.*?)(.{2})@", with: "***$2@", options: .regularExpression)
        subtitleLabel.text = "We are automatically detecting a verification code sent to your email \(maskedEmail)"
    }
    
    private func setupOTPFields() {
        // Create 6 OTP text fields
        for i in 0..<6 {
            let textField = UITextField()
            textField.borderStyle = .none
            textField.backgroundColor = UIColor(hex: "F5F9F5")
            textField.layer.cornerRadius = 12
            textField.textAlignment = .center
            textField.font = .systemFont(ofSize: 24, weight: .bold)
            textField.keyboardType = .numberPad
            textField.tag = i
            textField.delegate = self
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            otpTextFields.append(textField)
            otpStackView.addArrangedSubview(textField)
            
            textField.heightAnchor.constraint(equalTo: textField.widthAnchor).isActive = true
        }
        
        // Focus first field
        otpTextFields.first?.becomeFirstResponder()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "F5F9F5")
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(otpImageView)
        contentView.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(otpStackView)
        containerView.addSubview(verifyButton)
        
        contentView.addSubview(resendContainer)
        resendContainer.addSubview(resendLabel)
        resendContainer.addSubview(resendButton)
        
        verifyButton.addSubview(loadingIndicator)
        
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
            
            otpImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            otpImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            otpImageView.widthAnchor.constraint(equalToConstant: 140),
            otpImageView.heightAnchor.constraint(equalToConstant: 140),
            
            containerView.topAnchor.constraint(equalTo: otpImageView.bottomAnchor, constant: 32),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            otpStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            otpStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            otpStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            otpStackView.heightAnchor.constraint(equalToConstant: 50),
            
            verifyButton.topAnchor.constraint(equalTo: otpStackView.bottomAnchor, constant: 32),
            verifyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            verifyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            verifyButton.heightAnchor.constraint(equalToConstant: 50),
            verifyButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            
            resendContainer.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24),
            resendContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            resendContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            resendContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            resendLabel.centerYAnchor.constraint(equalTo: resendContainer.centerYAnchor),
            resendLabel.trailingAnchor.constraint(equalTo: resendButton.leadingAnchor, constant: -8),
            
            resendButton.centerYAnchor.constraint(equalTo: resendContainer.centerYAnchor),
            resendButton.centerXAnchor.constraint(equalTo: resendContainer.centerXAnchor, constant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: verifyButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: verifyButton.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
    }
    
    @objc private func verifyButtonTapped() {
        let otp = otpTextFields.map { $0.text ?? "" }.joined()
        guard !otp.isEmpty && otp.count == 6 else {
            showAlert(title: "Error", message: "Please enter the complete verification code")
            return
        }
        
        showLoadingIndicator()
        
        Task {
            do {
                try await DataControllerGG.shared.verifyPasswordResetOTP(email: email, otp: otp)
                await MainActor.run {
                    hideLoadingIndicator()
                    let newPasswordVC = NewPasswordViewController(email: email)
                    navigationController?.pushViewController(newPasswordVC, animated: true)
                }
            } catch let error as NSError {
                await MainActor.run {
                    hideLoadingIndicator()
                    
                    // Check for OTP expiration
                    if let errorCode = error.userInfo["x-sb-error-code"] as? String,
                       errorCode == "otp_expired" {
                        let alert = UIAlertController(
                            title: "Code Expired",
                            message: "The verification code has expired. Would you like to send a new one?",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        alert.addAction(UIAlertAction(title: "Send New Code", style: .default) { [weak self] _ in
                            self?.resendButtonTapped()
                        })
                        present(alert, animated: true)
                    } else {
                        showAlert(title: "Error", message: "Invalid verification code. Please try again.")
                    }
                }
            }
        }
    }
    
    @objc private func resendButtonTapped() {
        showLoadingIndicator()
        
        Task {
            do {
                try await DataControllerGG.shared.sendPasswordResetOTP(email: email)
                await MainActor.run {
                    hideLoadingIndicator()
                    // Clear existing OTP fields
                    otpTextFields.forEach { $0.text = "" }
                    otpTextFields.first?.becomeFirstResponder()
                    
                    // Show success message
                    let alert = UIAlertController(
                        title: "Code Sent",
                        message: "A new verification code has been sent to your email",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                }
            } catch {
                await MainActor.run {
                    hideLoadingIndicator()
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
        verifyButton.setTitle("", for: .normal)
        verifyButton.isEnabled = false
        resendButton.isEnabled = false
        
        // Disable all OTP fields during loading
        otpTextFields.forEach { $0.isEnabled = false }
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        verifyButton.setTitle("Verify", for: .normal)
        verifyButton.isEnabled = true
        resendButton.isEnabled = true
        
        // Re-enable all OTP fields after loading
        otpTextFields.forEach { $0.isEnabled = true }
    }
}

extension OTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Handle backspace
        if string.isEmpty {
            // Clear current field
            textField.text = ""
            
            // Move to previous field if exists, without clearing it
            if textField.tag > 0 {
                otpTextFields[textField.tag - 1].becomeFirstResponder()
            }
            return false
        }
        
        // Only allow single digit numbers
        guard string.count == 1, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        
        // Update current field
        textField.text = string
        
        // Move to next field if exists
        if textField.tag < otpTextFields.count - 1 {
            otpTextFields[textField.tag + 1].becomeFirstResponder()
        } else {
            // If we're on the last field, check if the OTP is complete
            let otp = otpTextFields.map { $0.text ?? "" }.joined()
            if otp.count == 6 {
                textField.resignFirstResponder()
            }
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Highlight the current field
        UIView.animate(withDuration: 0.2) {
            textField.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor(hex: "284329").cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Remove highlight
        UIView.animate(withDuration: 0.2) {
            textField.transform = .identity
            textField.layer.borderWidth = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
} 
