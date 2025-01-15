

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
                snapImage1.image = capturedImage
                instructionLabel.text = instruction[counter+1]
            }
            else if(counter == 1){
                snapImage2.image = capturedImage
                instructionLabel.text = instruction[counter+1]
            }
            else if(counter >= 2){
                snapImage3.image = capturedImage
                instructionLabel.text = "3 image done"
            }
            
            counter+=1
            
        }
    }
}

