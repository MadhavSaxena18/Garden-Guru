//
//  MySpaceHeaderCollectionReusableView.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class MySpaceHeaderCollectionReusableView: UICollectionReusableView {
   
        var headerLabel = UILabel()
        var totalPlantLabel = UILabel()
        
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
            //totalPlantLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(headerLabel)
            addSubview(totalPlantLabel)
         
            
            NSLayoutConstraint.activate([headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                         headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                                         headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                                        
                                         
            
                                         
                                         totalPlantLabel.bottomAnchor.constraint(equalTo: headerLabel.topAnchor , constant: 13),
                                         totalPlantLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
                                        ])
            
        }

    }

