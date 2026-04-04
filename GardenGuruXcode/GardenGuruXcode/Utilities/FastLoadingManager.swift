//
//  FastLoadingManager.swift
//  GardenGuruXcode
//
//  Created by Cascade on 04/04/25.
//

import UIKit

/// Manages instant UI loading with delightful plant growth animations
class FastLoadingManager {
    
    static let shared = FastLoadingManager()
    
    private var loadingViews: [UIView: GrowingPlantLoadingView] = [:]
    private var loadingTasks: [String: Task<Any, Error>] = [:]
    
    private init() {}
    
    // MARK: - Public Interface
    
    /// Shows loading animation instantly while data loads in background
    /// - Parameters:
    ///   - view: The view to show loading in
    ///   - task: The async task to load data
    ///   - onDataReady: Closure called when data is ready
    /// - Returns: Task that can be cancelled if needed
    @discardableResult
    func loadWithAnimation<T>(
        in view: UIView,
        taskKey: String? = nil,
        task: @escaping () async throws -> T,
        onDataReady: @escaping (T) -> Void
    ) -> Task<Void, Never> {
        
        let key = taskKey ?? UUID().uuidString
        
        // Cancel any existing task with the same key
        loadingTasks[key]?.cancel()
        
        // Show loading animation immediately
        let loadingView = GrowingPlantLoadingView.show(in: view)
        loadingViews[view] = loadingView
        
        // Start data loading in background
        let loadingTask = Task {
            do {
                let data = try await task()
                
                await MainActor.run {
                    // Hide loading animation with a delightful completion
                    loadingView.hide {
                        // Provide data to callback
                        onDataReady(data)
                    }
                    
                    // Clean up
                    self.loadingViews.removeValue(forKey: view)
                    self.loadingTasks.removeValue(forKey: key)
                }
                
            } catch {
                await MainActor.run {
                    // Handle error gracefully
                    loadingView.hide {
                        // You could show an error state here
                        print("❌ Loading failed: \(error)")
                    }
                    
                    self.loadingViews.removeValue(forKey: view)
                    self.loadingTasks.removeValue(forKey: key)
                }
            }
        }
        
        loadingTasks[key] = loadingTask as! Task<Any, Error>
        return loadingTask as! Task<Void, Never>
    }
    
    /// Instantly hides loading for a specific view
    func hideLoading(for view: UIView, completion: (() -> Void)? = nil) {
        guard let loadingView = loadingViews[view] else {
            completion?()
            return
        }
        
        loadingView.hide {
            self.loadingViews.removeValue(forKey: view)
            completion?()
        }
    }
    
    /// Cancels all ongoing loading tasks
    func cancelAllLoading() {
        loadingTasks.values.forEach { $0.cancel() }
        loadingTasks.removeAll()
        
        loadingViews.values.forEach { $0.hide() }
        loadingViews.removeAll()
    }
    
    /// Cancels loading for a specific task key
    func cancelLoading(taskKey: String) {
        loadingTasks[taskKey]?.cancel()
        loadingTasks.removeValue(forKey: taskKey)
        
        // Find and remove associated loading view
        if let (viewToRemove, _) = loadingViews.first(where: { _, _ in true }) {
            hideLoading(for: viewToRemove)
        }
    }
}

// MARK: - UIViewController Extension for Easy Usage
extension UIViewController {
    
    /// Load data with instant UI and plant growth animation
    /// - Parameters:
    ///   - taskKey: Unique key for the loading task
    ///   - task: Async task to load data
    ///   - onDataReady: Callback when data is ready
    /// - Returns: Cancellable task
    @discardableResult
    func loadWithPlantAnimation<T>(
        taskKey: String? = nil,
        task: @escaping () async throws -> T,
        onDataReady: @escaping (T) -> Void
    ) -> Task<Void, Never> {
        
        return FastLoadingManager.shared.loadWithAnimation(
            in: view,
            taskKey: taskKey,
            task: task,
            onDataReady: onDataReady
        )
    }
    
    /// Hide current loading animation
    func hidePlantLoading(completion: (() -> Void)? = nil) {
        FastLoadingManager.shared.hideLoading(for: view, completion: completion)
    }
    
