//
//  DiseaseDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 23/02/25.
//

import UIKit
import SDWebImage

class DiseaseDetailViewController: UIViewController {

    var disease: Diseases?
    private var expandedSections: Set<Int> = [0] // Start with first section expanded
    private var fullscreenImageView: UIImageView?
    private var currentImageIndex: Int = 0
    private var imageArray: [UIImage] = []
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var diseaseSymptoms: UILabel!
    @IBOutlet weak var headerBackgroundView: UIView!
    var isModallyPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureHeaderView()
        setupNavigationBar()
        setupHeaderGradient()
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
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
    
    private func setupUI() {
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register cell with XIB
        let nib = UINib(nibName: "DiseaseDetailTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DiseaseDetailCell")
        
        // Remove separators and set background
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.92, green: 0.96, blue: 0.92, alpha: 1.0)
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        
        // Setup Navigation
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureHeaderView() {
        guard let disease = disease else { return }
        
        // Configure image
        if let imageURL = disease.diseaseImage {
            headerImageView.sd_setImage(with: URL(string: imageURL), 
                                      placeholderImage: UIImage(named: "disease_placeholder"),
                                      options: [], 
                                      completed: { [weak self] image, error, _, _ in
                if let error = error {
                    print("Error loading disease image: \(error)")
                    self?.headerImageView.image = UIImage(named: "disease_placeholder")
                }
            })
        } else {
            headerImageView.image = UIImage(named: "disease_placeholder")
        }
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        
        // Configure disease name label
        diseaseNameLabel.text = disease.diseaseName
        
        // Configure symptoms label
        if let symptoms = disease.diseaseSymptoms {
            diseaseSymptoms.text = symptoms
        } else {
            diseaseSymptoms.text = "No symptoms available"
        }
        
        // Style the disease name label
        diseaseNameLabel.textColor = .white
        diseaseNameLabel.font = .systemFont(ofSize: 32, weight: .bold)
        diseaseNameLabel.layer.shadowColor = UIColor.black.cgColor
        diseaseNameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        diseaseNameLabel.layer.shadowRadius = 3
        diseaseNameLabel.layer.shadowOpacity = 0.5
        
        // Style the symptoms label
        diseaseSymptoms.textColor = .white
        diseaseSymptoms.font = .systemFont(ofSize: 16, weight: .medium)
        diseaseSymptoms.layer.shadowColor = UIColor.black.cgColor
        diseaseSymptoms.layer.shadowOffset = CGSize(width: 0, height: 1)
        diseaseSymptoms.layer.shadowRadius = 3
        diseaseSymptoms.layer.shadowOpacity = 0.5
        
        // Ensure labels are above the blur and gradient
        diseaseNameLabel.layer.zPosition = 1
        diseaseSymptoms.layer.zPosition = 1
    }
    
    private func setupHeaderGradient() {
        // Create and configure blur effect
        let blurEffect = UIBlurEffect(style: .dark)  // Changed to dark for better contrast
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = headerBackgroundView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = headerBackgroundView.bounds
        
        // Create an attractive gradient with multiple colors
        let primaryColor = UIColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1.0)  // Vibrant red
        let secondaryColor = UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0) // Darker red
        
        gradientLayer.colors = [
            UIColor.clear.cgColor,                                // Transparent at top
            primaryColor.withAlphaComponent(0.3).cgColor,        // Subtle primary color
            primaryColor.withAlphaComponent(0.5).cgColor,        // Medium primary color
            secondaryColor.withAlphaComponent(0.7).cgColor,      // Stronger secondary color
            secondaryColor.withAlphaComponent(0.8).cgColor       // Most intense at bottom
        ]
        
        // More precise gradient positioning
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        
        // Adjust gradient direction slightly
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Add blur view first
        headerBackgroundView.addSubview(blurView)
        
        // Add gradient on top of blur
        let gradientView = UIView(frame: headerBackgroundView.bounds)
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerBackgroundView.addSubview(gradientView)
        
        // Make background clear to let blur work
        headerBackgroundView.backgroundColor = .clear
        
        // Enhanced shadow effect
        headerBackgroundView.layer.shadowColor = UIColor.black.cgColor
        headerBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerBackgroundView.layer.shadowRadius = 4
        headerBackgroundView.layer.shadowOpacity = 0.2
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
        titleLabel.font = .systemFont(ofSize: 22, weight: .medium) // Adjusted font size and weight to match image
        
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
