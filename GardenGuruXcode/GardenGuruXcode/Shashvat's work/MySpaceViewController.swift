//
//  MySpaceViewController.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

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
    
    private func loadData() {
        print("\n=== MySpaceViewController loadData started ===")
        
        let users = dataController.getUsers()
        
        if let firstUser = users.first {
            // Get plants from both sources
            let dataControllerPlants = dataController.getUserPlants(for: firstUser.userId)
            let allUserPlants = dataControllerPlants + MySpaceViewController.newlyAddedPlants
            
            print("\nAll plant IDs:")
            allUserPlants.forEach { plant in
                print("Plant: \(plant.userPlantNickName), ID: \(plant.userplantID)")
            }
            
            // Map all plants to tuples with plant data
            let plants = allUserPlants.compactMap { userPlant -> (userPlant: UserPlant, plant: Plant)? in
                print("\nLooking up plant with ID: \(userPlant.userplantID)")
                if let plant = dataController.getPlant(by: userPlant.userplantID) {
                    print("✅ Found plant: \(plant.plantName)")
                    return (userPlant: userPlant, plant: plant)
                } else {
                    print("❌ No plant found with ID: \(userPlant.userplantID)")
                    // Print all available plant IDs for debugging
                    print("Available plant IDs:")
                    dataController.getPlants().forEach { plant in
                        print("- \(plant.plantName): \(plant.plantID)")
                    }
                    return nil
                }
            }
            
            // Calculate user stats with actual count
            let totalPlants = plants.count
            print("\nProcessed plants count: \(totalPlants)")
            
            // Count plants by category
            var categoryCount: [Category: Int] = [:]
            plants.forEach { plant in
                categoryCount[plant.plant.category, default: 0] += 1
                print("Added \(plant.plant.plantName) to category \(plant.plant.category)")
            }
            
            userStats = [
                "Total Plants": totalPlants,
                "Ornamental": categoryCount[.Ornamental] ?? 0,
                "Flowering": categoryCount[.Flowering] ?? 0,
                "Medicinal": categoryCount[.medicinal] ?? 0
            ]
            
            // Group plants by name with debug info
            let groupedPlants = Dictionary(grouping: plants) { tuple in
                tuple.plant.plantName
            }
            
            print("\nGrouped plants by name:")
            groupedPlants.forEach { (name, plants) in
                print("- \(name): \(plants.count) plant(s)")
            }
            
            // Create categories and categorized plants
            plantCategories = groupedPlants.keys.sorted()
            categorizedPlants = plantCategories.map { plantName in
                groupedPlants[plantName]?.map { $0.userPlant } ?? []
            }
            
            print("\nFinal organization:")
            print("Categories (\(plantCategories.count)): \(plantCategories)")
            for (index, category) in plantCategories.enumerated() {
                print("- \(category): \(categorizedPlants[index].count) plant(s)")
            }
            
            // Update UI on main thread
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.mySpaceCollectionView.reloadData()
                print("\nCollection view updated with:")
                print("- Number of sections: \(self.numberOfSections(in: self.mySpaceCollectionView))")
                for section in 0..<self.numberOfSections(in: self.mySpaceCollectionView) {
                    let items = self.collectionView(self.mySpaceCollectionView, numberOfItemsInSection: section)
                    print("- Section \(section): \(items) items")
                }
            }
        } else {
            print("ERROR: No users found in DataController")
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
                // Get the plant details
                guard let plant = dataController.getPlant(by: userPlant.userplantID) else { return false }
                
                // Check if either nickname or plant name contains the search text
                return userPlant.userPlantNickName.lowercased().contains(searchText) ||
                       plant.plantName.lowercased().contains(searchText)
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
        
        // Get plant data either from newly added plant or from data controller
        let plant: Plant
        if let newPlant = newlyAddedPlant, newPlant.userPlant.userPlantRelationID == userPlant.userPlantRelationID {
            plant = newPlant.plant
        } else {
            guard let existingPlant = dataController.getPlant(by: userPlant.userplantID) else {
                fatalError("Plant not found")
            }
            plant = existingPlant
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! MySpaceCollectionViewSection1Cell
        cell.configure(with: userPlant, plant: plant)
        
        cell.optionsHandler = { [weak self] in
            self?.showOptions(for: userPlant, at: indexPath)
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
                
                header.headerLabel.text = plantName
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                header.headerLabel.textColor = UIColor(hex: "284329")
                header.totalPlantLabel.text = "Total Plants: \(plantsInSection.count)"
                header.totalPlantLabel.textColor = UIColor(hex: "284329")
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
        section.interGroupSpacing = 15
        section.orthogonalScrollingBehavior = .groupPaging
        
        // Add header
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
    
    @IBOutlet weak var mySpaceCollectionView: UICollectionView!
    
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
        
        // Register cells - Use nib for MySpaceCollectionViewSection1Cell
        mySpaceCollectionView.register(MySpaceStatsCell.self, forCellWithReuseIdentifier: "StatsCell")
        mySpaceCollectionView.register(
            UINib(nibName: "MySpaceCollectionViewSection1Cell", bundle: nil),
            forCellWithReuseIdentifier: "first"
        )
        
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
    
    private func showDeleteConfirmation(for userPlant: UserPlant, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Plant",
            message: "Are you sure you want to delete \(userPlant.userPlantNickName)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePlant(userPlant, at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func deletePlant(_ userPlant: UserPlant, at indexPath: IndexPath) {
        // Delete from data controller
        dataController.deleteUserPlant(userPlant)
        
        // First update the data model
        if isSearching {
            // Update filtered arrays
            filteredCategorizedPlants[indexPath.section - 1].remove(at: indexPath.item)
            if filteredCategorizedPlants[indexPath.section - 1].isEmpty {
                filteredCategorizedPlants.remove(at: indexPath.section - 1)
                filteredPlantCategories.remove(at: indexPath.section - 1)
            }
            
            // Update original arrays
            if let originalPlantIndex = categorizedPlants.firstIndex(where: { plants in
                plants.contains { $0.userPlantRelationID == userPlant.userPlantRelationID }
            }) {
                if let plantIndex = categorizedPlants[originalPlantIndex].firstIndex(where: { $0.userPlantRelationID == userPlant.userPlantRelationID }) {
                    categorizedPlants[originalPlantIndex].remove(at: plantIndex)
                    if categorizedPlants[originalPlantIndex].isEmpty {
                        categorizedPlants.remove(at: originalPlantIndex)
                        plantCategories.remove(at: originalPlantIndex)
                    }
                }
            }
            
            // When searching, always use reloadData
            mySpaceCollectionView.reloadData()
        } else {
            // When not searching, we can use batch updates
            mySpaceCollectionView.performBatchUpdates {
                categorizedPlants[indexPath.section - 1].remove(at: indexPath.item)
                
                if categorizedPlants[indexPath.section - 1].isEmpty {
                    categorizedPlants.remove(at: indexPath.section - 1)
                    plantCategories.remove(at: indexPath.section - 1)
                    mySpaceCollectionView.deleteSections(IndexSet(integer: indexPath.section))
                } else {
                    mySpaceCollectionView.deleteItems(at: [indexPath])
                }
            } completion: { [weak self] _ in
                // Force a complete reload of data
                self?.loadData()
                self?.mySpaceCollectionView.reloadData()
                
                // Print debug info
                print("After deletion:")
                print("User plants count: \(self?.dataController.getUserPlants(for: self?.dataController.getUsers().first?.userId ?? UUID()).count ?? 0)")
                print("Care reminders count: \(self?.dataController.getCareReminders(for: self?.dataController.getUsers().first?.userId ?? UUID()).count ?? 0)")
            }
        }
        
        // Post notification that a plant was deleted
        NotificationCenter.default.post(name: NSNotification.Name("PlantDeleted"), object: nil)
    }
    
    private func showOptions(for userPlant: UserPlant, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Add delete action
        let deleteAction = UIAlertAction(title: "Delete Plant", style: .destructive) { [weak self] _ in
            self?.showDeleteConfirmation(for: userPlant, at: indexPath)
        }
        alertController.addAction(deleteAction)
        
        // Add cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        // Present the action sheet
        present(alertController, animated: true)
    }
    
    @objc private func handleNewPlantAdded(_ notification: Notification) {
        guard let userPlant = notification.userInfo?["userPlant"] as? UserPlant,
              let plant = notification.userInfo?["plant"] as? Plant else {
            return
        }
        
        // Add to newlyAddedPlants if not already there
        if !MySpaceViewController.newlyAddedPlants.contains(where: { $0.userplantID == userPlant.userplantID }) {
            MySpaceViewController.newlyAddedPlants.append(userPlant)
        }
        
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
