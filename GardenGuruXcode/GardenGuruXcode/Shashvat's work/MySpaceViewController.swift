//
//  MySpaceViewController.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit
import SDWebImage

class MySpaceViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout {
    // Static array to store newly added plants
    static var newlyAddedPlants: [UserPlant] = []
    
    // Use shared instance
    private let dataController = DataControllerGG.shared
    private var userPlants: [(userPlant: UserPlant, plant: Plant)] = []
    private var plantCategories: [String] = []
    private var categorizedPlants: [[UserPlant]] = []
    private var userStats: [String: Int] = [:]
    private let statsSectionIndex = 0 // Make stats the first section
    
    // Add these properties
    private var filteredPlantCategories: [String] = []
    private var filteredCategorizedPlants: [[UserPlant]] = []
    private var isSearching: Bool = false
    
    // Add property to store newly added plant
    private var newlyAddedPlant: (userPlant: UserPlant, plant: Plant)? = nil
    
    @IBOutlet weak var mySpaceCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MySpaceViewController viewDidLoad")
        
        // Setup search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search by plant name or nickname"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Verify collection view
        if mySpaceCollectionView == nil {
            print("ERROR: Collection view not connected!")
        } else {
            print("Collection view successfully connected")
        }
        
        // Setup collection view
        setupCollectionView()
        
