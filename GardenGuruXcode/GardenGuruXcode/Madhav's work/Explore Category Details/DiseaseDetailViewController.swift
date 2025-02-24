//
//  DiseaseDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 23/02/25.
//

import UIKit

class DiseaseDetailViewController: UIViewController {

    var disease: Diseases?
    private var expandedSections: Set<Int> = []
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var diseaseSymptoms: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureHeaderView()
    }
    
    private func setupUI() {
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Remove separators
        tableView.separatorStyle = .none
        
        // Setup Navigation
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureHeaderView() {
        guard let disease = disease else { return }
        
        // Configure image
        if let imageName = disease.diseaseImage.first {
            headerImageView.image = UIImage(named: imageName)
        }
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        
        // Configure disease name label
        diseaseNameLabel.text = disease.diseaseName
        let symptomsText = disease.diseaseSymptoms.joined(separator: ", ")
        diseaseSymptoms.text = "Symptoms: \(symptomsText)"
        diseaseNameLabel.textColor = .white
        diseaseNameLabel.font = .systemFont(ofSize: 32, weight: .bold)
    }
}

extension DiseaseDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections.contains(section) ? 2 : 1 // Show detail row if expanded
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 55 // Header cell height
        } else {
            return UITableView.automaticDimension // Let the content determine the height
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 55 : 100 // Provide estimated heights
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 16 : 8 // Regular spacing between sections
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let cellBackgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        if indexPath.row == 0 {
            // Header cell
            configureHeaderCell(cell, for: indexPath.section, backgroundColor: cellBackgroundColor)
        } else {
            // Detail cell
            configureDetailCell(cell, for: indexPath.section, backgroundColor: cellBackgroundColor)
        }
        
        return cell
    }
    
    private func configureHeaderCell(_ cell: UITableViewCell, for section: Int, backgroundColor: UIColor) {
        // Setup darker gray background view
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        backgroundView.layer.cornerRadius = 8
        cell.backgroundView = backgroundView
        
        // Setup selected background view
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        selectedBackgroundView.layer.cornerRadius = 8
        cell.selectedBackgroundView = selectedBackgroundView
        
        // Configure content
        let options = ["Cure and Treatment", "Preventive Measures", "Symptoms",
                      "Vitamins Required", "Related Images", "Video Solution"]
        cell.textLabel?.text = options[section]
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .black
        
        // Add padding to content
        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cell.contentView.preservesSuperviewLayoutMargins = false
        
        // Configure accessory
        let imageName = expandedSections.contains(section) ? "chevron.down" : "chevron.right"
        let chevronImage = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        let chevronView = UIImageView(image: chevronImage)
        chevronView.tintColor = .gray
        chevronView.contentMode = .scaleAspectFit
        cell.accessoryView = chevronView
        
        cell.selectionStyle = .none
    }
    
    private func configureDetailCell(_ cell: UITableViewCell, for section: Int, backgroundColor: UIColor) {
        // Setup background view with EBF4EB color
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 235/255, green: 244/255, blue: 235/255, alpha: 1.0)
        backgroundView.layer.cornerRadius = 8
        cell.backgroundView = backgroundView
        
        // Add padding
        let padding = UIEdgeInsets(top: 24, left: 20, bottom: 16, right: 20)
        cell.contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: padding.top,
            leading: padding.left,
            bottom: padding.bottom,
            trailing: padding.right
        )
        
        // Configure content based on section
        switch section {
        case 0: // Cure and Treatment
            cell.textLabel?.text = disease?.diseaseCure.joined(separator: "\n")
        case 1: // Preventive Measures
            cell.textLabel?.text = "Preventive measures details..."
        case 2: // Symptoms
            cell.textLabel?.text = disease?.diseaseSymptoms.joined(separator: "\n")
        case 3: // Vitamins Required
            cell.textLabel?.text = "Required vitamins details..."
        case 4: // Related Images
            cell.textLabel?.text = "Related images..."
        case 5: // Video Solution
            cell.textLabel?.text = "Video solution details..."
        default:
            break
        }
        
        // Style the text
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .systemFont(ofSize: 15)
        cell.textLabel?.textColor = .darkGray
        
        // Remove selection style and accessory
        cell.selectionStyle = .none
        cell.accessoryView = nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { // Only toggle for header cells
            let section = indexPath.section
            
            // Animate the chevron rotation
            if let cell = tableView.cellForRow(at: indexPath),
               let chevronView = cell.accessoryView as? UIImageView {
                UIView.animate(withDuration: 0.3) {
                    chevronView.transform = self.expandedSections.contains(section) ?
                        .identity : CGAffineTransform(rotationAngle: .pi/2)
                }
            }
            
            // Toggle section expansion
            if expandedSections.contains(section) {
                expandedSections.remove(section)
            } else {
                expandedSections.insert(section)
            }
            
            // Reload with animation
            UIView.animate(withDuration: 0.3) {
                tableView.performBatchUpdates({
                    tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                })
            }
        }
    }
    
    // Remove the extra spacing from section headers and footers
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 5 ? 20 : 0 // Only bottom padding for last section
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
}
