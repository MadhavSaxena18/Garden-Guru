

import UIKit

class DiagnosisViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UI Elements
    private let plantImageView = UIImageView()
    private let overlayView = UIView()
    private let plantNameLabel = UILabel()
    private let diagnosisLabel = UILabel()
    private let detailsStackView = UIStackView()
    private let tableView = UITableView()
    private let startCaringButton = UIButton()

    // Data
    var selectedPlant: DiagnosisDataModel?
    private var expandedSections: Set<Int> = []
    private var sectionTitles: [String] {
        return selectedPlant?.sectionDetails.keys.sorted() ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#EBF4EB")
        setupUI()
        setupConstraints()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Diagnosis"
        
        // Hide tab bar
        self.tabBarController?.tabBar.isHidden = true
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
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil { // This means we're being popped
            showBackAlert()
        }
    }
    
    private func setupUI() {
        // Plant Image
        plantImageView.image = UIImage(named: "parlor_palm3")
        plantImageView.contentMode = .scaleAspectFill
        plantImageView.clipsToBounds = true
        view.addSubview(plantImageView)

        // Overlay View
        overlayView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        view.addSubview(overlayView)

        // Plant Name Label
        plantNameLabel.text = selectedPlant?.plantName
        plantNameLabel.textColor = .white
        plantNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        overlayView.addSubview(plantNameLabel)

        // Diagnosis Label
        diagnosisLabel.text = selectedPlant?.diagnosis
        diagnosisLabel.textColor = .white
        diagnosisLabel.font = UIFont.systemFont(ofSize: 16)
        overlayView.addSubview(diagnosisLabel)

        // Details StackView
        detailsStackView.axis = .vertical
        detailsStackView.alignment = .leading
        detailsStackView.spacing = 8
        view.addSubview(detailsStackView)

        if let plant = selectedPlant {
            let generalDetails = [
                "Also Known as: \(plant.alsoKnownAs)",
                "Botanical Name: \(plant.botanicalName)",
            ]

            generalDetails.forEach { text in
                let label = UILabel()
                label.text = text
                label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                label.textColor = UIColor(hex: "#005E2C")
                label.numberOfLines = 0
                detailsStackView.addArrangedSubview(label)
            }
        }

        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DiagnosisCell")
        tableView.isScrollEnabled = true
        tableView.backgroundColor = UIColor(hex: "#EBF4EB")
        view.addSubview(tableView)

        // Start Caring Button
        startCaringButton.setTitle("Start Caring", for: .normal)
        startCaringButton.setTitleColor(.white, for: .normal)
        startCaringButton.backgroundColor = .systemGreen
        startCaringButton.layer.cornerRadius = 10
        view.addSubview(startCaringButton)
        startCaringButton.addTarget(self, action: #selector(startCaringTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // Enable Auto Layout
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        plantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        diagnosisLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
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
            plantNameLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            plantNameLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 8),

            // Diagnosis Label
            diagnosisLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            diagnosisLabel.topAnchor.constraint(equalTo: plantNameLabel.bottomAnchor, constant: 0),

            // Details StackView
            detailsStackView.topAnchor.constraint(equalTo: plantImageView.bottomAnchor, constant: 16),
            detailsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // TableView
            tableView.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 10),
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
    
    private func showBackAlert() {
        let alert = UIAlertController(
            title: "Scan Another Plant?",
            message: "Would you like to scan another plant?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { [weak self] _ in
            self?.tabBarController?.tabBar.isHidden = false
            self?.tabBarController?.selectedIndex = 0
            self?.navigationController?.popToRootViewController(animated: false)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
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
            
            if text.starts(with: "http") {
                cell.textLabel?.textColor = .systemBlue
                cell.textLabel?.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLink(_:)))
                cell.textLabel?.addGestureRecognizer(tapGesture)
            } else {
                cell.textLabel?.textColor = UIColor(hex: "#004E05")
                cell.textLabel?.isUserInteractionEnabled = false
            }
        }
        return cell
    }

    @objc func openLink(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
              let text = label.text,
              let url = URL(string: text) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        let newController = addNickNameViewController()
        navigationController?.present(newController, animated: true)
    }
}
