//
//  CardsDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 18/01/25.
//

import UIKit

class CardsDetailViewController: UIViewController, UICollectionViewDelegate ,UICollectionViewDataSource{

    @IBOutlet weak var cardDetailCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstNib = UINib(nibName: "CardsDetailCollectionViewCell", bundle: nil)
        cardDetailCollectionView.register(firstNib, forCellWithReuseIdentifier: "first")
        
        let secondNib = UINib(nibName: "CardsDetailSection2CollectionViewCell", bundle: nil)
        cardDetailCollectionView.register(secondNib, forCellWithReuseIdentifier: "second")
        cardDetailCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        let thirdNib = UINib(nibName: "CardDetailsSection3CollectionViewCell", bundle: nil)
        cardDetailCollectionView.register(thirdNib, forCellWithReuseIdentifier: "third")
        
        cardDetailCollectionView.dataSource = self
        cardDetailCollectionView.delegate = self
        
    }
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 2
//    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0:
            ExploreScreen.cardDetailSection1.count
        case 1:
            ExploreScreen.cardDetailSection2.count
        case 2:
            ExploreScreen.cardDetailSection3.count
        default:
             0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! CardsDetailCollectionViewCell
            cell.update(with: indexPath)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "second", for: indexPath) as! CardsDetailSection2CollectionViewCell
            cell.updateCardSection2(with: indexPath)
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "third", for: indexPath) as! CardDetailsSection3CollectionViewCell
            cell.updateCardSection3(with: indexPath)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! CardsDetailCollectionViewCell
            cell.update(with: indexPath)
            return cell
        }
        
    }
    
    func generateLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout
        {
            (sectionIndex, environment) -> NSCollectionLayoutSection? in let section: NSCollectionLayoutSection
            switch sectionIndex{
            case 0:
                print("heyoooo")
                section = self.generateSection1Layout()
            case 1:
                print("hello")
                section = self.generateSection2Layout()
            case 2:
                section = self.generateSection3Layout()
            default :
                print("Invalid Section")
                return nil
            }
            
            return section
        }
        return layout

    }
    
    func generateSection1Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(232))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitem: item, count : 1)
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 9, bottom: 9, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
       // section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    func generateSection2Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(300))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitem: item, count : 1)
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 9, bottom: 8, trailing: 9)
        
        let section = NSCollectionLayoutSection(group: group)
       // section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    func generateSection3Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(260))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize, subitems: [item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 9, bottom: 8, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
}