        // Add observer for new plant
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewPlantAdded(_:)),
            name: NSNotification.Name("NewPlantAdded"),
            object: nil
        )
        
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        loadData()
        mySpaceCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Collection view frame: \(mySpaceCollectionView.frame)")
        print("Collection view bounds: \(mySpaceCollectionView.bounds)")
        print("View frame: \(view.frame)")
        
        // Force layout if needed
        mySpaceCollectionView.layoutIfNeeded()
    }
    
    private func loadUserData() {
        if let user = dataController.getUserSync() {
            let userPlantsWithDetails = dataController.getUserPlantsWithBasicDetailsSync(for: user.userEmail)
            userPlants = userPlantsWithDetails ?? []
            mySpaceCollectionView.reloadData()
        }
    }
    
    private func loadData() {
        print("\n=== MySpaceViewController loadData started ===")
        print("🔑 Checking UserDefaults...")
        print("isLoggedIn: \(UserDefaults.standard.bool(forKey: "isLoggedIn"))")
        print("userEmail: \(UserDefaults.standard.string(forKey: "userEmail") ?? "nil")")
        
        guard let user = dataController.getUserSync() else {
            print("❌ ERROR: No users found in DataController")
            return
        }
        
        print("✅ Found user: \(user.userEmail)")
        
        // Get plants with details using the sync wrapper
        print("🌿 Fetching plants for user...")
        let plantsWithDetails = dataController.getUserPlantsWithBasicDetailsSync(for: user.userEmail) ?? []
        
        print("\n📊 Plant Details Summary:")
        print("Total plants found: \(plantsWithDetails.count)")
        
        plantsWithDetails.forEach { plantWithDetails in
            print("\nPlant: \(plantWithDetails.plant.plantName)")
            print("- ID: \(plantWithDetails.userPlant.userplantID?.uuidString ?? "nil")")
            print("- Nickname: \(plantWithDetails.userPlant.userPlantNickName ?? "nil")")
        }
        
        // Calculate user stats with actual count
        let totalPlants = plantsWithDetails.count
        print("\n📈 Stats:")
        print("Total Plants: \(totalPlants)")
        
        // Count plants by category
        var categoryCount: [Category: Int] = [:]
        plantsWithDetails.forEach { plantWithDetails in
            if let category = plantWithDetails.plant.category {
                categoryCount[category, default: 0] += 1
                print("Category \(category): \(categoryCount[category] ?? 0) plants")
            }
        }
        
        userStats = [
            "Total Plants": totalPlants,
            "Ornamental": categoryCount[.Ornamental] ?? 0,
            "Flowering": categoryCount[.Flowering] ?? 0,
            "Medicinal": categoryCount[.medicinal] ?? 0
        ]
        
        // Group plants by name with debug info
        let groupedPlants = Dictionary(grouping: plantsWithDetails) { tuple in
            tuple.plant.plantName
        }
        
        print("\n🔍 Plant Grouping:")
        groupedPlants.forEach { (name, plants) in
            print("- \(name): \(plants.count) plant(s)")
        }
        
        // Create categories and categorized plants
        plantCategories = groupedPlants.keys.sorted()
        categorizedPlants = plantCategories.map { plantName in
            groupedPlants[plantName]?.map { $0.userPlant } ?? []
        }
        
        print("\n🏷 Categories:")
        for (index, category) in plantCategories.enumerated() {
            print("- \(category): \(categorizedPlants[index].count) plant(s)")
        }
        
        // Update UI on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("\n🔄 Updating UI...")
            self.mySpaceCollectionView.reloadData()
            print("Collection view sections: \(self.numberOfSections(in: self.mySpaceCollectionView))")
            for section in 0..<self.numberOfSections(in: self.mySpaceCollectionView) {
                let items = self.collectionView(self.mySpaceCollectionView, numberOfItemsInSection: section)
                print("Section \(section): \(items) items")
            }
        }
        
        print("=== MySpaceViewController loadData completed ===\n")
    }
    
    // Update the search results
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces).lowercased(), !searchText.isEmpty else {
            isSearching = false
            filteredPlantCategories = plantCategories
            filteredCategorizedPlants = categorizedPlants
            mySpaceCollectionView.reloadData()
            return
        }
        
        isSearching = true
        
        // Create tuples of categories and their plants
        let categoryPlantPairs = zip(plantCategories, categorizedPlants)
        
        // Filter the plants based on search text
        let filteredPairs = categoryPlantPairs.compactMap { category, plants -> (String, [UserPlant])? in
            let filteredPlants = plants.filter { userPlant in
                // Get the plant details using sync wrapper
                if let plantID = userPlant.userplantID,
                   let plant = dataController.getPlantSync(by: plantID) {
                // Check if either nickname or plant name contains the search text
                    return (userPlant.userPlantNickName?.lowercased().contains(searchText))! ||
                       plant.plantName.lowercased().contains(searchText)
                }
                return false
            }
            
            // Only include categories that have matching plants
            return filteredPlants.isEmpty ? nil : (category, filteredPlants)
        }
        
        // Split the filtered pairs back into separate arrays
        filteredPlantCategories = filteredPairs.map { $0.0 }
        filteredCategorizedPlants = filteredPairs.map { $0.1 }
        
        mySpaceCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let plantSections = (isSearching ? filteredPlantCategories : plantCategories).count
        let totalSections = plantSections + 1 // +1 for stats section
        print("Number of sections: \(totalSections) (1 stats + \(plantSections) plant categories)")
        return totalSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == statsSectionIndex {
            print("Stats section (0): 1 item")
            return 1
        }
        
        let plants = isSearching ? filteredCategorizedPlants : categorizedPlants
        let categoryIndex = section - 1
        let count = plants[categoryIndex].count
        let categoryName = plantCategories[categoryIndex]
        print("Plant section \(section) (\(categoryName)): \(count) items")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == statsSectionIndex {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell", for: indexPath) as! MySpaceStatsCell
            cell.configure(with: userStats)
            return cell
        }
        let plants = isSearching ? filteredCategorizedPlants : categorizedPlants
        let userPlant = plants[indexPath.section - 1][indexPath.item]
        guard let plantID = userPlant.userplantID,
              let plant = dataController.getPlantSync(by: plantID) else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! MySpaceCollectionViewSection1Cell
        // Set nickname
        cell.section1NickNameLabel.text = userPlant.userPlantNickName ?? ""
        // Set image: Prefer userPlant image, else plant image, else placeholder
        if let userPlantImageURL = userPlant.userPlantImage, !userPlantImageURL.isEmpty, let url = URL(string: userPlantImageURL) {
            cell.section1PlantImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "plant_placeholder"))
        } else if let plantImageURL = plant.plantImage, !plantImageURL.isEmpty, let url = URL(string: plantImageURL) {
            cell.section1PlantImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "plant_placeholder"))
        } else {
            cell.section1PlantImageView.image = UIImage(named: "plant_placeholder")
        }
        // Set up 3-dots menu if needed
        cell.optionsHandler = { [weak self] in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self?.dataController.deleteUserPlantSync(userPlantID: userPlant.userPlantRelationID)
                self?.loadData()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            if let popover = alert.popoverPresentationController {
                popover.sourceView = cell
                popover.sourceRect = cell.bounds
            }
            self?.present(alert, animated: true)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "MySpaceHeaderCollectionReusableView",
                for: indexPath
            ) as! MySpaceHeaderCollectionReusableView
            
            if indexPath.section > 0 {
                let categories = isSearching ? filteredPlantCategories : plantCategories
                let plants = isSearching ? filteredCategorizedPlants : categorizedPlants
                
                let plantName = categories[indexPath.section - 1]
                let plantsInSection = plants[indexPath.section - 1]
                // Show name with count in brackets
                header.headerLabel.text = "\(plantName) (\(plantsInSection.count))"
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                header.headerLabel.textColor = UIColor(hex: "284329")
                // Hide the totalPlantLabel
                header.totalPlantLabel.isHidden = true
            }
            
            return header
        }
        return UICollectionReusableView()
    }
    
    func generateLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            if sectionIndex == self.statsSectionIndex {
                return self.generateStatsLayout()
            }
            
            // Use generateSection1Layout for all plant sections
            return self.generateSection1Layout()
        }
        return layout
    }
    
    private func generateStatsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(290)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .absolute(290)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPaging  // Add horizontal scrolling like plant cards
        
        return section
    }
    
    func generateSection1Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .absolute(260)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(260)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 2
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 0)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(45)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func setupCollectionView() {
        print("Setting up collection view")
        
        // Force layout if needed
        view.layoutIfNeeded()
        
        // Set theme background color
        mySpaceCollectionView.backgroundColor = UIColor(hex: "EBF4EB")
        
        // Add these constraints
        mySpaceCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mySpaceCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mySpaceCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mySpaceCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mySpaceCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup layout
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            if sectionIndex == self.statsSectionIndex {
                return self.generateStatsLayout()
            }
            
            return self.generateSection1Layout()
        }
        mySpaceCollectionView.collectionViewLayout = layout
        
        // Register cells
        mySpaceCollectionView.register(MySpaceStatsCell.self, forCellWithReuseIdentifier: "StatsCell")
        mySpaceCollectionView.register(UINib(nibName: "MySpaceCollectionViewSection1Cell", bundle: nil), forCellWithReuseIdentifier: "first")
        
        // Register header
        mySpaceCollectionView.register(
            MySpaceHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "MySpaceHeaderCollectionReusableView"
        )
        
        mySpaceCollectionView.delegate = self
        mySpaceCollectionView.dataSource = self
        
        // Ensure the collection view is not hidden
        mySpaceCollectionView.isHidden = false
        
        print("Collection view setup completed")
    }
    
    @objc private func handleMenuButton(_ sender: UIButton) {
        let section = sender.tag >> 16
        let item = sender.tag & 0xFFFF
        let plants = isSearching ? filteredCategorizedPlants : categorizedPlants
        let userPlant = plants[section - 1][item]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.dataController.deleteUserPlantSync(userPlantID: userPlant.userPlantRelationID)
            self?.loadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        present(alert, animated: true)
    }
    
    @objc private func handleNewPlantAdded(_ notification: Notification) {
        guard let userPlant = notification.userInfo?["userPlant"] as? UserPlant,
              let plant = notification.userInfo?["plant"] as? Plant else {
            return
        }
        
        print("🔍 DEBUG: Handling new plant notification")
        print("Plant name: \(plant.plantName)")
        print("Plant ID: \(plant.plantID)")
        print("UserPlant ID: \(userPlant.userplantID)")
        
        // Check if this plant is already in newlyAddedPlants
        let isDuplicate = MySpaceViewController.newlyAddedPlants.contains { existingPlant in
            existingPlant.userplantID == userPlant.userplantID
        }
        
        if isDuplicate {
            print("⚠️ Plant already exists in newlyAddedPlants - skipping addition")
            return
        }
        
        // Add to newlyAddedPlants
        MySpaceViewController.newlyAddedPlants.append(userPlant)
        print("✅ Added plant to newlyAddedPlants")
        
        // Store for UI updates
        newlyAddedPlant = (userPlant: userPlant, plant: plant)
        
        // Update UI
        loadData()
        mySpaceCollectionView.reloadData()
    }
    
    // Don't forget to remove observer in deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MySpaceViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == statsSectionIndex {
            return CGSize(width: collectionView.bounds.width * 0.9, height: 290)
        }
        return CGSize(width: collectionView.bounds.width * 0.9, height: 290)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}
