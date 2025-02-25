////
////  ChatViewController.swift
////  ReadBuddyAi
////
////  Created by Deepanshu-Maliyan-Mac on 16/01/25.
////
//import UIKit
//import GoogleGenerativeAI
//
//class ChatViewController: UIViewController {
//    private var messages: [Message] = []
//
//    
//    private let tableView: UITableView = {
//        let table = UITableView()
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.separatorStyle = .none
//        table.backgroundColor = .systemBackground
//        return table
//    }()
//    
//    private let inputContainer: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .systemBackground
//        return view
//    }()
//    
//    private let inputTextField: UITextField = {
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.placeholder = "Type your question..."
//        textField.borderStyle = .roundedRect
//        return textField
//    }()
//    
//    private let sendButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Send", for: .normal)
//        return button
//    }()
//    private let quickRepliesButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        // Using SF Symbol for the button
//        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
//        let image = UIImage(systemName: "list.bullet.circle.fill", withConfiguration: config)
//        button.setImage(image, for: .normal)
//        button.tintColor = .systemBlue
//        return button
//    }()
//    
//    //MARK: - Generative AI Model and Key
//    private var model: GenerativeModel!
//        
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            setupGeminiModel()
//            setupNavigation()
//            setupUI()
//            setupActions()
//        }
//        
//        private func setupGeminiModel() {
//            do {
//                let apiKey = try ConfigManager.shared.getGeminiAPIKey()
//                model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
//            } catch {
//                showAPIKeyError()
//            }
//        }
//        
//        private func showAPIKeyError() {
//            let alert = UIAlertController(
//                title: "Configuration Error",
//                message: "Failed to load API key. Please check your Config.plist file.",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//        }
//    
//    
//  
//    private func setupNavigation() {
//            title = "Read Buddy"
//            navigationController?.navigationBar.prefersLargeTitles = true
//            
//            // Add quick replies button
//            let quickRepliesButton = UIBarButtonItem(
//                image: UIImage(systemName: "list.bullet.circle.fill"),
//                style: .plain,
//                target: self,
//                action: #selector(showQuickReplies)
//            )
//            navigationItem.rightBarButtonItem = quickRepliesButton
//        }
//    
//    
//    
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
////        title = "Read Buddy"
//        
//        view.addSubview(tableView)
//        view.addSubview(inputContainer)
//        inputContainer.addSubview(inputTextField)
//        inputContainer.addSubview(sendButton)
//        
//        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),
//            
//            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            inputContainer.heightAnchor.constraint(equalToConstant: 60),
//            
//            inputTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
//            inputTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
//            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
//            
//            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
//            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
//            sendButton.widthAnchor.constraint(equalToConstant: 60)
//        ])
//    }
//    
//    private func setupActions() {
//        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
//        quickRepliesButton.addTarget(self, action: #selector(showQuickReplies), for: .touchUpInside)
//    }
//    
//    
//    
//    @objc private func sendMessage() {
//        guard let text = inputTextField.text, !text.isEmpty else { return }
//        
//        let userMessage = Message(content: text, isUser: true)
//        messages.append(userMessage)
//        inputTextField.text = ""
//        
//        let prompt = """
//        Act as an English language teacher. For the following input: "\(text)"
//        Provide:
//        1. Definition
//        2. Examples of usage
//        3. Synonyms (if applicable)
//        4. Additional context or tips
//        Format the response clearly with headers.
//        """
//        
//        Task {
//            do {
//                let response = try await model.generateContent(prompt)
//                if let responseText = response.text {
//                    let botMessage = Message(content: responseText, isUser: false)
//                    messages.append(botMessage)
//                    
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.scrollToBottom()
//                    }
//                }
//            } catch {
//                print("Error generating response: \(error)")
//            }
//        }
//        
//        tableView.reloadData()
//        scrollToBottom()
//    }
//    
//    private func scrollToBottom() {
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//    }
//    
//    
//    
//    
//    @objc private func showQuickReplies() {
//        let alertController = UIAlertController(title: "Quick Replies",
//                                                message: nil,
//                                                preferredStyle: .actionSheet)
//        
//        let actions = [
//            "What's the meaning of this word?",
//            "Give me examples of usage",
//            "What are the synonyms?",
//            "How do I pronounce this?",
//            "Explain the grammar"
//        ]
//        
//        actions.forEach { action in
//            alertController.addAction(UIAlertAction(title: action, style: .default) { [weak self] _ in
//                self?.inputTextField.text = action
//            })
//        }
//        
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        // For iPad support
//        if let popover = alertController.popoverPresentationController {
//            popover.sourceView = quickRepliesButton
//            popover.sourceRect = quickRepliesButton.bounds
//        }
//        
//        present(alertController, animated: true)
//    }
//}
//
//extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as? MessageCell else {
//            return UITableViewCell()
//        }
//        
//        let message = messages[indexPath.row]
//        cell.configure(with: message)
//        return cell
//    }
//}
//
//
//  ViewController.swift
//  ReadBuddyAi
//
//  Created by Deepanshu-Maliyan-Mac on 16/01/25.
//
import UIKit
import GoogleGenerativeAI

