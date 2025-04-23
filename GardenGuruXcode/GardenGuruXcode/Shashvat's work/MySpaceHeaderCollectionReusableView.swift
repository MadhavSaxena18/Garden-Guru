//
//  MySpaceHeaderCollectionReusableView.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

@IBDesignable
class MySpaceHeaderCollectionReusableView: UICollectionReusableView {
    let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let totalPlantLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(headerLabel)
        addSubview(totalPlantLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            totalPlantLabel.bottomAnchor.constraint(equalTo: headerLabel.topAnchor, constant: 13),
            totalPlantLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
    }
}

