//
//  GrowingPlantLoadingView.swift
//  GardenGuruXcode
//
//  Created by Cascade on 04/04/25.
//

import UIKit

class GrowingPlantLoadingView: UIView {
    
    // MARK: - Properties
    private let plantContainer = UIView()
    private let stemView = UIView()
    private let leafViews: [UIView] = (0..<4).map { _ in UIView() }
    private let flowerView = UIView()
    private let rootViews: [UIView] = (0..<3).map { _ in UIView() }
    
    private var animationTimer: Timer?
    private var currentGrowthStage: Int = 0
    
    // Growth stages for delightful animation
    private enum GrowthStage: Int, CaseIterable {
        case seed = 0
        case sprout = 1
        case growing = 2
        case leaves = 3
        case flowering = 4
        case fullGrowth = 5
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = UIColor(hex: "EBF4EB")
        
        // Add plant container
        addSubview(plantContainer)
        plantContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup stem
        stemView.backgroundColor = UIColor(hex: "4A9B4A")
        stemView.layer.cornerRadius = 2
        stemView.translatesAutoresizingMaskIntoConstraints = false
        plantContainer.addSubview(stemView)
        
        // Setup leaves
        for (index, leaf) in leafViews.enumerated() {
            leaf.backgroundColor = UIColor(hex: "2F8F2F")
            leaf.layer.cornerRadius = 8
            leaf.translatesAutoresizingMaskIntoConstraints = false
            leaf.alpha = 0
            leaf.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            plantContainer.addSubview(leaf)
        }
        
        // Setup flower
        flowerView.backgroundColor = UIColor(hex: "FF6B6B")
        flowerView.layer.cornerRadius = 12
        flowerView.translatesAutoresizingMaskIntoConstraints = false
        flowerView.alpha = 0
        flowerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        plantContainer.addSubview(flowerView)
        
        // Setup roots
        for root in rootViews {
            root.backgroundColor = UIColor(hex: "8B4513")
            root.layer.cornerRadius = 1
            root.translatesAutoresizingMaskIntoConstraints = false
            root.alpha = 0
            plantContainer.addSubview(root)
        }
        
        setupConstraints()
        resetToSeed()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Plant container centering
            plantContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            plantContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            plantContainer.widthAnchor.constraint(equalToConstant: 120),
            plantContainer.heightAnchor.constraint(equalToConstant: 160),
            
            // Stem constraints
            stemView.centerXAnchor.constraint(equalTo: plantContainer.centerXAnchor),
            stemView.bottomAnchor.constraint(equalTo: plantContainer.bottomAnchor, constant: -20),
            stemView.widthAnchor.constraint(equalToConstant: 4),
            stemView.heightAnchor.constraint(equalToConstant: 0), // Will grow
            
            // Leaves constraints
            leafViews[0].leadingAnchor.constraint(equalTo: stemView.trailingAnchor, constant: 8),
            leafViews[0].centerYAnchor.constraint(equalTo: stemView.topAnchor, constant: -20),
            leafViews[0].widthAnchor.constraint(equalToConstant: 16),
            leafViews[0].heightAnchor.constraint(equalToConstant: 20),
            
            leafViews[1].trailingAnchor.constraint(equalTo: stemView.leadingAnchor, constant: -8),
            leafViews[1].centerYAnchor.constraint(equalTo: stemView.topAnchor, constant: -40),
            leafViews[1].widthAnchor.constraint(equalToConstant: 16),
            leafViews[1].heightAnchor.constraint(equalToConstant: 20),
            
            leafViews[2].leadingAnchor.constraint(equalTo: stemView.trailingAnchor, constant: 10),
            leafViews[2].centerYAnchor.constraint(equalTo: stemView.topAnchor, constant: -60),
            leafViews[2].widthAnchor.constraint(equalToConstant: 18),
            leafViews[2].heightAnchor.constraint(equalToConstant: 22),
            
            leafViews[3].trailingAnchor.constraint(equalTo: stemView.leadingAnchor, constant: -10),
            leafViews[3].centerYAnchor.constraint(equalTo: stemView.topAnchor, constant: -80),
            leafViews[3].widthAnchor.constraint(equalToConstant: 18),
            leafViews[3].heightAnchor.constraint(equalToConstant: 22),
            
