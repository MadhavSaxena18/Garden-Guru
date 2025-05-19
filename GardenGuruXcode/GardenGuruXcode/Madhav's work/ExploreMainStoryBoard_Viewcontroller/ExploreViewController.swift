//
//  ExploreViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 13/01/25.
//

import UIKit
import CoreLocation

class ExploreViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UISearchResultsUpdating{
    private let dataController = DataControllerGG.shared
    let PlantCarAI = UIImageView()
    
    var identifier = 0
    
    @IBOutlet weak var plantCarAI: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    // Segmented control instance
    
    @IBOutlet weak var segmentControlOnExplore: UISegmentedControl!
    private var currentData: [[Any]] = []
    
    
    var discoverCategories: [(title: String, items: [Any])] = []
    var forMyPlantCategories: [(title: String, items: [Any])] = []
    var selectedSegment = 0
    
    // Add these properties
    private var filteredDiscoverCategories: [(title: String, items: [Any])] = []
    private var filteredForMyPlantCategories: [(title: String, items: [Any])] = []
    private var isSearchActive: Bool = false
    
    private let weatherService = WeatherService()
    private let locationManager = LocationManager()
    private var currentWeather: WeatherService.WeatherResponse?
    
    // Add missing properties
    private var plants: [Plant] = []
    private var diseases: [Diseases] = []
    private var fertilizers: [Fertilizer] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    // Add a label to show when there are no plants in 'For My Plants'
    private let noPlantsLabel: UILabel = {
        let label = UILabel()
        label.text = "No plants added yet"
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // Add a function to fetch weather and update plants
    private func fetchWeatherAndUpdatePlants() async {
        print("Starting weather fetch...")
        do {
            let location = try await locationManager.requestLocation()
            print("Got location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            print("Location accuracy: \(location.horizontalAccuracy)m")
            
            let weather = try await weatherService.fetchWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            await MainActor.run {
                print("Got weather for location: \(weather.name ?? "Unknown")")
                print("Temperature: \(weather.main.temp)°C")
                print("Weather condition: \(weather.weather.first?.main ?? "Unknown")")
                self.currentWeather = weather
                self.updatePlantsForCurrentWeather(weather)
            }
        } catch {
            print("Error in fetchWeatherAndUpdatePlants: \(error)")
            await MainActor.run {
                // Handle the error appropriately
                if (error as NSError).domain == "Location Access Denied" {
                    // Show alert to user about location access
                    let alert = UIAlertController(
                        title: "Location Access Required",
                        message: "Please enable location access in Settings to see weather-appropriate plants for your area.",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    })
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    
                    self.present(alert, animated: true)
                } else {
                    // Handle other errors
                    print("Error fetching weather: \(error)")
                }
            }
        }
    }
    
    private func updatePlantsForCurrentWeather(_ weather: WeatherService.WeatherResponse) {
        // Get temperature and weather condition
        let temperature = weather.main.temp
        let condition = weather.weather.first?.main.lowercased() ?? ""
        
        // Start async task to fetch and update plants
        Task {
            do {
                // Fetch plants asynchronously
                let allPlants = try await dataController.getPlants()
                
                // Fetch all diseases using a zero UUID
                let allCommonIssues = try await dataController.getDiseases(for: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
        
        // Filter plants based on weather conditions
        var recommendedPlants: [Plant] = []
        
        // Example logic - customize based on your needs
        if temperature < 10 {
                    recommendedPlants = allPlants.filter { plant in
                        plant.favourableSeason == .Winter
            }
        } else if temperature > 25 {
                    recommendedPlants = allPlants.filter { plant in
                        plant.favourableSeason == .Summer
            }
        }
        
        if condition.contains("rain") {
                    recommendedPlants.append(contentsOf: allPlants.filter { plant in
                        plant.favourableSeason == .Spring || plant.favourableSeason == .Autumn
            })
        }
        
        // Make sure we have some default plants if none match the weather conditions
        if recommendedPlants.isEmpty {
                    recommendedPlants = allPlants
        }
        
        // Take only first 5 plants
        recommendedPlants = Array(recommendedPlants.prefix(5))
        
        // Update discover categories while preserving the structure
        if selectedSegment == 0 { // Only update if we're in the Discover tab
                    await MainActor.run {
            self.discoverCategories = [
                ("Current Season Plants", recommendedPlants),
                            ("Common Issues", allCommonIssues)
            ]
            
            // Update filtered categories if search is active
            if self.isSearchActive {
                self.filteredDiscoverCategories = self.discoverCategories
            }
            
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                print("Error updating plants for weather: \(error)")
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to load plant data. Please try again later.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Initialize categories first
        updateDataForSelectedSegment()
        
        plantCarAI.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        configureSearchController()
        plantCarAI.addGestureRecognizer(tapGesture)
        collectionView.backgroundColor = UIColor(named: "#EBF4EB")
        updateSegmentedControlTitles(firstTitle: "Discover", secondTitle: "For My Plants")
        setupSegmentedControl()
        setUpcollectionView()
        
        // Request location authorization first
        Task {
            let authStatus = locationManager.getAuthorizationStatus() // Use the new public method
            if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
                // Only fetch weather after we have location authorization
            await fetchWeatherAndUpdatePlants()
            } else {
                print("⚠️ Location access not granted. Authorization status: \(authStatus)")
                // Handle the case where location access is not granted
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Location Access Required",
                        message: "Please enable location access in Settings to see weather-appropriate plants for your area.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    })
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(alert, animated: true)
                }
            }
        }
        
        // Add the noPlantsLabel above the collection view
        view.addSubview(noPlantsLabel)
        noPlantsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noPlantsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            noPlantsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            noPlantsLabel.topAnchor.constraint(equalTo: segmentControlOnExplore.bottomAnchor, constant: 24),
            noPlantsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
    override func viewWillAppear(_ animated: Bool) {
        updateDataForSelectedSegment()
    }
    func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }


    
    func setUpcollectionView(){
        let firstNib = UINib(nibName: "TopWinterCollectionViewCell", bundle: nil)
        let secondNib = UINib(nibName: "CommonIssueCollectionViewCell", bundle: nil)
        let thirdNib = UINib(nibName: "Section3CollectionViewCell", bundle: nil)
        collectionView.register(firstNib, forCellWithReuseIdentifier: "first")
        collectionView.register(secondNib, forCellWithReuseIdentifier: "second")
        collectionView.register(thirdNib, forCellWithReuseIdentifier: "third")
        
        let fourthNib = UINib(nibName: "Section1InForMyPlantSegmentCollectionViewCell", bundle: nil)
        let fifththNib = UINib(nibName: "Section2InForMyPlantCollectionViewCell", bundle: nil)
        let sixthNib = UINib(nibName: "Section3InForMyPlantCollectionViewCell", bundle: nil)
        collectionView.register(fourthNib, forCellWithReuseIdentifier: "FirstForMyPlant")
        collectionView.register(fifththNib, forCellWithReuseIdentifier: "SecondForMyPlant")
        collectionView.register(sixthNib, forCellWithReuseIdentifier: "ThirdForMyPlant")
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HeaderSectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderSectionCollectionReusableView")
        
    }
    func setupSegmentedControl() {
        // Optionally customize the segmented control
        segmentControlOnExplore.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    func updateSegmentedControlTitles(firstTitle: String, secondTitle: String) {
        segmentControlOnExplore.setTitle(firstTitle, forSegmentAt: 0)
        segmentControlOnExplore.setTitle(secondTitle, forSegmentAt: 1)
    }
    
    
    
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        updateDataForSelectedSegment()
    }
    
    private func fetchDataFromSupabase() async {
        print("🔄 Starting data fetch from Supabase...")
        do {
            // Fetch plants
            print("🌿 Fetching plants...")
            let plants = try await dataController.getPlants()
            print("✅ Successfully fetched \(plants.count) plants")
            self.plants = plants
            
            // Fetch diseases using getCommonIssues()
            print("🦠 Fetching common issues...")
            let diseases = try await dataController.getCommonIssues()
            print("✅ Successfully fetched \(diseases.count) diseases")
            self.diseases = diseases
            
            // Fetch fertilizers
            print("🌱 Fetching fertilizers...")
            let fertilizers = try await dataController.getCommonFertilizers()
            print("✅ Successfully fetched \(fertilizers.count) fertilizers")
            self.fertilizers = fertilizers

            // Debug: Print user email and user id before fetching UserPlant
            var userPlants: [UserPlant] = []
            if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
                print("[DEBUG] Current user email: \(userEmail)")
                
                // First try to get existing user
                var currentUser: userInfo? = nil
                do {
                    currentUser = try await dataController.getUser()
                    if let user = currentUser {
                        print("✅ Found existing user with ID: \(user.id)")
                        UserDefaults.standard.set(user.id, forKey: "userId")
                    }
                } catch {
                    print("❌ Error fetching user: \(error)")
                }
                
                if currentUser == nil {
                    print("❌ No existing user found. Attempting to create one...")
                    // Try to create new user
                    do {
                        currentUser = try await dataController.createUser(email: userEmail, userName: "Garden Guru User")
                        print("✅ Successfully created new user")
                        // Store the new user ID
                        if let userId = currentUser?.id {
                            UserDefaults.standard.set(userId, forKey: "userId")
                            print("[DEBUG] Stored new user ID: \(userId)")
                        }
                    } catch {
                        print("❌ Failed to create user: \(error)")
                        currentUser = nil
                    }
                }
                
                // Try to fetch user plants if we have a valid user
                if let user = currentUser {
                    print("[DEBUG] Using user with ID: \(user.id)")
                    do {
                        // Use the user ID directly from the current user object
                        userPlants = try await dataController.getUserPlants(for: user.id)
                        print("[DEBUG] Fetched userPlants count: \(userPlants.count)")
                        print("[DEBUG] userPlants: \(userPlants)")
                    } catch {
                        print("❌ Error fetching user plants: \(error)")
                        userPlants = []
                    }
                } else {
                    print("❌ No valid user available to fetch plants")
                }
            } else {
                print("❌ No user email found in UserDefaults")
            }
            
            await MainActor.run {
                print("📊 Updating UI with fetched data:")
                print("   - Plants: \(self.plants.count)")
                print("   - Diseases: \(self.diseases.count)")
                print("   - Fertilizers: \(self.fertilizers.count)")
                
                // Update discover categories
                self.discoverCategories = [
                    ("Current Season Plants", self.plants),
                    ("Common Issues", self.diseases)
                ]
                
                // Only show forMyPlantCategories if user has UserPlant records
                if !userPlants.isEmpty {
                    Task {
                        var userActualPlants: [Plant] = []
                        for userPlant in userPlants {
                            if let plantId = userPlant.userplantID,
                               let plant = try? await self.dataController.getPlant(by: plantId) {
                                userActualPlants.append(plant)
                            }
                        }
                        
                        await MainActor.run {
                            self.forMyPlantCategories = [
                                ("My Plants", userActualPlants),
                                ("Common Issues in your Plant", self.diseases),
                                ("Common Fertilizers", self.fertilizers)
                            ]
                            
                            if self.isSearchActive {
                                self.filteredDiscoverCategories = self.discoverCategories
                                self.filteredForMyPlantCategories = self.forMyPlantCategories
                            }
                            
                            self.collectionView.reloadData()
                            self.updateNoPlantsLabelVisibility()
                            print("✅ UI update complete")
                        }
                    }
                } else {
                    self.forMyPlantCategories = []
                    if self.isSearchActive {
                        self.filteredDiscoverCategories = self.discoverCategories
                        self.filteredForMyPlantCategories = self.forMyPlantCategories
                    }
                    
                    self.collectionView.reloadData()
                    self.updateNoPlantsLabelVisibility()
                    print("✅ UI update complete")
                }
            }
        } catch {
            print("❌ Error fetching data: \(error.localizedDescription)")
            print("Error details: \(error)")
            await MainActor.run {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Could not load data. Please check your internet connection and try again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func updateDataForSelectedSegment() {
        print("🔄 Updating data for segment: \(selectedSegment)")
        selectedSegment = segmentControlOnExplore.selectedSegmentIndex
        
        // Start loading data
        Task {
            print("🚀 Starting async data fetch...")
            await fetchDataFromSupabase()
            self.updateNoPlantsLabelVisibility()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            isSearchActive = false
            updateDataForSelectedSegment()
            collectionView.reloadData()
            return
        }
        
        isSearchActive = true
        
        if selectedSegment == 0 {
            // Keep original category structure but filter items
            filteredDiscoverCategories = discoverCategories.compactMap { category in
                switch category.title {
                    case "Current Season Plants" :
                        let filteredPlants = category.items.filter { item in
                            guard let plant = item as? Plant else { return false }
                            return plant.plantName.lowercased().contains(searchText)
                        }
                        return filteredPlants.isEmpty ? nil : (category.title, filteredPlants)
                        
                    case "Common Issues":
                        let filteredDiseases = category.items.filter { item in
                            guard let disease = item as? Diseases else { return false }
                            return disease.diseaseName.lowercased().contains(searchText)
                        }
                        return filteredDiseases.isEmpty ? nil : (category.title, filteredDiseases)
                        
                    default:
                        return nil
                }
            }
        } else {
            // Similar structure for For My Plants segment
            filteredForMyPlantCategories = forMyPlantCategories.compactMap { category in
                switch category.title {
                    case "Common Issues in your Plant":
                        let filteredDiseases = category.items.filter { item in
                            guard let disease = item as? Diseases else { return false }
                            return disease.diseaseName.lowercased().contains(searchText)
                        }
                        return filteredDiseases.isEmpty ? nil : (category.title, filteredDiseases)
                        
                    case "Common Fertilizers":
                        let filteredFertilizers = category.items.filter { item in
                            guard let fertilizer = item as? Fertilizer else { return false }
                            return fertilizer.fertilizerName.lowercased().contains(searchText)
                        }
                        return filteredFertilizers.isEmpty ? nil : (category.title, filteredFertilizers)
                        
                    default:
                        return nil
                }
            }
        }
        
        collectionView.reloadData()
        updateNoPlantsLabelVisibility()
    }
    
    
    
    // making unwind function which returns you back from any page you navigate from this page
    @IBAction func unwindToExploreViewController(segue: UIStoryboardSegue) {
        
    }
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if selectedSegment == 0 {
            return isSearchActive ? filteredDiscoverCategories.count : discoverCategories.count
        } else {
            return isSearchActive ? filteredForMyPlantCategories.count : forMyPlantCategories.count
        }
    }
    
    /*
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     switch section{
     case 0:
     ExploreScreen.dataOfSection1.count
     case 1:
     ExploreScreen.dataOfSection2.count
     case 2:
     ExploreScreen.dataOfSection3.count
     default: 0
     }
     }*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let categories = selectedSegment == 0 ?
            (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
            (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)
        
        guard section < categories.count else { return 0 }
        return (categories[section].items as? [Any])?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categories = selectedSegment == 0 ?
            (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
            (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)
        
        guard indexPath.section < categories.count else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.section]
        let item = category.items[indexPath.row]

        // First check the category title to determine which cell to use
        if category.title == "Current Season Plants" || category.title == "My Plants" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! Section1CollectionViewCell
            if let plant = item as? Plant {
                cell.plant = DataOfSection1InDicoverSegment(from: plant)
            }
            cell.contentView.layer.masksToBounds = true
            cell.layer.cornerRadius = 11
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 4
            cell.layer.shadowOpacity = 0.2
            cell.layer.masksToBounds = false
            return cell
        } else if category.title == "Common Issues" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "second", for: indexPath) as! Section2CollectionViewCell
            if let disease = item as? Diseases {
                cell.disease = DataOfSection2InDiscoverSegment(from: disease)
            }
            cell.contentView.layer.masksToBounds = true
            cell.layer.cornerRadius = 11
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 4
            cell.layer.shadowOpacity = 0.2
            cell.layer.masksToBounds = false
            return cell
        } else {
            // For My Plant Segment
            if category.title == "Common Issues in your Plant" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirstForMyPlant", for: indexPath) as! Section1InForMyPlantSegmentCollectionViewCell
                if let disease = item as? Diseases {
                    cell.configure(with: disease)
                }
                cell.contentView.layer.cornerRadius = 25
                cell.contentView.layer.masksToBounds = true
                
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2)
                cell.layer.shadowRadius = 4
                cell.layer.shadowOpacity = 0.2
                cell.layer.masksToBounds = false
                return cell
            } else { // Common Fertilizers
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondForMyPlant", for: indexPath) as! Section2InForMyPlantCollectionViewCell
                if let fertilizer = item as? Fertilizer {
                    cell.configure(with: fertilizer)
                }
                cell.contentView.layer.cornerRadius = 25
                cell.contentView.layer.masksToBounds = true
               
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2)
                cell.layer.shadowRadius = 4
                cell.layer.shadowOpacity = 0.2
                cell.layer.masksToBounds = false
                return cell
            }
        }
    }
    
    
    func generateLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [self]
            (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            // Get the current categories based on segment and search state
            let categories = selectedSegment == 0 ?
                (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
                (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)
            
            // Get the category title for this section
            let categoryTitle = categories[sectionIndex].title
            
            let section: NSCollectionLayoutSection
            
            // Choose layout based on category title instead of section index
            switch categoryTitle {
            case "Current Season Plants", "My Plants":
                section = self.generateSection1Layout()
                
            case "Common Issues":
                section = self.generateSection2Layout()
                
            case "Common Issues in your Plant":
                section = self.generateSection1LayoutInForMyPlants()
                
            case "Common Fertilizers":
                section = self.generateSection1LayoutInForMyPlants()
                
            default:
                print("Invalid Section")
                return nil
            }
            
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
        return layout
    }
    
    
    
    func generateSection1Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .absolute(290))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 20, bottom: 10, trailing: 0)
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
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(150))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 20, bottom: 10, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    func generateSection3Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .absolute(340), heightDimension: .absolute(260))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize, subitems: [item])
        
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 20, bottom: 10, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    
    
    func generateSection1LayoutInForMyPlants()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .absolute(320), heightDimension: .absolute(225))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize, subitems: [item])
        
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 20, bottom: 10, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderSectionCollectionReusableView", for: indexPath) as! HeaderSectionCollectionReusableView
            
            let categories = selectedSegment == 0 ?
                (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
                (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)
            
            headerView.headerTitle.text = categories[indexPath.section].title
            
            headerView.headerTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            headerView.headerTitle.textColor = UIColor(hex: "284329")
            headerView.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            headerView.button.tintColor = UIColor(hex: "284329")
            headerView.button.tag = indexPath.section
            headerView.button.imageEdgeInsets = UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 0)
            headerView.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    
    @objc func sectionButtonTapped(_ sender: UIButton) {
        // Use filtered categories when search is active
        let categories = selectedSegment == 0 ?
            (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
            (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)
        
        let selectedCategory = categories[sender.tag]
        
        // For all sections during search and normal state
        let storyBoard = UIStoryboard(name: "exploreTab", bundle: nil)
        let VC = storyBoard.instantiateViewController(withIdentifier: "SectionWiseDetailViewController") as! SectionWiseDetailViewController
        
        // Find the original section number based on category title
        let originalCategories = selectedSegment == 0 ? discoverCategories : forMyPlantCategories
        if let originalSectionIndex = originalCategories.firstIndex(where: { $0.title == selectedCategory.title }) {
            // Pass the original section number
            VC.sectionNumber = originalSectionIndex
        } else {
            VC.sectionNumber = sender.tag
        }
        
        // Pass the filtered data if searching
        if isSearchActive {
            VC.filteredItems = selectedCategory.items
        }
        
        VC.selectedSegmentIndex = segmentControlOnExplore.selectedSegmentIndex
        
        // Pass the correct header data based on segment
        if segmentControlOnExplore.selectedSegmentIndex == 0 {
            VC.headerData = ExploreScreen.headerData
        } else {
            VC.headerData = ExploreScreen.headerForInMyPlantSegment
        }
        
        // Configure back button to show "Explore"
        let backItem = UIBarButtonItem()
        backItem.title = "Explore"
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(VC, animated: true)
    }
    
    
    
    

    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categories = selectedSegment == 0 ?
            (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
            (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)
        
        let selectedCategory = categories[indexPath.section]
        let selectedItem = selectedCategory.items[indexPath.row]

        if let disease = selectedItem as? Diseases,
           (selectedCategory.title == "Common Issues" || selectedCategory.title == "Common Issues in your Plant") {
            if let detailVC = UIStoryboard(name: "exploreTab", bundle: nil)
                .instantiateViewController(withIdentifier: "DiseaseDetailViewController") as? DiseaseDetailViewController {
                detailVC.disease = disease
                detailVC.isModallyPresented = true
                let navVC = UINavigationController(rootViewController: detailVC)
                present(navVC, animated: true)
            }
        } else if let fertilizer = selectedItem as? Fertilizer,
                  selectedCategory.title == "Common Fertilizers" {
            // Handle fertilizer selection
            let detailVC = FertilizerDetailViewController()
            detailVC.fertilizer = fertilizer
            detailVC.title = "Fertilizer Details"
            let navVC = UINavigationController(rootViewController: detailVC)
            navVC.modalPresentationStyle = .formSheet
            present(navVC, animated: true)
        } else {
            // Show regular CardsDetailViewController for other items
            if let detailVC = UIStoryboard(name: "exploreTab", bundle: nil)
                .instantiateViewController(withIdentifier: "CardsDetailViewController") as? CardsDetailViewController {
                detailVC.selectedCardData = selectedItem
                detailVC.isModallyPresented = true // Set to true for modal presentation
                let navVC = UINavigationController(rootViewController: detailVC)
                detailVC.modalPresentationStyle = .formSheet
                present(navVC, animated: true)
            }
        }
    }
    

    
    @objc func imageTapped() {
        let plantCarAIVC = PlantCarAIViewController()
        let navController = UINavigationController(rootViewController: plantCarAIVC)
        navController.modalPresentationStyle = .pageSheet // or .formSheet for iPad compatibility
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()] // This makes it full height but still modal
            sheet.prefersGrabberVisible = true // Shows a grabber at the top
            sheet.preferredCornerRadius = 25 // Rounds the top corners
        }
        
        present(navController, animated: true)
    }
    
    private func updateNoPlantsLabelVisibility() {
        // Only show for 'For My Plants' segment
        if selectedSegment == 1 {
            let categories = isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories
            // If both categories are empty or all items arrays are empty, show the label
            let isEmpty = categories.isEmpty || categories.allSatisfy { ($0.items as? [Any])?.isEmpty ?? true }
            noPlantsLabel.isHidden = !isEmpty
        } else {
            noPlantsLabel.isHidden = true
        }
    }
  }
    

