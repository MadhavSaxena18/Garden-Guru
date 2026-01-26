import UIKit
import SDWebImage

class PlantSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private let dataController = DataControllerGG.shared
    private var allPlants: [Plant] = []
    private var filteredPlants: [Plant] = []
    
    private var searchBar: UISearchBar!
    private var tableView: UITableView!
    private let emptyStateLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupTableView()
        setupEmptyState()
        loadPlants()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Auto-focus search bar
        searchBar.becomeFirstResponder()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "EBF4EB")
        title = "Search Plants"
        
        // Add cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor(hex: "004E05")
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search plants by name..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .white
            textField.layer.cornerRadius = 12
            textField.clipsToBounds = true
            textField.textColor = UIColor(hex: "004E05")
            textField.clearButtonMode = .whileEditing
        }
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlantSearchCell.self, forCellReuseIdentifier: "PlantSearchCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateLabel.text = "Start typing to search plants"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.textColor = UIColor(hex: "6B7280")
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func loadPlants() {
        Task {
            do {
                allPlants = try await dataController.getPlants()
            } catch {
                await MainActor.run {
                    showError("Failed to load plants. Please try again.")
                }
            }
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func performSearch(with searchText: String) {
        if searchText.isEmpty {
            filteredPlants = []
            emptyStateLabel.text = "Start typing to search plants"
            emptyStateLabel.isHidden = false
            tableView.isHidden = true
        } else {
            filteredPlants = allPlants.filter {
                $0.plantName.lowercased().contains(searchText.lowercased()) ||
                ($0.plantBotanicalName?.lowercased().contains(searchText.lowercased()) ?? false)
            }
            
            if filteredPlants.isEmpty {
                emptyStateLabel.text = "No plants found matching '\(searchText)'"
                emptyStateLabel.isHidden = false
                tableView.isHidden = true
            } else {
                emptyStateLabel.isHidden = true
                tableView.isHidden = false
            }
        }
        
        tableView.reloadData()
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantSearchCell", for: indexPath) as! PlantSearchCell
        let plant = filteredPlants[indexPath.row]
        cell.configure(with: plant)
        cell.onAddTapped = { [weak self] in
            self?.addPlantToMySpace(plant)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let plant = filteredPlants[indexPath.row]
        addPlantToMySpace(plant)
    }
    
    // MARK: - Add Plant to My Space
    private func addPlantToMySpace(_ plant: Plant) {
        let nicknameVC = addNickNameViewController()
        nicknameVC.selectedPlant = plant
        nicknameVC.plantNameForReminder = plant.plantName
        
        let navController = UINavigationController(rootViewController: nicknameVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
}

// MARK: - PlantSearchCell
class PlantSearchCell: UITableViewCell {
    
    var onAddTapped: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let plantImageView: UIImageView = {
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
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(hex: "004E05")
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "6B7280")
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "2F8F2F")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(plantImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(addButton)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            plantImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            plantImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            plantImageView.widthAnchor.constraint(equalToConstant: 90),
            plantImageView.heightAnchor.constraint(equalToConstant: 90),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: plantImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: plantImageView.trailingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            addButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 80),
            addButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with plant: Plant) {
        nameLabel.text = plant.plantName
        descriptionLabel.text = plant.plantDescription ?? plant.plantBotanicalName ?? "Beautiful plant for your space"
        
        // Load image with proper URL cleaning
        if let urlString = plant.imageURLs.first {
            var cleanedURLString = urlString
                .replacingOccurrences(of: "//01", with: "/01")
                .trimmingCharacters(in: .whitespaces)
            
            if cleanedURLString.hasPrefix("https:/") && !cleanedURLString.hasPrefix("https://") {
                cleanedURLString = cleanedURLString.replacingOccurrences(of: "https:/", with: "https://")
            }
            
            if let range = cleanedURLString.range(of: "https://") {
                let afterProtocol = cleanedURLString[range.upperBound...]
                let fixedPath = afterProtocol.replacingOccurrences(of: "//", with: "/")
                cleanedURLString = "https://" + fixedPath
            }
            
            if let url = URL(string: cleanedURLString) {
                plantImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "leaf.fill")) { [weak self] image, error, _, _ in
                    if error != nil {
                        self?.plantImageView.image = UIImage(systemName: "leaf.fill")
                        self?.plantImageView.tintColor = UIColor(hex: "2F8F2F")
                    }
                }
            } else {
                plantImageView.image = UIImage(systemName: "leaf.fill")
                plantImageView.tintColor = UIColor(hex: "2F8F2F")
            }
        } else {
            plantImageView.image = UIImage(systemName: "leaf.fill")
            plantImageView.tintColor = UIColor(hex: "2F8F2F")
        }
    }
    
    @objc private func addButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = .identity
            }
        }
        onAddTapped?()
    }
}
