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
                                                                             "Cure and Treatment": ["Here's a step-by-step process to help you revive underwatered Parlor Palm..", "Gently water the plant.", "Water the plant thoroughly until water drains out from the bottom of the pot.", "Prune Yellow , crispy leaves, as they’re unlikely to recover. Trimming helps plant redirect energy to healthy parts", "Encourage users to water the plant consistently, checking the soil’s top inch for moisture before watering again."],
                                                                             "Preventive Measures": ["Maintain consistent soil moisture.", "Avoid overwatering."],
                                                                             "Symptoms": ["Brown tips on leaves.", "Dry soil."],
                                                                             "Vitamins Required": ["Nitrogen", "Phosphorus", "Potassium"],
                                                                             "Related Images": ["Image 1 Description", "Image 2 Description"],
                                                                             "Video Solution": ["https://youtu.be/BS4WRba4KWI?si=xdm_ZEgharndDdpy", "https://youtu.be/MiepVwi_d74?si=74l95b9ajG8mE4zF"]
                                                                    ])
                                                     ]
    
}
