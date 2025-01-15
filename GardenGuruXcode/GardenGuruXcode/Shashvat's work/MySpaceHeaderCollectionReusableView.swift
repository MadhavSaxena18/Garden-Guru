//
//  MySpaceHeaderCollectionReusableView.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class MySpaceHeaderCollectionReusableView: UICollectionReusableView {
    class HeaderSectionCollectionReusableView: UICollectionReusableView {
        var headerLabel = UILabel()
        var button = UIButton(type: .system)
        
        override init(frame: CGRect){
            super.init(frame: frame)
            updateSectionHeader()
        }
        
        required init?(coder: NSCoder){
            super.init(coder: coder)
            updateSectionHeader()
        }
        
        
        func updateSectionHeader(){
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(headerLabel)
            addSubview(button)
            
            NSLayoutConstraint.activate([headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                         headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                                         headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                                         //headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                                         
                                         button.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                         button.bottomAnchor.constraint(equalTo: bottomAnchor),
                                         button.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor , constant: 15),
                                         // button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -200),
                                        ])
            
        }
        
    }
}