            // Flower constraints
            flowerView.centerXAnchor.constraint(equalTo: stemView.centerXAnchor),
            flowerView.bottomAnchor.constraint(equalTo: stemView.topAnchor, constant: -10),
            flowerView.widthAnchor.constraint(equalToConstant: 24),
            flowerView.heightAnchor.constraint(equalToConstant: 24),
            
            // Roots constraints
            rootViews[0].centerXAnchor.constraint(equalTo: stemView.centerXAnchor, constant: -15),
            rootViews[0].topAnchor.constraint(equalTo: stemView.bottomAnchor, constant: 5),
            rootViews[0].widthAnchor.constraint(equalToConstant: 2),
            rootViews[0].heightAnchor.constraint(equalToConstant: 15),
            
            rootViews[1].centerXAnchor.constraint(equalTo: stemView.centerXAnchor),
            rootViews[1].topAnchor.constraint(equalTo: stemView.bottomAnchor, constant: 8),
            rootViews[1].widthAnchor.constraint(equalToConstant: 2),
            rootViews[1].heightAnchor.constraint(equalToConstant: 12),
            
            rootViews[2].centerXAnchor.constraint(equalTo: stemView.centerXAnchor, constant: 15),
            rootViews[2].topAnchor.constraint(equalTo: stemView.bottomAnchor, constant: 5),
            rootViews[2].widthAnchor.constraint(equalToConstant: 2),
            rootViews[2].heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    // MARK: - Animation Control
    func startGrowthAnimation() {
        resetToSeed()
        currentGrowthStage = 0
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            self?.growToNextStage()
        }
    }
    
    func stopGrowthAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Complete to full growth
        growToStage(.fullGrowth)
    }
    
    private func resetToSeed() {
        // Reset stem
        stemView.alpha = 1
        stemView.transform = CGAffineTransform(scaleX: 1, y: 0.1)
        
        // Hide all other elements
        leafViews.forEach { leaf in
            leaf.alpha = 0
            leaf.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        
        flowerView.alpha = 0
        flowerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        rootViews.forEach { root in
            root.alpha = 0
            root.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
    }
    
    private func growToNextStage() {
        guard currentGrowthStage < GrowthStage.fullGrowth.rawValue else {
            // Restart animation
            currentGrowthStage = 0
            resetToSeed()
            return
        }
        
        currentGrowthStage += 1
        if let stage = GrowthStage(rawValue: currentGrowthStage) {
            growToStage(stage)
        }
    }
    
    private func growToStage(_ stage: GrowthStage) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            switch stage {
            case .seed:
                // Show small stem sprout
                self.stemView.transform = CGAffineTransform(scaleX: 1, y: 0.2)
                
            case .sprout:
                // Grow stem taller
                self.stemView.transform = CGAffineTransform(scaleX: 1, y: 0.5)
                
            case .growing:
                // Grow stem to full height and show roots
                self.stemView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.rootViews.enumerated().forEach { index, root in
                    let delay = Double(index) * 0.1
                    UIView.animate(withDuration: 0.4, delay: delay, options: .curveEaseOut) {
                        root.alpha = 0.6
                        root.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }
                }
                
            case .leaves:
                // Show leaves with staggered animation
                self.leafViews.enumerated().forEach { index, leaf in
                    let delay = Double(index) * 0.15
                    UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
                        leaf.alpha = 1
                        leaf.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }
                }
                
            case .flowering:
                // Show flower
                self.flowerView.alpha = 1
                self.flowerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                
            case .fullGrowth:
                // Gentle swaying animation
                self.addSwayingAnimation()
            }
        }
    }
    
    private func addSwayingAnimation() {
        let swayAnimation = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation.duration = 3.0
        swayAnimation.fromValue = -0.05
        swayAnimation.toValue = 0.05
        swayAnimation.autoreverses = true
        swayAnimation.repeatCount = .infinity
        swayAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        plantContainer.layer.add(swayAnimation, forKey: "sway")
    }
    
    // MARK: - Convenience Methods
    static func show(in view: UIView, animated: Bool = true) -> GrowingPlantLoadingView {
        let loadingView = GrowingPlantLoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if animated {
            loadingView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 1
            }
        }
        
        loadingView.startGrowthAnimation()
        return loadingView
    }
    
    func hide(completion: (() -> Void)? = nil) {
        stopGrowthAnimation()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}
