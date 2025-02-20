//
//  ExploreViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 13/01/25.
//

import UIKit

class ExploreViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UISearchResultsUpdating{
    let PlantCarAI = UIImageView()

    var identifier = 0
    
    @IBOutlet weak var plantCarAI: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    // Segmented control instance
    
    @IBOutlet weak var segmentControlOnExplore: UISegmentedControl!
    private var currentData: [[Any]] = []
    
    var discoverCategories: [(title: String, items: [Any])] = []
    var forMyPlantCategories: [(title: String, items: [Any])] = []
    var selectedSegment = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a UISearchController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search plant, fertilizer..."
        
        // Add the search controller to the navigation item
        navigationItem.searchController = searchController
        
        // Ensure the search bar doesn't persist on navigation
        definesPresentationContext = true
        plantCarAI.isUserInteractionEnabled = true
            
        // Create a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            
        // Add the gesture recognizer to the image view
        plantCarAI.addGestureRecognizer(tapGesture)
        collectionView.backgroundColor = UIColor(named: "#EBF4EB")
        updateSegmentedControlTitles(firstTitle: "Discover", secondTitle: "For My Plants")
        setupSegmentedControl()
        updateDataForSelectedSegment()
        setUpcollectionView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        updateDataForSelectedSegment()
    }


    
    func setUpcollectionView(){
        let firstNib = UINib(nibName: "TopWinterCollectionViewCell", bundle: nil)
        let secondNib = UINib(nibName: "CommonIssueCollectionViewCell", bundle: nil)
        let thirdNib = UINib(nibName: "Section3CollectionViewCell", bundle: nil)
        collectionView.register(firstNib, forCellWithReuseIdentifier: "first")
        collectionView.register(secondNib, forCellWithReuseIdentifier: "second")
        collectionView.register(thirdNib, forCellWithReuseIdentifier: "third")
        
        let fourthNib = UINib(nibName: "Section1InForMyPlantSegmentCollectionViewCell", bundle: nil)
        let fifththNib = UINib(nibName: "Section2InForMyPlantCollectionViewCell", bundle: nil)
        let sixthNib = UINib(nibName: "Section3InForMyPlantCollectionViewCell", bundle: nil)
        collectionView.register(fourthNib, forCellWithReuseIdentifier: "FirstForMyPlant")
        collectionView.register(fifththNib, forCellWithReuseIdentifier: "SecondForMyPlant")
        collectionView.register(sixthNib, forCellWithReuseIdentifier: "ThirdForMyPlant")
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HeaderSectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderSectionCollectionReusableView")
        
    }
    func setupSegmentedControl() {
        // Optionally customize the segmented control
        segmentControlOnExplore.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    func updateSegmentedControlTitles(firstTitle: String, secondTitle: String) {
        segmentControlOnExplore.setTitle(firstTitle, forSegmentAt: 0)
        segmentControlOnExplore.setTitle(secondTitle, forSegmentAt: 1)
    }
    
    
    
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        updateDataForSelectedSegment()
    }
    
    func updateDataForSelectedSegment() {
        selectedSegment = segmentControlOnExplore.selectedSegmentIndex
        switch  segmentControlOnExplore.selectedSegmentIndex {
        case 0: // "Discover"
            print("Hey")
            identifier = 0
            print("Identifer: \(identifier)")
            discoverCategories = [
                   ("Top Summer Plants", DataControllerGG().getTopWinterPlants()),
                   ("Common Issues", DataControllerGG().getCommonIssues())
               ]
        case 1: // "For You"
            identifier = 1
            print("Identifer: \(identifier)")
            print("bbb")
            forMyPlantCategories = [
                        ("Common Issues for Rose Plant", DataControllerGG().getCommonIssuesForRose()),
                        ("Common Fertilizers for Parlor Palm", DataControllerGG().getCommonFertilizersForParlorPalm())
                    ]

        default:
            currentData = []
        }
        collectionView.reloadData()
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
        return selectedSegment == 0 ? discoverCategories.count : forMyPlantCategories.count
    }
    
    /*
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
     }*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let categories = selectedSegment == 0 ? discoverCategories : forMyPlantCategories
                return categories[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch indexPath.section{
//        case 0:
//            if(identifier == 0){
//                print("Section 1 In Discover")
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! Section1CollectionViewCell
//                cell.updateDataOfSection1(with: indexPath)
//                cell.layer.cornerRadius = 11
//                return cell
//            }else{
//                print("Section 1 in For my plants")
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirstForMyPlant", for: indexPath) as! Section1InForMyPlantSegmentCollectionViewCell
//                cell.updateDataOfSection1InForMyPlantSegment(with: indexPath)
//                cell.layer.cornerRadius = 25
//                return cell
//            }
//
//        case 1:
//            if(identifier == 0){
//                print("mm")
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "second", for: indexPath) as! Section2CollectionViewCell
//                cell.updateDataOfSection2(with: indexPath)
//                cell.layer.cornerRadius = 11
//                return cell
//            }else{
//                print("ttttt")
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondForMyPlant", for: indexPath) as! Section2InForMyPlantCollectionViewCell
//                cell.updateDataOfSection2InForMyPlantSegment(with: indexPath)
//                cell.layer.cornerRadius = 25
//                return cell
//            }
//
//
//        case 2:
//            if identifier == 0{
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "third", for: indexPath) as! Section3CollectionViewCell
//                cell.updateDataOfSection3(with: indexPath)
//                cell.layer.cornerRadius = 18
//                return cell
//            }else{
//                print("ababaaaaaaa")
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThirdForMyPlant", for: indexPath) as! Section3InForMyPlantCollectionViewCell
//                cell.updateDataOfSection3InForMyPlantSegment(with: indexPath)
//                cell.layer.cornerRadius = 25
//                return cell
//            }
//
//        default:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as! Section1CollectionViewCell
//            //cell.updateDataOfSection1(with: indexPath)
//            return cell
//        }
             let categories = selectedSegment == 0 ? discoverCategories : forMyPlantCategories
             let category = categories[indexPath.section]
             let item = category.items[indexPath.row]

             if selectedSegment == 0 { // Discover Segment
                 if category.title == "Top Summer Plants" {
                     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first", for: indexPath) as? Section1CollectionViewCell
                     if let plant = item as? Plant {
                         cell?.configure(with: plant)
                     }
                     //cell?.contentView.layer.cornerRadius = 11
                     cell?.contentView.layer.masksToBounds = true
                     
                     cell?.layer.cornerRadius = 11
                     cell?.layer.shadowColor = UIColor.black.cgColor
                     cell?.layer.shadowOffset = CGSize(width: 0, height: 2)
                     cell?.layer.shadowRadius = 4
                     cell?.layer.shadowOpacity = 0.2
                     cell?.layer.masksToBounds = false
                     return cell!
                 } else { // Common Issues
                     print("firsssssssss")
                     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "second", for: indexPath) as! Section2CollectionViewCell
                     if let disease = item as? Diseases {
                         cell.configure(with: disease)
                     }
                     //cell.contentView.layer.cornerRadius = 11
                     cell.contentView.layer.masksToBounds = true
                     
                     cell.layer.cornerRadius = 11
                     cell.layer.shadowColor = UIColor.black.cgColor
                     cell.layer.shadowOffset = CGSize(width: 0, height: 2)
                     cell.layer.shadowRadius = 4
                     cell.layer.shadowOpacity = 0.2
                     cell.layer.masksToBounds = false
                     
                     return cell
                 }
             } else { // For My Plant Segment
                 if category.title == "Common Issues in Rose Plant" {
                     print("chhikloooooo")
                     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirstForMyPlant", for: indexPath) as! Section1InForMyPlantSegmentCollectionViewCell
                     if let disease = item as? Diseases {
                         cell.configure(with: disease)
                     }
                     cell.contentView.layer.cornerRadius = 25
                     cell.contentView.layer.masksToBounds = true
                     
                     cell.layer.shadowColor = UIColor.black.cgColor
                     cell.layer.shadowOffset = CGSize(width: 0, height: 2)
                     cell.layer.shadowRadius = 4
                     cell.layer.shadowOpacity = 0.2
                     cell.layer.masksToBounds = false
                     return cell
                 } else { // Common Fertile for Parlour Palm
                     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondForMyPlant", for: indexPath) as!Section2InForMyPlantCollectionViewCell
                     if let fertilizer = item as? String {
                         cell.configure(with: fertilizer)
                     }
                     cell.contentView.layer.cornerRadius = 25
                     cell.contentView.layer.masksToBounds = true
                    
                     cell.layer.shadowColor = UIColor.black.cgColor
                     cell.layer.shadowOffset = CGSize(width: 0, height: 2)
                     cell.layer.shadowRadius = 4
                     cell.layer.shadowOpacity = 0.2
                     cell.layer.masksToBounds = false
                     return cell
                 }
        }
        
    }
    
    
    func generateLayout()-> UICollectionViewCompositionalLayout{
        let layout = UICollectionViewCompositionalLayout
        { [self]
            (sectionIndex, environment) -> NSCollectionLayoutSection? in let section: NSCollectionLayoutSection
            switch sectionIndex{
            case 0:
                if identifier == 0{
                    section = self.generateSection1Layout()
                }else{
                    section = self.generateSection1LayoutInForMyPlants()
                }
                
                
            case 1:
                if identifier == 0 {
                    section = self.generateSection2Layout()
                }
                else{
                    section = self.generateSection1LayoutInForMyPlants()
                }
                
            case 2:
                if identifier == 0{
                    section = self.generateSection3Layout()
                }else{
                    section = self.generateSection1LayoutInForMyPlants()
                }
                
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
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 20, bottom: 10, trailing: 0)
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
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 20, bottom: 10, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    func generateSection3Layout()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .absolute(340), heightDimension: .absolute(260))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize, subitems: [item])
        
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 20, bottom: 10, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    
    
    func generateSection1LayoutInForMyPlants()-> NSCollectionLayoutSection{
        let spacing: CGFloat = 5
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .absolute(320), heightDimension: .absolute(225))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize, subitems: [item])
        
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 20, bottom: 10, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPaging
        return section
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderSectionCollectionReusableView", for: indexPath) as! HeaderSectionCollectionReusableView
            if segmentControlOnExplore.selectedSegmentIndex == 0{
                header.headerLabel.text = ExploreScreen.headerData[indexPath.section]
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                header.headerLabel.textColor = UIColor(hex: "284329")
                header.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
                header.button.tintColor = UIColor(hex: "284329")
                header.button.tag = indexPath.section
                header.button.imageEdgeInsets = UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 0) // Adjust spacing between text and image
                header.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
                header.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
                return header
                
            }else{
                header.headerLabel.text = ExploreScreen.headerForInMyPlantSegment[indexPath.section]
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                header.headerLabel.textColor = UIColor(hex: "284329")
                header.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
                header.button.tintColor = UIColor(hex: "284329")
                header.button.tag = indexPath.section
                header.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
                header.button.imageEdgeInsets = UIEdgeInsets(top:9, left: 0, bottom: 0, right: 0) // Adjust spacing between text and image
                
                //header.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
                return header
                
            }
        }
        
        print("Supplementary item is not a error")
        return UICollectionReusableView()
    }
    
    
    @objc func sectionButtonTapped(_ sender: UIButton){
        let storyBoard = UIStoryboard(name: "exploreTab", bundle: nil)
        let VC = storyBoard.instantiateViewController(withIdentifier: "SectionWiseDetailViewController") as! SectionWiseDetailViewController
        
        VC.sectionNumber = sender.tag // Pass the section number
        VC.selectedSegmentIndex = segmentControlOnExplore.selectedSegmentIndex // Pass the selected segment index (if needed)
        
        if segmentControlOnExplore.selectedSegmentIndex == 0 {
            VC.headerData = ExploreScreen.headerData
            } else {
                VC.headerData = ExploreScreen.headerForInMyPlantSegment
            }
        navigationController?.pushViewController(VC, animated: true)
        
    }
    
    
    
    

    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//            let sectionData = currentData[indexPath.section]
//            let item = sectionData[indexPath.row]
        let categories = selectedSegment == 0 ? discoverCategories : forMyPlantCategories
            let selectedCategory = categories[indexPath.section]
            let selectedItem = selectedCategory.items[indexPath.row]  // Get the clicked item

            let storyboard = UIStoryboard(name: "exploreTab", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "CardsDetailViewController") as? CardsDetailViewController {
                detailVC.selectedCardData = selectedItem // Pass the selected `Plant` or `Diseases`
                
                // Set modal presentation style
//                detailVC.modalPresentationStyle = .fullScreen
//                detailVC.modalTransitionStyle = .coverVertical
                detailVC.navigationItem.title = "hello"
                present(detailVC, animated: true, completion: nil) // Present modally
                //navigationController?.pushViewController(detailVC, animated: true)
                
                detailVC.navigationItem.title = "hello"
                //navigationItem.title = "hello"
            }
    }
    

    
    @objc func imageTapped() {
        // Perform the segue when the image view is tapped
        performSegue(withIdentifier: "plantCarAI", sender: self)
    }
    
  }
    

