//
//  ExploreViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 13/01/25.
//

import UIKit
import CoreLocation

// Add this extension at the top of the file, after the imports
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class ExploreViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UISearchResultsUpdating, UICollectionViewDataSourcePrefetching{
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
    private var careTipOfTheDay: CareTip?
    @IBOutlet weak var tableView: UITableView!
    
    // Add a label to show when there are no plants in 'For My Plants'
    private let noPlantsLabel: UILabel = {
        let label = UILabel()
        label.text = "First add your plant to your My Space"
        label.textAlignment = .center
        label.textColor = UIColor(hex: "284329")
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let imageCache = NSCache<NSString, UIImage>()
    
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
        print("\n🌤️ Starting updatePlantsForCurrentWeather...")

        let condition = weather.weather.first?.main.lowercased() ?? "unknown"
        print("🌦️ Current Weather Condition: \(condition)")

        Task {
            do {
                // 🔍 Step 1: Fetch all plants and common issues
                let allPlants = try await dataController.getPlants()
                print("🌿 Total plants fetched from Supabase: \(allPlants.count)")

                let allCommonIssues = try await dataController.getDiseases(for: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
                print("🦠 Total common issues fetched: \(allCommonIssues.count)")

                // 🔍 Step 2: Determine current season
                let currentSeason = DataControllerGG.shared.getCurrentSeason()
                print("🍁 Determined Current Season: \(currentSeason.rawValue)")

                // 🔍 Step 3: Filter plants by season
                var recommendedPlants = allPlants.filter { $0.favourableSeason == currentSeason }
                print("🌱 Plants matching season \(currentSeason.rawValue): \(recommendedPlants.count)")

                // 🔁 Step 4: If raining, boost Spring and Autumn plants
                if condition.contains("rain") {
                    let rainBoosted = allPlants.filter {
                        $0.favourableSeason == .Spring || $0.favourableSeason == .Autumn
                    }
                    print("🌧️ Adding \(rainBoosted.count) Spring/Autumn plants due to rain")
                    recommendedPlants += rainBoosted
                }

                // 🧹 Step 5: Deduplicate and limit
                let uniqueRecommendedPlants = Array(Set(recommendedPlants)).prefix(5)
                print("✅ Unique recommended plants after deduplication: \(uniqueRecommendedPlants.count)")

                // 🖼️ Step 6: Update UI if in Discover segment
                if selectedSegment == 0 {
                    await MainActor.run {
                        self.discoverCategories = [
                            ("Current Season Plants", Array(uniqueRecommendedPlants)),
                            ("Common Issues", allCommonIssues)
                        ]

                        if self.isSearchActive {
                            self.filteredDiscoverCategories = self.discoverCategories
                        }

                        print("🟢 Discover categories updated and reloading collection view.")
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                print("❌ Error updating plants for weather: \(error)")
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
        setupComingSoonLabel()
        
        
        // Request location authorization first
        Task {
            let authStatus = locationManager.getAuthorizationStatus()
            if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
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
        
        Task {
            do {
                self.careTipOfTheDay = try await dataController.getCareTipOfTheDay()
                self.collectionView.reloadData()
            } catch {
                print("❌ Failed to load care tip: \(error)")
            }
        }

        
        // Add prefetching delegate
        collectionView.prefetchDataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("📱 View will appear")
        Task {
            await fetchDataFromSupabase()
            await MainActor.run {
                self.collectionView.reloadData()
                self.updateNoPlantsLabelVisibility()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("📱 View did appear")
        Task {
            // Force a data refresh and UI update
            print("🔄 Forcing data refresh in viewDidAppear")
            await fetchDataFromSupabase()

            await MainActor.run {
                print("🎯 Updating UI in viewDidAppear")

                // ✅ Don't overwrite discoverCategories here
                // Instead, just refresh UI — care tip already included by fetchDataFromSupabase

                if self.isSearchActive {
                    self.filteredDiscoverCategories = self.discoverCategories
                }

                self.collectionView.reloadData()
                self.updateNoPlantsLabelVisibility()

                print("✅ UI update completed in viewDidAppear")
            }
        }
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
        
        let careTipNib = UINib(nibName: "CareTipCollectionViewCell", bundle: nil)
        collectionView.register(careTipNib, forCellWithReuseIdentifier: "CareTipCell")
        
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
        selectedSegment = sender.selectedSegmentIndex
        print("🔄 Segment changed to: \(selectedSegment)")
        updateDataForSelectedSegment()
        
        // Update collection view and label visibility
        if selectedSegment == 1 {
            // For My Plants segment
            let hasContent = !forMyPlantCategories.isEmpty
            print("📊 For My Plants has content: \(hasContent)")
            print("📊 Categories count: \(forMyPlantCategories.count)")
            if let diseases = forMyPlantCategories.first?.items as? [Diseases] {
                print("📊 Diseases count: \(diseases.count)")
            }
            
            noPlantsLabel.isHidden = hasContent
            collectionView.isHidden = !hasContent
        } else {
            // Discover segment
            noPlantsLabel.isHidden = true
            collectionView.isHidden = false
        }
        
        print("🎯 Collection view hidden: \(collectionView.isHidden)")
        print("🎯 No plants label hidden: \(noPlantsLabel.isHidden)")
        
        // Reload collection view data
        collectionView.reloadData()
    }
    
    func fetchDataFromSupabase() async {
        print("\n=== Fetching Data from Supabase ===")
        do {
            // 🌿 Fetch plants
            print("🌿 Fetching plants...")
            let plants = try await dataController.getPlants()
            print("✅ Successfully fetched \(plants.count) plants")
            self.plants = plants

            // 🦠 Fetch common issues
            print("🦠 Fetching common issues...")
            let diseases = try await dataController.getCommonIssues()
            print("✅ Successfully fetched \(diseases.count) diseases")
            self.diseases = diseases

            // 🌼 Fetch care tip of the day
            do {
                self.careTipOfTheDay = try await dataController.getCareTipOfTheDay()
                print("✅ Care Tip: \(self.careTipOfTheDay?.message ?? "None")")
            } catch {
                print("❌ Failed to fetch care tip: \(error)")
            }

            // 🌠 Preload disease images
            Task {
                for disease in diseases {
                    if let imageUrlString = disease.diseaseImage,
                       let imageUrl = URL(string: imageUrlString),
                       imageCache.object(forKey: imageUrlString as NSString) == nil {
                        if let (data, _) = try? await URLSession.shared.data(from: imageUrl),
                           let image = UIImage(data: data) {
                            imageCache.setObject(image, forKey: imageUrlString as NSString)
                            print("✅ Preloaded image for disease: \(disease.diseaseName)")
                        }
                    }
                }
            }

            // 🧠 Update Discover categories
            await MainActor.run {
                print("🔄 Updating Discover segment data")
                var categories: [(title: String, items: [Any])] = []

                if let tip = self.careTipOfTheDay {
                    categories.append(("Care Tip of the Day", [tip]))
                }

                categories.append(("Current Season Plants", self.plants))
                categories.append(("Common Issues", self.diseases))
               // categories.append(("Care Tip of the Day", self.careTipOfTheDay))

                
                self.discoverCategories = categories

                if self.isSearchActive {
                    self.filteredDiscoverCategories = self.discoverCategories
                }

                if self.selectedSegment == 0 {
                    self.collectionView.reloadData()
                }
            }

            // 🔄 FOR MY PLANTS SECTION (unchanged)
            var shouldUpdateForMyPlants = false
            if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
                print("\n=== Checking User Data ===")
                print("🔍 Checking UserTable for email: \(userEmail)")

                if let user = try await dataController.getUser() {
                    print("✅ Found existing user with ID: \(user.id)")

                    print("🔍 Fetching diseases for user's plants...")
                    let userPlantDiseases = try await dataController.getDiseasesForUserPlants(userEmail: userEmail)
                    print("✅ Found \(userPlantDiseases.count) diseases for user's plants")

                    print("🌱 Fetching fertilizers for diseases...")
                    var allFertilizers: [Fertilizer] = []
                    var fertilizerSet = Set<UUID>()

                    for disease in userPlantDiseases {
                        let fertilizers = try await dataController.getFertilizers(for: disease.diseaseID)
                        for fert in fertilizers {
                            if !fertilizerSet.contains(fert.fertilizerId) {
                                allFertilizers.append(fert)
                                fertilizerSet.insert(fert.fertilizerId)
                            }
                        }
                    }

                    print("✅ Found \(allFertilizers.count) unique fertilizers")

                    await MainActor.run {
                        if !userPlantDiseases.isEmpty {
                            var categories: [(title: String, items: [Any])] = [
                                ("Common Issues in your Plant", userPlantDiseases)
                            ]
                            if !allFertilizers.isEmpty {
                                categories.append(("Common Fertilizers", allFertilizers))
                            }
                            self.forMyPlantCategories = categories
                        } else {
                            self.forMyPlantCategories = []
                        }

                        if self.isSearchActive {
                            self.filteredForMyPlantCategories = self.forMyPlantCategories
                        }
                        shouldUpdateForMyPlants = true
                    }
                } else {
                    print("❌ No user found")
                    await MainActor.run {
                        self.forMyPlantCategories = []
                        shouldUpdateForMyPlants = true
                    }
                }
            } else {
                print("❌ No user email found in UserDefaults")
                await MainActor.run {
                    self.forMyPlantCategories = []
                    shouldUpdateForMyPlants = true
                }
            }

            // 🔄 Refresh UI if needed
            if shouldUpdateForMyPlants {
                await MainActor.run {
                    if self.selectedSegment == 1 {
                        self.updateNoPlantsLabelVisibility()
                        self.collectionView.reloadData()
                    }
                }
            }
        } catch {
            print("❌ Error fetching data: \(error)")
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
                    case   "Common Issues in your Plant":
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
        print("📱 Getting number of sections")
        print("📱 Current segment: \(selectedSegment)")
        
        if selectedSegment == 1 {
            let count = forMyPlantCategories.count
            print("📱 For My Plants sections count: \(count)")
            return count
        }
        
        let count = isSearchActive ? filteredDiscoverCategories.count : discoverCategories.count
        print("📱 Discover sections count: \(count)")
        return count
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
        print("📱 Getting number of items for section \(section)")
        print("📱 Current segment: \(selectedSegment)")
        
        if selectedSegment == 1 {
            let count = forMyPlantCategories[safe: section]?.items.count ?? 0
            print("📱 For My Plants items count: \(count)")
            return count
        }
        
        let categories = isSearchActive ? filteredDiscoverCategories : discoverCategories
        guard section < categories.count else { return 0 }
        let count = (categories[section].items as? [Any])?.count ?? 0
        print("📱 Discover items count: \(count)")
        return count
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

        // ✅ STEP 1: CARE TIP SECTION
        if category.title == "Care Tip of the Day",
           let tip = item as? CareTip {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareTipCell", for: indexPath) as! CareTipCollectionViewCell
            cell.configure(with: tip.message)
            return cell
        }

        // ✅ STEP 2: SEASONAL PLANTS
        if category.title == "Current Season Plants" {
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
        }

        // ✅ STEP 3: COMMON ISSUES
        else if category.title == "Common Issues" || category.title == "Common Issues in your Plant" {
            if selectedSegment == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "second", for: indexPath) as! Section2CollectionViewCell
                if let disease = item as? Diseases {
                    if let imageUrlString = disease.diseaseImage,
                       let cachedImage = imageCache.object(forKey: imageUrlString as NSString) {
                        print("📸 Using cached image for disease: \(disease.diseaseName)")
                        cell.disease = DataOfSection2InDiscoverSegment(from: disease)
                        cell.imageViewLabel.image = cachedImage
                    } else {
                        cell.disease = DataOfSection2InDiscoverSegment(from: disease)
                    }
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
            }
        }

        // ✅ STEP 4: COMMON FERTILIZERS
        else if category.title == "Common Fertilizers" {
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

        return UICollectionViewCell()
    }

    
    func generateLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [self]
            (sectionIndex, environment) -> NSCollectionLayoutSection? in

            print("🎨 Generating layout for section \(sectionIndex)")
            print("🎨 Current segment: \(selectedSegment)")

            // Get the current categories based on segment and search state
            let categories = selectedSegment == 0 ?
                (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
                (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)

            print("🎨 Categories count: \(categories.count)")
            guard sectionIndex < categories.count else {
                print("❌ Section index out of bounds")
                return nil
            }

            // Get the category title for this section
            let categoryTitle = categories[sectionIndex].title
            print("🎨 Category title: \(categoryTitle)")

            let section: NSCollectionLayoutSection

            if selectedSegment == 1 {
                // For My Plants segment - use a consistent layout for diseases/fertilizers
                section = generateSection1LayoutInForMyPlants()
                print("🎨 Using For My Plants layout")
            } else {
                // Discover segment - choose layout based on category title
                switch categoryTitle {
                case "Care Tip of the Day":
                    // ✅ Layout for Care Tip of the Day (one full-width cell)
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(100)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(100)
                    )
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                    section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                    section.interGroupSpacing = 12
                    print("🎨 Using layout for Care Tip of the Day")

                case "Current Season Plants":
                    section = generateSection1Layout()

                case "Common Issues":
                    section = generateSection2Layout()

                default:
                    print("❌ Invalid category title: \(categoryTitle)")
                    return nil
                }

                print("🎨 Using Discover layout for \(categoryTitle)")
            }

            // Add header for all sections
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
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderSectionCollectionReusableView",
                for: indexPath
            ) as! HeaderSectionCollectionReusableView
            
            let categories = selectedSegment == 0 ?
                (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
                (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)
            
            let sectionTitle = categories[indexPath.section].title
            
            headerView.headerTitle.text = sectionTitle
            headerView.headerTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            headerView.headerTitle.textColor = UIColor(hex: "284329")
            
            if sectionTitle == "Care Tip of the Day" {
                headerView.button.isHidden = true
                
            } else {
                headerView.button.isHidden = false
                headerView.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
                headerView.button.tintColor = UIColor(hex: "284329")
                headerView.button.tag = indexPath.section
                headerView.button.imageEdgeInsets = UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 0)
                headerView.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
            }

            headerView.isHidden = false
            
            return headerView
        }
        return UICollectionReusableView()
    }

    
    
    @objc func sectionButtonTapped(_ sender: UIButton) {
        // Full list and currently visible list
        let fullCategories = selectedSegment == 0 ? discoverCategories : forMyPlantCategories
        let activeCategories = selectedSegment == 0 ?
            (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
            (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)

        guard sender.tag < activeCategories.count else {
            print("❌ Invalid section index tapped")
            return
        }

        let selectedCategory = activeCategories[sender.tag]

        // Skip Care Tip section
        if selectedCategory.title == "Care Tip of the Day" {
            print("⛔️ Skipping navigation for Care Tip section")
            return
        }

        // Instantiate view controller
        let storyBoard = UIStoryboard(name: "exploreTab", bundle: nil)
        guard let VC = storyBoard.instantiateViewController(withIdentifier: "SectionWiseDetailViewController") as? SectionWiseDetailViewController else {
            print("❌ Could not instantiate SectionWiseDetailViewController")
            return
        }

        // ✅ Get index from full (unfiltered) categories
        VC.sectionNumber = fullCategories.firstIndex(where: { $0.title == selectedCategory.title }) ?? sender.tag
        print("📌 Passing sectionNumber: \(VC.sectionNumber) for category: \(selectedCategory.title)")

        // Pass filtered items
        VC.filteredItems = selectedCategory.items
        VC.selectedSegmentIndex = selectedSegment

        if selectedSegment == 0 {
            VC.headerData = ExploreScreen.headerData
        } else {
            VC.headerData = ExploreScreen.headerForInMyPlantSegment

            if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
                Task {
                    do {
                        let userPlantDiseases = try await dataController.getDiseasesForUserPlants(userEmail: userEmail)
                        await MainActor.run {
                            VC.setDiseases(userPlantDiseases)
                        }
                    } catch {
                        print("❌ Error fetching user plant diseases: \(error)")
                    }
                }
            }
        }

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
        // Show message for 'For My Plants' segment only when there are no diseases
        if selectedSegment == 1 {
            let hasContent = !forMyPlantCategories.isEmpty
            print("📊 Updating visibility - Has content: \(hasContent)")
            print("📊 Categories: \(forMyPlantCategories)")
            
            noPlantsLabel.isHidden = hasContent
            collectionView.isHidden = !hasContent
            
            print("🎯 After update - Collection view hidden: \(collectionView.isHidden)")
            print("🎯 After update - No plants label hidden: \(noPlantsLabel.isHidden)")
        } else {
            noPlantsLabel.isHidden = true
            collectionView.isHidden = false
        }
    }

    private func setupComingSoonLabel() {
        // Remove any existing constraints
        noPlantsLabel.removeFromSuperview()
        
        // Add the label to the view
        view.addSubview(noPlantsLabel)
        noPlantsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Center the label vertically between segmentControl and bottom of screen
        NSLayoutConstraint.activate([
            noPlantsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPlantsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50), // Adjust position slightly up
            noPlantsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            noPlantsLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
        
        // Hide collection view when showing Coming Soon
        collectionView.isHidden = selectedSegment == 1
    }
    
    // Add prefetching methods
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let categories = selectedSegment == 0 ?
                (isSearchActive ? filteredDiscoverCategories : discoverCategories) :
                (isSearchActive ? filteredForMyPlantCategories : forMyPlantCategories)
            
            guard indexPath.section < categories.count else { continue }
            
            let category = categories[indexPath.section]
            guard indexPath.row < category.items.count else { continue }
            
            let item = category.items[indexPath.row]
            
            // Prefetch disease images
            if let disease = item as? Diseases {
                guard let imageUrlString = disease.diseaseImage,
                      let imageUrl = URL(string: imageUrlString) else { continue }
                
                // Check if image is already cached
                if imageCache.object(forKey: imageUrlString as NSString) == nil {
                    print("🔄 Prefetching image for disease: \(disease.diseaseName)")
                    URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            self?.imageCache.setObject(image, forKey: imageUrlString as NSString)
                            print("✅ Cached image for disease: \(disease.diseaseName)")
                        }
                    }.resume()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // Optional: Implement if you need to cancel prefetching
    }
  }
    

