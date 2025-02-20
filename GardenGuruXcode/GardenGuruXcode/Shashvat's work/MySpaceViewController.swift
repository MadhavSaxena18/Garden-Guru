//
//  MySpaceViewController.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class MySpaceViewController:  UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating{
    private let dataController = DataControllerGG()
    private var userPlants: [(userPlant: UserPlant, plant: Plant)] = []
    private var plantCategories: [String] = []
    private var categorizedPlants: [[UserPlant]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        
        // Setup collection view
        setupCollectionView()
        
        // Load data
        loadData()
    }
    
    private func loadData() {
        // Get the first user's plants
        if let firstUser = dataController.getUsers().first {
            // Get all user plants and map to named tuples
            let plants = dataController.getCareReminders(for: firstUser.userId).map { reminder -> (userPlant: UserPlant, plant: Plant) in
                return (userPlant: reminder.userPlant, plant: reminder.plant)
            }
            
            // Group plants by name
            let groupedPlants = Dictionary(grouping: plants) { tuple in
                tuple.plant.plantName
            }
            
            // Create categories and categorized plants
            plantCategories = groupedPlants.keys.sorted()
            categorizedPlants = plantCategories.map { plantName in
                groupedPlants[plantName]?.map { $0.userPlant } ?? []
            }
            
            mySpaceCollectionView.reloadData()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print("Searching for \(text)")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return plantCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorizedPlants[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userPlant = categorizedPlants[indexPath.section][indexPath.item]
        let plant = dataController.getPlant(by: userPlant.userplantID)!
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! MySpaceCollectionViewSection1Cell
        
        // Configure cell
        cell.section1PlantImageView.image = UIImage(named: plant.plantImage[0])
        cell.section1NickNameLabel.text = userPlant.userPlantNickName
        cell.layer.cornerRadius = 25
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "MySpaceHeaderCollectionReusableView",
                for: indexPath
            ) as! MySpaceHeaderCollectionReusableView
            
            let plantName = plantCategories[indexPath.section]
            let plantsInSection = categorizedPlants[indexPath.section]
            
            header.headerLabel.text = plantName
            header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            header.headerLabel.textColor = UIColor(hex: "284329")
            header.totalPlantLabel.text = "Total Plants: \(plantsInSection.count)"
            header.totalPlantLabel.textColor = UIColor(hex: "284329")
            
            return header
        }
        return UICollectionReusableView()
    }
    
    func generateLayout()->UICollectionViewCompositionalLayout{
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in let section: NSCollectionLayoutSection
            switch sectionIndex {
            case 0:
                section = self.generateSection1Layout()
            case 1:
                section = self.generateSection2Layout()
            case 2:
                section = self.generateSection3Layout()
            default:
                print("error")
                return nil
                
            }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(45))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                       
           
            section.boundarySupplementaryItems = [header]
            
            return section
            
        }
        return layout
    }
    
    
    
    func generateSection1Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(290))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
       
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        group.interItemSpacing = .fixed(15)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
       
    }
    
    func generateSection2Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(290))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
       
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        group.interItemSpacing = .fixed(15)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
       
    }
    
    func generateSection3Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(290))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
       
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        group.interItemSpacing = .fixed(15)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
       
    }
    
    @IBOutlet weak var mySpaceCollectionView: UICollectionView!
    
    private func setupCollectionView() {
        let nib1 = UINib(nibName: "MySpaceCollectionViewSection1Cell", bundle: nil)
        let nib2 = UINib(nibName: "MySpaceSection2CollectionViewCell", bundle: nil)
        let nib3 = UINib(nibName: "MySpaceSection3CollectionViewCell", bundle: nil)
        
        mySpaceCollectionView.register(nib1, forCellWithReuseIdentifier: "first")
        mySpaceCollectionView.register(nib2, forCellWithReuseIdentifier: "second")
        mySpaceCollectionView.register(nib3, forCellWithReuseIdentifier: "third")
        mySpaceCollectionView.register(MySpaceHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MySpaceHeaderCollectionReusableView")
        
        mySpaceCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        mySpaceCollectionView.dataSource = self
        mySpaceCollectionView.delegate = self
    }
}
