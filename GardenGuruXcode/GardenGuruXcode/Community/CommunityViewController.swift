//
//  CommunityViewController.swift
//  GardenGuruXcode
//
//  Created by Garden Guru Team
//

import UIKit

class CommunityViewController: UIViewController {
    
    // MARK: - Properties
    
    private let dataController = DataControllerGG.shared
    private var posts: [CommunityPost] = []
    private var filteredPosts: [CommunityPost] = []
    private var isSearching = false
    private var isLoading = false
    private var currentPage = 0
    private let postsPerPage = 20
    private var lastScrollOffset: CGFloat = 0
    
    // Sort options
    private enum SortOption {
        case newest
        case oldest
        
        var title: String {
            switch self {
            case .newest: return "Newest First"
            case .oldest: return "Oldest First"
            }
        }
        
        var icon: String {
            switch self {
            case .newest: return "arrow.down"
            case .oldest: return "arrow.up"
            }
        }
    }
    
    private var currentSortOption: SortOption = .newest
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = generateLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(hex: "EBF4EB")
        cv.delegate = self
        cv.dataSource = self
        cv.register(CommunityPostCell.self, forCellWithReuseIdentifier: CommunityPostCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        refresh.tintColor = UIColor(hex: "284329")
        return refresh
    }()
    
    private lazy var fabButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(hex: "284329")
        button.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(fabButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(hex: "284329")
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "leaf.fill")
        imageView.tintColor = UIColor(hex: "284329").withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No posts yet.\nBe the first to share!"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor(hex: "284329").withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.delegate = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search posts..."
        search.searchBar.tintColor = UIColor(hex: "284329")
        search.searchBar.searchTextField.backgroundColor = UIColor(hex: "F5F9F5")
        return search
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        loadInitialPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh posts when view appears
        Task {
            await fetchPosts(refresh: true)
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "EBF4EB")
        title = "Community"
        
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor(hex: "284329")]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(hex: "284329")]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(hex: "284329")
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Add search button to navigation bar (search bar will appear on scroll up)
        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchButtonTapped)
        )
        searchButton.tintColor = UIColor(hex: "284329")
        
        // Add filter button
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        filterButton.tintColor = UIColor(hex: "284329")
        
        navigationItem.rightBarButtonItems = [searchButton, filterButton]
        
        // Add subviews
        view.addSubview(collectionView)
        view.addSubview(fabButton)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        // Add refresh control
        collectionView.refreshControl = refreshControl
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Collection View
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // FAB Button
            fabButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fabButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            fabButton.widthAnchor.constraint(equalToConstant: 56),
            fabButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 20),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostCreated),
            name: .communityPostCreated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostDeleted),
            name: .communityPostDeleted,
            object: nil
        )
    }
    
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(500)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(500)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Data Loading
    
    private func loadInitialPosts() {
        guard !isLoading else { return }
        
        loadingIndicator.startAnimating()
        collectionView.isHidden = true
        emptyStateView.isHidden = true
        
        Task {
            await fetchPosts(refresh: true)
            
            await MainActor.run {
                loadingIndicator.stopAnimating()
                updateEmptyState()
            }
        }
    }
    
    private func fetchPosts(refresh: Bool = false) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        if refresh {
            currentPage = 0
        }
        
        do {
            let newPosts = try await dataController.fetchCommunityPosts(
                limit: postsPerPage,
                offset: currentPage * postsPerPage
            )
            
            await MainActor.run {
                if refresh {
                    self.posts = newPosts
                } else {
                    self.posts.append(contentsOf: newPosts)
                }
                
                // Apply current sort option
                self.sortPosts()
                
                self.collectionView.reloadData()
                self.isLoading = false
                self.updateEmptyState()
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = isSearching ? filteredPosts.isEmpty : posts.isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        
        if isSearching && isEmpty {
            emptyStateLabel.text = "No posts found.\nTry a different search."
        } else {
            emptyStateLabel.text = "No posts yet.\nBe the first to share!"
        }
    }
    
    @objc private func searchButtonTapped() {
        print("🔍 Search button tapped")
        
        // Show search bar in navigation
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Scroll to top to reveal search bar
        if !posts.isEmpty {
            collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.contentInset.top), animated: true)
        }
        
        // Activate search bar after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    @objc private func filterButtonTapped() {
        print("🔽 Filter button tapped")
        
        let alert = UIAlertController(
            title: "Sort Posts",
            message: "Choose how to sort community posts",
            preferredStyle: .actionSheet
        )
        
        // Newest First option
        let newestAction = UIAlertAction(title: "Newest First", style: .default) { [weak self] _ in
            self?.applySortOption(.newest)
        }
        if currentSortOption == .newest {
            newestAction.setValue(UIImage(systemName: "checkmark"), forKey: "image")
        }
        
        // Oldest First option
        let oldestAction = UIAlertAction(title: "Oldest First", style: .default) { [weak self] _ in
            self?.applySortOption(.oldest)
        }
        if currentSortOption == .oldest {
            oldestAction.setValue(UIImage(systemName: "checkmark"), forKey: "image")
        }
        
        alert.addAction(newestAction)
        alert.addAction(oldestAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.last
        }
        
        present(alert, animated: true)
    }
    
    private func applySortOption(_ option: SortOption) {
        print("📊 Applying sort: \(option.title)")
        currentSortOption = option
        sortPosts()
        collectionView.reloadData()
        
        // Scroll to top to show the newly sorted posts
        if !posts.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
        
        // Show feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func sortPosts() {
        switch currentSortOption {
        case .newest:
            posts.sort { $0.createdAt > $1.createdAt }
            if isSearching {
                filteredPosts.sort { $0.createdAt > $1.createdAt }
            }
        case .oldest:
            posts.sort { $0.createdAt < $1.createdAt }
            if isSearching {
                filteredPosts.sort { $0.createdAt < $1.createdAt }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshPosts() {
        Task {
            await fetchPosts(refresh: true)
            
            await MainActor.run {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc private func fabButtonTapped() {
        print("\n🟢 FAB BUTTON TAPPED!")
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate button
        UIView.animate(withDuration: 0.1, animations: {
            self.fabButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.fabButton.transform = .identity
            }
        }
        
        // Present create post view
        print("📱 Creating CreatePostViewController...")
        let createPostVC = CreatePostViewController()
        let navController = UINavigationController(rootViewController: createPostVC)
        navController.modalPresentationStyle = .formSheet
        
        print("📱 Presenting CreatePostViewController...")
        present(navController, animated: true) {
            print("✅ CreatePostViewController presented")
        }
    }
    
    @objc private func handlePostCreated(_ notification: Notification) {
        // Refresh feed to show new post
        Task {
            await fetchPosts(refresh: true)
            
            await MainActor.run {
                // Scroll to top to show new post (if sorting by newest)
                if !self.posts.isEmpty && self.currentSortOption == .newest {
                    self.collectionView.scrollToItem(
                        at: IndexPath(item: 0, section: 0),
                        at: .top,
                        animated: true
                    )
                }
            }
        }
    }
    
    @objc private func handlePostDeleted(_ notification: Notification) {
        // Refresh feed
        Task {
            await fetchPosts(refresh: true)
        }
    }
    
    // MARK: - Error Handling
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource

extension CommunityViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredPosts.count : posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommunityPostCell.reuseIdentifier,
            for: indexPath
        ) as? CommunityPostCell else {
            return UICollectionViewCell()
        }
        
        let post = isSearching ? filteredPosts[indexPath.item] : posts[indexPath.item]
        cell.configure(with: post)
        
        return cell
    }
}

// MARK: - UISearchResultsUpdating

extension CommunityViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              !searchText.isEmpty else {
            isSearching = false
            filteredPosts = []
            collectionView.reloadData()
            updateEmptyState()
            return
        }
        
        isSearching = true
        
        // Filter posts by plant name, description, or user name
        filteredPosts = posts.filter { post in
            let plantNameMatch = post.plantName.lowercased().contains(searchText)
            let descriptionMatch = post.description.lowercased().contains(searchText)
            let userNameMatch = post.userName?.lowercased().contains(searchText) ?? false
            
            return plantNameMatch || descriptionMatch || userNameMatch
        }
        
        print("🔍 Search: '\(searchText)' - Found \(filteredPosts.count) results")
        
        collectionView.reloadData()
        updateEmptyState()
    }
}

// MARK: - UISearchControllerDelegate

extension CommunityViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        // When search is dismissed, remove the search bar
        isSearching = false
        filteredPosts = []
        collectionView.reloadData()
        updateEmptyState()
        
        // Remove search bar from navigation after dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigationItem.searchController = nil
        }
    }
}

