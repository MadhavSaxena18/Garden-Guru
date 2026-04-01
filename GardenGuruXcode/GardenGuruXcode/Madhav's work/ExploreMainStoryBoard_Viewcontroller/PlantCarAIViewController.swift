//
//  PlantCarAIViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 21/01/25.
//

import UIKit
import GoogleGenerativeAI

class PlantCarAIViewController: UIViewController {
    private var messages: [Message] = []
    private var model: GenerativeModel!
    private var userPlants: [(userPlant: UserPlant, plant: Plant)] = []
    private var userEmail: String?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.backgroundColor = UIColor(hex: "EBF4EB")
        return table
    }()
    
    private let inputContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Ask about plant care..."
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 20
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.rightViewMode = .always
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(hex: "284329")
        return button
    }()
    
    private let quickRepliesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let image = UIImage(systemName: "list.bullet.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(hex: "284329")
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupGeminiModel()
        setupNavigation()
        setupUI()
        setupActions()
        loadUserPlants()
    }
    
    private func loadUserPlants() {
        userEmail = UserDefaults.standard.string(forKey: "userEmail")
        guard let email = userEmail else { return }
        
        Task {
            do {
                userPlants = try await DataControllerGG.shared.getUserPlantsWithBasicDetails(for: email)
                print("✅ Loaded \(userPlants.count) user plants for PlantCarAI")
            } catch {
                print("❌ Error loading user plants: \(error)")
            }
        }
    }
    
//    private func setupGeminiModel() {
//        do {
//            let apiKey = try ConfigManager.shared.getGeminiAPIKey()
//            model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
//        } catch {
//            showAPIKeyError()
//        }
//    }
    
    private func setupGeminiModel() {
        // Validate configuration first
        guard APIConfig.validateConfiguration() else {
            print("❌ API configuration validation failed")
            showAPIKeyError()
            return
        }
        
        let apiKey = APIConfig.geminiAPIKey
        print("🔑 Using API Key from configuration")
        print("🌐 Model: \(APIConfig.geminiModel)")
        
        model = GenerativeModel(name: APIConfig.geminiModel, apiKey: apiKey)
        print("✅ Gemini model initialized successfully")
    }
    private func showAPIKeyError() {
        let alert = UIAlertController(
            title: "Configuration Error",
            message: "Failed to load API key. Please check your configuration.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupNavigation() {
        self.title = "Plant Doctor"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Change from X to Done button
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(dismissVC)
        )
        navigationItem.leftBarButtonItem = doneButton
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = UIColor(hex: "284329")
            navigationBar.largeTitleTextAttributes = [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: quickRepliesButton
        )
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "EBF4EB")
        
        view.addSubview(tableView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(inputTextField)
        inputContainer.addSubview(sendButton)
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        inputContainer.backgroundColor = UIColor(hex: "EBF4EB")
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
        
        // Build conversation history
        var conversation = ""
        for message in messages {
            if message.isUser {
                conversation += "User: \(message.content)\n"
            } else {
                conversation += "Plant Doctor: \(message.content)\n"
            }
        }
        // Build context about user's plants
        var plantContext = ""
        if !userPlants.isEmpty {
            let plantNames = userPlants.map { $0.plant.plantName }.joined(separator: ", ")
            plantContext = "\n\nUser's Plants: \(plantNames)"
        }
        
        // Get current season
        let month = Calendar.current.component(.month, from: Date())
        let season = getSeason(for: month)
        
        // Add instruction for the model
        let prompt = """
        You are a friendly plant doctor helping a gardener. Continue the conversation below, replying as a human expert would. Be brief, clear, and conversational.\(plantContext)
        Current Season: \(season)
        Location: India
        
        IMPORTANT: Write in plain text without any markdown formatting. Don't use asterisks, underscores, or special characters for emphasis. Use simple bullet points (•) if listing items. Write naturally as if texting a friend.
        
        \(conversation)Plant Doctor:
        """
        
        Task {
            do {
                let response = try await model.generateContent(prompt)
                if let responseText = response.text {
                    // Clean up markdown formatting for more natural appearance
                    let cleanedText = cleanMarkdownFormatting(responseText)
                    let botMessage = Message(content: cleanedText, isUser: false)
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
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc private func showQuickReplies() {
        let alertController = UIAlertController(
            title: "Quick Questions",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        var actions: [String] = []
        
        // Add plant-specific questions if user has plants
        if !userPlants.isEmpty {
            let plantNames = userPlants.prefix(3).map { $0.plant.plantName }
            
            if plantNames.count == 1 {
                actions.append("How do I care for my \(plantNames[0])?")
                actions.append("Is my \(plantNames[0]) getting enough light?")
            } else {
                actions.append("Care tips for my plants")
                actions.append("Which of my plants needs more attention?")
            }
        }
        
        // Add seasonal questions
        let month = Calendar.current.component(.month, from: Date())
        let season = getSeason(for: month)
        actions.append("Best plants to grow in \(season)")
        actions.append("What should I plant this season?")
        
        // Add general questions
        actions.append("Signs of overwatering")
        actions.append("Common plant diseases and treatments")
        actions.append("Best organic fertilizers")
        
        actions.forEach { action in
            alertController.addAction(UIAlertAction(title: action, style: .default) { [weak self] _ in
                self?.inputTextField.text = action
                self?.sendMessage()
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = quickRepliesButton
            popover.sourceRect = quickRepliesButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    private func getSeason(for month: Int) -> String {
        switch month {
        case 3...5: return "Spring"
        case 6...9: return "Monsoon/Summer"
        case 10...11: return "Autumn"
        case 12, 1, 2: return "Winter"
        default: return "Current Season"
        }
    }
    
    private func cleanMarkdownFormatting(_ text: String) -> String {
        var cleaned = text
        
        // Remove bold markers (**text**)
        cleaned = cleaned.replacingOccurrences(of: "**", with: "")
        
        // Remove italic markers (*text* or _text_)
        cleaned = cleaned.replacingOccurrences(of: "*", with: "")
        cleaned = cleaned.replacingOccurrences(of: "_", with: "")
        
        // Remove code markers (`text`)
        cleaned = cleaned.replacingOccurrences(of: "`", with: "")
        
        // Clean up bullet points - replace markdown bullets with proper bullets
        cleaned = cleaned.replacingOccurrences(of: "- ", with: "• ")
        
        // Remove extra whitespace
        cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
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
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}

extension PlantCarAIViewController: UITableViewDelegate, UITableViewDataSource {
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
