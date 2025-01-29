//
//  SplashViewController.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 20/01/25.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
            super.viewDidLoad()
            // Perform setup or animations here
        perform(#selector(transitionToMainScreen), with: nil, afterDelay: 0.9) // Adjust delay time as needed
        }
        
        @objc func transitionToMainScreen() {
            let mainStoryboard = UIStoryboard(name: "exploreTab", bundle: nil)
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "ExploreViewController")
            mainVC.modalTransitionStyle = .partialCurl// Optional transition animation
            mainVC.modalPresentationStyle = .custom
            present(mainVC, animated: true)
        }

}