class ChatViewController: UIViewController {
    private var messages: [Message] = []
//    private let model = GenerativeModel(name: "", apiKey: "APIConfig.geminiAPIKey")
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.backgroundColor = .systemBackground
        return table
    }()
    
    private let inputContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        // Add shadow and border
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Type your question..."
        textField.borderStyle = .none // Remove default border
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 20
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.rightViewMode = .always
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        // Use SF Symbol for send button
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    private let quickRepliesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        // Using SF Symbol for the button
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let image = UIImage(systemName: "list.bullet.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    //MARK: - Generative AI Model and Key
    private var model: GenerativeModel!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            hideKeyboardWhenTappedAround()
            setupGeminiModel()
            setupNavigation()
            setupUI()
            setupActions()
        }
        
        private func setupGeminiModel() {
            do {
                let apiKey = try ConfigManager.shared.getGeminiAPIKey()
                model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
            } catch {
                showAPIKeyError()
            }
        }
        
        private func showAPIKeyError() {
            let alert = UIAlertController(
                title: "Configuration Error",
                message: "Failed to load API key. Please check your Config.plist file.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    
   // MARK: - SETUP NAVIGATION
//    private func setupNavigation() {
//        title = "Read Buddy"
//        navigationController?.navigationBar.prefersLargeTitles = true
//
//        // Add quick replies button to navigation bar
//        let rightBarButton = UIBarButtonItem(customView: quickRepliesButton)
//        navigationItem.rightBarButtonItem = rightBarButton
//
//        // Optional: Customize navigation bar appearance
//        if let navigationBar = navigationController?.navigationBar {
//            navigationBar.tintColor = .systemBlue
//            navigationBar.largeTitleTextAttributes = [
//                .foregroundColor: UIColor.label,
//                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
//            ]
//        }
//    }
    
    private func setupNavigation() {
            // Set the title
            self.title = "Read Buddy"
            
            // Enable large titles
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            
            // Optional: Customize navigation bar appearance
            if let navigationBar = navigationController?.navigationBar {
                navigationBar.tintColor = .systemBlue
                navigationBar.largeTitleTextAttributes = [
                    .foregroundColor: UIColor.label,
                    .font: UIFont.systemFont(ofSize: 34, weight: .bold)
                ]
            }
            
            // Optional: Add right button if needed
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                customView: quickRepliesButton
            )
        }
        
    
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
//        title = "Read Buddy"
        
        view.addSubview(tableView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(inputTextField)
        inputContainer.addSubview(sendButton)
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),
            
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 80),
            
            inputTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            inputTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputTextField.heightAnchor.constraint(equalToConstant: 40),
            
            
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        quickRepliesButton.addTarget(self, action: #selector(showQuickReplies), for: .touchUpInside)
    }
    
    
    
    @objc private func sendMessage() {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        
        let userMessage = Message(content: text, isUser: true)
        messages.append(userMessage)
        inputTextField.text = ""
        
        let prompt = """
        Act as an English language teacher. For the following input: "\(text)"
        Provide:
        1. Definition
        2. Examples of usage
        3. Synonyms (if applicable)
        4. Additional context or tips
        Format the response clearly with headers.
        """
        
        Task {
            do {
                let response = try await model.generateContent(prompt)
                if let responseText = response.text {
                    let botMessage = Message(content: responseText, isUser: false)
                    messages.append(botMessage)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                }
            } catch {
                print("Error generating response: \(error)")
            }
        }
        
        tableView.reloadData()
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    
    
    
    @objc private func showQuickReplies() {
        let alertController = UIAlertController(title: "Quick Replies",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let actions = [
            "What's the meaning of this word?",
            "Give me examples of usage",
            "What are the synonyms?",
            "How do I pronounce this?",
            "Explain the grammar"
        ]
        
        actions.forEach { action in
            alertController.addAction(UIAlertAction(title: action, style: .default) { [weak self] _ in
                self?.inputTextField.text = action
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = quickRepliesButton
            popover.sourceRect = quickRepliesButton.bounds
        }
        
        present(alertController, animated: true)
    }

    // Add these methods to handle keyboard
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let bottomInset = keyboardSize.height - view.safeAreaInsets.bottom
        inputContainer.transform = CGAffineTransform(translationX: 0, y: -bottomInset)
        tableView.contentInset.bottom = bottomInset
        tableView.verticalScrollIndicatorInsets.bottom = bottomInset
        
        if !messages.isEmpty {
            scrollToBottom()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        inputContainer.transform = .identity
        tableView.contentInset.bottom = 0
        tableView.verticalScrollIndicatorInsets.bottom = 0
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
}

