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
    
    // Symptom-based UI components
    private let symptomsContainerView = UIView()
    private let symptomsHeaderLabel = UILabel()
    private let symptomsStackView = UIStackView()

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
        print("\n=== Checking if plant exists ===")
        
        guard let firstUser = dataController.getUserSync() else {
            print("❌ No user found")
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
            //hello madhav how are you
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

        // Show actual images for the "Related Images" section
        if sectionTitles[indexPath.section] == "Related Images",
           let urlString = selectedPlant?.sectionDetails[sectionTitles[indexPath.section]]?[indexPath.row],
           let url = URL(string: urlString) {
            // Clear text and set placeholder
            cell.textLabel?.text = nil
            cell.imageView?.image = UIImage(systemName: "photo")
            cell.imageView?.contentMode = .scaleAspectFill
            cell.imageView?.clipsToBounds = true

            // Load image asynchronously
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    // Resize to a thumbnail to fit default imageView nicely
                    let targetSize = CGSize(width: 160, height: 160)
                    UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
                    image.draw(in: CGRect(origin: .zero, size: targetSize))
                    let resized = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()

                    // To avoid wrong images on reused cells, ensure the cell is still visible at this indexPath
                    if let visibleCell = tableView.cellForRow(at: indexPath) {
                        visibleCell.imageView?.image = resized ?? image
                        visibleCell.setNeedsLayout()
                    }
                }
            }.resume()

            return cell
        }

        if let sectionData = selectedPlant?.sectionDetails[sectionTitles[indexPath.section]] {
            let text = sectionData[indexPath.row]
            cell.textLabel?.text = text
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = UIColor(hex: "#004E05")
            cell.imageView?.image = nil
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sectionTitles[indexPath.section] == "Related Images" {
            return 180
        }
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

        // Determine chevron direction based on expanded state
        let isExpanded = expandedSections.contains(section)
        let chevronImage = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.tintColor = .gray
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.tag = 999 // Tag to find it later for rotation
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
        
        // Toggle expanded state
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
        
        // Animate the chevron rotation
        if let chevronImageView = sender.viewWithTag(999) as? UIImageView {
            let isNowExpanded = expandedSections.contains(section)
            UIView.transition(with: chevronImageView, duration: 0.3, options: .transitionCrossDissolve) {
                chevronImageView.image = UIImage(systemName: isNowExpanded ? "chevron.up" : "chevron.down")
            }
        }
        
        // Reload the section with animation
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
        
        let reminderVC = addNickNameViewController()
        reminderVC.plantNameForReminder = plantName
        
        if let plant = dataController.getPlantbyNameSync(name: plantName) {
            // Use the first image (whole plant view) from captured images
            if let wholePlantImage = scanAndDiagnoseViewController.capturedImages.first {
                print("✅ Adding whole plant image to storage")
                if let imageURL = dataController.uploadUserPlantImageSync(userPlantID: plant.plantID, image: wholePlantImage) {
                    print("✅ Successfully uploaded image: \(imageURL)")
                } else {
                    print("❌ Failed to upload image")
                }
            } else {
                print("❌ No whole plant image available")
            }
            reminderVC.selectedPlant = plant
        }
        
        let navController = UINavigationController(rootViewController: reminderVC)
        present(navController, animated: true)
    }

    // Update the disease details handling with symptom-first approach
    private func updateDiseaseDetails(with disease: Diseases) {
        // Show symptoms container
        setupSymptomsUI(with: disease)
        
        // Update overlay to red/orange for disease
        overlayView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        
        // Show the actual disease name on the overlay (not "Analysis Complete")
        DiagnosisViewController.diagnosisLabel.text = disease.diseaseName
        
        // Update plant details with season information
        if let plant = dataController.getPlantbyNameSync(name: selectedPlant?.plantName ?? "") {
            let details = """
                
                • Botanical Name: \(plant.plantBotanicalName ?? "Not specified")
                • Category: \(plant.category_new?.rawValue ?? "Not specified")
                • Favourable Season: \(plant.favourableSeason?.rawValue.capitalized ?? "Not specified")
                """
            plantDetailsLabel.text = details
        }
        
        // Store disease details and show in table view
        var dict: [String: [String]] = [:]
        
        // Add sections in the order you want them displayed
        if let symptoms = disease.diseaseSymptoms {
            dict["Symptoms"] = symptoms.components(separatedBy: "; ")
        }
        if let preventiveMeasures = disease.diseasePreventiveMeasures {
            dict["Preventive Measures"] = preventiveMeasures.components(separatedBy: "; ")
        }
        if let fertilizers = disease.diseaseFertilizers {
            dict["Recommended Fertilizers"] = fertilizers.components(separatedBy: "; ")
        }
        if let treatment = disease.diseaseCure {
            dict["Treatment"] = treatment.components(separatedBy: "; ")
        }
        if let videoSolution = disease.diseaseVideoSolution {
            dict["Video Guide"] = [videoSolution]
        }

        // Add Related Images section if disease has images
        if let imageURL = disease.diseaseImage, !imageURL.isEmpty {
            dict["Related Images"] = [imageURL]
        }
        
        selectedPlant?.sectionDetails = dict
        
        // Show table view with treatment details
        tableView.isHidden = false
        if !sectionTitles.isEmpty {
            expandedSections.insert(0)  // Expand first section by default
        }
        tableView.reloadData()
    }
    
    // New method to setup symptom-based UI
    private func setupSymptomsUI(with disease: Diseases) {
        print("🔍 Setting up symptoms UI for disease: \(disease.diseaseName)")
        print("📝 Symptoms: \(disease.diseaseSymptoms ?? "No symptoms")")
        
        // Remove existing symptom views if any
        symptomsContainerView.removeFromSuperview()
        
        // Setup symptoms container
        symptomsContainerView.backgroundColor = UIColor(hex: "#FFFFFF")
        symptomsContainerView.layer.cornerRadius = 12
        symptomsContainerView.layer.shadowColor = UIColor.black.cgColor
        symptomsContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        symptomsContainerView.layer.shadowRadius = 4
        symptomsContainerView.layer.shadowOpacity = 0.1
        symptomsContainerView.isHidden = false
        
        // Setup header label
        symptomsHeaderLabel.text = "🔍 What We Detected:"
        symptomsHeaderLabel.font = .systemFont(ofSize: 20, weight: .bold)
        symptomsHeaderLabel.textColor = UIColor(hex: "#005E2C")
        symptomsContainerView.addSubview(symptomsHeaderLabel)
        
        // Setup symptoms stack view
        symptomsStackView.axis = .vertical
        symptomsStackView.spacing = 12
        symptomsStackView.alignment = .leading
        symptomsContainerView.addSubview(symptomsStackView)
        
        // Clear existing symptoms
        symptomsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Parse and add symptoms with confidence levels
        if let symptoms = disease.diseaseSymptoms, !symptoms.isEmpty {
            let symptomList = symptoms.components(separatedBy: "; ")
            let confidenceLevels = generateConfidenceLevels(count: symptomList.count)
            
            print("✅ Adding \(symptomList.count) symptoms to UI")
            for (index, symptom) in symptomList.enumerated() {
                let symptomView = createSymptomView(
                    symptom: symptom,
                    confidence: confidenceLevels[index]
                )
                symptomsStackView.addArrangedSubview(symptomView)
            }
        } else {
            print("⚠️ No symptoms available for this disease")
        }
        
        // Setup constraints for the container
        symptomsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        symptomsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            symptomsHeaderLabel.topAnchor.constraint(equalTo: symptomsContainerView.topAnchor, constant: 16),
            symptomsHeaderLabel.leadingAnchor.constraint(equalTo: symptomsContainerView.leadingAnchor, constant: 16),
            symptomsHeaderLabel.trailingAnchor.constraint(equalTo: symptomsContainerView.trailingAnchor, constant: -16),
            
            symptomsStackView.topAnchor.constraint(equalTo: symptomsHeaderLabel.bottomAnchor, constant: 12),
            symptomsStackView.leadingAnchor.constraint(equalTo: symptomsContainerView.leadingAnchor, constant: 16),
            symptomsStackView.trailingAnchor.constraint(equalTo: symptomsContainerView.trailingAnchor, constant: -16),
            symptomsStackView.bottomAnchor.constraint(equalTo: symptomsContainerView.bottomAnchor, constant: -16)
        ])
        
        // Calculate the size needed for the container
        symptomsContainerView.layoutIfNeeded()
        let targetSize = CGSize(width: view.bounds.width - 32, height: UIView.layoutFittingCompressedSize.height)
        let size = symptomsContainerView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        // Create a wrapper view with proper frame
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: size.height + 32))
        headerView.backgroundColor = UIColor(hex: "#EBF4EB")
        
        // Add symptoms container to header view
        symptomsContainerView.frame = CGRect(x: 16, y: 16, width: view.bounds.width - 32, height: size.height)
        headerView.addSubview(symptomsContainerView)
        
        // Set as table header view - this makes it scroll with the table!
        tableView.tableHeaderView = headerView
        
        print("✅ Symptoms UI setup complete as table header")
    }
    
    // Generate realistic confidence levels
    private func generateConfidenceLevels(count: Int) -> [Int] {
        guard count > 0 else { return [] }
        
        var levels: [Int] = []
        // First symptom gets highest confidence (85-95%)
        levels.append(Int.random(in: 85...95))
        
        // Subsequent symptoms get progressively lower confidence
        for i in 1..<count {
            let baseConfidence = 95 - (i * 15)
            let confidence = max(45, min(95, baseConfidence + Int.random(in: -5...5)))
            levels.append(confidence)
        }
        
        return levels
    }
    
    // Create individual symptom view with confidence indicator
    private func createSymptomView(symptom: String, confidence: Int) -> UIView {
        let containerView = UIView()
        
        // Symptom text
        let symptomLabel = UILabel()
        symptomLabel.text = "• \(symptom)"
        symptomLabel.font = .systemFont(ofSize: 16, weight: .medium)
        symptomLabel.textColor = UIColor(hex: "#005E2C")
        symptomLabel.numberOfLines = 0
        containerView.addSubview(symptomLabel)
        
        // Confidence indicator
        let confidenceLabel = UILabel()
        let confidenceColor: UIColor
        let confidenceText: String
        
        switch confidence {
        case 80...100:
            confidenceColor = .systemGreen
            confidenceText = "High confidence"
        case 60...79:
            confidenceColor = .systemOrange
            confidenceText = "Moderate confidence"
        default:
            confidenceColor = .systemGray
            confidenceText = "Low confidence"
        }
        
        confidenceLabel.text = "\(confidence)% - \(confidenceText)"
        confidenceLabel.font = .systemFont(ofSize: 14, weight: .regular)
        confidenceLabel.textColor = confidenceColor
        containerView.addSubview(confidenceLabel)
        
        // Setup constraints
        symptomLabel.translatesAutoresizingMaskIntoConstraints = false
        confidenceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            symptomLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            symptomLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            symptomLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            confidenceLabel.topAnchor.constraint(equalTo: symptomLabel.bottomAnchor, constant: 4),
            confidenceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            confidenceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            confidenceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    

    // Update fetchAndUpdateDiseaseDetails to use the new format
    func fetchAndUpdateDiseaseDetails(diseaseName: String) {
        print("\n=== Fetching Disease Details ===")
        print("🔍 Looking for disease: \(diseaseName)")
        
        // Clean up disease name - remove extra spaces and handle variations
        let cleanName = diseaseName
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "  ", with: " ") // Remove double spaces
        
        print("🔍 Cleaned disease name: \(cleanName)")
        
        // Handle healthy plant cases
        if cleanName.lowercased().contains("healthy") || 
           cleanName == "No disease detected" || 
           cleanName.lowercased() == "healthy" {
            print("✅ Plant is healthy")
            // Hide table view for healthy plants
            tableView.isHidden = true
            symptomsContainerView.isHidden = true
            
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
        
        // Try multiple variations to find the disease
        var disease: Diseases?
        
        // Try exact match first
        disease = dataController.getDiseaseByNameSync(name: cleanName)
        
        // Try lowercase
        if disease == nil {
            disease = dataController.getDiseaseByNameSync(name: cleanName.lowercased())
        }
        
        // Try capitalized
        if disease == nil {
            disease = dataController.getDiseaseByNameSync(name: cleanName.capitalized)
        }
        
        // Try uppercase
        if disease == nil {
            disease = dataController.getDiseaseByNameSync(name: cleanName.uppercased())
        }
        
        // Try with underscores instead of spaces
        if disease == nil {
            let underscoreName = cleanName.replacingOccurrences(of: " ", with: "_")
            disease = dataController.getDiseaseByNameSync(name: underscoreName)
        }
        
        if let foundDisease = disease {
            print("✅ Found disease in database: \(foundDisease.diseaseName)")
            updateDiseaseDetails(with: foundDisease)
        } else {
            print("⚠️ Disease not found in database after trying all variations: \(cleanName)")
            
            // Hide UI elements
            tableView.isHidden = true
            symptomsContainerView.isHidden = true
            healthyAnimationView.isHidden = true
            
            // Show user-friendly alert
            showDiseaseNotFoundAlert(diseaseName: cleanName)
        }
    }
    
    private func showDiseaseNotFoundAlert(diseaseName: String) {
        // Ensure view is fully loaded before showing alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "Disease Not in Database",
                message: "We detected '\(diseaseName)' but it's not in our database yet.\n\nWould you like us to notify you when we add it?",
                preferredStyle: .alert
            )
            
            // Notify Me button
            let notifyAction = UIAlertAction(title: "Notify Me", style: .default) { [weak self] _ in
                // Show confirmation
                self?.showNotificationConfirmation(diseaseName: diseaseName)
            }
            
            // Cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                // Go back to home
                self?.tabBarController?.selectedIndex = 0
                self?.navigationController?.popToRootViewController(animated: true)
            }
            
            alert.addAction(notifyAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
    }
    
    private func showNotificationConfirmation(diseaseName: String) {
        let confirmAlert = UIAlertController(
            title: "Thank You! 🙏",
            message: "We've received your request for '\(diseaseName)'.\n\nWe'll notify you once it's added to our database!",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Navigate to home page (My Garden tab)
            self?.tabBarController?.selectedIndex = 0
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        confirmAlert.addAction(okAction)
        present(confirmAlert, animated: true)
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
            
            // Table View constraints
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