    /// Cancel loading by task key
    func cancelPlantLoading(taskKey: String) {
        FastLoadingManager.shared.cancelLoading(taskKey: taskKey)
    }
}

// MARK: - UICollectionView Extension
extension UICollectionView {
    
    /// Load collection view data with instant UI
    /// - Parameters:
    ///   - taskKey: Unique key for the loading task
    ///   - task: Async task to load data
    ///   - onDataReady: Callback to update collection view
    /// - Returns: Cancellable task
    @discardableResult
    func loadWithPlantAnimation<T>(
        taskKey: String? = nil,
        task: @escaping () async throws -> T,
        onDataReady: @escaping (T) -> Void
    ) -> Task<Void, Never> {
        
        // Show loading immediately, keep collection view visible
        isUserInteractionEnabled = false
        alpha = 0.6
        
        return FastLoadingManager.shared.loadWithAnimation(
            in: self,
            taskKey: taskKey,
            task: task
        ) { data in
            self.isUserInteractionEnabled = true
            self.alpha = 1.0
            onDataReady(data)
        }
    }
}

// MARK: - Specialized Loading Methods for Garden Guru

extension FastLoadingManager {
    
    /// Load Explore data with optimized caching
    func loadExploreData(
        in view: UIView,
        onDataReady: @escaping ([(title: String, items: [Any])]) -> Void
    ) {
        loadWithAnimation(
            in: view,
            taskKey: "explore_data"
        ) {
            // Load actual explore data from DataControllerGG
            let dataController = DataControllerGG.shared
            
            // Get user info first for user-specific data
            guard let user = dataController.getUserSync() else {
                throw NSError(domain: "ExploreError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
            
            // Load data concurrently
            async let plantsTask = try await dataController.getPlants()
            async let diseasesTask = try await dataController.getDiseasesForUserPlants(userEmail: user.userEmail!)
            async let fertilizersTask = try await dataController.getCommonFertilizers()
            async let careTipTask = try await dataController.getCareTipOfTheDay()
            async let preventionTipsTask = try await dataController.getPreventionTips()
            
            let (plants, diseases, fertilizers, careTip, preventionTips) = try await (
                plantsTask, diseasesTask, fertilizersTask, careTipTask, preventionTipsTask
            )
            
            // Return formatted data
            var result: [(title: String, items: [Any])] = []
            
            if let tip = careTip {
                result.append(("Care Tip of the Day", [tip]))
            }
            
            result.append(("All Plants", plants))
            result.append(("Common Issues", diseases))
            result.append(("Common Fertilizers", fertilizers))
            result.append(("Pest & Disease Prevention", preventionTips))
            
            return result
        } onDataReady: { data in
            onDataReady(data)
        }
    }
    
    /// Load MySpace data with instant UI
    func loadMySpaceData(
        in view: UIView,
        onDataReady: @escaping ([(category: String, plants: [UserPlant])]) -> Void
    ) {
        loadWithAnimation(
            in: view,
            taskKey: "myspace_data"
        ) {
            // Load actual MySpace data from DataControllerGG
            let dataController = DataControllerGG.shared
            guard let user = dataController.getUserSync() else {
                throw NSError(domain: "MySpaceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
            
            let plantsWithDetails = try await dataController.getUserPlantsWithDetails(for: user.userEmail!)
            
            // Format data by categories
            let result = [("My Plants", plantsWithDetails.map { $0.userPlant })]
            
            return result
        } onDataReady: { data in
            onDataReady(data)
        }
    }
    
    /// Load Community posts with pagination
    func loadCommunityPosts(
        in view: UIView,
        page: Int = 0,
        onDataReady: @escaping ([CommunityPost]) -> Void
    ) {
        loadWithAnimation(
            in: view,
            taskKey: "community_posts_\(page)"
        ) {
            // Load actual Community posts from DataControllerGG
            let dataController = DataControllerGG.shared
            let posts = try await dataController.fetchCommunityPosts(limit: 20, offset: page * 20)
            
            return posts
        } onDataReady: { posts in
            onDataReady(posts)
        }
    }
}
