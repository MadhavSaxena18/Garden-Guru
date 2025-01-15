//
//  scanAndDiagnoseViewController.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

//import UIKit
//import VisionKit
//
//class scanAndDiagnoseViewController: UIViewController {
//
//    var scannerAvailable: Bool {
//        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
//    }
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//    
//    @IBAction func scanButtonPressed(_ sender: Any) {
//        guard scannerAvailable == true else {
//            let alert = UIAlertController(title: "Error", message: "Scanner not available", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//            
//            return
//        }
//        let dataScanner = DataScannerViewController(recognizedDataTypes: [.text(), ])
//        
//    }
//    
//    
//
//}




import UIKit
import AVFoundation

class scanAndDiagnoseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
}

