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
    private var isShowingPlants = true
    private var dataType: DataType = .plants
    
    private enum DataType {
        case plants
        case diseases
        case none // Added for empty state
    }
    // MARK: - Dependencies
    var filteredItems: [Any]?
    // MARK: - Dependencies
    private let dataController = DataControllerGG.shared // Changed to initialize without shared
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        var didSetFiltered = false

        // Debug print for received section and segment
        print("🔍 SectionWiseDetailViewController - viewDidLoad")
        print("🔍 sectionNumber = \(String(describing: sectionNumber))")
        print("🔍 selectedSegmentIndex = \(String(describing: selectedSegmentIndex))")
        print("🔍 headerData = \(String(describing: headerData))")

        // 🌿 Use section title to make behavior flexible
        if let section = sectionNumber,
           let segmentIndex = selectedSegmentIndex,
           segmentIndex == 1,
           let sectionTitle = headerData?[section] {
            
            print("🔍 SectionWiseDetailViewController - Processing For My Plants segment")
            print("🔍 Section title: \(sectionTitle)")

            if sectionTitle == "Common Issues in your Plant",
               let filteredDiseases = filteredItems as? [Diseases] {
                print("🔍 Setting filtered diseases: \(filteredDiseases.count) items")
                self.diseases = filteredDiseases
                self.dataType = .diseases
                self.plants = []
                didSetFiltered = true
            } else if sectionTitle == "Common Fertilizers" {
                print("🔍 Setting empty state for Common Fertilizers")
                self.diseases = []
                self.plants = []
                self.dataType = .none
                didSetFiltered = true
            }
        }

        if !didSetFiltered {
            print("🔍 Loading data through loadData()")
            loadData()
        }

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
            print("❌ SectionWiseDetailViewController - Section or segment index is nil")
            return
        }
        print("🔍 SectionWiseDetailViewController - loadData")
        print("🔍 SectionWiseDetailViewController - Loading data for segment: \(segmentIndex), section: \(section)")
        Task {
            do {
        switch segmentIndex {
        case 0: // Discover
                    print("🔍 SectionWiseDetailViewController - Processing Discover segment")
            switch section {
            case 0: // Top Winter Plants
                        print("🔍 SectionWiseDetailViewController - Loading winter plants")
                dataType = .plants
                        plants = try await dataController.getPlants()
                        print("🔍 SectionWiseDetailViewController - Loaded winter plants: \(plants.count)")
            case 1: // Common Issues
                        print("🔍 SectionWiseDetailViewController - Loading common issues")
                dataType = .diseases
                        diseases = try await dataController.getCommonIssues()
                        print("🔍 SectionWiseDetailViewController - Loaded common issues: \(diseases.count)")
            default:
                        print("❌ SectionWiseDetailViewController - Unknown section in Discover segment")
                break
            }
        case 1: // For My Plants
                    print("🔍 SectionWiseDetailViewController - Processing For My Plants segment")
            switch section {
            case 0: // Common Issues for User Plants
                        print("🔍 SectionWiseDetailViewController - Setting up diseases for user plants")
                dataType = .diseases
                if let filteredDiseases = filteredItems as? [Diseases] {
                    diseases = filteredDiseases
                            print("🔍 SectionWiseDetailViewController - Using filtered diseases: \(diseases.count)")
                }
            default:
                        print("❌ SectionWiseDetailViewController - Unknown section for For My Plants segment")
            }
        default:
                    print("❌ SectionWiseDetailViewController - Unknown segment index")
        }
                print("🔍 SectionWiseDetailViewController - Final data counts - Plants: \(plants.count), Diseases: \(diseases.count)")
                print("🔍 SectionWiseDetailViewController - Current data type: \(dataType)")
                await MainActor.run {
            self.collectionView.reloadData()
                }
            } catch {
                print("Error loading data: \(error)")
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to load data. Please try again later.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    // Add public method to set diseases
    func setDiseases(_ diseases: [Diseases]) {
        self.diseases = diseases
        self.dataType = .diseases
        collectionView?.reloadData()
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
        case .none:
            return 0
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
        case .none:
            // Return a blank cell (will never be called since numberOfItemsInSection returns 0)
                return cell
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
        case .none:
            print("Helllllo")
        }
    }
}
