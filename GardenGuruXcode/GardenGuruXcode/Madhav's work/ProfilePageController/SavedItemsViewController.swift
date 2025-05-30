import UIKit

enum SavedItemType: String {
    case plant
    case disease
}

class SavedItemsViewController: UITableViewController {

    // Stores list of saved items for the user
    var savedItems: [(itemType: String, item: Any)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Items"
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(SavedItemCell.self, forCellReuseIdentifier: "SavedItemCell")
        loadSavedItems()
    }

    /// Fetch saved plants/diseases for current user
    private func loadSavedItems() {
        guard let userId = DataControllerGG.shared.getCurrentUserIdSync() else { return }

        Task {
            do {
                let result = try await DataControllerGG.shared.getSavedItems(for: userId)
                DispatchQueue.main.async {
                    self.savedItems = result
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Failed to load saved items: \(error)")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedItemCell", for: indexPath) as! SavedItemCell
        let (itemType, item) = savedItems[indexPath.row]

        switch SavedItemType(rawValue: itemType) {
        case .plant:
            if let plant = item as? Plant {
                cell.configure(
                    title: plant.plantName,
                    subtitle: "Plant",
                    imageURL: plant.plantImage,
                    placeholder: UIImage(named: "plantPlaceholder")
                )
            }
        case .disease:
            if let disease = item as? Diseases {
                cell.configure(
                    title: disease.diseaseName,
                    subtitle: "Disease",
                    imageURL: disease.diseaseImage,
                    placeholder: UIImage(named: "diseasePlaceholder")
                )
            }
        default:
            cell.configure(title: "Unknown", subtitle: "", image: nil)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (itemType, item) = savedItems[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "exploreTab", bundle: nil)

        switch SavedItemType(rawValue: itemType) {
        case .plant:
            if let plant = item as? Plant,
               let detailVC = storyboard.instantiateViewController(withIdentifier: "CardsDetailViewController") as? CardsDetailViewController {
                detailVC.selectedCardData = plant
                navigationController?.pushViewController(detailVC, animated: true)
            }
        case .disease:
            if let disease = item as? Diseases {
                let detailVC = storyboard.instantiateViewController(withIdentifier: "DiseaseDetailViewController") as? DiseaseDetailViewController;()
                detailVC!.disease = disease
                navigationController?.pushViewController(detailVC!, animated: true)
            }
        default:
            break
        }
    }
}
