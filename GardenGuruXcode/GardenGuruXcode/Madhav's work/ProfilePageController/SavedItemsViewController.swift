import UIKit

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
                print("u274c Failed to load saved items: \(error)")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedItemCell", for: indexPath) as! SavedItemCell
        let (itemType, item) = savedItems[indexPath.row]

        if itemType == "plant", let plant = item as? Plant {
            cell.configure(title: plant.plantName, subtitle: "Plant", image: UIImage(named: "plantPlaceholder"))
        } else if itemType == "disease", let disease = item as? Diseases {
            cell.configure(title: disease.diseaseName, subtitle: "Disease", image: UIImage(named: "diseasePlaceholder"))
        } else {
            cell.configure(title: "Unknown", subtitle: "", image: nil)
        }

        return cell
    }
}

// MARK: - Custom Cell for Saved Items
class SavedItemCell: UITableViewCell {

    private let itemImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let container: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.05
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.clipsToBounds = false

        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(subtitleLabel)

        let hStack = UIStackView(arrangedSubviews: [itemImageView, container])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(hStack)

        NSLayoutConstraint.activate([
            itemImageView.widthAnchor.constraint(equalToConstant: 60),
            itemImageView.heightAnchor.constraint(equalToConstant: 60),

            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subtitle: String, image: UIImage?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        itemImageView.image = image
    }
}
