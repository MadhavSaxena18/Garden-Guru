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
    private var expandedSections: Set<Int> = [0] // Start with first section expanded
    private var fullscreenImageView: UIImageView?
    private var currentImageIndex: Int = 0
    private var imageArray: [UIImage] = []
    var selectedCardData: Any?
    
    // Programmatic UI elements
    private let headerImageView = UIImageView()
    private let diseaseNameLabel = UILabel()
    private let diseaseSymptomsLabel = UILabel() // Renamed to avoid conflict with existing IBOutlet name
    private let headerBackgroundView = UIView()
    private let tableView = UITableView()
    private let textLabelsStackView = UIStackView() // New Stack View for labels
    
    var isModallyPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let disease = disease else {
            print("Disease is nil")
            return
        }
        selectedCardData = disease
        
        setupViews() // New method to setup all UI programmatically
        setupNavigationBar()
        checkIfAlreadySaved()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient frame when view resizes
        if let gradientView = headerBackgroundView.subviews.last,
           let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = headerBackgroundView.bounds
        }
    }
    
    private func setupNavigationBar() {
        // Only show Done button if modally presented
        if isModallyPresented {
            let doneButton = UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(dismissVC)
            )
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
        // Add all UI elements to the main view hierarchy
        view.addSubview(headerImageView)
        view.addSubview(tableView)
        view.addSubview(headerBackgroundView) // Add headerBackgroundView to view here

        // Set translatesAutoresizingMaskIntoConstraints to false for all programmatically created views
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        diseaseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        diseaseSymptomsLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure headerImageView
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        
        // Configure headerBackgroundView
        headerBackgroundView.backgroundColor = .clear
        headerBackgroundView.layer.shadowColor = UIColor.black.cgColor
        headerBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerBackgroundView.layer.shadowRadius = 4
        headerBackgroundView.layer.shadowOpacity = 0.2
        
        // Configure diseaseNameLabel
        diseaseNameLabel.textColor = .white
        diseaseNameLabel.font = .systemFont(ofSize: 36, weight: .bold)
        diseaseNameLabel.layer.shadowColor = UIColor.black.cgColor
        diseaseNameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        diseaseNameLabel.layer.shadowRadius = 3
        diseaseNameLabel.layer.shadowOpacity = 0.5
        diseaseNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Configure diseaseSymptomsLabel
        diseaseSymptomsLabel.textColor = .white
        diseaseSymptomsLabel.font = .systemFont(ofSize: 20, weight: .medium)
        diseaseSymptomsLabel.layer.shadowColor = UIColor.black.cgColor
        diseaseSymptomsLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        diseaseSymptomsLabel.layer.shadowRadius = 3
        diseaseSymptomsLabel.layer.shadowOpacity = 0.5
        diseaseSymptomsLabel.numberOfLines = 2 // Limit to 2 lines
        diseaseSymptomsLabel.lineBreakMode = .byTruncatingTail // Add ellipsis if truncated
        diseaseSymptomsLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Configure textLabelsStackView
        textLabelsStackView.axis = .vertical
        textLabelsStackView.spacing = 0 // Reduced spacing between name and symptoms to 0
        textLabelsStackView.distribution = .fill
        textLabelsStackView.alignment = .leading
        textLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
        textLabelsStackView.addArrangedSubview(diseaseNameLabel)
        textLabelsStackView.addArrangedSubview(diseaseSymptomsLabel)

        // Configure tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DiseaseDetailTableViewCell.self, forCellReuseIdentifier: "DiseaseDetailCell") // Register programmatic cell
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.92, green: 0.96, blue: 0.92, alpha: 1.0)
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        
        // Setup Navigation
        navigationItem.largeTitleDisplayMode = .never
        
        // Set initial data
        if let disease = disease {
            // Configure image
            if let imageURLString = disease.diseaseImage {
                print("🖼️ Debug: Original imageURLString: \(imageURLString)")
                
                let cleanURLString = imageURLString.replacingOccurrences(of: "//01", with: "/01").replacingOccurrences(of: "//", with: "/").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                print("🖼️ Debug: Cleaned imageURLString: \(cleanURLString ?? "nil after encoding")")
                
                if let url = URL(string: cleanURLString ?? "") {
                    print("🖼️ Debug: Final URL to load: \(url.absoluteString)")
                    headerImageView.sd_setImage(with: url, 
                                              placeholderImage: UIImage(named: "disease_placeholder"),
                                              options: [], 
                                              completed: { [weak self] image, error, cacheType, url in
                        if let error = error {
                            print("❌ Error loading disease image: \(error.localizedDescription)")
                            self?.headerImageView.image = UIImage(named: "disease_placeholder")
                        } else {
                            print("✅ Successfully loaded disease image from: \(url?.absoluteString ?? "unknown URL")")
                        }
                    })
                } else {
                    print("❌ Failed to create URL object from cleaned string: \(cleanURLString ?? "")")
                    self.headerImageView.image = UIImage(named: "disease_placeholder")
                }
            } else {
                print("❌ No valid disease image URL provided for \(disease.diseaseName)")
                headerImageView.image = UIImage(named: "disease_placeholder")
            }
            
            // Configure disease name label
            diseaseNameLabel.text = disease.diseaseName
            
            // Configure symptoms label
            if let symptoms = disease.diseaseSymptoms {
                diseaseSymptomsLabel.text = symptoms
            } else {
                diseaseSymptomsLabel.text = "No symptoms available"
            }
        }
        
        // Setup header gradient (integrated from setupHeaderGradient)
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial) 
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        let gradientLayer = CAGradientLayer()
        let primaryColor = UIColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1.0)
        let secondaryColor = UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0)
        
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            primaryColor.withAlphaComponent(0.02).cgColor,
            primaryColor.withAlphaComponent(0.05).cgColor,
            secondaryColor.withAlphaComponent(0.1).cgColor,
            secondaryColor.withAlphaComponent(0.2).cgColor  
        ]
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.addSublayer(gradientLayer)
        
        // ENSURE these are added as subviews BEFORE their constraints are activated
        headerBackgroundView.addSubview(blurView)
        headerBackgroundView.addSubview(gradientView)
        headerBackgroundView.addSubview(textLabelsStackView) // Add stack view to headerBackgroundView
        
        // Add constraints
        NSLayoutConstraint.activate([
            // headerImageView constraints
            headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 450), // Further increased height for header image
            
            // headerBackgroundView constraints (positioned at bottom of headerImageView with fixed height)
            headerBackgroundView.leadingAnchor.constraint(equalTo: headerImageView.leadingAnchor),
            headerBackgroundView.trailingAnchor.constraint(equalTo: headerImageView.trailingAnchor),
            headerBackgroundView.bottomAnchor.constraint(equalTo: headerImageView.bottomAnchor), // Pin to bottom of headerImageView
            headerBackgroundView.heightAnchor.constraint(equalToConstant: 80), // Fixed height for the overlay
            
            // blurView constraints (fills headerBackgroundView)
            blurView.topAnchor.constraint(equalTo: headerBackgroundView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: headerBackgroundView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: headerBackgroundView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: headerBackgroundView.bottomAnchor),
            
            // gradientView constraints (fills headerBackgroundView)
            gradientView.topAnchor.constraint(equalTo: headerBackgroundView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: headerBackgroundView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: headerBackgroundView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: headerBackgroundView.bottomAnchor),
            
            // textLabelsStackView constraints (positioned within headerBackgroundView, pinned to bottom)
            textLabelsStackView.leadingAnchor.constraint(equalTo: headerBackgroundView.leadingAnchor, constant: 16),
            textLabelsStackView.trailingAnchor.constraint(equalTo: headerBackgroundView.trailingAnchor, constant: -8),
            textLabelsStackView.bottomAnchor.constraint(equalTo: headerBackgroundView.bottomAnchor, constant: -8), // Pin to bottom of overlay with padding
            textLabelsStackView.topAnchor.constraint(greaterThanOrEqualTo: headerBackgroundView.topAnchor, constant: -2), // Ensure stack view doesn't go too high
            
            // tableView constraints (fills the rest of the view below the header)
            tableView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension DiseaseDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}

