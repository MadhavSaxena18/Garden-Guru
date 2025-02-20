//
//  CardsDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 18/01/25.
//

import UIKit

class CardsDetailViewController: UIViewController, UICollectionViewDelegate ,UICollectionViewDataSource{
    static var detailData: CardDetailsSection1?
    @IBOutlet weak var cardDetailCollectionView: UICollectionView!
    var selectedCardData: Any? 
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
            case 0: // First NIB (Main card details)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! CardDataSection1
                cell.update(with: item)
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2)
                cell.layer.shadowRadius = 4
                cell.layer.shadowOpacity = 0.2
                cell.layer.masksToBounds = false
                return cell
                
            case 1: // Second NIB (Additional info)
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
                
            case 2: // Third NIB (Fertilizer or extra details)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "third", for: indexPath) as! CardDetailsSection3CollectionViewCell
                if let plant = item as? Plant {
                    cell.updateWithPlantInfo(plant)
                } else if let disease = item as? Diseases {
                    cell.updateWithDiseaseInfo(disease)
                }
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
        // Main image section with plant image
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .absolute(220)) // Increased height for main image
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16,
                                                       bottom: 0, trailing: 16)
        return section
    }
    
    func generateDescriptionSection() -> NSCollectionLayoutSection {
        // Description section with care instructions and plant details
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
        // Gallery section with horizontal scrolling images
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Make the group width smaller to show multiple items
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
