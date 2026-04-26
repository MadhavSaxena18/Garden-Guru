//
//  DiseaseDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 23/02/25.
//

import UIKit
import SDWebImage

class DiseaseDetailViewController: UIViewController {
    private var isSaved = false
    private var heartButton: UIBarButtonItem!
    var disease: Diseases?
    private var fullscreenImageView: UIImageView?
    private var currentImageIndex: Int = 0
    private var imageArray: [UIImage] = []
    var selectedCardData: Any?
    // Collapsible state - Symptoms expanded by default
    private var expandedSection: Int? = 0
    
    // UI Elements
    private let headerImageView = UIImageView()
    private let overlayGradientView = UIView()
    private let diseaseNameLabel = UILabel()
    private let diseaseSymptomsLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    var isModallyPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let disease = disease else {
            print("Disease is nil")
            return
        }
        selectedCardData = disease
        setupViews()
        setupNavigationBar()
        checkIfAlreadySaved()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frame
        overlayGradientView.frame = headerImageView.bounds
        if let gradientLayer = overlayGradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = overlayGradientView.bounds
        }
    }
    
    private func setupNavigationBar() {
        if isModallyPresented {
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissVC))
            navigationItem.leftBarButtonItem = doneButton
        }
        let heartImage = UIImage(systemName: isSaved ? "heart.fill" : "heart")
        heartButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(toggleHeartTapped))
        navigationItem.rightBarButtonItem = heartButton
    }
    
    @objc private func toggleHeartTapped() {
        print("❤️ Heart button tapped")

        guard let userId = DataControllerGG.shared.getCurrentUserIdSync() else {
            print("❌ User ID not found")
            return
        }
        print("✅ User ID: \(userId)")

        var itemId: UUID?
        var itemType: String?

        if let plant = selectedCardData as? Plant {
            itemId = plant.plantID
            itemType = "plant"
            print("🔍 Selected item is a Plant with ID: \(plant.plantID)")
        } else if let disease = selectedCardData as? Diseases {
            itemId = disease.diseaseID
            itemType = "disease"
            print("🔍 Selected item is a Disease with ID: \(disease.diseaseID)")
        } else {
            print("❌ selectedCardData is neither Plant nor Disease — it is: \(String(describing: selectedCardData))")
        }

        guard let id = itemId, let type = itemType else {
            print("❌ Missing item ID or type — itemId: \(String(describing: itemId)), type: \(String(describing: itemType))")
            return
        }

        Task {
            do {
                if isSaved {
                    print("🔄 Trying to unsave \(type) with ID \(id)")
                    try await DataControllerGG.shared.unsaveUserItem(userId: userId, itemId: id, itemType: type)
                    isSaved = false
                    print("✅ Item unsaved")
                } else {
                    print("💾 Trying to save \(type) with ID \(id)")
                    try await DataControllerGG.shared.saveUserItem(userId: userId, itemId: id, itemType: type)
                    isSaved = true
                    print("✅ Item saved")
                }

                DispatchQueue.main.async {
                    self.updateHeartButton()
                    print("🔁 Heart button UI updated")
                }
            } catch {
                print("❌ Error during save/unsave: \(error)")
            }
        }
    }


    private func checkIfAlreadySaved() {
        guard let userId = DataControllerGG.shared.getCurrentUserIdSync() else { return }

        var itemId: UUID?
        var itemType: String?

        if let plant = selectedCardData as? Plant {
            itemId = plant.plantID
            itemType = "plant"
        } else if let disease = selectedCardData as? Diseases {
            itemId = disease.diseaseID
            itemType = "disease"
        }

        guard let id = itemId, let type = itemType else { return }

        Task {
            do {
                let saved = try await DataControllerGG.shared.isItemSaved(userId: userId, itemId: id, itemType: type)
                self.isSaved = saved
                DispatchQueue.main.async {
                    self.updateHeartButton()
                }
            } catch {
                print("❌ Failed to check if item is saved: \(error)")
            }
        }
    }
    private func updateHeartButton() {
        let heartImage = UIImage(systemName: isSaved ? "heart.fill" : "heart")
        heartButton.image = heartImage
    }
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
    
    private func setupViews() {
        view.backgroundColor = .systemGroupedBackground
        // Header image
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerImageView)
        
        // Gradient overlay
        overlayGradientView.translatesAutoresizingMaskIntoConstraints = false
        overlayGradientView.isUserInteractionEnabled = false
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        overlayGradientView.layer.insertSublayer(gradientLayer, at: 0)
        headerImageView.addSubview(overlayGradientView)
        
        // Disease name label
        diseaseNameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        diseaseNameLabel.textColor = .white
        diseaseNameLabel.numberOfLines = 2
        diseaseNameLabel.adjustsFontForContentSizeCategory = true
        diseaseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.addSubview(diseaseNameLabel)
        
        // Disease symptoms label
        diseaseSymptomsLabel.font = UIFont.preferredFont(forTextStyle: .body)
        diseaseSymptomsLabel.textColor = .white
        diseaseSymptomsLabel.numberOfLines = 2
        diseaseSymptomsLabel.adjustsFontForContentSizeCategory = true
        diseaseSymptomsLabel.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.addSubview(diseaseSymptomsLabel)
        
        // Table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DiseaseDetailTableViewCell.self, forCellReuseIdentifier: "DiseaseDetailCell")
        view.addSubview(tableView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 320),
            
            overlayGradientView.leadingAnchor.constraint(equalTo: headerImageView.leadingAnchor),
            overlayGradientView.trailingAnchor.constraint(equalTo: headerImageView.trailingAnchor),
            overlayGradientView.bottomAnchor.constraint(equalTo: headerImageView.bottomAnchor),
            overlayGradientView.topAnchor.constraint(equalTo: headerImageView.topAnchor),
            
            diseaseNameLabel.leadingAnchor.constraint(equalTo: headerImageView.leadingAnchor, constant: 20),
            diseaseNameLabel.trailingAnchor.constraint(equalTo: headerImageView.trailingAnchor, constant: -20),
            diseaseNameLabel.bottomAnchor.constraint(equalTo: diseaseSymptomsLabel.topAnchor, constant: -4),
            
            diseaseSymptomsLabel.leadingAnchor.constraint(equalTo: headerImageView.leadingAnchor, constant: 20),
            diseaseSymptomsLabel.trailingAnchor.constraint(equalTo: headerImageView.trailingAnchor, constant: -20),
            diseaseSymptomsLabel.bottomAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set data
        if let disease = disease {
            if let imageURLString = disease.diseaseImage, let url = URL(string: imageURLString) {
                headerImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "disease_placeholder"), options: [], completed: nil)
            } else {
                headerImageView.image = UIImage(named: "disease_placeholder")
            }
            diseaseNameLabel.text = disease.diseaseName
            diseaseSymptomsLabel.text = disease.diseaseSymptoms ?? ""
        }
    }
}

