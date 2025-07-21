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
    var currentWeather: WeatherService.WeatherResponse?
    
    private var plants: [Plant] = []
    private var diseases: [Diseases] = []
    private var preventionTips: [PreventionTip] = []
    private var fertilizers: [Fertilizer] = []
    private var isShowingPlants = true
    private var dataType: DataType = .plants
    
    private enum DataType {
        case plants
        case diseases
        case preventionTips
        case fertilizers
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

        // Use filteredItems if available for Discover segment as well
        if let section = sectionNumber,
           let segmentIndex = selectedSegmentIndex,
           let headerData = headerData,
           section < headerData.count,
           let receivedFilteredItems = filteredItems {
            
            let sectionTitle = headerData[section]
            print("🔍 SectionWiseDetailViewController - Checking filteredItems for section title: \(sectionTitle)")
            print("🔍 SectionWiseDetailViewController - receivedFilteredItems count: \(receivedFilteredItems.count)")
            print("🔍 SectionWiseDetailViewController - receivedFilteredItems type: \(type(of: receivedFilteredItems))")

            // Use filteredItems for all relevant sections in Discover segment
            if segmentIndex == 0 {
                if sectionTitle == "Current Season Plants",
                   let filteredPlants = receivedFilteredItems as? [Plant] {
                    self.plants = filteredPlants
                    self.dataType = .plants
                    didSetFiltered = true
                    print("🔍 SectionWiseDetailViewController - Set filtered plants for Current Season from viewDidLoad: \(filteredPlants.count) items")
                } else if sectionTitle == "Common Issues",
                   let filteredDiseases = receivedFilteredItems as? [Diseases] {
                    self.diseases = filteredDiseases
                    self.dataType = .diseases
                    didSetFiltered = true
                    print("🔍 SectionWiseDetailViewController - Set filtered diseases from viewDidLoad: \(filteredDiseases.count) items")
                } else if sectionTitle == "Pest & Disease Prevention",
                          let filteredPreventionTips = receivedFilteredItems as? [PreventionTip] {
                    self.preventionTips = filteredPreventionTips
                    self.dataType = .preventionTips
                    didSetFiltered = true
                    print("🔍 SectionWiseDetailViewController - Set filtered prevention tips from viewDidLoad: \(filteredPreventionTips.count) items")
                }
            } else if segmentIndex == 1 { // For My Plants segment
                if sectionTitle == "Common Issues in your Plant",
                          let filteredDiseases = receivedFilteredItems as? [Diseases] {
                    self.diseases = filteredDiseases
                    self.dataType = .diseases
                    self.plants = []
                    didSetFiltered = true
                    print("🔍 SectionWiseDetailViewController - Set filtered diseases for My Plants from viewDidLoad: \(filteredDiseases.count) items")
                } else if sectionTitle == "Common Fertilizers",
                          let filteredFertilizers = receivedFilteredItems as? [Fertilizer] {
                    self.fertilizers = filteredFertilizers
                    self.dataType = .fertilizers
                    self.diseases = []
                    self.plants = []
                    didSetFiltered = true
                    print("🔍 SectionWiseDetailViewController - Set filtered fertilizers for My Plants from viewDidLoad: \(filteredFertilizers.count) items")
                } else if sectionTitle == "Common Fertilizers" {
                    self.diseases = []
                    self.plants = []
                    self.dataType = .none
                    didSetFiltered = true
                    print("🔍 SectionWiseDetailViewController - Set empty state for Common Fertilizers from viewDidLoad")
                }
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
        guard let section = sectionNumber, let segmentIndex = selectedSegmentIndex, let headerData = headerData else {
            print("❌ SectionWiseDetailViewController - Section or segment index is nil")
            return
        }
        print("🔍 SectionWiseDetailViewController - loadData")
        print("🔍 SectionWiseDetailViewController - Loading data for segment: \(segmentIndex), section: \(section)")
        Task {
            do {
                switch segmentIndex {
                case 0: // Discover
                    let sectionTitle = headerData[section]
                    print("🔍 SectionWiseDetailViewController - Discover section title: \(sectionTitle)")
                    switch sectionTitle {
                    case "Current Season Plants":
                        dataType = .plants
                        // Use the passed filtered plants if available
                        if let filteredPlants = filteredItems as? [Plant] {
                            self.plants = filteredPlants
                            print("🔍 SectionWiseDetailViewController - Using passed filtered plants: \(self.plants.count)")
                            print("🔍 SectionWiseDetailViewController - Plant names: \(self.plants.map { $0.plantName })")
                        } else {
                            // Fallback to fetching all plants if no filtered plants were passed
                            let allPlants = try await dataController.getPlants()
                            
                            // Use passed weather data if available
                            if let weather = currentWeather {
                                let temp = weather.main.temp
                                let mappedSeason = seasonForTemperature(temp)
                                self.plants = allPlants.filter { $0.favourableSeason?.rawValue.lowercased() == mappedSeason }
                                print("🔍 SectionWiseDetailViewController - Loaded plants for current season based on passed weather: \(self.plants.count)")
                            } else {
                                // Fallback to location-based weather
                                let weatherService = WeatherService()
                                let latitude = UserDefaults.standard.double(forKey: "userLatitude")
                                let longitude = UserDefaults.standard.double(forKey: "userLongitude")
                                
                                if latitude != 0 && longitude != 0 {
                                    if let weather = try? await weatherService.fetchWeather(latitude: latitude, longitude: longitude) {
                                        let temp = weather.main.temp
                                        let mappedSeason = seasonForTemperature(temp)
                                        self.plants = allPlants.filter { $0.favourableSeason?.rawValue.lowercased() == mappedSeason }
                                        print("🔍 SectionWiseDetailViewController - Loaded plants for current season based on location weather: \(self.plants.count)")
                                    } else {
                                        let currentSeason = dataController.getCurrentSeason()
                                        self.plants = allPlants.filter { $0.favourableSeason == currentSeason }
                                        print("🔍 SectionWiseDetailViewController - Fallback: Loaded plants for current season: \(self.plants.count)")
                                    }
                                } else {
                                    let currentSeason = dataController.getCurrentSeason()
                                    self.plants = allPlants.filter { $0.favourableSeason == currentSeason }
                                    print("🔍 SectionWiseDetailViewController - No location data, using current season: \(self.plants.count)")
                                }
                            }
                        }
                    
                    case "Common Issues":
                        dataType = .diseases
                        diseases = try await dataController.getCommonIssues()
                        print("🔍 SectionWiseDetailViewController - Loaded common issues: \(diseases.count)")
                    default:
                        dataType = .none
                        print("🔍 SectionWiseDetailViewController - No data for this section title")
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
                    case 1: // Common Fertilizers
                        print("🔍 SectionWiseDetailViewController - Setting up fertilizers for user plants")
                        dataType = .fertilizers
                        if let filteredFertilizers = filteredItems as? [Fertilizer] {
                            fertilizers = filteredFertilizers
                            print("🔍 SectionWiseDetailViewController - Using filtered fertilizers: \(fertilizers.count)")
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

    // Helper function to map temperature to season (same as in ExploreViewController)
    private func seasonForTemperature(_ temp: Double) -> String {
        switch temp {
        case ..<15:
            return "winter"
        case 15..<25:
            return "spring"
        case 25..<50:
            return "summer"
        default:
            return "extreme summer"
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
        case .none:
            return 0
        case .preventionTips:
            return preventionTips.count
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
            cell.configure(with: plant)
        case .diseases:
            guard indexPath.item < diseases.count else {
                print("Disease index out of bounds")
                return cell
            }
            let disease = diseases[indexPath.item]
            cell.configureForDisease(with: disease)
        case .none:
            // Return a blank cell (will never be called since numberOfItemsInSection returns 0)
            return cell
        case .preventionTips:
            guard indexPath.item < preventionTips.count else {
                print("Prevention Tip index out of bounds")
                return cell
            }
            let preventionTip = preventionTips[indexPath.item]
            cell.configureForPreventionTip(with: preventionTip)
        case .fertilizers:
            print("[DEBUG] cellForItemAt called for fertilizer at index \(indexPath.item)")
            guard indexPath.item < fertilizers.count else {
                print("Fertilizer index out of bounds")
                return cell
            }
            let fertilizer = fertilizers[indexPath.item]
            print("[DEBUG] cellForItemAt: Configuring fertilizer cell for: \(fertilizer.fertilizerName)")
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
        case .none:
            print("Helllllo")
        case .preventionTips:
            if let detailVC = PreventionTipDetailViewController() as? PreventionTipDetailViewController {
                detailVC.preventionTip = preventionTips[indexPath.item]
                let navVC = UINavigationController(rootViewController: detailVC)
                navVC.modalPresentationStyle = .pageSheet // Or .formSheet for iPad compatibility
                if let sheet = navVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 25
                }
                present(navVC, animated: true)
            }
            break
        case .fertilizers:
            let fertilizer = fertilizers[indexPath.item]
            let detailVC = FertilizerDetailViewController()
            detailVC.fertilizer = fertilizer
            detailVC.title = fertilizer.fertilizerName
            let navVC = UINavigationController(rootViewController: detailVC)
            navVC.modalPresentationStyle = .formSheet
            present(navVC, animated: true)
        }
    }
}
