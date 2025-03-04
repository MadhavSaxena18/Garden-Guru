//
//  SectionWiseDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 16/01/25.
//

import UIKit

class SectionWiseDetailViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!
    
    var sectionNumber: Int?
    var selectedSegmentIndex: Int?
    var headerData: [String]?
    
    private var plants: [Plant] = []
    private var diseases: [Diseases] = []
    private var fertilizers: [Fertilizer] = [] // Changed from [String] to [Fertilizer]
    private var isShowingPlants = true
    private var dataType: DataType = .plants
    
    private enum DataType {
        case plants
        case diseases
        case fertilizers
    }
    // MARK: - Dependencies
    var filteredItems: [Any]?
    // MARK: - Dependencies
    private let dataController = DataControllerGG.shared // Changed to initialize without shared
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadData()
        
        // Set the title based on section and segment
        updateTitle()
    }
    
    private func updateTitle() {
        guard let section = sectionNumber, let headerData = headerData else { return }
        if section < headerData.count {
            title = headerData[section]
        }
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
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(400)  // Fixed height for each card
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(400)  // Same fixed height
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        section.interGroupSpacing = 16
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    private func loadData() {
        guard let section = sectionNumber, let segmentIndex = selectedSegmentIndex else {
            print("Section or segment index is nil")
            return
        }
        
        print("Loading data for segment: \(segmentIndex), section: \(section)")
        
        switch segmentIndex {
        case 0: // Discover
            switch section {
            case 0: // Top Winter Plants
                dataType = .plants
                plants = dataController.getTopSeasonPlants()
                print("Loaded winter plants: \(plants.count)")
                
            case 1: // Common Issues
                dataType = .diseases
                diseases = dataController.getCommonIssues()
                print("Loaded common issues: \(diseases.count)")
                
            case 2: // Common Fertilizers
                dataType = .fertilizers
                fertilizers = dataController.getCommonFertilizers() // This now correctly assigns [Fertilizer]
                print("Loaded fertilizers: \(fertilizers.count)")
                
            default:
                break
            }
            
        case 1: // For My Plants
            switch section {
            case 0: // Common Issues for User Plants
                dataType = .diseases
                diseases = dataController.getCommonIssuesForUserPlants()
                print("Loaded user plant diseases: \(diseases.count)")
                print("Disease names: \(diseases.map { $0.diseaseName })")
                
            case 1: // Common Fertilizers
                dataType = .fertilizers
                fertilizers = dataController.getCommonFertilizers()
                print("Loaded fertilizers: \(fertilizers.count)")
                print("Fertilizers: \(fertilizers)")
                
            default:
                print("Unknown section for For My Plants segment")
            }
            
        default:
            print("Unknown segment index")
        }
        
        print("Final data counts - Plants: \(plants.count), Diseases: \(diseases.count), Fertilizers: \(fertilizers.count)")
        print("Current data type: \(dataType)")
        
        // Use filtered items if available, otherwise use regular data
        if let filteredData = filteredItems {
            // Use the filtered data
            // Example: diseases = filteredData as? [Diseases] ?? []
        } else {
            // Use regular data setup
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension SectionWiseDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch dataType {
        case .plants:
            return plants.count
        case .diseases:
            return diseases.count
        case .fertilizers:
            return fertilizers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCell", for: indexPath) as? AllDataCollectionViewCell else {
            print("Failed to dequeue cell")
            return UICollectionViewCell()
        }
        
        print("Configuring cell at index \(indexPath.item) for dataType: \(dataType)")
        
        switch dataType {
        case .plants:
            guard indexPath.item < plants.count else {
                print("Plant index out of bounds")
                return cell
            }
            let plant = plants[indexPath.item]
            print("Configuring cell with plant: \(plant.plantName)")
            cell.configure(with: plant)
            
        case .diseases:
            guard indexPath.item < diseases.count else {
                print("Disease index out of bounds")
                return cell
            }
            let disease = diseases[indexPath.item]
            print("Configuring cell with disease: \(disease.diseaseName)")
            cell.configureForDisease(with: disease)
            
        case .fertilizers:
            guard indexPath.item < fertilizers.count else {
                print("Fertilizer index out of bounds")
                return cell
            }
            let fertilizer = fertilizers[indexPath.item]
            print("Configuring cell with fertilizer: \(fertilizer)")
            cell.configureForFertilizer(with: fertilizer)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch dataType {
        case .diseases:
            if let detailVC = UIStoryboard(name: "exploreTab", bundle: nil)
                .instantiateViewController(withIdentifier: "DiseaseDetailViewController") as? DiseaseDetailViewController {
                detailVC.disease = diseases[indexPath.item]
                detailVC.isModallyPresented = false
                navigationController?.pushViewController(detailVC, animated: true)
            }
            
        case .plants:
            if let detailVC = UIStoryboard(name: "exploreTab", bundle: nil)
                .instantiateViewController(withIdentifier: "CardsDetailViewController") as? CardsDetailViewController {
                detailVC.selectedCardData = plants[indexPath.item]
                navigationController?.pushViewController(detailVC, animated: true)
            }
            
        case .fertilizers:
            let detailVC = FertilizerDetailViewController()
            detailVC.fertilizer = fertilizers[indexPath.item]
            //detailVC.title = fertilizers[indexPath.item].fertilizerName
            detailVC.isPresentedModally = false
            
            // Configure back button to show "Explore"
            let backItem = UIBarButtonItem()
            backItem.title = "Common Fertilizers"
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