// MARK: - UICollectionViewDelegate

extension CommunityViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        
        // Show search bar when scrolling up (like Photos app)
        if currentOffset < lastScrollOffset && currentOffset < -50 {
            // Scrolling up - show search bar
            if navigationItem.searchController == nil {
                navigationItem.searchController = searchController
                navigationItem.hidesSearchBarWhenScrolling = false
                definesPresentationContext = true
            }
        } else if currentOffset > 50 && navigationItem.searchController != nil && !searchController.isActive {
            // Scrolling down and search not active - hide search bar completely
            navigationItem.searchController = nil
        }
        
        lastScrollOffset = currentOffset
        
        // Hide FAB when scrolling down, show when scrolling up
        if translation.y < 0 {
            // Scrolling down
            UIView.animate(withDuration: 0.3) {
                self.fabButton.transform = CGAffineTransform(translationX: 0, y: 100)
            }
        } else if translation.y > 0 {
            // Scrolling up
            UIView.animate(withDuration: 0.3) {
                self.fabButton.transform = .identity
            }
        }
        
        // Load more posts when reaching bottom (only when not searching)
        if !isSearching {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height
            
            if offsetY > contentHeight - height - 200 && !isLoading {
                currentPage += 1
                Task {
                    await fetchPosts(refresh: false)
                }
            }
        }
    }
}
