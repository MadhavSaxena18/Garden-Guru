import UIKit
import SDWebImage

class BrowsePlantsViewController: UIViewController {
    
    private let dataController = DataControllerGG.shared
    private var allPlants: [Plant] = []
    private var filteredPlants: [Plant] = []
    private var categories: [Category] = [.ornamental, .flowering, .medical]
    private var selectedCategory: Category?
    
    private var collectionView: UICollectionView!
    private var segmentedControl: UISegmentedControl!
    private let searchBar = UISearchBar()
    private let emptyStateLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSegmentedControl()
        setupSearchBar()
        setupCollectionView()
        setupEmptyState()
        loadPlants()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "EBF4EB")
        title = "Browse Plants"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = UIColor(hex: "004E05")
    }
    
    private func setupSegmentedControl() {
        let items = ["All", "Ornamental", "Flowering", "Medical"]
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .white
        segmentedControl.selectedSegmentTintColor = UIColor(hex: "2F8F2F")
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor(hex: "004E05"),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        segmentedControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search plants..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .white
            textField.layer.cornerRadius = 12
            textField.clipsToBounds = true
            textField.textColor = UIColor(hex: "004E05")
        }
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let width = (view.bounds.width - 44) / 2
        layout.itemSize = CGSize(width: width, height: width + 70)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PlantBrowseCell.self, forCellWithReuseIdentifier: "PlantBrowseCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateLabel.text = "No plants found"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textColor = UIColor(hex: "6B7280")
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadPlants() {
        Task {
            do {
                allPlants = try await dataController.getPlants()
                filteredPlants = allPlants
                
                // Debug: Check categories in loaded plants
                print("📦 Loaded \(allPlants.count) plants")
                
                // Debug: Show raw category values
                print("🔍 Checking first 10 plants for category data:")
                for (index, plant) in allPlants.prefix(10).enumerated() {
                    print("  \(index + 1). \(plant.plantName)")
                    print("     - category_new: \(plant.category_new?.rawValue ?? "nil")")
                }
                
                let categoryCounts = Dictionary(grouping: allPlants) { $0.category_new }
                print("📊 Category distribution:")
                print("  - Ornamental: \(categoryCounts[.ornamental]?.count ?? 0)")
                print("  - Flowering: \(categoryCounts[.flowering]?.count ?? 0)")
                print("  - Medical: \(categoryCounts[.medical]?.count ?? 0)")
                print("  - No category: \(categoryCounts[nil]?.count ?? 0)")
                
                await MainActor.run {
                    updateEmptyState()
                    collectionView.reloadData()
                }
            } catch {
                print("❌ Error loading plants: \(error)")
                await MainActor.run {
                    showError("Failed to load plants. Please try again.")
                }
            }
        }
    }
    
    @objc private func categoryChanged() {
        let index = segmentedControl.selectedSegmentIndex
        
        switch index {
        case 0:
            selectedCategory = nil
            print("🔍 Filter: All plants")
        case 1:
            selectedCategory = .ornamental
            print("🔍 Filter: Ornamental")
        case 2:
            selectedCategory = .flowering
            print("🔍 Filter: Flowering")
        case 3:
            selectedCategory = .medical
            print("🔍 Filter: Medical")
        default:
            selectedCategory = nil
            print("🔍 Filter: All plants (default)")
        }
        
        print("📊 Total plants: \(allPlants.count)")
        filterPlants()
    }
    
    private func filterPlants() {
        let searchText = searchBar.text?.lowercased() ?? ""
        
        filteredPlants = allPlants.filter { plant in
            let matchesCategory = selectedCategory == nil || plant.category_new == selectedCategory
            let matchesSearch = searchText.isEmpty || 
                plant.plantName.lowercased().contains(searchText) ||
                (plant.plantBotanicalName?.lowercased().contains(searchText) ?? false)
            return matchesCategory && matchesSearch
        }
        
        print("✅ Filtered plants: \(filteredPlants.count)")
        if let category = selectedCategory {
            print("📋 Category filter: \(category.rawValue)")
            // Debug: Show first few plants and their categories
            for (index, plant) in allPlants.prefix(5).enumerated() {
                print("  Plant \(index + 1): \(plant.plantName) - Category: \(plant.category_new?.rawValue ?? "nil")")
            }
        }
        
        updateEmptyState()
        collectionView.reloadData()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !filteredPlants.isEmpty
        collectionView.isHidden = filteredPlants.isEmpty
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func addPlantToMySpace(_ plant: Plant) {
        let nicknameVC = addNickNameViewController()
        nicknameVC.selectedPlant = plant
        nicknameVC.plantNameForReminder = plant.plantName
        
        let navController = UINavigationController(rootViewController: nicknameVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension BrowsePlantsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPlants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantBrowseCell", for: indexPath) as! PlantBrowseCell
        let plant = filteredPlants[indexPath.item]
        cell.configure(with: plant)
        cell.onAddTapped = { [weak self] in
            self?.addPlantToMySpace(plant)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension BrowsePlantsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let plant = filteredPlants[indexPath.item]
        addPlantToMySpace(plant)
    }
}

// MARK: - UISearchBarDelegate
extension BrowsePlantsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterPlants()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - PlantBrowseCell
class PlantBrowseCell: UICollectionViewCell {
    
    var onAddTapped: (() -> Void)?
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(hex: "F2F6F2")
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(hex: "004E05")
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryBadge: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        label.textColor = .white
        label.backgroundColor = UIColor(hex: "2F8F2F")
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = UIColor(hex: "2F8F2F")
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(categoryBadge)
        contentView.addSubview(addButton)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.85),
            
            categoryBadge.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 6),
            categoryBadge.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 6),
            categoryBadge.heightAnchor.constraint(equalToConstant: 18),
            categoryBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            addButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 6),
            addButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -6),
            addButton.widthAnchor.constraint(equalToConstant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with plant: Plant) {
        nameLabel.text = plant.plantName
        
        // Set category badge
        if let category = plant.category_new {
            categoryBadge.text = " \(category.rawValue.uppercased()) "
            categoryBadge.isHidden = false
        } else {
            categoryBadge.isHidden = true
        }
        
        // Load image with proper URL cleaning
        if let urlString = plant.imageURLs.first {
            var cleanedURLString = urlString
                .replacingOccurrences(of: "//01", with: "/01")
                .trimmingCharacters(in: .whitespaces)
            
            // Fix missing slash after https:
            if cleanedURLString.hasPrefix("https:/") && !cleanedURLString.hasPrefix("https://") {
                cleanedURLString = cleanedURLString.replacingOccurrences(of: "https:/", with: "https://")
            }
            
            // Remove any remaining double slashes except after https://
            if let range = cleanedURLString.range(of: "https://") {
                let afterProtocol = cleanedURLString[range.upperBound...]
                let fixedPath = afterProtocol.replacingOccurrences(of: "//", with: "/")
                cleanedURLString = "https://" + fixedPath
            }
            
            if let url = URL(string: cleanedURLString) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "leaf.fill")) { [weak self] image, error, _, _ in
                    if error != nil {
                        // Silently use fallback icon
                        self?.imageView.image = UIImage(systemName: "leaf.fill")
                        self?.imageView.tintColor = UIColor(hex: "2F8F2F")
                    }
                }
            } else {
                imageView.image = UIImage(systemName: "leaf.fill")
                imageView.tintColor = UIColor(hex: "2F8F2F")
            }
        } else {
            imageView.image = UIImage(systemName: "leaf.fill")
            imageView.tintColor = UIColor(hex: "2F8F2F")
        }
    }
    
    @objc private func addButtonTapped() {
        // Animate button
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = .identity
            }
        }
        onAddTapped?()
    }
}
