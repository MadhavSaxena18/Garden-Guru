//
//
//  scanAndDiagnoseViewController.swift
//  GardenGuruXcode
//
//  Created by Nikhil Gupta on 17/01/25.




import UIKit
import AVFoundation
import CoreML
import Vision


class scanAndDiagnoseViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var snapImage1: UIImageView!
    @IBOutlet weak var snapImage2: UIImageView!
    @IBOutlet weak var snapImage3: UIImageView!
    
    let instruction: [String] = ["1. Snap The whole Plant", "2. Snap the infected area", "3. Now take the same with different angle"]
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCapturePhotoOutput!
    var counter: Int = 0
    static var capturedImages: [UIImage] = []
    
    // Property to track the uploaded image URL
    private var uploadedImageURL: String? = nil
    
    private let dataController = DataControllerGG.shared
    
    private var fullScreenScanningView: UIView!
    private var scanningLine: UIView!
    private var processingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Test YOLO model initialization
               do {
                   let _ = try VNCoreMLModel(for: YOLOv3TinyFP16().model)
                   print("✅ YOLO model initialized successfully in viewDidLoad")
               } catch {
                   print("❌ YOLO model initialization failed: \(error.localizedDescription)")
               }
        
        setupCamera()
        instructionLabel.text = instruction[0]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        DiagnosisViewController.plantNameLabel.text = ""
        DiagnosisViewController.diagnosisLabel.text = ""
        // Reset everything and start fresh
        resetForNewScan()
        setupCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        // Stop the capture session and clean up
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
        
        // Reset everything when leaving
        resetForNewScan()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func resetState() {
        counter = 0
        scanAndDiagnoseViewController.capturedImages.removeAll()
        instructionLabel.text = instruction[0]
        snapImage1.image = nil
        snapImage2.image = nil
        snapImage3.image = nil
        
        // Remove any existing preview image views
        for subview in cameraView.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        
        // Ensure preview layer is added back
        if previewLayer?.superlayer == nil {
            previewLayer?.frame = cameraView.bounds
            cameraView.layer.insertSublayer(previewLayer!, at: 0)
        }
        
        // Start capture session if it's not running
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    func setupCamera() {
        // If session exists, stop it first
        if captureSession != nil {
            captureSession.stopRunning()
            captureSession = nil
        }
        
        // Create new capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Error: No camera available.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            // Setup preview layer
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = cameraView.bounds
            cameraView.layer.insertSublayer(previewLayer, at: 0)
            
            // Start running in background thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        } catch {
            print("Error setting up the camera: \(error.localizedDescription)")
        }
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let photoData = photo.fileDataRepresentation() else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
         
        if let capturedImage = UIImage(data: photoData) {
            DispatchQueue.main.async {
                if self.counter == 0 {
                    self.snapImage1.image = capturedImage
                    self.instructionLabel.text = self.instruction[self.counter + 1]
                    scanAndDiagnoseViewController.capturedImages.append(capturedImage)
                    self.counter += 1
                } else if self.counter == 1 {
                    self.snapImage2.image = capturedImage
                    self.instructionLabel.text = self.instruction[self.counter + 1]
                    scanAndDiagnoseViewController.capturedImages.append(capturedImage)
                    self.counter += 1
                } else if self.counter == 2 {
                    self.snapImage3.image = capturedImage
                    self.captureSession.stopRunning()
                    self.previewLayer.removeFromSuperlayer()
                    
                    let imageView = UIImageView(frame: self.cameraView.bounds)
                    imageView.image = capturedImage
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    self.cameraView.addSubview(imageView)
                    scanAndDiagnoseViewController.capturedImages.append(capturedImage)
                    print("\(scanAndDiagnoseViewController.capturedImages.count)")
//                    self.processImages()
                    self.processImages()
                    self.setupFullScreenScanning()
                    
                }
                
//                print("Capture")
//                scanAndDiagnoseViewController.capturedImages.append(capturedImage)
//                print("\(scanAndDiagnoseViewController.capturedImages.count)")
//                self.counter += 1
            }
        }
    }
    private func processImages() {
        print("Starting image processing...")
        print("Number of captured images: \(scanAndDiagnoseViewController.capturedImages.count)")
        
        // Upload the first (full plant) image to Supabase
        if let firstImage = scanAndDiagnoseViewController.capturedImages.first {
            Task {
                await uploadImageToSupabase(image: firstImage)
            }
        }
        
        // Continue with existing YOLO processing
        var yoloResults: [String] = []
        
        for (index, image) in scanAndDiagnoseViewController.capturedImages.enumerated() {
            print("\n--- Processing image \(index + 1) with YOLO ---")
            if let yoloResult = runYOLOModel(image) {
                let lowercaseResult = yoloResult.lowercased()
                print("YOLO Result for image \(index + 1): \(lowercaseResult)")
                yoloResults.append(lowercaseResult)
            } else {
                print("⚠️ No YOLO result for image \(index + 1)")
                yoloResults.append("no objects detected")
            }
        }
        
        print("\nAll YOLO results: \(yoloResults)")
        
        // Check if majority of YOLO results are plants
        let plantDetections = yoloResults.filter {
            $0.contains("pottedplant") || $0.contains("vase") || $0.contains("no objects detected")
        }.count
        
        if plantDetections >= 2 {  // At least 2 images detected as plants
            // Step 2: Run plant classifier on first image only
            if let firstImage = scanAndDiagnoseViewController.capturedImages.first,
               let plantType = runPlantClassifier(firstImage) {
                print("Plant Classification Result: \(plantType)")
                
                // Check if it's a non-plant object
                if isNonPlantObject(plantType) {
                    DispatchQueue.main.async {
                        DiagnosisViewController.plantNameLabel.text = "Unknown Plant"
                        DiagnosisViewController.diagnosisLabel.text = "No disease detected"
                        self.showPlantNotIdentifiedAlert()
                    }
                    return
                }
                
                // Check if plant exists in database before proceeding
                if findPlantCaseInsensitive(name: plantType) == nil {
                    DispatchQueue.main.async {
                        DiagnosisViewController.plantNameLabel.text = plantType
                        DiagnosisViewController.diagnosisLabel.text = "No disease detected"
                        self.showPlantNotFoundAlert()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    DiagnosisViewController.plantNameLabel.text = plantType
                }
                
                // Step 3: Run disease detection on all images
                var diseaseResults: [String] = []
                
                for (index, image) in scanAndDiagnoseViewController.capturedImages.enumerated() {
                    if let diseaseResult = runDiseaseDetection(image) {
                        print("Disease Detection Result for image \(index + 1): \(diseaseResult)")
                        diseaseResults.append(diseaseResult)
                    }
                }
                
                // Get most frequent disease result
                if !diseaseResults.isEmpty {
                    let mostFrequentDisease = mostFrequentResult(diseaseResults)
                    print("Most frequent disease: \(mostFrequentDisease)")
                    
                    DispatchQueue.main.async {
                        DiagnosisViewController.diagnosisLabel.text = "\(mostFrequentDisease)"
                    }
                } else {
                    DispatchQueue.main.async {
                        DiagnosisViewController.diagnosisLabel.text = "No disease detected"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    DiagnosisViewController.plantNameLabel.text = "Unknown Plant"
                    DiagnosisViewController.diagnosisLabel.text = "No disease detected"
                   // self.showPlantNotIdentifiedAlert()
                }
            }
        } else {
            DispatchQueue.main.async {
                DiagnosisViewController.plantNameLabel.text = "Unknown Plant"
                DiagnosisViewController.diagnosisLabel.text = "No disease detected"
              //  self.showPlantNotIdentifiedAlert()
            }
        }
    }
    
    private func runYOLOModel(_ image: UIImage) -> String? {
        do {
            print("Initializing YOLO model...")
            let model = try VNCoreMLModel(for: YOLOv3TinyFP16().model)
            print("YOLO model initialized successfully")
            
            guard let cgImage = image.cgImage else {
                print("Failed to get CGImage")
                return nil
            }
            
            var resultIdentifier: String?
            let semaphore = DispatchSemaphore(value: 0)
            
            let request = VNCoreMLRequest(model: model) { request, error in
                defer { semaphore.signal() }
                
                guard error == nil else {
                    print("YOLO Request Error: \(error!.localizedDescription)")
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                    print("No YOLO observations found")
                    return
                }
                
                // Sort observations by confidence
                let sortedObservations = observations.sorted { $0.confidence > $1.confidence }
                
                // Print all detections for debugging
                for observation in sortedObservations {
                    for label in observation.labels {
                        print("YOLO detected: \(label.identifier) with confidence: \(observation.confidence)")
                    }
                }
                
                // Get the highest confidence detection
                if let bestObservation = sortedObservations.first,
                   let bestLabel = bestObservation.labels.first {
                    resultIdentifier = bestLabel.identifier
                    print("Best YOLO detection: \(bestLabel.identifier) with confidence: \(bestObservation.confidence)")
                }
            }
            
            // Set image crop and scale option
            request.imageCropAndScaleOption = .scaleFit
            
            // Perform the request
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
            try handler.perform([request])
            
            semaphore.wait()
            
            if let result = resultIdentifier {
                print("YOLO returning result: \(result)")
            } else {
                print("YOLO returning nil result")
            }
            
            return resultIdentifier
            
        } catch {
            print("YOLO Model Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func runPlantClassifier(_ image: UIImage) -> String? {
        guard let model = try? VNCoreMLModel(for: PLANT_IDENTIFICATION_MODEL_1().model),
              let cgImage = image.cgImage else { return nil }
        
        var resultIdentifier: String?
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = VNCoreMLRequest(model: model) { request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                resultIdentifier = topResult.identifier
                print("Plant classified as: \(topResult.identifier) with confidence: \(topResult.confidence)")
            }
            semaphore.signal()
        }
        
        try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        semaphore.wait()
        return resultIdentifier
    }
    
    private func runDiseaseDetection(_ image: UIImage) -> String? {
        guard let model = try? VNCoreMLModel(for: GardenGuruDiseasesDetection_2().model),
              let cgImage = image.cgImage else { return nil }
        
        var resultIdentifier: String?
        var resultConfidence: Float = 0.0
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = VNCoreMLRequest(model: model) { request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                // Only accept results with confidence above 0.5
                if topResult.confidence > 0.5 {
                    resultIdentifier = topResult.identifier
                    resultConfidence = topResult.confidence
                }
                print("Disease detection: \(topResult.identifier) with confidence: \(topResult.confidence)")
            }
            semaphore.signal()
        }
        
        try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        semaphore.wait()
        
        // If confidence is too low, return nil instead of a potentially incorrect result
        return resultConfidence > 0.5 ? resultIdentifier : nil
    }
    
    private func mostFrequentResult(_ results: [String]) -> String {
        // Filter out nil and empty results
        let validResults = results.filter { !$0.isEmpty }
        
        // If no valid results, return healthy
        if validResults.isEmpty {
            return "Healthy"
        }
        
        // Count frequency of each result
        let frequency = validResults.reduce(into: [:]) { counts, result in
            counts[result, default: 0] += 1
        }
        
        // Get the most frequent result
        if let (result, count) = frequency.max(by: { $0.value < $1.value }) {
            // Only return disease if it appears in more than one image
            if count > 1 && !result.lowercased().contains("healthy") {
                return result
            } else {
                // If disease only appears once or result is "healthy", return healthy
                return "Healthy"
            }
        }
        
        return "Healthy"
    }
    
    private func isNonPlantObject(_ result: String) -> Bool {
        let nonPlantPrefixes = [
            "Non-Plant Object",
            "Non plant object",
            "Non plnat object"  // Including the typo variant
        ]
        return nonPlantPrefixes.contains { result.hasPrefix($0) }
    }
    
    private func showPlantNotIdentifiedAlert() {
        let alert = UIAlertController(
            title: "Plant Not Identified",
            message: "We couldn't identify a plant in your images. Please ensure:\n\n• The plant is clearly visible\n• There's good lighting\n• The plant takes up most of the frame\n• You're capturing different angles",
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
         //   self?.navigationController?.popViewController(animated: true)
            self?.resetForNewScan()
            self?.resetState()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showPlantNotFoundAlert() {
        let alert = UIAlertController(
            title: "Plant Not Found",
            message: "Sorry, we couldn't find this plant in our database. Please try scanning a different plant.",
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.resetForNewScan()
            self?.resetState()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func setupFullScreenScanning() {
        snapImage1.isHidden = true
        snapImage2.isHidden = true
        snapImage3.isHidden = true
        instructionLabel.isHidden = true
        
        fullScreenScanningView = UIView(frame: cameraView.bounds)
        fullScreenScanningView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cameraView.addSubview(fullScreenScanningView)
        
        processingLabel = UILabel()
        processingLabel.text = "Processing Images..."
        processingLabel.textColor = .white
        processingLabel.textAlignment = .center
        processingLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        processingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(processingLabel)
        
        NSLayoutConstraint.activate([
            processingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            processingLabel.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: -20)
        ])
        
        scanningLine = UIView(frame: CGRect(x: 0, y: 0, width: cameraView.frame.width, height: 3))
        scanningLine.backgroundColor = UIColor.green.withAlphaComponent(0.7)
        fullScreenScanningView.addSubview(scanningLine)
        fullScreenScanningView.clipsToBounds = true
        
        animateScanningLine()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            self.stopScanningAnimation()
            
            let plantName = DiagnosisViewController.plantNameLabel.text ?? "Unknown Plant"
            
            // Check if the result is a non-plant object
            if self.isNonPlantObject(plantName) {
                self.showPlantNotIdentifiedAlert()
                return
            }
            
            // Check if plant name is empty or unknown
            if plantName.isEmpty || plantName == "Unknown Plant" {
                self.showPlantNotIdentifiedAlert()
                return
            }
            
            // Check if plant exists in database
            if findPlantCaseInsensitive(name: plantName) == nil {
                self.showPlantNotFoundAlert()
                return
            }
            
            let diagnosis = DiagnosisViewController.diagnosisLabel.text ?? "No disease detected"
            
            // Create DiagnosisDataModel with the processed results
            let diagnosisData = DiagnosisDataModel(
                plantName: plantName,
                diagnosis: diagnosis,
                botanicalName: "", // Will be populated in DiagnosisViewController
                sectionDetails: [:] // Will be populated in DiagnosisViewController
            )
            
            self.navigateToDiagnosisView(with: diagnosis)
        }
    }
    
    private func animateScanningLine() {
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            self.scanningLine.frame.origin.y = self.cameraView.frame.height - self.scanningLine.frame.height
        }, completion: nil)
    }
    
    private func stopScanningAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.fullScreenScanningView.alpha = 0
            self.processingLabel.alpha = 0
        }) { _ in
            self.scanningLine.layer.removeAllAnimations()
            self.fullScreenScanningView.removeFromSuperview()
            self.processingLabel.removeFromSuperview()
            
            self.snapImage1.isHidden = false
            self.snapImage2.isHidden = false
            self.snapImage3.isHidden = false
            self.instructionLabel.isHidden = false
        }
    }
    
    func resetForNewScan() {
        counter = 0
        scanAndDiagnoseViewController.capturedImages.removeAll()
        instructionLabel.text = instruction[0]
        snapImage1.image = nil
        snapImage2.image = nil
        snapImage3.image = nil
        
        // Remove any existing preview images and animations
        for subview in cameraView.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        
        // Remove scanning animation views
        fullScreenScanningView?.removeFromSuperview()
        processingLabel?.removeFromSuperview()
        scanningLine?.removeFromSuperview()
        
        // Reset visibility
        snapImage1.isHidden = false
        snapImage2.isHidden = false
        snapImage3.isHidden = false
        instructionLabel.isHidden = false
        
        // Remove preview layer if it exists
        previewLayer?.removeFromSuperlayer()
    }
    
    private func navigateToDiagnosisView(with diseaseName: String) {
        let diagnosisVC = DiagnosisViewController()
        
        // Get the plant name that was detected
        let plantName = DiagnosisViewController.plantNameLabel.text ?? "Unknown Plant"
        
        // Get plant details from database using case-insensitive search
        if let plant = findPlantCaseInsensitive(name: plantName) {
            // Create diagnosis data model with plant details
            diagnosisVC.selectedPlant = DiagnosisDataModel(
                plantName: plant.plantName,
                diagnosis: diseaseName,
                botanicalName: plant.plantBotanicalName ?? "",
                sectionDetails: [:]
            )
            
            // Store plant ID in UserDefaults
            UserDefaults.standard.set(plant.plantID.uuidString, forKey: "tempPlantID")
            print("✅ Plant ID stored in UserDefaults")
            
            // Verify image URL is in UserDefaults
            if let storedURL = UserDefaults.standard.string(forKey: "tempPlantImageURL") {
                print("✅ Found stored image URL: \(storedURL)")
            } else {
                print("⚠️ No image URL found in UserDefaults")
            }
            
            // Fetch disease details and navigate
            diagnosisVC.fetchAndUpdateDiseaseDetails(diseaseName: diseaseName)
            navigationController?.pushViewController(diagnosisVC, animated: true)
        } else {
            print("Error: Plant not found in database")
            showPlantNotFoundAlert()
        }
    }
    
    // Helper function to find plant with case-insensitive search
    private func findPlantCaseInsensitive(name: String) -> Plant? {
        // Try exact match first
        if let plant = dataController.getPlantbyNameSync(name: name) {
            return plant
        }
        
        // Try lowercase
        if let plant = dataController.getPlantbyNameSync(name: name.lowercased()) {
            return plant
        }
        
        // Try uppercase
        if let plant = dataController.getPlantbyNameSync(name: name.uppercased()) {
            return plant
        }
        
        // Try capitalized (first letter uppercase, rest lowercase)
        if let plant = dataController.getPlantbyNameSync(name: name.capitalized) {
            return plant
        }
        
        return nil
    }
    
    private func uploadImageToSupabase(image: UIImage) async {
        print("\n=== Uploading Image to Supabase ===")
        
        // Generate a unique ID for this upload
        let imageID = UUID()
        
        do {
            // Upload the image and get the URL
            let imageURL = try await dataController.uploadUserPlantImage(userPlantID: imageID, image: image)
            print("✅ Image uploaded successfully")
            print("🔗 Image URL: \(imageURL)")
            self.uploadedImageURL = imageURL
            
            // Store in UserDefaults immediately after successful upload
            UserDefaults.standard.set(imageURL, forKey: "tempPlantImageURL")
            print("✅ Image URL stored in UserDefaults")
        } catch {
            print("❌ Failed to upload image: \(error)")
        }
    }
}


































