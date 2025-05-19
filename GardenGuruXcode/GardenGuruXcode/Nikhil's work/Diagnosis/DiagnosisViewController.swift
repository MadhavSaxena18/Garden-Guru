import UIKit

struct DiagnosisDataModel {
    var plantName: String
    var diagnosis: String
    var botanicalName: String
    var sectionDetails: [String: [String]]
}

class DiagnosisViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UI Elements
    private let plantImageView = UIImageView()
    private let overlayView = UIView()
    static var plantNameLabel = UILabel()
    static var diagnosisLabel = UILabel()
    private let plantDetailsLabel = UILabel()
    static var detailsStackView = UIStackView()
    private let tableView = UITableView()
    private let startCaringButton = UIButton()

    let dataController : DataControllerGG = DataControllerGG.shared
    // Data
    var selectedPlant: DiagnosisDataModel?
    private var expandedSections: Set<Int> = []
    private var sectionTitles: [String] {
        return selectedPlant?.sectionDetails.keys.sorted() ?? []
    }

    // Add this property at the top of the class
    private var isExistingPlant: Bool = false
    private var hasUserResponded: Bool = false

    // Add these properties at the top of DiagnosisViewController class
    private let healthyAnimationView = UIView()
    private let healthyLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n=== DiagnosisViewController Loading ===")
        
        view.backgroundColor = UIColor(hex: "#EBF4EB")
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Initially hide UI elements until we verify the plant
        startCaringButton.isHidden = true
        tableView.isHidden = true
        healthyAnimationView.isHidden = true
        plantDetailsLabel.isHidden = true
        
        setupUI()
        setupConstraints()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Diagnosis"
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DiagnosisCell")
        tableView.backgroundColor = UIColor(hex: "#EBF4EB")
        tableView.isHidden = false
        tableView.reloadData()
        
        self.tabBarController?.tabBar.isHidden = true
        
        // Initialize plant check
        initializePlantCheck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure tab bar stays hidden
        self.tabBarController?.tabBar.isHidden = true
        
        // Add this to handle the back button action
        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Double ensure tab bar stays hidden
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Only show tab bar when actually leaving the view
        if isMovingFromParent {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    // Override the back button action
//    override func willMove(toParent parent: UIViewController?) {
//        super.willMove(toParent: parent)
//        if parent == nil { // This means we're being popped
//            showBackAlert()
//        }
//    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        // Plant Image
        plantImageView.image = scanAndDiagnoseViewController.capturedImages[2]
        plantImageView.contentMode = .scaleAspectFill
        plantImageView.clipsToBounds = true
        view.addSubview(plantImageView)

        // Overlay View
        overlayView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        view.addSubview(overlayView)

        // Plant Name Label
        DiagnosisViewController.plantNameLabel.text = selectedPlant?.plantName
        DiagnosisViewController.plantNameLabel.textColor = .white
        DiagnosisViewController.plantNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        overlayView.addSubview(DiagnosisViewController.plantNameLabel)

        // Diagnosis Label
        DiagnosisViewController.diagnosisLabel.text = selectedPlant?.diagnosis
        DiagnosisViewController.diagnosisLabel.textColor = .white
        DiagnosisViewController.diagnosisLabel.font = UIFont.systemFont(ofSize: 24)
        overlayView.addSubview(DiagnosisViewController.diagnosisLabel)

        // Plant Details Label
        plantDetailsLabel.numberOfLines = 0
        plantDetailsLabel.textColor = UIColor(hex: "#005E2C")
        plantDetailsLabel.font = .systemFont(ofSize: 16, weight: .medium)
        plantDetailsLabel.backgroundColor = UIColor(hex: "#E2EAE2").withAlphaComponent(0.5)
        plantDetailsLabel.layer.cornerRadius = 8
        plantDetailsLabel.clipsToBounds = true
        plantDetailsLabel.textAlignment = .left
        // Add padding to the label
        plantDetailsLabel.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(plantDetailsLabel)

        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DiagnosisCell")
        tableView.backgroundColor = UIColor(hex: "#EBF4EB")
        tableView.isHidden = false
        view.addSubview(tableView)

        // Start Caring Button
        startCaringButton.setTitle("Add and Start Caring", for: .normal)
        startCaringButton.setTitleColor(.white, for: .normal)
        startCaringButton.backgroundColor = .systemGreen
        startCaringButton.layer.cornerRadius = 10
        startCaringButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.addSubview(startCaringButton)
        startCaringButton.addTarget(self, action: #selector(startCaringTapped), for: .touchUpInside)
    }
    
    private func initializePlantCheck() {
        guard let plantName = selectedPlant?.plantName else {
            print("⚠️ No plant name available in selectedPlant")
            showPlantNotFoundAlert()
            return
        }
        
        print("\n=== Initializing Plant Check ===")
        print("📝 Selected plant name: \(plantName)")
        
        // First get the plant from database
        if let plant = dataController.getPlantbyNameSync(name: plantName) {
            print("✅ Found plant in database")
            print("📝 Plant details:")
            print("   - Name: \(plant.plantName)")
            print("   - Botanical Name: \(plant.plantBotanicalName ?? "Not specified")")
            print("   - Category: \(plant.category_new?.rawValue ?? "Not specified")")
            print("   - Season: \(plant.favourableSeason?.rawValue ?? "Not specified")")
            
            // Update UI with plant details
            updatePlantUI(plant: plant)
            
            // Check if user has this plant
            checkIfPlantExists(plantName: plantName)
        } else {
            print("⚠️ Plant not found in database: \(plantName)")
            showPlantNotFoundAlert()
        }
    }
    
    private func updatePlantUI(plant: Plant) {
        // Update the plant details in the model
        selectedPlant?.plantName = plant.plantName
        selectedPlant?.botanicalName = plant.plantBotanicalName ?? "Not specified"
        
        // Create a more detailed and formatted plant details string
        let details = """
            
            • Botanical Name: \(plant.plantBotanicalName ?? "Not specified")
            • Category: \(plant.category_new?.rawValue ?? "Not specified")
            • Favourable Season: \(plant.favourableSeason?.rawValue.capitalized ?? "Not specified")
            """
        
        // Update the UI
        plantDetailsLabel.text = details
        plantDetailsLabel.isHidden = false
        print("✅ Updated plant details label")
    }

    private func showPlantNotFoundAlert() {
        let alert = UIAlertController(
            title: "Plant Not Found",
            message: "Sorry, we couldn't find this plant in our database. Would you like to scan another plant?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Scan Again", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true) {
            // Hide all UI elements since plant is not found
            self.tableView.isHidden = true
            self.healthyAnimationView.isHidden = true
            self.startCaringButton.isHidden = true
            self.plantDetailsLabel.isHidden = true
        }
    }

    private func checkIfPlantExists(plantName: String) {
        print("\n=== Checking if plant exists (Improved) ===")
        
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {
            print("❌ No user email found in UserDefaults")
            startCaringButton.isHidden = false
            startCaringButton.setTitle("Add and Start Caring", for: .normal)
            return
        }
        

        let userPlants = dataController.getUserPlantsSync(for: firstUser.userEmail!)
        print("📝 Found \(userPlants.count) user plants")
        
        isExistingPlant = userPlants.contains { userPlant in
            if let plantID = userPlant.userplantID,
               let existingPlant = dataController.getPlantSync(by: plantID) {
                return existingPlant.plantName == plantName
            }
            return false
        }

        // Use the improved function to check if plant exists
        isExistingPlant = dataController.doesPlantExistInUserGardenSync(plantName: plantName, userEmail: userEmail)

        
        if isExistingPlant {
            print("✅ Plant already exists in user's garden")
            hasUserResponded = false
            startCaringButton.isHidden = true
            DispatchQueue.main.async {
                self.showExistingPlantAlert()
            }
        } else {
            print("📝 New plant - showing add button")
            hasUserResponded = true
            isExistingPlant = false
            startCaringButton.isHidden = false
            startCaringButton.setTitle("Add and Start Caring", for: .normal)
        }
    }

    private func showExistingPlantAlert() {
        let alert = UIAlertController(
            title: "Plant Already in Your Garden",
            message: "We noticed you already have a \(selectedPlant?.plantName ?? "plant") in your garden. Is this the same plant or a different one?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Same Plant", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.hasUserResponded = true
            self.isExistingPlant = true
            
            // Keep the button hidden for same plant
            self.startCaringButton.isHidden = true
            
            // Show confirmation message
            let confirmAlert = UIAlertController(
                title: "Plant Already Being Monitored",
                message: "This plant is already being monitored in your garden. You can view its details and care schedule in My Garden.",
                preferredStyle: .alert
            )
            confirmAlert.addAction(UIAlertAction(title: "View in My Garden", style: .default) { [weak self] _ in
                // Navigate to My Garden tab
                self?.tabBarController?.selectedIndex = 0
                self?.navigationController?.popToRootViewController(animated: false)
            })
            confirmAlert.addAction(UIAlertAction(title: "Stay Here", style: .cancel))
            self.present(confirmAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Different Plant", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.hasUserResponded = true
            self.isExistingPlant = false
            // Show the add button for different plant
            self.startCaringButton.isHidden = false
            self.startCaringButton.setTitle("Add as New Plant", for: .normal)
        })
        
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections.contains(section) ? selectedPlant?.sectionDetails[sectionTitles[section]]?.count ?? 0 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiagnosisCell", for: indexPath)
        if let sectionData = selectedPlant?.sectionDetails[sectionTitles[indexPath.section]] {
            let text = sectionData[indexPath.row]
            cell.textLabel?.text = text
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = UIColor(hex: "#004E05")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(hex: "E2EAE2").withAlphaComponent(1)
        headerView.layer.cornerRadius = 10
        
        let headerButton = UIButton(type: .system)
        headerButton.setTitle(sectionTitles[section], for: .normal)
        headerButton.setTitleColor(.black, for: .normal)
        headerButton.tag = section
        headerButton.addTarget(self, action: #selector(handleExpandCollapse(_:)), for: .touchUpInside)
        headerButton.contentHorizontalAlignment = .left
        headerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        let chevronImage = UIImage(systemName: "chevron.down")
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.tintColor = .gray
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        headerButton.addSubview(chevronImageView)
        
        chevronImageView.centerYAnchor.constraint(equalTo: headerButton.centerYAnchor).isActive = true
        chevronImageView.trailingAnchor.constraint(equalTo: headerButton.trailingAnchor, constant: -16).isActive = true

        headerView.addSubview(headerButton)
        headerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerButton.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            headerButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16)
        ])

        return headerView
    }

    @objc func handleExpandCollapse(_ sender: UIButton) {
        let section = sender.tag
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    @objc func startCaringTapped() {
        guard let plantName = selectedPlant?.plantName else {
            print("❌ No plant name available")
            return
        }
        
        // If user hasn't responded to the existing plant alert yet and it's an existing plant
        if isExistingPlant && !hasUserResponded {
            print("⚠️ User needs to respond to existing plant alert first")
            showExistingPlantAlert()
            return
        }
        
        // If it's an existing plant and user chose "Same Plant", don't proceed
        if isExistingPlant && hasUserResponded && startCaringButton.isHidden {
            print("ℹ️ User chose 'Same Plant' - not adding duplicate")
            return
        }
        
        print("\n=== Starting Add Plant Flow ===")
        print("Plant name from DiagnosisViewController: \(plantName)")
        
        // Retrieve the stored image URL from UserDefaults
        let imageURL = UserDefaults.standard.string(forKey: "pendingPlantImageURL")
        print("🔗 Using stored image URL: \(imageURL ?? "none")")
        
        let reminderVC = addNickNameViewController()
        reminderVC.plantNameForReminder = plantName
        
        if let plant = dataController.getPlantbyNameSync(name: plantName) {
            // We no longer need to upload the image here since it was already uploaded during diagnosis
            // and the URL is stored in UserDefaults
            reminderVC.selectedPlant = plant
        }
        
        let navController = UINavigationController(rootViewController: reminderVC)
        present(navController, animated: true)
    }

    // Update the disease details handling
    private func updateDiseaseDetails(with disease: Diseases) {
        var dict: [String: [String]] = [:]
        
        // 1. Add symptoms section
        if let symptoms = disease.diseaseSymptoms {
            dict["Symptoms"] = symptoms.components(separatedBy: "; ")
        }
        
        // 2. Add treatment section
        if let treatment = disease.diseaseCure {
            dict["Treatment"] = treatment.components(separatedBy: "; ")
        }
        
        // 3. Add preventive measures section
        if let preventiveMeasures = disease.diseasePreventiveMeasures {
            dict["Preventive Measures"] = preventiveMeasures.components(separatedBy: "; ")
        }
        
        // 4. Add fertilizers section
        if let fertilizers = disease.diseaseFertilizers {
            dict["Recommended Fertilizers"] = fertilizers.components(separatedBy: "; ")
        }
        
        // 5. Add video solution section if available
        if let videoSolution = disease.diseaseVideoSolution {
            dict["Video Guide"] = [videoSolution]
        }
        
        selectedPlant?.sectionDetails = dict
        DiagnosisViewController.diagnosisLabel.text = disease.diseaseName

        // Update plant details with season information
        if let plant = dataController.getPlantbyNameSync(name: selectedPlant?.plantName ?? "") {
            let details = """
                Plant: \(plant.plantName)
                Botanical Name: \(plant.plantBotanicalName ?? "Not specified")
                Season: \(disease.diseaseSeason?.rawValue.capitalized ?? "Not specified")
                """
            plantDetailsLabel.text = details
        }
        
        // Ensure table view is visible and reload
        tableView.isHidden = false
        if !sectionTitles.isEmpty {
            expandedSections.insert(0)  // Expand first section by default
        }
        tableView.reloadData()
    }

    // Update fetchAndUpdateDiseaseDetails to use the new format
    func fetchAndUpdateDiseaseDetails(diseaseName: String) {
        print("\n=== Fetching Disease Details ===")
        print("🔍 Looking for disease: \(diseaseName)")
        
        // Clean up disease name
        let cleanName = diseaseName.replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle healthy plant cases
        if cleanName.lowercased().contains("healthy") || cleanName == "No disease detected" {
            print("✅ Plant is healthy")
            // Hide table view for healthy plants
            tableView.isHidden = true
            
            // Update diagnosis label
            DiagnosisViewController.diagnosisLabel.text = "Healthy"
            
            // Show healthy animation and message
            showHealthyAnimation()
            
            // Update the overlay to green
            overlayView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            
            // Update plant details if we have the plant name
            if let plantName = selectedPlant?.plantName {
                initializePlantCheck()
            }
            
            return
        }
        
        if let disease = dataController.getDiseaseByNameSync(name: cleanName) {
            print("✅ Found disease in database")
            updateDiseaseDetails(with: disease)
        } else {
            print("⚠️ No specific condition detected")
            // Hide table view
            tableView.isHidden = true
            
            // Show healthy status if no disease is found
            DiagnosisViewController.diagnosisLabel.text = "Healthy"
            overlayView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            showHealthyAnimation()
            
            // Update plant details
            if let plantName = selectedPlant?.plantName {
                initializePlantCheck()
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Plant Condition Not Found",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Add this method after setupUI()
    private func setupHealthyAnimation() {
        // Setup animation container view
        healthyAnimationView.backgroundColor = UIColor(hex: "#EBF4EB")
        healthyAnimationView.alpha = 0
        healthyAnimationView.layer.cornerRadius = 15
        healthyAnimationView.clipsToBounds = true
        healthyAnimationView.layer.borderWidth = 1
        healthyAnimationView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.3).cgColor
        view.addSubview(healthyAnimationView)
        
        // Setup checkmark image
        checkmarkImageView.image = UIImage(systemName: "checkmark.seal.fill")
        checkmarkImageView.tintColor = .systemGreen
        checkmarkImageView.contentMode = .scaleAspectFit
        healthyAnimationView.addSubview(checkmarkImageView)
        
        // Setup healthy label with more padding and styling
        healthyLabel.textColor = UIColor(hex: "#005E2C")
        healthyLabel.font = .systemFont(ofSize: 20, weight: .bold)
        healthyLabel.textAlignment = .center
        healthyLabel.numberOfLines = 0
        healthyLabel.backgroundColor = .clear
        healthyLabel.layer.cornerRadius = 12
        healthyLabel.clipsToBounds = true
        healthyAnimationView.addSubview(healthyLabel)
        
        // Setup constraints
        healthyAnimationView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        healthyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            healthyAnimationView.topAnchor.constraint(equalTo: plantDetailsLabel.bottomAnchor, constant: 10),
            healthyAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            healthyAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            healthyAnimationView.bottomAnchor.constraint(equalTo: startCaringButton.topAnchor, constant: -20),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: healthyAnimationView.centerXAnchor),
            checkmarkImageView.topAnchor.constraint(equalTo: healthyAnimationView.topAnchor, constant: 10),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 80),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 80),
            
            healthyLabel.topAnchor.constraint(equalTo: checkmarkImageView.bottomAnchor, constant: 10),
            healthyLabel.leadingAnchor.constraint(equalTo: healthyAnimationView.leadingAnchor, constant: 20),
            healthyLabel.trailingAnchor.constraint(equalTo: healthyAnimationView.trailingAnchor, constant: -20),
            healthyLabel.bottomAnchor.constraint(lessThanOrEqualTo: healthyAnimationView.bottomAnchor, constant: -20)
        ])
    }

    // Add this method to show the healthy animation
    private func showHealthyAnimation() {
        // Hide the table view
        tableView.isHidden = true
        
        // Configure healthy animation view if not already configured
        if healthyAnimationView.superview == nil {
            setupHealthyAnimation()
        }
        
        // Update healthy label text with more detailed message
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.systemGreen
        ]
        
        let subtitleAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#005E2C")
        ]
        
        let bulletPointAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular),
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#005E2C")
        ]
        
        let attributedString = NSMutableAttributedString()
        
        // Title
        attributedString.append(NSAttributedString(string: "Your plant is healthy! 🌱\n\n", attributes: titleAttributes))
        
        // Subtitle
        attributedString.append(NSAttributedString(string: "Keep maintaining the current care routine:\n\n", attributes: subtitleAttributes))
        
        // Bullet points
        let bulletPoints = [
            "• Proper watering\n",
            "• Good light exposure\n",
            "• Regular monitoring"
        ]
        
        for point in bulletPoints {
            attributedString.append(NSAttributedString(string: point, attributes: bulletPointAttributes))
        }
        
        healthyLabel.attributedText = attributedString
        
        // Show the healthy animation view with shadow
        healthyAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        healthyAnimationView.alpha = 0
        healthyAnimationView.isHidden = false
        healthyAnimationView.layer.shadowColor = UIColor.black.cgColor
        healthyAnimationView.layer.shadowOffset = CGSize(width: 0, height: 2)
        healthyAnimationView.layer.shadowRadius = 4
        healthyAnimationView.layer.shadowOpacity = 0.1
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.healthyAnimationView.transform = .identity
            self.healthyAnimationView.alpha = 1
        })
        
        // Animate the checkmark
        checkmarkImageView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.checkmarkImageView.transform = .identity
        })
    }

    @objc func openLink(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
              let text = label.text,
              let urlText = text.components(separatedBy: ": ").last,
              let url = URL(string: urlText) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func setupConstraints() {
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        DiagnosisViewController.plantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        DiagnosisViewController.diagnosisLabel.translatesAutoresizingMaskIntoConstraints = false
        plantDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        startCaringButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Plant Image
            plantImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            plantImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            plantImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            plantImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            
            // Overlay
            overlayView.leadingAnchor.constraint(equalTo: plantImageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: plantImageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: plantImageView.bottomAnchor),
            overlayView.heightAnchor.constraint(equalToConstant: 60),
            
            // Plant Name Label
            DiagnosisViewController.plantNameLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            DiagnosisViewController.plantNameLabel.topAnchor.constraint(equalTo: DiagnosisViewController.diagnosisLabel.bottomAnchor, constant: 0),
            
            // Diagnosis Label
            DiagnosisViewController.diagnosisLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            DiagnosisViewController.diagnosisLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 8),
            
            // Plant Details Label
            plantDetailsLabel.topAnchor.constraint(equalTo: plantImageView.bottomAnchor, constant: 16),
            plantDetailsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            plantDetailsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: plantDetailsLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: startCaringButton.topAnchor, constant: -16),
            
            // Start Caring Button
            startCaringButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startCaringButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            startCaringButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            startCaringButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
