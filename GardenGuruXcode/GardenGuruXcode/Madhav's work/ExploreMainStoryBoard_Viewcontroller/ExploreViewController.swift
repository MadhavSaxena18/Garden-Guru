//
//  ExploreViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 13/01/25.
//

import UIKit

class ExploreViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UISearchResultsUpdating{
    
   
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


               // Create a UISearchController
               let searchController = UISearchController(searchResultsController: nil)
               searchController.searchResultsUpdater = self
               searchController.obscuresBackgroundDuringPresentation = false
               searchController.searchBar.placeholder = "Search here..."

               // Add the search controller to the navigation item
               navigationItem.searchController = searchController

               // Ensure the search bar doesn't persist on navigation
               definesPresentationContext = true
        collectionView.backgroundColor = UIColor(named: "#EBF4EB")

               
        
        
        
        //connecting first nib flie i.e topWinterCollectionViewCell to main explore screen
        
        let firstNib = UINib(nibName: "TopWinterCollectionViewCell", bundle: nil)
        let secondNib = UINib(nibName: "CommonIssueCollectionViewCell", bundle: nil)
        let thirdNib = UINib(nibName: "Section3CollectionViewCell", bundle: nil)
        collectionView.register(firstNib, forCellWithReuseIdentifier: "first")
        collectionView.register(secondNib, forCellWithReuseIdentifier: "second")
        collectionView.register(thirdNib, forCellWithReuseIdentifier: "third")
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HeaderSectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderSectionCollectionReusableView")

    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
            guard let searchText = searchController.searchBar.text else { return }
            print("Search text: \(searchText)")
            // Update your search results based on the searchText
        }
    

    
    // making unwind function which returns you back from any page you navigate from this page
    @IBAction func unwindToExploreViewController(segue: UIStoryboardSegue) {
        
    }
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ExploreScreen.headerData.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0:
            ExploreScreen.dataOfSection1.count
        case 1:
            ExploreScreen.dataOfSection2.count
        case 2:
            ExploreScreen.dataOfSection3.count
        default: 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            print("Section 1")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! Section1CollectionViewCell
            cell.updateDataOfSection1(with: indexPath)
            cell.layer.cornerRadius = 11
            return cell
        case 1:
            print("section2")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "second", for: indexPath) as! Section2CollectionViewCell
            cell.updateDataOfSection2(with: indexPath)
            cell.layer.cornerRadius = 11
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "third", for: indexPath) as! Section3CollectionViewCell
            cell.updateDataOfSection3(with: indexPath)
            cell.layer.cornerRadius = 25
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! Section1CollectionViewCell
            //cell.updateDataOfSection1(with: indexPath)
            return cell
        }
    }
    
    
    func generateLayout()-> UICollectionViewCompositionalLayout{
        let layout = UICollectionViewCompositionalLayout
        {
            (sectionIndex, environment) -> NSCollectionLayoutSection? in let section: NSCollectionLayoutSection
            switch sectionIndex{
            case 0:
                section = self.generateSection1Layout()
                
            case 1:
                section = self.generateSection2Layout()
            case 2:
                section = self.generateSection3Layout()
            default :
                print("Invalid Section")
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

    func generateSection2Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(150))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupsize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging

        return section
    }
    func generateSection3Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .absolute(340), heightDimension: .absolute(240))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize, subitems: [item])
        
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0)
        
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
    
    
    
}
