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
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Register nibs
            cardDetailCollectionView.register(UINib(nibName: "CardsDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "first")
            cardDetailCollectionView.register(UINib(nibName: "CardsDetailSection2CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "second")
            cardDetailCollectionView.register(CardDetailsSection3CollectionViewCell.self, forCellWithReuseIdentifier: "third")
            
            // Set the layout
            cardDetailCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
            
            cardDetailCollectionView.dataSource = self
            cardDetailCollectionView.delegate = self
            setupNavigationBar()
        }
        
        private func setupNavigationBar() {
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
                                                 heightDimension: .absolute(220))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16,
                                                           bottom: 0, trailing: 16)
            return section
        }
        
        func generateDescriptionSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(250))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .estimated(250))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16,
                                                           bottom: 16, trailing: 16)
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
                leading: 16,
                bottom: 16,
                trailing: 16
            )
            return section
        }
    }

    // MARK: - CardDetailsSection3CollectionViewCellDelegate
    extension CardsDetailViewController: CardDetailsSection3CollectionViewCellDelegate {
        func didTapImage(at index: Int) {
            guard let selectedData = selectedCardData else { return }
            
            let fullScreenVC = FullScreenImageViewController()
            var images: [UIImage] = []
            
            // Get images based on the data type
            if let plant = selectedData as? Plant {
                images = plant.plantImage.compactMap { UIImage(named: $0) }
            } else if let disease = selectedData as? Diseases {
                images = disease.diseaseImage.compactMap { UIImage(named: $0) }
            }
            
            // Configure and present the full-screen viewer
            fullScreenVC.images = images
            fullScreenVC.currentIndex = index
            fullScreenVC.modalPresentationStyle = .fullScreen
            present(fullScreenVC, animated: true)
        }
    }
