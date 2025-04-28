import UIKit
class AddPlantViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private let dataController = DataControllerGG.shared
    private var filteredPlants: [Plant] = []
    private var searchResultsTableView: UITableView!
    private var selectedPlant: Plant?
    
    @IBOutlet weak var searchBar: UISearchBar!
  
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupSearchBar()
            setupTableView()
            
            // Set back button color to green
            navigationController?.navigationBar.tintColor = UIColor(hex: "004E05") // Dark green color
        }
        
        private func setupSearchBar() {
            searchBar.delegate = self
            searchBar.placeholder = "Search Plants"
        }
        
        private func setupTableView() {
            searchResultsTableView = UITableView()
            searchResultsTableView.delegate = self
            searchResultsTableView.dataSource = self
            searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlantCell")
            searchResultsTableView.isHidden = true
            searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
            searchResultsTableView.backgroundColor = UIColor(hex: "EBF4EB")
            
            view.addSubview(searchResultsTableView)
            
            NSLayoutConstraint.activate([
                searchResultsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                searchResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
            ])
        }
        
        // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) async {
            if searchText.isEmpty {
                filteredPlants = []
                searchResultsTableView.isHidden = true
            searchResultsTableView.reloadData()
            return
        }
        
        do {
                // Get all plants using the proper method
            let allPlants = try await dataController.getPlants()
                print("Found \(allPlants.count) total plants")
                
                filteredPlants = allPlants.filter {
                    $0.plantName.lowercased().contains(searchText.lowercased())
                }
                print("Filtered to \(filteredPlants.count) plants matching '\(searchText)'")
                
            await MainActor.run {
                searchResultsTableView.isHidden = filteredPlants.isEmpty
                searchResultsTableView.reloadData()
            }
        } catch {
            print("Error fetching plants: \(error)")
            await MainActor.run {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Failed to search plants. Please try again later.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
                // Clear results and hide table view
                filteredPlants = []
                searchResultsTableView.isHidden = true
            searchResultsTableView.reloadData()
            }
        }
        }
        
        // MARK: - Table View Data Source
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredPlants.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath)
            let plant = filteredPlants[indexPath.row]
            cell.textLabel?.text = plant.plantName
            cell.backgroundColor = .white
            return cell
        }
        
        // MARK: - Table View Delegate
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let plant = filteredPlants[indexPath.row]
            print("\n=== Search Flow: Adding Plant ===")
            print("Selected plant: \(plant.plantName)")
            
            let nicknameVC = addNickNameViewController()
            nicknameVC.selectedPlant = plant  // Pass the actual Plant object
            nicknameVC.plantNameForReminder = plant.plantName  // Pass the exact plant name
            
            // Create navigation controller
            let navController = UINavigationController(rootViewController: nicknameVC)
            
            // Present modally
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true)
        }
        
        @IBAction func unwindToAddPlantViewController(segue: UIStoryboardSegue) {
            if let sourceViewController = segue.source as? addPlantCameraViewController {
                // Now we can access stopCameraSession
                sourceViewController.stopCameraSession()
            }
        }
        
        @IBAction func openCamera(_ sender: Any) {
            let storyboard = UIStoryboard(name: "mySpaceTab", bundle: nil)
            if let cameraVC = storyboard.instantiateViewController(withIdentifier: "addPlantCameraViewController") as? addPlantCameraViewController {
                // Create a navigation controller
                let navController = UINavigationController(rootViewController: cameraVC)
                navController.modalPresentationStyle = .fullScreen
                present(navController, animated: true)
            }
        }
    }
