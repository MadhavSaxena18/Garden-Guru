//
//  CareReminderCollectionReusableView.swift
//  GardenGuruXcode
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit

class CareReminderCollectionReusableView: UICollectionReusableView {
    var headerLabel = UILabel()
//    var headerCheckBox: UIButton
    
    override init(frame: CGRect){
        super.init(frame: frame)
        updateCareReminderSectionHeader()
    }
    
    required init?(coder: NSCoder){
        super.init(coder: coder)
        updateCareReminderSectionHeader()
    }
    
    
    func updateCareReminderSectionHeader(){
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
      
        addSubview(headerLabel)
      
     
        
        NSLayoutConstraint.activate([headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)])
        
    }

}
