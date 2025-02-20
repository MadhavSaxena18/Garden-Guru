//
//
//  scanAndDiagnoseViewController.swift
//  GardenGuruXcode
//
//  Created by Nikhil Gupta on 17/01/25.




import UIKit
import AVFoundation

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
    
    private var fullScreenScanningView: UIView!
    private var scanningLine: UIView!
    private var processingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        instructionLabel.text = instruction[0]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
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
            if counter == 0 {
                snapImage1.image = capturedImage
                instructionLabel.text = instruction[counter + 1]
            } else if counter == 1 {
                snapImage2.image = capturedImage
                instructionLabel.text = instruction[counter + 1]
            } else if counter == 2 {
                snapImage3.image = capturedImage
                captureSession.stopRunning()
                previewLayer.removeFromSuperlayer()
                
                let imageView = UIImageView(frame: cameraView.bounds)
                imageView.image = capturedImage
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                cameraView.addSubview(imageView)
                
                setupFullScreenScanning()
            }
            
            scanAndDiagnoseViewController.capturedImages.append(capturedImage)
            counter += 1
        }
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
            
            let plant = DiagnosisScreen.diagnosisData[0]
            let diagnosisVC = DiagnosisViewController()
            diagnosisVC.selectedPlant = plant
            self.navigationController?.pushViewController(diagnosisVC, animated: true)
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
}















