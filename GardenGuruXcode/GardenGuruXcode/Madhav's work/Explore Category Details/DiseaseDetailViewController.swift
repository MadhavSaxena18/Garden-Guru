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

// Update the tableView section header to use a modern, rounded, system-style header with chevron
extension DiseaseDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // Symptoms, Causes, Treatments, Prevention
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections.contains(section) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiseaseDetailCell", for: indexPath) as! DiseaseDetailTableViewCell
        guard let disease = disease else {
            cell.configure(with: nil, section: "", showHeader: false)
            return cell
        }
        cell.isExpanded = true
        // Configure the cell as before, let the cell handle its own layout
        switch indexPath.section {
        case 0: cell.configure(with: disease, section: "Symptoms", showHeader: false)
        case 1: cell.configure(with: disease, section: "Causes", showHeader: false)
        case 2: cell.configure(with: disease, section: "Treatment", showHeader: false)
        case 3: cell.configure(with: disease, section: "Prevention", showHeader: false)
        default: cell.configure(with: nil, section: "", showHeader: false)
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
        header.backgroundColor = .tertiarySystemGroupedBackground
        header.layer.cornerRadius = 14
        header.layer.masksToBounds = true
        header.tag = section
        header.isUserInteractionEnabled = true
        // Add tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        header.addGestureRecognizer(tap)
        // Title label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        let titles = ["Symptoms", "Causes", "Treatment", "Prevention"]
        titleLabel.text = "  " + titles[section]
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)
        // Chevron
        let chevron = UIImageView(image: UIImage(systemName: expandedSections.contains(section) ? "chevron.down" : "chevron.right"))
        chevron.tintColor = .systemGray
        chevron.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(chevron)
        container.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            header.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            header.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 0),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            chevron.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 20),
            chevron.heightAnchor.constraint(equalToConstant: 20)
        ])
        return container
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    @objc private func headerTapped(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }
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
