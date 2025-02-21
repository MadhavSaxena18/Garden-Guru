//
//  SectionWiseDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 16/01/25.
//

import UIKit

class SectionWiseDetailViewController: UIViewController {
    var sectionNumber: Int?
    var selectedSegmentIndex: Int?
    var headerData: [String]?
    
    private var plants: [Plant] = []
    private var diseases: [Diseases] = []
    private var isShowingPlants = true // To track what type of data we're showing
    
    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Dependencies
    private let dataController = DataControllerGG()  // Changed to initialize without shared
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure section label
//        sectionLabel.font = .systemFont(ofSize: 24, weight: .bold)
//        sectionLabel.textColor = .label
//        sectionLabel.textAlignment = .left
        
        setupCollectionView()
        loadData()
    }
    
    // MARK: - Private Methods
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cell
        let nib = UINib(nibName: "AllDataCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PlantCell")
        
        // Setup compositional layout
        collectionView.collectionViewLayout = createCompositionalLayout()
        //collectionView.backgroundColor = .systemBackground
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(600)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 0,
            bottom: 16,
            trailing: 0
        )
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    private func loadData() {
        guard let section = sectionNumber else { return }
        
        // Determine what data to load based on section
        switch section {
        case 0: // Top Winter Plants
            isShowingPlants = true
            plants = dataController.getTopWinterPlants()
        case 1: // Common Issues
            isShowingPlants = false
            diseases = dataController.getCommonIssues()
        case 2: // Common Issues for Rose
            isShowingPlants = false
            diseases = dataController.getCommonIssuesForRose()
        default:
            break
        }
        
        collectionView.reloadData()
    }
    
    
}

// MARK: - UICollectionView DataSource & Delegate
extension SectionWiseDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isShowingPlants ? plants.count : diseases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCell", for: indexPath) as? AllDataCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if isShowingPlants {
            let plant = plants[indexPath.item]
            cell.configure(with: plant)
        } else {
            let disease = diseases[indexPath.item]
            cell.configureForDisease(with: disease)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the storyboard that contains CardsDetailViewController
        if let detailVC = UIStoryboard(name: "exploreTab", bundle: nil)
            .instantiateViewController(withIdentifier: "CardsDetailViewController") as? CardsDetailViewController {
            
            // Pass the selected data based on whether we're showing plants or diseases
            if isShowingPlants {
                let selectedPlant = plants[indexPath.item]
                detailVC.selectedCardData = selectedPlant
            } else {
                let selectedDisease = diseases[indexPath.item]
                detailVC.selectedCardData = selectedDisease
            }
            
            let navVC = UINavigationController(rootViewController: detailVC)
            // Configure modal presentation
            detailVC.modalPresentationStyle = .formSheet // or .pageSheet
            detailVC.modalTransitionStyle = .coverVertical
            
            // Present the view controller
            present(navVC, animated: true)
        }
    }
}
