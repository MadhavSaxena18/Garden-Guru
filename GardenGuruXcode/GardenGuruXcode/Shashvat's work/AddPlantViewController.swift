import UIKit
class AddPlantViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private let dataController = DataControllerGG()
    private var filteredPlants: [Plant] = []
    private var searchResultsTableView: UITableView!
    private var selectedPlant: Plant?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
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
            searchResultsTableView.bottomAnchor.constraint(equalTo: cameraButton.topAnchor, constant: -20)
        ])
    }
    
    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredPlants = []
            searchResultsTableView.isHidden = true
        } else {
            // Get all plants using the proper method
            let allPlants = dataController.getPlants()
            print("Found \(allPlants.count) total plants")
            
            filteredPlants = allPlants.filter {
                $0.plantName.lowercased().contains(searchText.lowercased())
            }
            print("Filtered to \(filteredPlants.count) plants matching '\(searchText)'")
            
            searchResultsTableView.isHidden = filteredPlants.isEmpty
        }
        searchResultsTableView.reloadData()
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
        selectedPlant = filteredPlants[indexPath.row]
        
        guard let plant = selectedPlant else { return }
        print("Selected plant: \(plant.plantName)")
        
        // Show nickname dialog using existing addNickNameViewController
        let nicknameVC = addNickNameViewController()
        nicknameVC.modalPresentationStyle = .overCurrentContext
        nicknameVC.modalTransitionStyle = .crossDissolve
        
        // Add target for the add button
        nicknameVC.addButton.addTarget(self, action: #selector(handleNickname(_:)), for: .touchUpInside)
        
        present(nicknameVC, animated: true)
    }
    
    @objc private func handleNickname(_ sender: UIButton) {
        guard let nicknameVC = presentedViewController as? addNickNameViewController,
              let nickname = nicknameVC.textField.text,
              !nickname.isEmpty,
              let plant = selectedPlant else {
            print("Failed to get nickname or plant")
            return
        }
        
        // Create new UserPlant and add to data controller
        let newUserPlant = UserPlant(
            userId: dataController.getUsers().first!.userId,
            userplantID: plant.plantID,
            userPlantNickName: nickname,
            lastWatered: Date(),
            lastFertilized: Date(),
            lastRepotted: Date(),
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        dataController.addUserPlant(newUserPlant)
        print("Added new user plant with nickname: \(nickname)")
        
        // Dismiss nickname view controller first
        nicknameVC.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // Create and present SetReminderViewController modally
            let setReminderVC = SetReminderViewController()
            setReminderVC.configure(plantName: plant.plantName, nickname: nickname)
            setReminderVC.modalPresentationStyle = .fullScreen
            self.present(setReminderVC, animated: true)
        }
    }
}
