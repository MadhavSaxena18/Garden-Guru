//
//  HeaderSectionCollectionReusableView.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit

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
         
         NSLayoutConstraint.activate([headerLabel.topAnchor.constraint(equalTo: topAnchor),
                                      headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                                      headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                                      //headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                                      
                                      button.topAnchor.constraint(equalTo: topAnchor),
                                      button.bottomAnchor.constraint(equalTo: bottomAnchor),
                                      //button.leadingAnchor.constraint(equalTo: leadingAnchor),
                                      button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -200),
                                     ])
         
     }
}
