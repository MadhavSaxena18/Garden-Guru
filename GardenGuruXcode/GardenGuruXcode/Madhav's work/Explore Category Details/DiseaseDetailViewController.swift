//
//  DiseaseDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 23/02/25.
//

import UIKit

class DiseaseDetailViewController: UIViewController {

    var disease: Diseases?
    private var expandedSections: Set<Int> = []
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Remove separators
        tableView.separatorStyle = .none
        
        // Setup Navigation
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureHeaderView() {
        guard let disease = disease else { return }
        
        // Configure image
        if let imageName = disease.diseaseImage.first {
            headerImageView.image = UIImage(named: imageName)
        }
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        
        // Configure disease name label
        diseaseNameLabel.text = disease.diseaseName
        let symptomsText = disease.diseaseSymptoms.joined(separator: ", ")
        diseaseSymptoms.text = "\(symptomsText)"
        
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
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections.contains(section) ? 2 : 1 // Show detail row if expanded
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 55 // Header cell height
        } else {
            return UITableView.automaticDimension // Let the content determine the height
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 55 : 100 // Provide estimated heights
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 16 : 8 // Regular spacing between sections
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let cellBackgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        if indexPath.row == 0 {
            // Header cell
            configureHeaderCell(cell, for: indexPath.section, backgroundColor: cellBackgroundColor)
        } else {
            // Detail cell
            configureDetailCell(cell, for: indexPath.section, backgroundColor: cellBackgroundColor)
        }
        
        return cell
    }
    
    private func configureHeaderCell(_ cell: UITableViewCell, for section: Int, backgroundColor: UIColor) {
        // Setup darker gray background view
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        backgroundView.layer.cornerRadius = 8
        cell.backgroundView = backgroundView
        
        // Setup selected background view
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        selectedBackgroundView.layer.cornerRadius = 8
        cell.selectedBackgroundView = selectedBackgroundView
        
        // Configure content
        let options = ["Cure and Treatment", "Preventive Measures", "Symptoms",
                      "Vitamins Required", "Related Images", "Video Solution"]
        cell.textLabel?.text = options[section]
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .black
        
        // Add padding to content
        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cell.contentView.preservesSuperviewLayoutMargins = false
        
        // Configure accessory
        let imageName = expandedSections.contains(section) ? "chevron.down" : "chevron.right"
        let chevronImage = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        let chevronView = UIImageView(image: chevronImage)
        chevronView.tintColor = .gray
        chevronView.contentMode = .scaleAspectFit
        cell.accessoryView = chevronView
        
        cell.selectionStyle = .none
    }
    
    private func configureDetailCell(_ cell: UITableViewCell, for section: Int, backgroundColor: UIColor) {
        // Setup background view with white color
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 8
        cell.backgroundView = backgroundView
        
        // Add padding
        let padding = UIEdgeInsets(top: 24, left: 20, bottom: 16, right: 20)
        cell.contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: padding.top,
            leading: padding.left,
            bottom: padding.bottom,
            trailing: padding.right
        )
        
        // Remove any existing subviews from previous cells
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.textLabel?.text = nil // Clear existing text
        
