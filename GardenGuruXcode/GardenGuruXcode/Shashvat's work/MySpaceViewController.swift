//
//  MySpaceViewController.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class MySpaceViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout {
    private let dataController = DataControllerGG()
    private var userPlants: [(userPlant: UserPlant, plant: Plant)] = []
    private var plantCategories: [String] = []
    private var categorizedPlants: [[UserPlant]] = []
    private var userStats: [String: Int] = [:]
    private let statsSectionIndex = 0 // Make stats the first section
    
    // Add these properties
    private var filteredPlantCategories: [String] = []
    private var filteredCategorizedPlants: [[UserPlant]] = []
    private var isSearching: Bool = false
    
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
        
        // Load data
        loadData()
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
        print("=== MySpaceViewController loadData started ===")
        
        // Get the first user's plants
        let users = dataController.getUsers()
        print("Found \(users.count) users")
        
        if let firstUser = users.first {
            print("Found user: \(firstUser.userName)")
            
            // Get all user plants and care reminders
            let plantReminders = dataController.getCareReminders(for: firstUser.userId)
            print("Found \(plantReminders.count) plant reminders")
            
            // Map to named tuples
            let plants = plantReminders.map { (userPlant: $0.userPlant, plant: $0.plant) }
            print("Mapped to \(plants.count) plants")
            
            // Calculate user stats
            let totalPlants = plants.count
            print("Total plants: \(totalPlants)")
            
            // Count plants by category
            var categoryCount: [Category: Int] = [:]
            plants.forEach { plant in
                categoryCount[plant.plant.category, default: 0] += 1
            }
            
            userStats = [
                "Total Plants": totalPlants,
                "Ornamental": categoryCount[.Ornamental] ?? 0,
                "Flowering": categoryCount[.Flowering] ?? 0,
                "Medicinal": categoryCount[.medicinal] ?? 0
            ]
            print("User stats: \(userStats)")
            
            // Group plants by name
            let groupedPlants = Dictionary(grouping: plants) { tuple in
                tuple.plant.plantName
            }
            
            // Create categories and categorized plants
            plantCategories = groupedPlants.keys.sorted()
            categorizedPlants = plantCategories.map { plantName in
                groupedPlants[plantName]?.map { $0.userPlant } ?? []
            }
            
            print("Plant categories: \(plantCategories)")
            print("Categorized plants count: \(categorizedPlants.count)")
            
            // Check if we have any data
            if plants.isEmpty {
                print("WARNING: No plants found!")
                // You might want to show a message in the UI here
            }
            
            mySpaceCollectionView.reloadData()
        } else {
            print("ERROR: No users found in DataController")
        }
        
        print("=== MySpaceViewController loadData completed ===")
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
        let sections = (isSearching ? filteredPlantCategories : plantCategories).count + 1
        print("Number of sections: \(sections)")
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == statsSectionIndex {
            print("Stats section: 1 item")
            return 1
        }
        let plants = isSearching ? filteredCategorizedPlants : categorizedPlants
        let count = plants[section - 1].count
        print("Section \(section) has \(count) items")
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
        let plant = dataController.getPlant(by: userPlant.userplantID)!
        
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
        
        // Enable swipe to delete
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            if sectionIndex == self.statsSectionIndex {
                return self.generateStatsLayout()
            }
            
            return self.generateSection1Layout()
        }
        mySpaceCollectionView.collectionViewLayout = layout
        
        // Register cells
        let nib1 = UINib(nibName: "MySpaceCollectionViewSection1Cell", bundle: nil)
        mySpaceCollectionView.register(nib1, forCellWithReuseIdentifier: "first")
        mySpaceCollectionView.register(MySpaceStatsCell.self, forCellWithReuseIdentifier: "StatsCell")
        
        // Register header
        mySpaceCollectionView.register(
            MySpaceHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "MySpaceHeaderCollectionReusableView"
        )
        
        mySpaceCollectionView.dataSource = self
        mySpaceCollectionView.delegate = self
        
        // Ensure the collection view is not hidden
        mySpaceCollectionView.isHidden = false
        
        print("Collection view setup complete")
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
