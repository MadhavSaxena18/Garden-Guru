//
//  SectionWiseDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 16/01/25.
//

import UIKit

class SectionWiseDetailViewController: UIViewController {
var sectionNumber = -1
    
    @IBOutlet weak var sectionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hey")
        updateSectionLabel()

        // Do any additional setup after loading the view.
    }
    func updateSectionLabel(){
        sectionLabel.text = ExploreScreen.headerData[sectionNumber]
        print("Hello")
    }

}
