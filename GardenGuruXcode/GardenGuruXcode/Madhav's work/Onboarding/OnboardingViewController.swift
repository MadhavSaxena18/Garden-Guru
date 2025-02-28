import UIKit

class OnboardingViewController: UIViewController {
    
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Welcome to Garden Guru",
            description: "Your personal plant care companion that helps you grow and maintain healthy plants.",
            image: "leaf.fill"
        ),
        OnboardingSlide(
            title: "Smart Plant Care",
            description: "Get personalized care reminders for watering, fertilizing, and repotting your plants.",
            image: "bell.badge.fill"
        ),
        OnboardingSlide(
            title: "Disease Detection",
            description: "Identify common plant diseases and get advice on treatment and prevention.",
            image: "magnifyingglass.circle.fill"
        ),
        OnboardingSlide(
            title: "AI Plant Assistant",
            description: "Chat with our AI assistant for instant answers to all your plant care questions.",
            image: "message.and.waveform.fill"
        ),
        OnboardingSlide(
            title: "Explore & Learn",
            description: "Discover new plants and check out their care tips.",
            image: "leaf.arrow.circlepath"
        )
    ]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor(hex: "EBF4EB")
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = UIColor(hex: "284329")
        pc.pageIndicatorTintColor = .systemGray3
        pc.isUserInteractionEnabled = true
        return pc
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(hex: "284329")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        return button
    }()
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                nextButton.setTitle("Get Started", for: .normal)
            } else {
                nextButton.setTitle("Next", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "EBF4EB")
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: "OnboardingCell")
        
        pageControl.numberOfPages = slides.count
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75),
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func nextButtonTapped() {
        if currentPage == slides.count - 1 {
            // Navigate to main app
            let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            mainVC?.modalPresentationStyle = .fullScreen
            present(mainVC!, animated: true)
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        currentPage = sender.currentPage
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
        cell.configure(with: slides[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
} 
