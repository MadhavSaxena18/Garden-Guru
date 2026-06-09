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
    
    let instruction: [String] = ["1. Snap the whole plant", "2. Snap the infected area", "3. Now take the same with different angle"]
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
        
        // Upload the first (full plant) image to Supabase and wait for completion
        if let firstImage = scanAndDiagnoseViewController.capturedImages.first {
            Task {
                await uploadImageToSupabase(image: firstImage)
                // Continue processing after upload completes
                await MainActor.run {
                    self.continueImageProcessing()
                }
            }
        } else {
            // If no image, continue anyway
            continueImageProcessing()
        }
    }
    
    private func continueImageProcessing() {
        print("Continuing with image processing...")
        
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
        
        // IMPROVED VALIDATION: YOLO is now advisory, not blocking
        // We'll use it to warn about non-plants but not reject scans
        let plantDetections = yoloResults.filter {
            $0.contains("pottedplant") || $0.contains("plant")
        }.count
        
        let nonPlantDetections = yoloResults.filter {
            $0.contains("chair") || $0.contains("table") || $0.contains("person") ||
            $0.contains("bottle") || $0.contains("cup") || $0.contains("book") ||
            $0.contains("laptop") || $0.contains("keyboard") || $0.contains("mouse") ||
            $0.contains("cell phone") || $0.contains("tv") || $0.contains("couch") ||
            $0.contains("bed") || $0.contains("dining table") || $0.contains("toilet") ||
            $0.contains("car") || $0.contains("bicycle") || $0.contains("motorcycle")
        }.count
        
        print("📊 Plant detections: \(plantDetections), Non-plant detections: \(nonPlantDetections)")
        
        // Only reject if we have STRONG evidence of non-plant objects (2+ detections)
        if nonPlantDetections >= 2 {
            print("❌ Multiple non-plant objects detected - rejecting scan")
            DispatchQueue.main.async {
                DiagnosisViewController.plantNameLabel.text = "Not a Plant"
                DiagnosisViewController.diagnosisLabel.text = "Object detected"
                self.stopScanningAnimation()
                self.showNonPlantObjectAlert()
            }
            return
        }
        
        // YOLO is now advisory - we'll proceed to plant classifier even if YOLO doesn't detect plants
        if plantDetections == 0 && nonPlantDetections == 0 {
            print("⚠️ YOLO didn't detect anything clear - proceeding to plant classifier anyway")
        }
        
        print("✅ YOLO validation passed - proceeding with classification")
        
        // Step 2: Run plant classifier on first image only
        if let firstImage = scanAndDiagnoseViewController.capturedImages.first,
           let plantType = runPlantClassifier(firstImage) {
            print("Plant Classification Result: \(plantType)")
            
            // IMPROVED: Check if it's a non-plant object with better detection
            if isNonPlantObject(plantType) || isCommonNonPlantResult(plantType) {
                print("❌ Non-plant object detected by classifier: \(plantType)")
                DispatchQueue.main.async {
                    DiagnosisViewController.plantNameLabel.text = "Not a Plant"
                    DiagnosisViewController.diagnosisLabel.text = "Object detected"
                    self.showNonPlantObjectAlert()
                }
                return
            }
            
            // Check if plant exists in database before proceeding
            let foundPlant = findPlantCaseInsensitive(name: plantType)
            if foundPlant == nil {
                print("⚠️ Plant '\(plantType)' not found in database")
                
                // Try to find a similar plant name in database
                if let similarPlant = findSimilarPlant(name: plantType) {
                    print("✅ Found similar plant: \(similarPlant.plantName)")
                    DispatchQueue.main.async {
                        DiagnosisViewController.plantNameLabel.text = similarPlant.plantName
                    }
                } else {
                    print("❌ No similar plant found - showing generic result")
                    DispatchQueue.main.async {
                        DiagnosisViewController.plantNameLabel.text = plantType
                        DiagnosisViewController.diagnosisLabel.text = "Plant identified but not in database"
                        self.stopScanningAnimation()
                        self.showPlantNotInDatabaseAlert(plantName: plantType)
                    }
                    return
                }
            } else {
                print("✅ Plant '\(foundPlant!.plantName)' found in database")
                DispatchQueue.main.async {
                    DiagnosisViewController.plantNameLabel.text = foundPlant!.plantName
                }
            }
            
            // Step 3: Run disease detection on all images (focus on images 2 and 3 - infected areas)
            var diseaseResults: [String] = []
            
            // Prioritize the last two images (infected area close-ups)
            let imagesToCheck = scanAndDiagnoseViewController.capturedImages.count >= 2 ? 
                Array(scanAndDiagnoseViewController.capturedImages.suffix(2)) : 
                scanAndDiagnoseViewController.capturedImages
            
            for (index, image) in imagesToCheck.enumerated() {
                print("\n--- Running disease detection on image \(index + 1) ---")
                if let diseaseResult = runDiseaseDetection(image) {
                    // Trim whitespace from disease name
                    let cleanedResult = diseaseResult.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Only add non-empty results
                    if !cleanedResult.isEmpty {
                        print("✅ Disease Detection Result for image \(index + 1): \(cleanedResult)")
                        diseaseResults.append(cleanedResult)
                    } else {
                        print("⚠️ Empty disease result after trimming for image \(index + 1)")
                    }
                } else {
                    print("⚠️ No disease detected for image \(index + 1) (confidence too low)")
                }
            }
            
            // Get most frequent disease result
            if !diseaseResults.isEmpty {
                let mostFrequentDisease = mostFrequentResult(diseaseResults)
                print("✅ Final disease diagnosis: \(mostFrequentDisease)")
                
                DispatchQueue.main.async {
                    DiagnosisViewController.diagnosisLabel.text = mostFrequentDisease
                }
            } else {
                print("ℹ️ No diseases detected - plant appears healthy")
                DispatchQueue.main.async {
                    DiagnosisViewController.diagnosisLabel.text = "Healthy"
                }
            }
        } else {
            print("❌ Plant classifier returned no result")
            DispatchQueue.main.async {
                DiagnosisViewController.plantNameLabel.text = "Unknown Plant"
                DiagnosisViewController.diagnosisLabel.text = "No plant detected"
                self.showPlantNotIdentifiedAlert()
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
              let cgImage = image.cgImage else {
            print("❌ Failed to initialize plant classifier model")
            return nil
        }
        
        var resultIdentifier: String?
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("❌ Plant classification error: \(error.localizedDescription)")
                semaphore.signal()
                return
            }
            
            if let results = request.results as? [VNClassificationObservation] {
                // Print top 10 results for debugging
                print("Top 10 plant classification results:")
                for (index, result) in results.prefix(10).enumerated() {
                    print("  \(index + 1). \(result.identifier) - confidence: \(result.confidence)")
                }
                
                if let topResult = results.first {
                    // LOWERED threshold from 0.3 to 0.15 to accept more results
                    // Many plant classifiers have lower confidence scores
                    if topResult.confidence > 0.15 {
                        resultIdentifier = topResult.identifier
                        print("✅ Selected plant: \(topResult.identifier) with confidence: \(topResult.confidence)")
                    } else {
                        print("⚠️ Plant classification confidence too low: \(topResult.confidence)")
                        // Still return the top result if it's above 0.05 (very permissive)
                        if topResult.confidence > 0.05 {
                            resultIdentifier = topResult.identifier
                            print("⚠️ Accepting low-confidence result: \(topResult.identifier)")
                        }
                    }
                }
            }
            semaphore.signal()
        }
        
        request.imageCropAndScaleOption = .scaleFit
        
        do {
            try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        } catch {
            print("❌ Failed to perform plant classification: \(error.localizedDescription)")
        }
        
        semaphore.wait()
        return resultIdentifier
    }
    
    private func runDiseaseDetection(_ image: UIImage) -> String? {
        guard let model = try? VNCoreMLModel(for: GG_Diseases_1().model),
              let cgImage = image.cgImage else {
            print("❌ Failed to initialize disease detection model")
            return nil
        }
        
        var resultIdentifier: String?
        var resultConfidence: Float = 0.0
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("❌ Disease detection error: \(error.localizedDescription)")
                semaphore.signal()
                return
            }
            
            if let results = request.results as? [VNClassificationObservation] {
                // Print top 3 results for debugging
                print("Top 3 disease detection results:")
                for (index, result) in results.prefix(3).enumerated() {
                    print("  \(index + 1). \(result.identifier) - confidence: \(result.confidence)")
                }
                
                if let topResult = results.first {
                    // Accept results with confidence above 0.5 (increased from 0.4 for better accuracy)
                    if topResult.confidence > 0.5 {
                        resultIdentifier = topResult.identifier
                        resultConfidence = topResult.confidence
                        print("✅ Selected disease: \(topResult.identifier) with confidence: \(topResult.confidence)")
                    } else {
                        print("⚠️ Top result confidence too low: \(topResult.confidence)")
                    }
                }
            }
            semaphore.signal()
        }
        
        request.imageCropAndScaleOption = .scaleFit
        
        do {
            try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        } catch {
            print("❌ Failed to perform disease detection: \(error.localizedDescription)")
        }
        
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
        
        print("📊 Disease frequency: \(frequency)")
        
        // Separate healthy and disease results
        let healthyResults = frequency.filter { $0.key.lowercased().contains("healthy") }
        let diseaseResults = frequency.filter { !$0.key.lowercased().contains("healthy") }
        
        // If we have any disease detections, prefer them over healthy
        if !diseaseResults.isEmpty {
            // Get the most frequent disease
            // In case of tie, prefer the one with highest count, then alphabetically
            let sortedDiseases = diseaseResults.sorted { first, second in
                if first.value != second.value {
                    return first.value > second.value  // Higher frequency wins
                }
                return first.key < second.key  // Alphabetical tie-breaker
            }
            
            if let (disease, count) = sortedDiseases.first {
                print("✅ Returning disease: \(disease) (count: \(count))")
                return disease
            }
        }
        
        // If only healthy results or no diseases detected
        if let (result, count) = frequency.max(by: { $0.value < $1.value }) {
            print("✅ Returning result: \(result) (count: \(count))")
            return result
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
    
    // NEW: Additional check for common non-plant results from the classifier
    private func isCommonNonPlantResult(_ result: String) -> Bool {
        let lowercaseResult = result.lowercased()
        let nonPlantKeywords = [
            "chair", "table", "desk", "furniture",
            "person", "human", "face", "hand",
            "bottle", "cup", "glass", "mug",
            "book", "paper", "document",
            "laptop", "computer", "keyboard", "mouse", "phone",
            "tv", "monitor", "screen",
            "wall", "floor", "ceiling", "door", "window",
            "car", "vehicle", "bicycle", "motorcycle",
            "food", "plate", "bowl",
            "clothing", "shirt", "pants", "shoe",
            "toy", "ball", "doll"
        ]
        
        return nonPlantKeywords.contains { lowercaseResult.contains($0) }
    }
    
    private func showNonPlantObjectAlert() {
        let alert = UIAlertController(
            title: "Not a Plant Detected",
            message: "We detected a non-plant object in your images. Please scan an actual plant.\n\nMake sure:\n• You're scanning a real plant\n• The plant is clearly visible\n• There's good lighting\n• No other objects are in the frame",
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
            
            let plantName = DiagnosisViewController.plantNameLabel.text ?? "Unknown Plant"
            let diagnosis = DiagnosisViewController.diagnosisLabel.text ?? "No disease detected"
            
            print("\n=== Final Scan Results ===")
            print("Plant Name: \(plantName)")
            print("Diagnosis: \(diagnosis)")
            
            // IMPROVED: Check if the result is a non-plant object or common non-plant keyword
            if self.isNonPlantObject(plantName) || self.isCommonNonPlantResult(plantName) {
                print("❌ Non-plant object detected in final check: \(plantName)")
                self.stopScanningAnimation()
                self.showNonPlantObjectAlert()
                return
            }
            
            // Check if plant name is empty, unknown, or "Not a Plant"
            if plantName.isEmpty || plantName == "Unknown Plant" || plantName == "Not a Plant" {
                print("❌ Invalid plant name in final check: \(plantName)")
                self.stopScanningAnimation()
                self.showPlantNotIdentifiedAlert()
                return
            }
            
            // Check if plant exists in database
            guard let plant = findPlantCaseInsensitive(name: plantName) else {
                print("❌ Plant not found in database: \(plantName)")
                self.stopScanningAnimation()
                self.showPlantNotFoundAlert()
                return
            }
            
            print("✅ All validations passed - navigating to diagnosis view")
            self.stopScanningAnimation()
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
    
    // Helper function to find similar plant names
    private func findSimilarPlant(name: String) -> Plant? {
        // Common plant name variations and mappings
        let nameVariations: [String: [String]] = [
            "rose": ["Rose", "Roses"],
            "aloe": ["Aloe Vera", "Aloe"],
            "cactus": ["Cactus"],
            "fern": ["Fern"],
            "lily": ["Lily"],
            "orchid": ["Orchid"],
            "tulip": ["Tulip"],
            "sunflower": ["Sunflower"],
            "daisy": ["Daisy"],
            "hibiscus": ["Hibiscus"],
            "jasmine": ["Jasmine"],
            "lavender": ["Lavender"],
            "mint": ["Mint"],
            "basil": ["Basil"],
            "tomato": ["Tomato"],
            "pepper": ["Pepper"],
            "cucumber": ["Cucumber"]
        ]
        
        let lowercaseName = name.lowercased()
        
        // Check if the name contains any known plant keywords
        for (keyword, variations) in nameVariations {
            if lowercaseName.contains(keyword) {
                // Try each variation
                for variation in variations {
                    if let plant = findPlantCaseInsensitive(name: variation) {
                        print("✅ Found similar plant: \(variation) for input: \(name)")
                        return plant
                    }
                }
            }
        }
        
        // Try removing common suffixes/prefixes
        let cleanedName = lowercaseName
            .replacingOccurrences(of: "plant", with: "")
            .replacingOccurrences(of: "tree", with: "")
            .replacingOccurrences(of: "flower", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !cleanedName.isEmpty && cleanedName != lowercaseName {
            return findPlantCaseInsensitive(name: cleanedName)
        }
        
        return nil
    }
    
    private func showPlantNotInDatabaseAlert(plantName: String) {
        let alert = UIAlertController(
            title: "Plant Identified",
            message: "We identified this as '\(plantName)', but it's not in our database yet.\n\nWould you like to:\n• Try scanning again\n• Continue anyway (limited features)",
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Scan Again", style: .default) { [weak self] _ in
            self?.resetForNewScan()
            self?.resetState()
        }
        
        let continueAction = UIAlertAction(title: "Continue Anyway", style: .default) { [weak self] _ in
            // Allow user to continue with limited functionality
            self?.stopScanningAnimation()
            self?.navigateToDiagnosisView(with: "Unknown")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.addAction(retryAction)
        alert.addAction(continueAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
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
            UserDefaults.standard.synchronize() // Force save
            print("✅ Image URL stored in UserDefaults")
            
            // Verify storage
            if let storedURL = UserDefaults.standard.string(forKey: "tempPlantImageURL") {
                print("✅ Verified stored URL: \(storedURL)")
            } else {
                print("⚠️ Failed to verify stored URL")
            }
        } catch {
            print("❌ Failed to upload image: \(error.localizedDescription)")
            // Continue anyway - image upload is not critical for diagnosis
        }
    }
}

//func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//    if let image = info[.originalImage] as? UIImage {
//        uploadImageToSupabase(image: image)
//    }
//    picker.dismiss(animated: true)
//}
//3. Upload Image to Supabase Storage
//func uploadImageToSupabase(image: UIImage) {
//    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
//    let fileName = UUID().uuidString + ".jpg"
//
//    Task {
//        do {
//            // Upload to Supabase Storage
//            try await supabase.storage.from("user-images").upload(
//                path: fileName,
//                file: imageData,
//                options: FileOptions(contentType: "image/jpeg")
//            )
//
//            // Get public URL
//            let publicURL = supabase.storage.from("user-images").getPublicURL(path: fileName)
//
//            // Save this URL to your table
//            await saveImageURLToTable(publicURL: publicURL.absoluteString)
//
//        } catch {
//            print("Upload failed: \(error)")
//        }
//    }
//}
//4. Save Image URL to Supabase Table
//func saveImageURLToTable(publicURL: String) async {
//    do {
//        try await supabase.database
//            .from("profiles")
//            .update(["image_url": publicURL])
//            .eq("id", "user-id") // Replace with actual user ID
//
//        print("Image URL saved in database")
//    } catch {
//        print("Error saving URL to table: \(error)")
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
