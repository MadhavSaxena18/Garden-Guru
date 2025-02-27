//
//  addPlantCameraViewController.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 27/02/25.
//

import UIKit
import AVFoundation
import Vision
import CoreML

class addPlantCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
    // MARK: - Properties
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private let dataController = DataControllerGG()
    
    // ML model properties
    private var yoloModel: VNCoreMLModel?
    private var plantIdentifyModel: VNCoreMLModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupMLModels()
        
        // Hide tab bar
        self.tabBarController?.tabBar.isHidden = true
        
        // Setup capture button
        captureButton.layer.cornerRadius = captureButton.bounds.width / 2
        captureButton.backgroundColor = .white
        captureButton.layer.borderWidth = 4
        captureButton.layer.borderColor = UIColor.systemGreen.cgColor
        
        // Add tap gesture to button
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCameraSession()
        // Hide tab bar
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCameraSession()
        // Show tab bar again
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Camera Setup
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            showAlert(message: "Unable to access camera")
            return
        }
        
        captureSession?.addInput(input)
        
        photoOutput = AVCapturePhotoOutput()
        captureSession?.addOutput(photoOutput!)
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = cameraView.bounds
        cameraView.layer.addSublayer(videoPreviewLayer!)
    }
    
    private func setupMLModels() {
        // Load YOLO model
        if let yoloURL = Bundle.main.url(forResource: "YOLOv3TinyFP16", withExtension: "mlmodel") {
            do {
                let config = MLModelConfiguration()
                let model = try MLModel(contentsOf: yoloURL, configuration: config)
                yoloModel = try VNCoreMLModel(for: model)
            } catch {
                print("Error loading YOLO model: \(error)")
            }
        }
        
        // Load Plant Identify model
        if let plantURL = Bundle.main.url(forResource: "PlantIdentify", withExtension: "mlmodel") {
            do {
                let config = MLModelConfiguration()
                let model = try MLModel(contentsOf: plantURL, configuration: config)
                plantIdentifyModel = try VNCoreMLModel(for: model)
            } catch {
                print("Error loading Plant Identify model: \(error)")
            }
        }
    }
    
    private func startCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopCameraSession() {
        captureSession?.stopRunning()
    }
    
    // MARK: - Actions
    @IBAction func captureButtonTapped(_ sender: Any) {
        print("Capture button tapped")
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Photo Capture Delegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            showAlert(message: "Failed to capture image")
            return
        }
        
        // Process image with ML models
        processImage(image)
    }
    
    // MARK: - ML Processing
    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // Create requests for both models
        let yoloRequest = VNCoreMLRequest(model: yoloModel!) { [weak self] request, error in
            self?.handleYOLOResults(request.results as? [VNRecognizedObjectObservation])
        }
        
        let plantRequest = VNCoreMLRequest(model: plantIdentifyModel!) { [weak self] request, error in
            self?.handlePlantResults(request.results as? [VNClassificationObservation])
        }
        
        // Perform requests
        try? requestHandler.perform([yoloRequest, plantRequest])
    }
    
    private func handleYOLOResults(_ results: [VNRecognizedObjectObservation]?) {
        // Handle YOLO detection results
    }
    
    private func handlePlantResults(_ results: [VNClassificationObservation]?) {
        guard let plantResults = results?.prefix(3) else { return } // Get top 3 results
        
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Detected Plants", message: "Please select the correct plant:", preferredStyle: .actionSheet)
            
            // Add an action for each detected plant
            for result in plantResults {
                let plantName = result.identifier
                let confidence = Int(result.confidence * 100)
                
                let action = UIAlertAction(title: "\(plantName) (\(confidence)%)", style: .default) { [weak self] _ in
                    if let plant = self?.getPlantFromIdentification(name: plantName) {
                        self?.showNicknameViewController(for: plant)
                    } else {
                        self?.showAlert(message: "Plant not found in database")
                    }
                }
                alert.addAction(action)
            }
            
            // Add cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self?.present(alert, animated: true)
        }
    }
    
    private func getPlantFromIdentification(name: String) -> Plant? {
        return dataController.getPlants().first { $0.plantName.lowercased() == name.lowercased() }
    }
    
    private func showNicknameViewController(for plant: Plant) {
        // Create and show nickname dialog
        let nicknameVC = addNickNameViewController()
        nicknameVC.modalPresentationStyle = .overCurrentContext
        nicknameVC.modalTransitionStyle = .crossDissolve
        
        // Add target for the add button
        nicknameVC.addButton.addTarget(self, action: #selector(handleNickname(_:)), for: .touchUpInside)
        
        // Store selected plant for later use
        selectedPlant = plant
        
        present(nicknameVC, animated: true)
    }
    
    private var selectedPlant: Plant?
    
    @objc private func handleNickname(_ sender: UIButton) {
        guard let nicknameVC = presentedViewController as? addNickNameViewController,
              let nickname = nicknameVC.textField.text,
              !nickname.isEmpty,
              let plant = selectedPlant else {
            print("Failed to get nickname or plant")
            return
        }
        
        // Create new UserPlant
        let newUserPlant = UserPlant(
            userId: dataController.getUsers().first!.userId,
            userplantID: plant.plantID,
            userPlantNickName: nickname,
            lastWatered: Date(),
            lastFertilized: Date(),
            lastRepotted: Date(),
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        dataController.addUserPlant(newUserPlant)
        print("Added new user plant with nickname: \(nickname)")
        
        // Dismiss nickname view controller
        nicknameVC.dismiss(animated: true) { [weak self] in
            // Show SetReminderViewController
            let setReminderVC = SetReminderViewController()
            setReminderVC.configure(plantName: plant.plantName, nickname: nickname)
            setReminderVC.modalPresentationStyle = .fullScreen
            self?.present(setReminderVC, animated: true)
        }
    }
    
    // MARK: - Helpers
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}