extension DiseaseDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}

// TableView Delegate/DataSource: Remove collapsible logic, just return 1 row per section
extension DiseaseDetailViewController: UITableViewDelegate, UITableViewDataSource {
    // Define all sections you want to show
    enum DiseaseDetailSection: Int, CaseIterable {
        case symptoms
      
        case vitaminsRequired
     
        case cure
        case fertilizers
        case prevention

        var title: String {
            switch self {
            case .symptoms: return "Symptoms"
//            case .causes: return "Causes"
            case .vitaminsRequired: return "Vitamins Required"
//            case .treatment: return "Treatment"
            case .cure: return "Cure"
            case .fertilizers: return "Fertilizers"
            case .prevention: return "Prevention"
            }
        }
        
        var icon: String {
            switch self {
            case .symptoms: return "leaf.fill"
            case .vitaminsRequired: return "pills.fill"
            case .cure: return "cross.case.fill"
            case .fertilizers: return "bag.fill"
            case .prevention: return "drop.fill"
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return DiseaseDetailSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSection == section ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiseaseDetailCell", for: indexPath) as! DiseaseDetailTableViewCell
        guard let disease = disease else {
            cell.configure(with: nil, section: "", showHeader: false)
            return cell
        }
        cell.isExpanded = expandedSection == indexPath.section
        let sectionType = DiseaseDetailSection(rawValue: indexPath.section)!
        switch sectionType {
        case .symptoms:
            cell.configure(with: disease, section: "Symptoms", showHeader: true)
       
        case .vitaminsRequired:
            cell.configure(with: disease, section: "Vitamins Required", showHeader: true)
        
        case .cure:
            cell.configure(with: disease, section: "Cure", showHeader: true)
        case .fertilizers:
            cell.configure(with: disease, section: "Fertilizers", showHeader: true)
        case .prevention:
            cell.configure(with: disease, section: "Prevention", showHeader: true)
        }
        cell.backgroundColor = .clear
        cell.layer.cornerRadius = 0
        cell.layer.masksToBounds = false
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .clear
        let header = UIView()
        header.backgroundColor = .white
        header.layer.cornerRadius = 16
        header.layer.masksToBounds = true
        header.tag = section
        header.isUserInteractionEnabled = true
        
        // Add tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        header.addGestureRecognizer(tap)
        
        let sectionType = DiseaseDetailSection(rawValue: section)!
        
        // Icon background view
        let iconBackgroundView = UIView()
        iconBackgroundView.backgroundColor = UIColor(red: 0.93, green: 0.97, blue: 0.93, alpha: 1.0) // Light green background
        iconBackgroundView.layer.cornerRadius = 20
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(iconBackgroundView)
        
        // Icon
        let iconImageView = UIImageView(image: UIImage(systemName: sectionType.icon))
        iconImageView.tintColor = UIColor(red: 0.36, green: 0.61, blue: 0.39, alpha: 1.0) // Green color
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.addSubview(iconImageView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.text = sectionType.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)
        
        // Chevron for all sections (including Symptoms)
        let chevron = UIImageView(image: UIImage(systemName: expandedSection == section ? "chevron.down" : "chevron.right"))
        chevron.tintColor = .systemGray
        chevron.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(chevron)
        
        container.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            header.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            header.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            header.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            header.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            
            iconBackgroundView.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            iconBackgroundView.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 40),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ]
        
        constraints.append(contentsOf: [
            chevron.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 20),
            chevron.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate(constraints)
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }

    @objc private func headerTapped(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }
        if expandedSection == section {
            expandedSection = nil // Collapse if already open
        } else {
            expandedSection = section // Expand tapped section
        }
        tableView.reloadData()
    }
}
