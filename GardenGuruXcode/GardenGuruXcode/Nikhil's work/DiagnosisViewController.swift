//
//  DiagnosisViewController.swift
//  GardenGuruXcode
//
//  Created by Nikhil Gupta on 15/01/25.
//

import UIKit

class DiagnosisViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // UI Elements
    private let plantImageView = UIImageView()
    private let overlayView = UIView()
    private let plantNameLabel = UILabel()
    private let diagnosisLabel = UILabel()
    private let detailsStackView = UIStackView()
    private let tableView = UITableView()
    private let startCaringButton = UIButton()

    // Data
    private let sections = ["Cure and Treatment", "Preventive Measures", "Symptoms", "Vitamins Required", "Related Images", "Video Solution"]
    private var expandedSections: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        // Plant Image
        plantImageView.image = UIImage(named: "parlor_palm") // Replace with your image name
        plantImageView.contentMode = .scaleAspectFill
        plantImageView.clipsToBounds = true
        view.addSubview(plantImageView)

        // Overlay View
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        plantImageView.addSubview(overlayView)

        // Plant Name Label
        plantNameLabel.text = "Parlor Palm"
        plantNameLabel.textColor = .white
        plantNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        overlayView.addSubview(plantNameLabel)

        // Diagnosis Label
        diagnosisLabel.text = "UnderWatered"
        diagnosisLabel.textColor = .white
        diagnosisLabel.font = UIFont.systemFont(ofSize: 16)
        overlayView.addSubview(diagnosisLabel)

        // Details StackView
        detailsStackView.axis = .vertical
        detailsStackView.alignment = .leading
        detailsStackView.spacing = 8
        view.addSubview(detailsStackView)

        let details = [
            "Also Known as: Good Luck Palm, neanthe Bella Palm",
            "Botanical Garden: Chamaedorea",
            "Nick Name: Near Sofa"
        ]
        details.forEach { text in
            let label = UILabel()
            label.text = text
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 0
            detailsStackView.addArrangedSubview(label)
        }

        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.isScrollEnabled = false
        view.addSubview(tableView)

        // Start Caring Button
        startCaringButton.setTitle("Start Caring", for: .normal)
        startCaringButton.setTitleColor(.white, for: .normal)
        startCaringButton.backgroundColor = .systemGreen
        startCaringButton.layer.cornerRadius = 10
        view.addSubview(startCaringButton)
    }

    private func setupConstraints() {
        // Enable Auto Layout
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        plantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        diagnosisLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        startCaringButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Plant Image
            plantImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            plantImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            plantImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            plantImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.33),

            // Overlay
            overlayView.leadingAnchor.constraint(equalTo: plantImageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: plantImageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: plantImageView.bottomAnchor),
            overlayView.heightAnchor.constraint(equalToConstant: 60),

            // Plant Name Label
            plantNameLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            plantNameLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 8),

            // Diagnosis Label
            diagnosisLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            diagnosisLabel.topAnchor.constraint(equalTo: plantNameLabel.bottomAnchor, constant: 4),

            // Details StackView
            detailsStackView.topAnchor.constraint(equalTo: plantImageView.bottomAnchor, constant: 16),
            detailsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // TableView
            tableView.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(sections.count * 50)),

            // Start Caring Button
            startCaringButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            startCaringButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startCaringButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            startCaringButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections.contains(section) ? 1 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(sections[indexPath.section]) Details..."
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerButton = UIButton()
        headerButton.setTitle(sections[section], for: .normal)
        headerButton.setTitleColor(.black, for: .normal)
        headerButton.tag = section
        headerButton.addTarget(self, action: #selector(handleExpandCollapse(_:)), for: .touchUpInside)
        headerButton.contentHorizontalAlignment = .left
        headerButton.backgroundColor = UIColor.systemGray6
        headerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return headerButton
    }

    @objc func handleExpandCollapse(_ sender: UIButton) {
        let section = sender.tag
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}

