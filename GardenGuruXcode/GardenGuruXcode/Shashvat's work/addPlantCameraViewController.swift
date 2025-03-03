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
        
        // Setup navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark.square.fill"),
            style: .plain,
            target: self,
            action: #selector(dismissCamera)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        // Check camera permission first
        checkCameraPermission()
        setupMLModels()
        
        // Hide tab bar
        self.tabBarController?.tabBar.isHidden = true
        
        // Remove all button styling code, let storyboard handle it
        // captureButton.layer.cornerRadius = captureButton.bounds.width / 2
        // captureButton.backgroundColor = .white
        // captureButton.layer.borderWidth = 4
        // captureButton.layer.borderColor = UIColor.black.cgColor
        // captureButton.tintColor = .black
        // captureButton.configuration?.background.backgroundColor = .clear
        // captureButton.configuration?.baseForegroundColor = .black
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = cameraView.bounds
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
        
        // Initialize photo output
        photoOutput = AVCapturePhotoOutput()
        
        // Configure capture session
        captureSession?.beginConfiguration()
        
        if captureSession?.canAddInput(input) == true {
            captureSession?.addInput(input)
        }
        
        if let photoOutput = photoOutput, captureSession?.canAddOutput(photoOutput) == true {
            captureSession?.addOutput(photoOutput)
        }
        
        captureSession?.commitConfiguration()
        
        // Setup preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        
        // Update preview layer frame in viewDidLayoutSubviews instead
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.videoPreviewLayer?.frame = self.cameraView.bounds
            self.cameraView.layer.addSublayer(self.videoPreviewLayer!)
        }
    }
    
    private func setupMLModels() {
        // Test YOLO model initialization
        do {
            let _ = try VNCoreMLModel(for: YOLOv3TinyFP16().model)
            yoloModel = try VNCoreMLModel(for: YOLOv3TinyFP16().model)
            print("✅ YOLO model initialized successfully")
        } catch {
            print("❌ YOLO model initialization failed: \(error.localizedDescription)")
            showAlert(message: "Failed to load YOLO model")
            return
        }
        
        // Test Plant Identify model initialization
        do {
            let _ = try VNCoreMLModel(for: PlantIdentify().model)
            plantIdentifyModel = try VNCoreMLModel(for: PlantIdentify().model)
            print("✅ Plant Identify model initialized successfully")
        } catch {
            print("❌ Plant Identify model initialization failed: \(error.localizedDescription)")
            showAlert(message: "Failed to load Plant Identify model")
            return
        }
    }
    
    private func startCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopCameraSession() {
        captureSession?.stopRunning()
    }
    
    // MARK: - Actions
    @IBAction func captureButtonTapped(_ sender: Any) {
        print("Capture button tapped")
        guard let photoOutput = photoOutput else {
            showAlert(message: "Camera not ready")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func dismissCamera() {
        stopCameraSession()
        dismiss(animated: true)
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
        guard let cgImage = image.cgImage else { 
            showAlert(message: "Failed to process image")
            return 
        }
        
        // First run YOLO to detect if there's a plant in the image
        runYOLOModel(image) { [weak self] yoloResult in
            if let result = yoloResult?.lowercased() {
                print("\n--- Processing image with YOLO ---")
                print("YOLO Result: \(result)")
                
                // Check if it's a plant (using same conditions as scanAndDiagnoseViewController)
                if result.contains("pottedplant") || result.contains("vase") || result.contains("no objects detected") {
                    // If YOLO detects a plant or no objects, run plant identification
                    self?.runPlantClassifier(image) { plantResult in
                        if let plantName = plantResult {
                            // Check if it's not a non-plant object
                            if !plantName.lowercased().contains("non plant object") {
                                DispatchQueue.main.async {
                                    self?.handleIdentifiedPlant(plantName)
                                }
                            } else {
                                self?.showAlert(message: "Please capture a plant image to identify")
                            }
                        } else {
                            self?.showAlert(message: "Could not classify plant")
                        }
                    }
                } else {
                    self?.showAlert(message: "Please capture a plant image")
                }
            } else {
                self?.showAlert(message: "Failed to analyze image")
            }
        }
    }
    
    private func runYOLOModel(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let model = yoloModel,
              let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("YOLO error: \(error)")
                completion(nil)
                return
            }
            
            if let results = request.results as? [VNRecognizedObjectObservation],
               let bestResult = results.first,
               let bestLabel = bestResult.labels.first {
                print("YOLO Result: \(bestLabel.identifier)")
                completion(bestLabel.identifier)
            } else {
                print("⚠️ No YOLO result")
                completion("no objects detected")  // Important: Return this instead of nil
            }
        }
        
        request.imageCropAndScaleOption = .scaleFit
        
        do {
            try VNImageRequestHandler(cgImage: cgImage).perform([request])
        } catch {
            print("YOLO request failed: \(error)")
            completion(nil)
        }
    }
    
    private func runPlantClassifier(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let model = plantIdentifyModel,
              let cgImage = image.cgImage else {
            print("❌ Failed to prepare plant classification - model or image is nil")
            completion(nil)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("❌ Plant classification error: \(error)")
                completion(nil)
                return
            }
            
            print("\n--- Plant Classification Results ---")
            if let results = request.results as? [VNClassificationObservation] {
                // Print top 3 results with confidence scores
                for (index, result) in results.prefix(3).enumerated() {
                    let confidence = Int(result.confidence * 100)
                    print("🌿 #\(index + 1): \(result.identifier) (\(confidence)% confidence)")
                }
                
                if let topResult = results.first {
                    print("✅ Selected plant: \(topResult.identifier)")
                    completion(topResult.identifier)
                } else {
                    print("❌ No classification results")
                    completion(nil)
                }
            } else {
                print("❌ No valid classification results")
                completion(nil)
            }
        }
        
        do {
            try VNImageRequestHandler(cgImage: cgImage).perform([request])
        } catch {
            print("❌ Plant classification request failed: \(error)")
            completion(nil)
        }
    }
    
    private func handleIdentifiedPlant(_ plantName: String) {
        // Check if the plant exists in our database
        if let plant = getPlantFromIdentification(name: plantName) {
            // Show confirmation alert with confidence
            let alert = UIAlertController(
                title: "Plant Identified",
                message: "Is this a \(plantName)?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                self?.showNicknameViewController(for: plant)
            })
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            
            present(alert, animated: true)
        } else {
            showAlert(message: "Sorry, this plant is not in our database")
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
    
    // Add camera usage description to Info.plist
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            showAlert(message: "Camera access is required to take photos")
        }
    }
}



