//
//  MySpaceViewController.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class MySpaceViewController:  UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print("Searching for \(text)")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        SectionData.plants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            print("Section 1")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! MySpaceCollectionViewCell
            cell.updatesectionData(with: indexPath)
            cell.layer.cornerRadius = 11
            return cell
        case 1:
            print("section2")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! MySpaceCollectionViewCell
            cell.updatesectionData(with: indexPath)
            cell.layer.cornerRadius = 11
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! MySpaceCollectionViewCell
            cell.updatesectionData(with: indexPath)
            cell.layer.cornerRadius = 25
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! MySpaceCollectionViewCell
            //cell.updateDataOfSection1(with: indexPath)
            return cell
        }
    }
    
    func generateLayout()->UICollectionViewCompositionalLayout{
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in let section: NSCollectionLayoutSection
            switch sectionIndex {
            case 0:
                section = self.generateSection1Layout()
            case 1:
                section = self.generateSection1Layout()
            case 2:
                section = self.generateSection1Layout()
            default:
                print("error")
                return nil
                
            }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(45))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                       
           
            section.boundarySupplementaryItems = [header]
            
            return section
            
        }
        return layout
    }
    
    
    
    func generateSection1Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .absolute(290))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
       
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        group.interItemSpacing = .fixed(15)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
       
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderSectionCollectionReusableView", for: indexPath) as! HeaderSectionCollectionReusableView
            header.headerLabel.text = ExploreScreen.headerData[indexPath.section]
            header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            header.headerLabel.textColor = UIColor(hex: "284329")
            header.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            header.button.tintColor = UIColor(hex: "284329")
            header.button.tag = indexPath.section
            header.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // Adjust spacing between text and image
            
            //header.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
            return header
        }
        
       print("Supplementary item is not a error")
        return UICollectionReusableView()
    }
    
    
    
  
//    var plants: [Plant] = []
//    var reminders: [Reminder] = []

    @IBOutlet weak var mySpaceCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search"   
        
        let nib = UINib(nibName: "MySpaceCollectionViewCell", bundle: nil)
        mySpaceCollectionView.register(nib, forCellWithReuseIdentifier: "first")
        mySpaceCollectionView.register(HeaderSectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MySpaceHeaderSectionReusableView")
        
        mySpaceCollectionView.dataSource = self
        mySpaceCollectionView.delegate = self
    }
   
   
}
