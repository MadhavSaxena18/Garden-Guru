//
//  CreatePostViewController.swift
//  GardenGuruXcode
//
//  Created by Garden Guru Team
//

import UIKit
import PhotosUI

class CreatePostViewController: UIViewController {
    
    // MARK: - Properties
    
    private let dataController = DataControllerGG.shared
    private var selectedImage: UIImage?
    
    // MARK: - UI Components
    
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
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "F5F9F5")
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = ThemeManager.Colors.primary.withAlphaComponent(0.2).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = UIColor(hex: "F5F9F5")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Plant Photo", for: .normal)
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.tintColor = ThemeManager.Colors.primary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let plantNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Plant Name"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: "F5F9F5")
        textField.layer.cornerRadius = 12
        textField.font = .systemFont(ofSize: 16)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let plantNameCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/50"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = UIColor(hex: "F5F9F5")
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Share your plant story... (10-500 characters)"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/500"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Creating post..."
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔵 CreatePostViewController - viewDidLoad")
        setupUI()
        setupActions()
        setupKeyboardHandling()
        
        // Debug initial state
        print("🔍 Initial State:")
        print("   - Post button enabled: \(navigationItem.rightBarButtonItem?.isEnabled ?? false)")
        print("   - Selected image: \(selectedImage != nil)")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "EBF4EB")
        title = "Create Post"
        
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: ThemeManager.Colors.primary]
        appearance.largeTitleTextAttributes = [.foregroundColor: ThemeManager.Colors.primary]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = ThemeManager.Colors.primary
        
        // Navigation bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.Colors.primary
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(postButtonTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = ThemeManager.Colors.primary
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        imageContainerView.addSubview(selectImageButton)
        
        contentView.addSubview(plantNameTextField)
        contentView.addSubview(plantNameCountLabel)
        contentView.addSubview(descriptionTextView)
        descriptionTextView.addSubview(descriptionPlaceholder)
        contentView.addSubview(descriptionCountLabel)
        
        view.addSubview(loadingOverlay)
        loadingOverlay.addSubview(loadingIndicator)
        loadingOverlay.addSubview(loadingLabel)
        
        // Setup constraints
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
            
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageContainerView.heightAnchor.constraint(equalToConstant: 300),
            
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            selectImageButton.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            selectImageButton.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            
            plantNameTextField.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 20),
            plantNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            plantNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            plantNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            plantNameCountLabel.topAnchor.constraint(equalTo: plantNameTextField.bottomAnchor, constant: 4),
            plantNameCountLabel.trailingAnchor.constraint(equalTo: plantNameTextField.trailingAnchor),
            
            descriptionTextView.topAnchor.constraint(equalTo: plantNameCountLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 150),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 12),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 16),
            descriptionPlaceholder.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -16),
            
            descriptionCountLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4),
            descriptionCountLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 16),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        print("🔧 Setting up actions...")
        selectImageButton.addTarget(self, action: #selector(selectImageButtonTapped), for: .touchUpInside)
        plantNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        plantNameTextField.delegate = self
        descriptionTextView.delegate = self
        
        // Verify navigation bar buttons
        print("🔍 Navigation bar setup:")
        print("   - Left button (Cancel): \(navigationItem.leftBarButtonItem != nil)")
        print("   - Right button (Post): \(navigationItem.rightBarButtonItem != nil)")
        print("   - Post button enabled: \(navigationItem.rightBarButtonItem?.isEnabled ?? false)")
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func selectImageButtonTapped() {
        let alert = UIAlertController(title: "Select Photo", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = selectImageButton
            popover.sourceRect = selectImageButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        if selectedImage != nil || !(plantNameTextField.text?.isEmpty ?? true) || !descriptionTextView.text.isEmpty {
            let alert = UIAlertController(
                title: "Discard Post?",
                message: "Are you sure you want to discard this post?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func postButtonTapped() {
        print("\n🟢 POST BUTTON TAPPED!")
        print("📊 Current State:")
        print("   - Selected image: \(selectedImage != nil)")
        print("   - Plant name: '\(plantNameTextField.text ?? "")'")
        print("   - Description: '\(descriptionTextView.text ?? "")'")
        
        guard validateInput() else {
            print("❌ Validation failed")
            return
        }
        
        print("✅ Validation passed - Creating post...")
        Task {
            await createPost()
        }
    }
    
    @objc private func textFieldDidChange() {
        updateCharacterCounts()
        print("📝 Plant name changed: '\(plantNameTextField.text ?? "")' (\(plantNameTextField.text?.count ?? 0) characters)")
        validateAndUpdatePostButton()
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Image Selection
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - Validation
    
    private func validateInput() -> Bool {
        print("\n🔍 VALIDATING INPUT:")
        
        // Check image
        if selectedImage == nil {
            print("❌ No image selected")
            showError(message: "Please select a plant photo")
            return false
        }
        print("✅ Image selected")
        
        // Check plant name
        guard let plantName = plantNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("❌ Plant name is nil")
            showError(message: "Please enter a plant name")
            return false
        }
        
        print("📝 Plant name: '\(plantName)' (length: \(plantName.count))")
        
        if plantName.count < 2 {
            print("❌ Plant name too short: \(plantName.count) < 2")
            showError(message: "Plant name must be at least 2 characters")
            return false
        }
        
        if plantName.count > 50 {
            print("❌ Plant name too long: \(plantName.count) > 50")
            showError(message: "Plant name must be 50 characters or less")
            return false
        }
        print("✅ Plant name valid")
        
        // Check description
        let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        print("📝 Description: '\(description)' (length: \(description.count))")
        
        if description.count < 10 {
            print("❌ Description too short: \(description.count) < 10")
            showError(message: "Description must be at least 10 characters")
            return false
        }
        
        if description.count > 500 {
            print("❌ Description too long: \(description.count) > 500")
            showError(message: "Description must be 500 characters or less")
            return false
        }
        print("✅ Description valid")
        
        print("✅ ALL VALIDATION PASSED")
        return true
    }
    
    private func validateAndUpdatePostButton() {
        let hasImage = selectedImage != nil
        let plantNameCount = plantNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        let hasValidPlantName = plantNameCount >= 2
        let descriptionCount = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count
        let hasValidDescription = descriptionCount >= 10
        
        let shouldEnable = hasImage && hasValidPlantName && hasValidDescription
        
        print("🔄 Updating Post Button:")
        print("   - Has image: \(hasImage)")
        print("   - Plant name count: \(plantNameCount) (valid: \(hasValidPlantName))")
        print("   - Description count: \(descriptionCount) (valid: \(hasValidDescription))")
        print("   - Button should be enabled: \(shouldEnable)")
        
        navigationItem.rightBarButtonItem?.isEnabled = shouldEnable
        
        if shouldEnable {
            print("✅ Post button ENABLED")
        } else {
            print("⚠️ Post button DISABLED")
        }
    }
    
    private func updateCharacterCounts() {
        let plantNameCount = plantNameTextField.text?.count ?? 0
        plantNameCountLabel.text = "\(plantNameCount)/50"
        plantNameCountLabel.textColor = plantNameCount > 50 ? .systemRed : .systemGray
        
        let descriptionCount = descriptionTextView.text.count
        descriptionCountLabel.text = "\(descriptionCount)/500"
        descriptionCountLabel.textColor = descriptionCount > 500 ? .systemRed : .systemGray
    }
    
    // MARK: - Post Creation
    
    private func createPost() async {
        print("\n🚀 CREATE POST STARTED")
        
        guard let image = selectedImage else {
            print("❌ No image in createPost")
            return
        }
        print("✅ Image available")
        
        guard let plantName = plantNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !plantName.isEmpty else {
            print("❌ No plant name in createPost")
            return
        }
        print("✅ Plant name: '\(plantName)'")
        
        let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        print("✅ Description: '\(description)'")
        
        await MainActor.run {
            print("🔄 Showing loading overlay...")
            showLoading()
        }
        
        do {
            print("📤 Calling dataController.createCommunityPost...")
            let post = try await dataController.createCommunityPost(
                plantName: plantName,
                description: description,
                image: image
            )
            
            print("✅ Post created successfully!")
            print("   - Post ID: \(post.postID)")
            print("   - Image URL: \(post.imageURL)")
            
            await MainActor.run {
                print("🔄 Hiding loading and dismissing...")
                hideLoading()
                dismiss(animated: true)
                print("✅ View dismissed")
            }
        } catch {
            print("❌ ERROR creating post: \(error)")
            print("   - Error type: \(type(of: error))")
            print("   - Error description: \(error.localizedDescription)")
            
            await MainActor.run {
                hideLoading()
                showError(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func showLoading() {
        loadingOverlay.isHidden = false
        loadingIndicator.startAnimating()
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func hideLoading() {
        loadingOverlay.isHidden = true
        loadingIndicator.stopAnimating()
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\n📸 Image Picker - Image Selected")
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            print("✅ Image loaded successfully")
            print("   - Size: \(image.size)")
            selectedImage = image
            imageView.image = image
            selectImageButton.isHidden = true
            validateAndUpdatePostButton()
        } else {
            print("❌ Failed to load image from picker")
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CreatePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("\n📸 PHPicker - Image Selected")
        picker.dismiss(animated: true)
        
        guard let result = results.first else {
            print("❌ No result from PHPicker")
            return
        }
        
        print("🔄 Loading image from PHPicker...")
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
            if let error = error {
                print("❌ Error loading image: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                if let image = reading as? UIImage {
                    print("✅ Image loaded successfully from PHPicker")
                    print("   - Size: \(image.size)")
                    self?.selectedImage = image
                    self?.imageView.image = image
                    self?.selectImageButton.isHidden = true
                    self?.validateAndUpdatePostButton()
                } else {
                    print("❌ Failed to cast reading to UIImage")
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension CreatePostViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 50
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension CreatePostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
        updateCharacterCounts()
        print("📝 Description changed: \(textView.text.count) characters")
        validateAndUpdatePostButton()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 500
    }
}
