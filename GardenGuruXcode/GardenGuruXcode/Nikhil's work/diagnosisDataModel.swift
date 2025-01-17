//
//  diagnosisDataModel.swift
//  GardenGuruXcode
//
//  Created by Nikhil Gupta on 17/01/25.
//

import Foundation

struct DiagnosisDataModel {
    var plantName: String
    var botanicalName: String
    var alsoKnownAs: String
    var nickName: String
    var diagnosis: String
    var sectionDetails: [String: [String]] // Section titles and their content
}

class DiagnosisScreen{
    static var diagnosisData: [DiagnosisDataModel] = [DiagnosisDataModel( plantName: "Parlor Palm",
                                                                         botanicalName: "Chamaedorea elegans",
                                                                         alsoKnownAs: "Good Luck Palm, Neanthe Bella Palm",
                                                                         nickName: "Near Sofa",
                                                                         diagnosis: "UnderWatered",
                                                                         sectionDetails: [
                                                                             "Cure and Treatment": ["Water the plant twice a week.", "Ensure proper drainage."],
                                                                             "Preventive Measures": ["Maintain consistent soil moisture.", "Avoid overwatering."],
                                                                             "Symptoms": ["Brown tips on leaves.", "Dry soil."],
                                                                             "Vitamins Required": ["Nitrogen", "Phosphorus", "Potassium"],
                                                                             "Related Images": ["Image 1 Description", "Image 2 Description"],
                                                                             "Video Solution": ["Video Link 1", "Video Link 2"]
                                                                    ])
                                                     ]
    
}
