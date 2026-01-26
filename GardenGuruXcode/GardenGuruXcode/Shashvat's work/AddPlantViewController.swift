import UIKit
import SDWebImage

class AddPlantViewController: UIViewController, UISearchBarDelegate {
    
    private let dataController = DataControllerGG.shared
    private var searchResultsTableView: UITableView!
    
    private var headerPlants: [Plant] = []
    private var imageCache: NSCache<NSString, UIImage> = NSCache()
    private var isLoadingHeader = false
    
    // Weather service for getting recommended plants
    private let weatherService = WeatherService()
    private let locationManager = LocationManager()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupSearchBar()
            setupTableView()
            
            // Set back button color to green
            navigationController?.navigationBar.tintColor = UIColor(hex: "004E05")
            
            searchResultsTableView.isHidden = false
        }
    
    @objc private func searchBarTapped() {
        // Open dedicated search page
        let searchVC = PlantSearchViewController()
        let navController = UINavigationController(rootViewController: searchVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Recalculate header size if it exists and view size changed
        if let header = searchResultsTableView.tableHeaderView, 
           header.frame.width != searchResultsTableView.bounds.width {
            
            let targetWidth = searchResultsTableView.bounds.width
            let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
            let size = header.systemLayoutSizeFitting(
                fittingSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            
            if size.height > 0 && targetWidth > 0 {
                header.frame = CGRect(x: 0, y: 0, width: targetWidth, height: size.height)
                searchResultsTableView.tableHeaderView = header
                print("🔄 Header resized to: \(header.frame)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup header after view is in window hierarchy to avoid layout warnings
        if searchResultsTableView.tableHeaderView == nil && !isLoadingHeader {
            isLoadingHeader = true
            setupHeaderIfNeeded()
            Task { [weak self] in
                await self?.loadHeaderPlants()
                await MainActor.run {
                    self?.isLoadingHeader = false
                }
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "EBF4EB")
        title = "Add Plant"
        
        // Style navigation bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = UIColor(hex: "EBF4EB")
    }
        
        private func setupSearchBar() {
            searchBar.delegate = self
            searchBar.placeholder = "Search Plants"
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundColor = .clear
            searchBar.barTintColor = .clear
            searchBar.returnKeyType = .search
            searchBar.enablesReturnKeyAutomatically = false
            
            // Style the search text field
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.backgroundColor = .white
                textField.layer.cornerRadius = 12
                textField.clipsToBounds = true
                textField.textColor = UIColor(hex: "004E05")
                textField.clearButtonMode = .whileEditing
            }
            
            // Add tap gesture to open search page
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchBarTapped))
            searchBar.addGestureRecognizer(tapGesture)
        }
        
        private func setupTableView() {
            searchResultsTableView = UITableView()
            searchResultsTableView.isHidden = false
            searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
            searchResultsTableView.backgroundColor = UIColor(hex: "EBF4EB")
            searchResultsTableView.separatorStyle = .none
            searchResultsTableView.contentInsetAdjustmentBehavior = .never
            searchResultsTableView.isScrollEnabled = true
            searchResultsTableView.showsVerticalScrollIndicator = false
            
            view.addSubview(searchResultsTableView)
            
            NSLayoutConstraint.activate([
                searchResultsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
                searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                searchResultsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    
    @MainActor private func setupHeaderIfNeeded() {
        // Ensure table view has proper frame and is in window before setting up header
        guard searchResultsTableView.window != nil else {
            return
        }
        view.layoutIfNeeded()
        // Build an empty header initially; will populate after data loads
        setupTableHeader(with: [])
    }

    private func loadHeaderPlants() async {
        // Only load if we haven't already loaded plants
        guard headerPlants.isEmpty else {
            await MainActor.run {
                self.setupTableHeader(with: headerPlants)
            }
            return
        }
        
        do {
            // Get weather-based recommendations like home page
            let allPlants = try await dataController.getPlants()
            
            // Try to get location and weather
            do {
                let location = try await locationManager.requestLocation()
                let weather = try await weatherService.fetchWeather(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                // Map temperature to season
                let temp = weather.main.temp
                let mappedSeason: String
                if temp < 15 {
                    mappedSeason = "winter"
                } else if temp >= 15 && temp < 25 {
                    mappedSeason = "spring"
                } else if temp >= 25 && temp < 35 {
                    mappedSeason = "summer"
                } else {
                    mappedSeason = "rainy"
                }
                
                // Filter plants by season
                let weatherPlants = allPlants.filter { 
                    $0.favourableSeason?.rawValue.lowercased() == mappedSeason 
                }
                
                print("🌡️ Temperature: \(temp)°C, Season: \(mappedSeason)")
                print("🌱 Weather-based plants: \(weatherPlants.count)")
                
                // Limit to 8-10 plants
                let picks = Array(weatherPlants.prefix(10))
                self.headerPlants = picks.isEmpty ? Array(allPlants.prefix(8)) : picks
                
            } catch {
                print("⚠️ Could not get weather, using random plants: \(error)")
                // Fallback to random plants
                self.headerPlants = Array(allPlants.prefix(8))
            }
            
            await MainActor.run {
                self.setupTableHeader(with: self.headerPlants)
            }
        } catch {
            print("❌ Failed to load header plants: \(error)")
            await MainActor.run {
                self.setupTableHeader(with: [])
            }
        }
    }

    private func setupTableHeader(with plants: [Plant]) {
        let container = UIView()
        container.backgroundColor = .clear
        
        // IMPORTANT: Don't set translatesAutoresizingMaskIntoConstraints here
        // Table header views need manual frame sizing

        // 1) Action cards (Scan, Browse) - Equal size
        let actionsStack = UIStackView()
        actionsStack.axis = .horizontal
        actionsStack.spacing = 12
        actionsStack.distribution = .fillEqually

        func makeActionCard(title: String, subtitle: String, systemImage: String, bgColor: UIColor, action: @escaping () -> Void) -> UIView {
            let card = UIButton(type: .system)
            card.backgroundColor = .white
            card.layer.cornerRadius = 16
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.08
            card.layer.shadowOffset = CGSize(width: 0, height: 2)
            card.layer.shadowRadius = 6

            let iconContainer = UIView()
            iconContainer.backgroundColor = bgColor.withAlphaComponent(0.15)
            iconContainer.layer.cornerRadius = 30
            iconContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let icon = UIImageView(image: UIImage(systemName: systemImage))
            icon.tintColor = bgColor
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false

            iconContainer.addSubview(icon)
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            titleLabel.textColor = UIColor(hex: "004E05")
            titleLabel.textAlignment = .center

            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            subtitleLabel.textColor = UIColor(hex: "6B7280")
            subtitleLabel.textAlignment = .center

            let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            textStack.axis = .vertical
            textStack.spacing = 2
            textStack.alignment = .center

            let mainStack = UIStackView(arrangedSubviews: [iconContainer, textStack])
            mainStack.axis = .vertical
            mainStack.alignment = .center
            mainStack.spacing = 10
            mainStack.isUserInteractionEnabled = false

            card.addSubview(mainStack)
            mainStack.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                mainStack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                mainStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                mainStack.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 12),
                mainStack.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -12),
                
                iconContainer.widthAnchor.constraint(equalToConstant: 60),
                iconContainer.heightAnchor.constraint(equalToConstant: 60),
                
                icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 30),
                icon.heightAnchor.constraint(equalToConstant: 30),
                
                card.heightAnchor.constraint(equalToConstant: 110)
            ])

            card.addAction(UIAction { _ in action() }, for: .touchUpInside)
            return card
        }

        let scanCard = makeActionCard(
            title: "Scan Plant",
            subtitle: "Identify instantly",
            systemImage: "camera.fill",
            bgColor: UIColor(hex: "2F8F2F")
        ) { [weak self] in
            self?.openCamera(self as Any)
        }
        
        let browseCard = makeActionCard(
            title: "Browse Plants",
            subtitle: "Explore catalog",
            systemImage: "leaf.fill",
            bgColor: UIColor(hex: "4A9B4A")
        ) { [weak self] in
            self?.openBrowsePlants()
        }
        
        actionsStack.addArrangedSubview(scanCard)
        actionsStack.addArrangedSubview(browseCard)

        // 2) Section header: Recommended (NO See All button)
        let sectionHeader = UIView()
        
        let sectionTitle = UILabel()
        sectionTitle.text = "Recommended for You"
        sectionTitle.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        sectionTitle.textColor = UIColor(hex: "004E05")
        sectionTitle.translatesAutoresizingMaskIntoConstraints = false
        
        sectionHeader.addSubview(sectionTitle)
        
        NSLayoutConstraint.activate([
            sectionTitle.leadingAnchor.constraint(equalTo: sectionHeader.leadingAnchor),
            sectionTitle.trailingAnchor.constraint(equalTo: sectionHeader.trailingAnchor),
            sectionTitle.topAnchor.constraint(equalTo: sectionHeader.topAnchor),
            sectionTitle.bottomAnchor.constraint(equalTo: sectionHeader.bottomAnchor)
        ])

        // 3) Horizontal cards for plants
        let productsScroll = UIScrollView()
        productsScroll.showsHorizontalScrollIndicator = false
        let productsStack = UIStackView()
        productsStack.axis = .horizontal
        productsStack.spacing = 10

        func loadImage(for plant: Plant, into imageView: UIImageView) {
            // Use the imageURLs computed property from Plant model
            guard let urlString = plant.imageURLs.first else {
                imageView.image = UIImage(systemName: "leaf.fill")
                imageView.tintColor = UIColor(hex: "2F8F2F")
                return
            }
            
            // Clean and fix URL formatting - fix the https:/ issue
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
            
            guard let url = URL(string: cleanedURLString) else {
                print("❌ Invalid URL after cleaning: \(cleanedURLString)")
                imageView.image = UIImage(systemName: "leaf.fill")
                imageView.tintColor = UIColor(hex: "2F8F2F")
                return
            }
            
            // Use SDWebImage for better caching and performance
            imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "leaf.fill")) { image, error, _, _ in
                if error != nil {
                    // Silently use fallback icon - no need to log cancelled operations
                    imageView.image = UIImage(systemName: "leaf.fill")
                    imageView.tintColor = UIColor(hex: "2F8F2F")
                }
            }
        }

        func makePlantCard(_ plant: Plant) -> UIView {
            let card = UIView()
            card.backgroundColor = .white
            card.layer.cornerRadius = 14
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.08
            card.layer.shadowOffset = CGSize(width: 0, height: 2)
            card.layer.shadowRadius = 6

            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = UIColor(hex: "F2F6F2")
            imageView.layer.cornerRadius = 10
            loadImage(for: plant, into: imageView)

            let nameLabel = UILabel()
            nameLabel.text = plant.plantName
            nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            nameLabel.textColor = UIColor(hex: "004E05")
            nameLabel.numberOfLines = 2
            nameLabel.textAlignment = .center

            let addButton = UIButton(type: .system)
            addButton.setTitle("+ Add", for: .normal)
            addButton.setTitleColor(.white, for: .normal)
            addButton.backgroundColor = UIColor(hex: "2F8F2F")
            addButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            addButton.layer.cornerRadius = 8
            addButton.addAction(UIAction { [weak self] _ in
                self?.addPlantToMySpace(plant)
            }, for: .touchUpInside)

            card.addSubview(imageView)
            card.addSubview(nameLabel)
            card.addSubview(addButton)

            imageView.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            addButton.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
                imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
                imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
                imageView.heightAnchor.constraint(equalToConstant: 90),

                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
                nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 6),
                nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -6),

                addButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
                addButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                addButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
                addButton.widthAnchor.constraint(equalToConstant: 70),
                addButton.heightAnchor.constraint(equalToConstant: 32)
            ])

            card.translatesAutoresizingMaskIntoConstraints = false
            
            // Fixed calculation: Show 2.5 cards on screen
            // Use actual view width for responsive sizing
            let viewWidth = self.view.bounds.width > 0 ? self.view.bounds.width : 393
            let containerPadding: CGFloat = 32 // 16px on each side
            let totalSpacing: CGFloat = 20 // 10px × 2 gaps between 3 cards
            let cardWidth = (viewWidth - containerPadding - totalSpacing) / 2.5
            
            print("📏 Card width calculation: viewWidth=\(viewWidth), cardWidth=\(cardWidth)")
            
            card.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
            return card
        }

        for p in plants.prefix(8) { productsStack.addArrangedSubview(makePlantCard(p)) }

        // 4) Layout hierarchy
        let vStack = UIStackView(arrangedSubviews: [actionsStack, sectionHeader, productsScroll])
        vStack.axis = .vertical
        vStack.spacing = 16

        container.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        productsScroll.addSubview(productsStack)
        productsScroll.translatesAutoresizingMaskIntoConstraints = false
        productsStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),

            productsScroll.heightAnchor.constraint(equalToConstant: 195),
            productsStack.topAnchor.constraint(equalTo: productsScroll.topAnchor),
            productsStack.bottomAnchor.constraint(equalTo: productsScroll.bottomAnchor),
            productsStack.leadingAnchor.constraint(equalTo: productsScroll.leadingAnchor),
            productsStack.trailingAnchor.constraint(equalTo: productsScroll.trailingAnchor),
            productsStack.heightAnchor.constraint(equalTo: productsScroll.heightAnchor)
        ])

        // Compute size and assign header
        container.setNeedsLayout()
        container.layoutIfNeeded()

        // Use the actual view width from the table view
        let targetWidth = searchResultsTableView.bounds.width > 0 ? searchResultsTableView.bounds.width : view.bounds.width
        print("📐 Table view width: \(searchResultsTableView.bounds.width)")
        print("📐 View width: \(view.bounds.width)")
        print("📐 Using width: \(targetWidth)")
        
        let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        let size = container.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        print("📐 Calculated header size: \(size)")
        
        // Only set header if we have a valid size
        if size.height > 0 && targetWidth > 0 {
            container.frame = CGRect(x: 0, y: 0, width: targetWidth, height: size.height)
            searchResultsTableView.tableHeaderView = container
            
            // Force layout update
            searchResultsTableView.layoutIfNeeded()
            
            // Re-assign to trigger proper sizing
            let header = searchResultsTableView.tableHeaderView
            searchResultsTableView.tableHeaderView = nil
            searchResultsTableView.tableHeaderView = header
            
            print("✅ Header set with frame: \(container.frame)")
        } else {
            print("❌ Invalid size - width: \(targetWidth), height: \(size.height)")
        }
    }
        
        // MARK: - Search Bar Delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Open dedicated search page when user taps search bar
        searchBar.resignFirstResponder()
        searchBarTapped()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // This won't be called since we open a new page
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
        
        // MARK: - Table View Data Source (Not used - search opens new page)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Not used
    }
    
    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Not used
    }
        
        @IBAction func unwindToAddPlantViewController(segue: UIStoryboardSegue) {
            if let sourceViewController = segue.source as? addPlantCameraViewController {
                // Now we can access stopCameraSession
                sourceViewController.stopCameraSession()
            }
        }
        
        @IBAction func openCamera(_ sender: Any) {
            let storyboard = UIStoryboard(name: "mySpaceTab", bundle: nil)
            if let cameraVC = storyboard.instantiateViewController(withIdentifier: "addPlantCameraViewController") as? addPlantCameraViewController {
                let navController = UINavigationController(rootViewController: cameraVC)
                navController.modalPresentationStyle = .fullScreen
                present(navController, animated: true)
            }
        }
    
    // MARK: - Browse Plants
    private func openBrowsePlants() {
        let browsePlantsVC = BrowsePlantsViewController()
        browsePlantsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(browsePlantsVC, animated: true)
    }
    
    // MARK: - Add Plant to My Space
    private func addPlantToMySpace(_ plant: Plant) {
        print("\n=== Adding Plant to My Space ===")
        print("Selected plant: \(plant.plantName)")
        
        let nicknameVC = addNickNameViewController()
        nicknameVC.selectedPlant = plant
        nicknameVC.plantNameForReminder = plant.plantName
        
        let navController = UINavigationController(rootViewController: nicknameVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
}