extension DiseaseDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // Symptoms, Causes, Treatments, Prevention
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections.contains(section) ? 1 : 0 // Show row only if section is expanded
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiseaseDetailCell", for: indexPath) as! DiseaseDetailTableViewCell
        
        guard let disease = disease else {
            cell.configure(with: nil, section: "", showHeader: false)
            return cell
        }
        
        cell.isExpanded = true // Always show content when row is visible
        
        switch indexPath.section {
        case 0: // Symptoms
            cell.configure(with: disease, section: "Symptoms", showHeader: false)
        case 1: // Causes
            cell.configure(with: disease, section: "Causes", showHeader: false)
        case 2: // Treatments
            cell.configure(with: disease, section: "Treatment", showHeader: false)
        case 3: // Prevention
            cell.configure(with: disease, section: "Prevention", showHeader: false)
        default:
            cell.configure(with: nil, section: "", showHeader: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        // Create container view with gray background
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0) // Solid light gray background
        containerView.layer.cornerRadius = 16
        
        // Add subtle shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowRadius = 1
        containerView.layer.shadowOpacity = 0.1
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 22, weight: .medium) // Adjusted font size and weight to match design
        
        // Set title based on section
        switch section {
        case 0:
            titleLabel.text = "Symptoms"
        case 1:
            titleLabel.text = "Causes"
        case 2:
            titleLabel.text = "Treatment"
        case 3:
            titleLabel.text = "Prevention"
        default:
            titleLabel.text = ""
        }
        
        // Create chevron image view
        let chevronImage = UIImageView(image: UIImage(systemName: expandedSections.contains(section) ? "chevron.down" : "chevron.right"))
        chevronImage.translatesAutoresizingMaskIntoConstraints = false
        chevronImage.tintColor = .gray
        chevronImage.contentMode = .scaleAspectFit
        
        headerView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(chevronImage)
        
        NSLayoutConstraint.activate([
            // Container view constraints - adjusted for better spacing
            containerView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Chevron image constraints
            chevronImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            chevronImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: 20),
            chevronImage.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag = section
        headerView.isUserInteractionEnabled = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60 // Increased height to match design
    }
    
    @objc private func headerTapped(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else {
            return
        }
        
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
        
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
    
    // Optional: Animate height changes
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? DiseaseDetailTableViewCell else { return }
        cell.isExpanded = true // Always show content when row is visible
    }
    
    @objc private func imageTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedImageView = gesture.view as? UIImageView,
              let image = tappedImageView.image else { return }
        
        // Get all images from the stack view
        if let stackView = tappedImageView.superview as? UIStackView {
            imageArray = stackView.arrangedSubviews.compactMap { view in
                guard let imageView = view as? UIImageView else { return nil }
                return imageView.image
            }
            
            // Set current index to the tapped image
            if let index = imageArray.firstIndex(of: image) {
                currentImageIndex = index
            }
        }
        
        // Create fullscreen image view
        let fullscreenView = UIView(frame: UIScreen.main.bounds)
        fullscreenView.backgroundColor = .black.withAlphaComponent(0.9)
        
        let imageView = UIImageView(frame: fullscreenView.bounds)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        // Add swipe gestures
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        
        fullscreenView.addGestureRecognizer(leftSwipe)
        fullscreenView.addGestureRecognizer(rightSwipe)
        
        // Add tap gesture to dismiss
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        fullscreenView.addGestureRecognizer(dismissTap)
        
        fullscreenView.addSubview(imageView)
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(dismissFullscreenImage), for: .touchUpInside)
        fullscreenView.addSubview(closeButton)
        
        // Add page indicator
        let pageLabel = UILabel()
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.textColor = .white
        pageLabel.text = "\(currentImageIndex + 1)/\(imageArray.count)"
        pageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        fullscreenView.addSubview(pageLabel)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: fullscreenView.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: fullscreenView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            pageLabel.bottomAnchor.constraint(equalTo: fullscreenView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            pageLabel.centerXAnchor.constraint(equalTo: fullscreenView.centerXAnchor)
        ])
        
        // Add to window with animation
        if let window = view.window {
            fullscreenView.alpha = 0
            window.addSubview(fullscreenView)
            
            UIView.animate(withDuration: 0.3) {
                fullscreenView.alpha = 1
            }
            
            self.fullscreenImageView = imageView
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let fullscreenView = fullscreenImageView?.superview,
              let pageLabel = fullscreenView.subviews.first(where: { $0 is UILabel }) as? UILabel else { return }
        
        if gesture.direction == .left && currentImageIndex < imageArray.count - 1 {
            currentImageIndex += 1
        } else if gesture.direction == .right && currentImageIndex > 0 {
            currentImageIndex -= 1
        } else {
            return
        }
        
        // Update image and page indicator
        UIView.transition(with: fullscreenImageView!,
                         duration: 0.3,
                         options: .transitionCrossDissolve,
                         animations: {
            self.fullscreenImageView?.image = self.imageArray[self.currentImageIndex]
            pageLabel.text = "\(self.currentImageIndex + 1)/\(self.imageArray.count)"
        }, completion: nil)
    }
    
    @objc private func dismissFullscreenImage() {
        guard let fullscreenView = fullscreenImageView?.superview else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            fullscreenView.alpha = 0
        }) { _ in
            fullscreenView.removeFromSuperview()
            self.fullscreenImageView = nil
        }
    }
}
