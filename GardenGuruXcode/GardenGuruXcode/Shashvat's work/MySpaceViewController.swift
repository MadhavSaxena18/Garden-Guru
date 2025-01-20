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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        MySpaceScreen.sectionHeaderNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       switch section{
       case 0:
           MySpaceScreen.mySpaceSection1Data.count
       case 1:
           MySpaceScreen.mySpaceSection2Data.count
       case 2:
           MySpaceScreen.mySpaceSection3Data.count
       default:
           0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            print("Section 1")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! MySpaceCollectionViewSection1Cell
            cell.updatesection1Data(with: indexPath)
            cell.layer.cornerRadius = 25
            return cell
        case 1:
            print("section2")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "second", for: indexPath) as! MySpaceSection2CollectionViewCell
            cell.updatesection2Data(with: indexPath)
            cell.layer.cornerRadius = 25
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "third", for: indexPath) as! MySpaceSection3CollectionViewCell
            cell.updatesection3Data(with: indexPath)
            cell.layer.cornerRadius = 25
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! MySpaceCollectionViewSection1Cell
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
                section = self.generateSection2Layout()
            case 2:
                section = self.generateSection3Layout()
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
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(290))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
       
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        group.interItemSpacing = .fixed(15)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
       
    }
    
    func generateSection2Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(290))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
       
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        group.interItemSpacing = .fixed(15)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
       
    }
    
    func generateSection3Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(290))
        
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
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MySpaceHeaderCollectionReusableView", for: indexPath) as! MySpaceHeaderCollectionReusableView
            header.headerLabel.text = MySpaceScreen.sectionHeaderNames[indexPath.section]
            header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            header.headerLabel.textColor = UIColor(hex: "284329")
            header.totalPlantLabel.text = "Total Plant: 50"
            header.totalPlantLabel.textColor = UIColor(hex: "284329")
        

            return header
        }
        
       print("Supplementary item is not a error")
        return UICollectionReusableView()
    }
    
    
    
  


    @IBOutlet weak var mySpaceCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
       
        
        let nib1 = UINib(nibName: "MySpaceCollectionViewSection1Cell", bundle: nil)
        let nib2 = UINib(nibName: "MySpaceSection2CollectionViewCell", bundle: nil)
        let nib3 = UINib(nibName: "MySpaceSection3CollectionViewCell", bundle: nil)
        
        mySpaceCollectionView.register(nib1, forCellWithReuseIdentifier: "first")
        mySpaceCollectionView.register(nib2, forCellWithReuseIdentifier: "second")
        mySpaceCollectionView.register(nib3, forCellWithReuseIdentifier: "third")
        mySpaceCollectionView.register(MySpaceHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MySpaceHeaderCollectionReusableView")
        
        mySpaceCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        mySpaceCollectionView.dataSource = self
        mySpaceCollectionView.delegate = self
    }
   
   
}
