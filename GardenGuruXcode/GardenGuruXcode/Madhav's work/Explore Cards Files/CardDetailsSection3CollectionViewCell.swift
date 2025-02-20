import UIKit

class CardDetailsSection3CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImageSection3: UIImageView?
    private var collectionView: UICollectionView!
    private var images: [UIImage] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        // Create a flow layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: contentView.frame.width * 0.8, height: contentView.frame.height)
        
        // Create collection view
        collectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        
        // Add to content view
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func updateWithPlantInfo(_ plant: Plant) {
        // Convert string array to UIImage array
        let plantImages = plant.plantImage.compactMap { UIImage(named: $0) }
        self.images = plantImages
        
        // Ensure we're on the main thread when reloading
        if Thread.isMainThread {
            self.collectionView?.reloadData()
        } else {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    func updateWithDiseaseInfo(_ disease: Diseases) {
        // Convert string array to UIImage array
        let diseaseImages = disease.diseaseImage.compactMap { UIImage(named: $0) }
        self.images = diseaseImages
        
        // Ensure we're on the main thread when reloading
        if Thread.isMainThread {
            self.collectionView?.reloadData()
        } else {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension CardDetailsSection3CollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
}

// MARK: - Image Cell
class ImageCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
