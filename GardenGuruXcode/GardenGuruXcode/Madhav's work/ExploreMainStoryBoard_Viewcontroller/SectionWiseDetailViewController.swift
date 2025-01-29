//
//  SectionWiseDetailViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 16/01/25.
//

import UIKit

class SectionWiseDetailViewController: UIViewController {
    var sectionNumber: Int?
    var selectedSegmentIndex: Int?
    var headerData: [String]?
    @IBOutlet weak var sectionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hey")
        updateSectionLabel()

        // Do any additional setup after loading the view.
    }
    func updateSectionLabel(){
        guard let section = sectionNumber, let headers = headerData, section < headers.count else {
                    sectionLabel.text = "No data available"
                    return
                }
                sectionLabel.text = headers[section] // Set the appropriate header
                print("Selected Segment: \(selectedSegmentIndex ?? -1), Section: \(section), Header: \(headers[section])")
    }

}
