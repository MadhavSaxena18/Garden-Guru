//
//  CardsDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 18/01/25.
//

import UIKit

class CardsDetailViewController: UIViewController, UICollectionViewDelegate ,UICollectionViewDataSource{
    //static var detailData: CardDetailsSection1?
    @IBOutlet weak var cardDetailCollectionView: UICollectionView!
    var selectedCardData: Any?
    var isModallyPresented: Bool = false
    private var isSaved = false
    private var heartButton: UIBarButtonItem!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Register cells - first cell is now programmatic
            cardDetailCollectionView.register(CardDataSection1.self, forCellWithReuseIdentifier: "first")
            cardDetailCollectionView.register(CardsDetailSection2CollectionViewCell.self, forCellWithReuseIdentifier: "second")
            cardDetailCollectionView.register(CardDetailsSection3CollectionViewCell.self, forCellWithReuseIdentifier: "third")
            
            // Set the layout
            cardDetailCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
            
            cardDetailCollectionView.dataSource = self
            cardDetailCollectionView.delegate = self
            cardDetailCollectionView.backgroundColor = UIColor(hex: "#F5F5F0")
            
            setupNavigationBar()
            checkIfAlreadySaved()
        }
        
        private func setupNavigationBar() {
            // Configure navigation bar appearance
            navigationController?.navigationBar.prefersLargeTitles = false
            
            // Only show Done button if modally presented
            if isModallyPresented {
                let doneButton = UIBarButtonItem(
                    title: "Done",
                    style: .done,
                    target: self,
                    action: #selector(dismissVC)
                )
                navigationItem.leftBarButtonItem = doneButton
            }
            
            let heartImage = UIImage(systemName: isSaved ? "heart.fill" : "heart")
            heartButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(toggleHeartTapped))
            navigationItem.rightBarButtonItem = heartButton
        }
        
    @objc private func toggleHeartTapped() {
        guard let userId = DataControllerGG.shared.getCurrentUserIdSync() else {
            print("❌ User ID not found")
            showAlert(title: "Error", message: "Please log in to save items")
            return
        }

        var itemId: UUID?
        var itemType: String?

        if let plant = selectedCardData as? Plant {
            itemId = plant.plantID
            itemType = "plant"
        } else if let disease = selectedCardData as? Diseases {
            itemId = disease.diseaseID
            itemType = "disease"
        }

        guard let id = itemId, let type = itemType else {
            showAlert(title: "Error", message: "Unable to identify item")
            return
        }

        // Optimistic UI update
        isSaved.toggle()
        updateHeartButton()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        Task {
            do {
                if isSaved {
                    try await DataControllerGG.shared.saveUserItem(userId: userId, itemId: id, itemType: type)
                    print("✅ Item saved successfully")
                    
                    // Success feedback
                    DispatchQueue.main.async {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                } else {
                    try await DataControllerGG.shared.unsaveUserItem(userId: userId, itemId: id, itemType: type)
                    print("✅ Item unsaved successfully")
                }

                DispatchQueue.main.async {
                    self.updateHeartButton()
                }
            } catch {
                print("❌ Error saving/unsaving item: \(error)")
                
                // Revert optimistic update on error
                DispatchQueue.main.async {
                    self.isSaved.toggle()
                    self.updateHeartButton()
                    self.showAlert(title: "Error", message: "Failed to save item. Please try again.")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    private func checkIfAlreadySaved() {
        guard let userId = DataControllerGG.shared.getCurrentUserIdSync() else { return }

        var itemId: UUID?
        var itemType: String?

        if let plant = selectedCardData as? Plant {
            itemId = plant.plantID
            itemType = "plant"
        } else if let disease = selectedCardData as? Diseases {
            itemId = disease.diseaseID
            itemType = "disease"
        }

        guard let id = itemId, let type = itemType else { return }

        Task {
            do {
                let saved = try await DataControllerGG.shared.isItemSaved(userId: userId, itemId: id, itemType: type)
                self.isSaved = saved
                DispatchQueue.main.async {
                    self.updateHeartButton()
                }
            } catch {
                print("❌ Failed to check if item is saved: \(error)")
            }
        }
    }

    private func updateHeartButton() {
        let heartImage = UIImage(systemName: isSaved ? "heart.fill" : "heart")
        heartButton.image = heartImage
    }
        @objc private func dismissVC() {
            dismiss(animated: true)
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 3
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let item = selectedCardData else {
                print("Error: selectedCardData is nil")
                return UICollectionViewCell()
            }

            switch indexPath.section {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! CardDataSection1
                cell.update(with: item)
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2)
                cell.layer.shadowRadius = 4
                cell.layer.shadowOpacity = 0.2
                cell.layer.masksToBounds = false
                return cell
                
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "second", for: indexPath) as! CardsDetailSection2CollectionViewCell
                if let plant = item as? Plant {
                    cell.updateCardSection2(with: plant)
                } else if let disease = item as? Diseases {
                    cell.updateCardSection2WithDisease(with: disease)
                }
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2)
                cell.layer.shadowRadius = 4
                cell.layer.shadowOpacity = 0.2
                cell.layer.masksToBounds = false
                return cell
                
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "third", for: indexPath) as! CardDetailsSection3CollectionViewCell
                if let plant = item as? Plant {
                    cell.updateWithPlantInfo(plant)
                } else if let disease = item as? Diseases {
                    cell.updateWithDiseaseInfo(disease)
                }
                cell.delegate = self // Set the delegate
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2)
                cell.layer.shadowRadius = 4
                cell.layer.shadowOpacity = 0.2
                cell.layer.masksToBounds = false
                return cell
                
            default:
                print("Error: Unexpected section")
                return UICollectionViewCell()
            }
        }
        
        func generateLayout() -> UICollectionViewCompositionalLayout {
            return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
                guard let self = self else { return nil }
                
                switch sectionIndex {
                case 0:
                    return self.generateMainImageSection()
                case 1:
                    return self.generateDescriptionSection()
                case 2:
                    return self.generateGallerySection()
                default:
                    return nil
                }
            }
        }
        
        func generateMainImageSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .absolute(400))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0,
                                                           bottom: 0, trailing: 0)
            return section
        }
        
        func generateDescriptionSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(300))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .estimated(300))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20,
                                                           bottom: 20, trailing: 20)
            return section
        }
        
        func generateGallerySection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .absolute(250)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 20,
                bottom: 20,
                trailing: 20
            )
            return section
        }
    }

    // MARK: - CardDetailsSection3CollectionViewCellDelegate
extension CardsDetailViewController: CardDetailsSection3CollectionViewCellDelegate {
    func didTapImage(at index: Int, images: [UIImage]) {
            let fullScreenVC = FullScreenImageViewController()
            fullScreenVC.images = images
            fullScreenVC.currentIndex = index
            fullScreenVC.modalPresentationStyle = .fullScreen
            present(fullScreenVC, animated: true)
        }
    }
