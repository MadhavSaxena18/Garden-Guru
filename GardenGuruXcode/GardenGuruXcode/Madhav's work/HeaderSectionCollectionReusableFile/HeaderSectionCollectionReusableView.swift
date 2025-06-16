//
//  HeaderSectionCollectionReusableView.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 14/01/25.
//

import UIKit

class HeaderSectionCollectionReusableView: UICollectionReusableView {
    var headerTitle = UILabel()
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
         headerTitle.translatesAutoresizingMaskIntoConstraints = false
         button.translatesAutoresizingMaskIntoConstraints = false
         
         addSubview(headerTitle)
         addSubview(button)
         
         NSLayoutConstraint.activate([headerTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                      headerTitle.bottomAnchor.constraint(equalTo: bottomAnchor),
                                      headerTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                      //headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                                      
                                      button.topAnchor.constraint(equalTo: topAnchor, constant: -2),
                                      button.bottomAnchor.constraint(equalTo: bottomAnchor),
                                      button.leadingAnchor.constraint(equalTo: headerTitle.trailingAnchor , constant: 15),
//                                      button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -200),
                                     ])
         
     }
}