        // Configure content based on section
        switch section {
        case 0: // Cure and Treatment
            if let cureAndTreatment = disease?.diseaseDetail["Cure and Treatment"] as? [String] {
                cell.textLabel?.text = cureAndTreatment.joined(separator: "\n")
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = .systemFont(ofSize: 15)
                cell.textLabel?.textColor = .darkGray
            }
            
        case 1: // Preventive Measures
            if let preventiveMeasures = disease?.diseaseDetail["Preventive Measures"] as? [String] {
                cell.textLabel?.text = preventiveMeasures.joined(separator: "\n")
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = .systemFont(ofSize: 15)
                cell.textLabel?.textColor = .darkGray
            }
            
        case 2: // Symptoms
            if let symptoms = disease?.diseaseDetail["Symptoms"] as? [String] {
                cell.textLabel?.text = symptoms.joined(separator: "\n")
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = .systemFont(ofSize: 15)
                cell.textLabel?.textColor = .darkGray
            }
            
        case 3: // Vitamins Required
            if let vitamins = disease?.diseaseDetail["Vitamins Required"] as? [String] {
                cell.textLabel?.text = vitamins.joined(separator: "\n")
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = .systemFont(ofSize: 15)
                cell.textLabel?.textColor = .darkGray
            }
            
        case 4: // Related Images
            if let images = disease?.diseaseDetail["Related Images"] as? [String] {
                // Create scroll view for horizontal scrolling
                let scrollView = UIScrollView()
                scrollView.translatesAutoresizingMaskIntoConstraints = false
                scrollView.showsHorizontalScrollIndicator = false
                scrollView.showsVerticalScrollIndicator = false
                
                // Create stack view to hold images
                let stackView = UIStackView()
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackView.axis = .horizontal
                stackView.spacing = 10
                stackView.alignment = .center
                
                // Add images to stack view
                for imageName in images {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    imageView.image = UIImage(named: imageName)
                    imageView.isUserInteractionEnabled = true
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                    imageView.addGestureRecognizer(tapGesture)
                    
                    let imageSize: CGFloat = 280
                    imageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
                    imageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
                    imageView.layer.cornerRadius = 12
                    
                    stackView.addArrangedSubview(imageView)
                }
                
                scrollView.addSubview(stackView)
                cell.contentView.addSubview(scrollView)
                
                NSLayoutConstraint.activate([
                    scrollView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                    scrollView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                    scrollView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
                    scrollView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),
                    scrollView.heightAnchor.constraint(equalToConstant: 300),
                    
                    stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                    stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                    stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
                ])
            }
            
        case 5: // Video Solution
            if let videos = disease?.diseaseDetail["Video Solution"] as? [String] {
                // Create text view for clickable links
                let textView = UITextView()
                textView.translatesAutoresizingMaskIntoConstraints = false
                textView.isEditable = false
                textView.isScrollEnabled = false
                textView.backgroundColor = .clear
                textView.delegate = self
                
                // Create attributed string for links
                let attributedString = NSMutableAttributedString()
                for (index, video) in videos.enumerated() {
                    let linkAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.systemBlue,
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .link: video
                    ]
                    
                    let videoLink = NSAttributedString(string: "Video Solution \(index + 1)", attributes: linkAttributes)
                    attributedString.append(videoLink)
                    
                    if index < videos.count - 1 {
                        attributedString.append(NSAttributedString(string: "\n"))
                    }
                }
                
                textView.attributedText = attributedString
                textView.linkTextAttributes = [
                    .foregroundColor: UIColor.systemBlue,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
                
                cell.contentView.addSubview(textView)
                
                NSLayoutConstraint.activate([
                    textView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: padding.top),
                    textView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: padding.left),
                    textView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -padding.right),
                    textView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -padding.bottom)
                ])
            }
            
        default:
            break
        }
        
        // Remove selection style and accessory
        cell.selectionStyle = .none
        cell.accessoryView = nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { // Only toggle for header cells
            let section = indexPath.section
            
            // Animate the chevron rotation
            if let cell = tableView.cellForRow(at: indexPath),
               let chevronView = cell.accessoryView as? UIImageView {
                UIView.animate(withDuration: 0.3) {
                    chevronView.transform = self.expandedSections.contains(section) ?
                        .identity : CGAffineTransform(rotationAngle: .pi/2)
                }
            }
            
            // Toggle section expansion
            if expandedSections.contains(section) {
                expandedSections.remove(section)
            } else {
                expandedSections.insert(section)
            }
            
            // Reload with animation
            UIView.animate(withDuration: 0.3) {
                tableView.performBatchUpdates({
                    tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                })
            }
        }
    }
    
    // Remove the extra spacing from section headers and footers
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 5 ? 20 : 0 // Only bottom padding for last section
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
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
