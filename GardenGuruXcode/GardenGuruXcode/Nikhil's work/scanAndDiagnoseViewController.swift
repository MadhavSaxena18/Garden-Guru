

import UIKit
import AVFoundation

class scanAndDiagnoseViewController: UIViewController , AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIView! // Connect your UIView from the storyboard
    // Connect your UILabel
    
    let instruction : [String] = ["1. Snap The whole Plant" , "2. Snap the infected area" , "3. Now take the same with different angle"]
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCapturePhotoOutput!
    @IBOutlet weak var instructionLabel: UILabel!
    
    @IBOutlet weak var snapImage1: UIImageView!
    
    @IBOutlet weak var snapImage2: UIImageView!
    
    @IBOutlet weak var snapImage3: UIImageView!
    
    var counter : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        instructionLabel.text = instruction[0]
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        resetState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    func resetState() {
        counter = 0
        instructionLabel.text = instruction[0]
        snapImage1.image = nil
        snapImage2.image = nil
        snapImage3.image = nil
    }
    
    func setupCamera() {
        // Initialize the capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // Access the device's camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Error: No camera available.")
            return
        }
        
        do {
            // Create input for the camera
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            } else {
                fatalError("Unable to add photo output.")
            }
            
            // Add the preview layer to the cameraView
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = cameraView.bounds
            
            // Insert the preview layer behind all subviews of cameraView
            cameraView.layer.insertSublayer(previewLayer, at: 0)
            
            // Start the camera session
            captureSession.startRunning()
        } catch {
            print("Error setting up the camera: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Adjust the preview layer to match the cameraView's bounds dynamically
        previewLayer?.frame = cameraView.bounds
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        // Capture photo settings
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto // Use auto flash if available
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // Delegate method to handle captured photo
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let photoData = photo.fileDataRepresentation() else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        // Convert photo data to UIImage
        if let capturedImage = UIImage(data: photoData) {
            print("Captured Image: \(capturedImage)")
            // Display the image in the imageView (optional)
            if(counter == 0){
                print("FirstCount :\(counter)")
                snapImage1.image = capturedImage
                instructionLabel.text = instruction[counter+1]
            }
            else if(counter == 1){
                print("2ndCount :\(counter)")
                snapImage2.image = capturedImage
                instructionLabel.text = instruction[counter+1]
            }
            else if(counter == 2){
                print("3rdCount :\(counter)")
                snapImage3.image = capturedImage
                instructionLabel.text = "3 image done"
            }
            
//            else if(counter == 3){
            else{
                print("hello")
                navigateToDiagnosisView()
            }
//            print("Count :\(counter)")
            counter+=1
            
        }
        
    }
    func navigateToDiagnosisView() {
        print("inside the function")
        // Load the storyboard containing the DiagnosisViewController
        let storyboard = UIStoryboard(name: "Diagnosis", bundle: nil)
        print("storyboard")
//
//        // Instantiate the DiagnosisViewController by its Storyboard ID
        guard let diagnosisVC = storyboard.instantiateViewController(withIdentifier: "Diagnosis") as? DiagnosisViewController else {
            print("Error: DiagnosisViewController could not be instantiated.")
            return
        }
       print("Guard condition true")
        
        // Option 1: Push to Navigation Controller

        if let currentNavController = self.navigationController {
            print("Navigation controller embedded")
            currentNavController.pushViewController(diagnosisVC, animated: true)
        
        } else {
            // Option 2: Present Modally
            self.show(diagnosisVC , sender: self)
        }
  }

    
   
    
}
