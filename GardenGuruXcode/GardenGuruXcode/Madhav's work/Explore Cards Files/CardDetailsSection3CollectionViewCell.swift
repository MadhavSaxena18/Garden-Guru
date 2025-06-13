import UIKit
import SDWebImage

protocol CardDetailsSection3CollectionViewCellDelegate: AnyObject {
    func didTapImage(at index: Int, images: [UIImage])
}

class CardDetailsSection3CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImageSection3: UIImageView?
    private var collectionView: UICollectionView!
    private var images: [UIImage] = []
        
        weak var delegate: CardDetailsSection3CollectionViewCellDelegate?
        
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
            // Try to get the second image URL, fall back to the first if not available
            if let imageURLString = plant.imageURLs[safe: 1] ?? plant.imageURLs[safe: 0], // Get second image, or first as fallback
               let url = URL(string: imageURLString.replacingOccurrences(of: "//01", with: "/01").replacingOccurrences(of: "//", with: "/").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                // Use SDWebImage to fetch the image from URL
                SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { [weak self] image, _, error, _, _, _ in
                    if let error = error {
                        print("❌ Error loading plant image for Section 3: \(error.localizedDescription)")
                        self?.images = []
                    } else if let image = image {
                        self?.images = [image]
                    } else {
                        self?.images = []
                    }
                    self?.reloadCollectionView()
                }
            } else {
                print("❌ No valid image URL found for plant in Section 3: \(plant.plantName)")
                self.images = []
                self.reloadCollectionView()
            }
        }
        
        func updateWithDiseaseInfo(_ disease: Diseases) {
            if let imageString = disease.diseaseImage?.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespacesAndNewlines),
               let url = URL(string: imageString), !imageString.isEmpty {
                // Use SDWebImage to fetch the image from URL
                SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { [weak self] image, _, error, _, _, _ in
                    if let image = image {
                        self?.images = [image]
                    } else {
                        self?.images = []
                    }
                    self?.reloadCollectionView()
                }
            } else {
                self.images = []
                self.reloadCollectionView()
            }
        }
        
        private func reloadCollectionView() {
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
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            delegate?.didTapImage(at: indexPath.item, images: self.images)
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
