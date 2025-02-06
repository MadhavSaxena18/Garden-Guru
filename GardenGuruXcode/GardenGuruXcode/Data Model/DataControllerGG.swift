import Foundation


    var rootRot : Diseases = Diseases(
        diseaseName: "Root Rot",
        diseaseID: 1,
        diseaseSymptoms: ["Yellowing leaves", "Soft, mushy roots", "Wilting despite watering"],
        diseaseImage: ["rootrot1.jpg", "rootrot2.jpg"],
        diseaseCure: ["Remove affected roots", "Repot with well-draining soil", "Reduce watering"],
        diseaseFertilizers: ["Organic compost", "Neem-based fungicide"],
        cureDuration: 14,
        diseaseSeason: .winter
    )
    
    var powderyMildew : Diseases = Diseases(
        diseaseName: "Powdery Mildew",
        diseaseID: 2,
        diseaseSymptoms: ["White powdery spots on leaves", "Distorted growth", "Leaves turning yellow"],
        diseaseImage: ["powderymildew1.jpg", "powderymildew2.jpg"],
        diseaseCure: ["Apply sulfur-based fungicide", "Increase air circulation", "Remove infected leaves"],
        diseaseFertilizers: ["Compost tea", "Liquid seaweed fertilizer"],
        cureDuration: 10,
        diseaseSeason: .rainy
    )
    
    var leafSpot : Diseases = Diseases(
        diseaseName: "Leaf Spot",
        diseaseID: 3,
        diseaseSymptoms: ["Dark brown or black spots on leaves", "Yellowing of leaves", "Leaves dropping prematurely"],
        diseaseImage: ["leafspot1.jpg", "leafspot2.jpg"],
        diseaseCure: ["Remove infected leaves", "Apply copper-based fungicide", "Ensure proper air circulation"],
        diseaseFertilizers: ["Fish emulsion", "Balanced NPK fertilizer (10-10-10)"],
        cureDuration: 7,
        diseaseSeason: .summer
    )
    
    var blight : Diseases = Diseases(
        diseaseName: "Blight",
        diseaseID: 4,
        diseaseSymptoms: ["Brown, sunken spots on stems and leaves", "Rapid wilting", "Fungal growth on plant surface"],
        diseaseImage: ["blight1.jpg", "blight2.jpg"],
        diseaseCure: ["Use copper fungicide", "Remove infected parts", "Avoid overhead watering"],
        diseaseFertilizers: ["Bone meal", "Slow-release potassium fertilizer"],
        cureDuration: 12,
        diseaseSeason: .winter
    )
    
    var rust : Diseases = Diseases(
        diseaseName: "Rust",
        diseaseID: 5,
        diseaseSymptoms: ["Orange or brown pustules on leaves", "Leaf curling", "Early leaf drop"],
        diseaseImage: ["rust1.jpg", "rust2.jpg"],
        diseaseCure: ["Remove infected leaves", "Apply sulfur-based fungicide", "Keep foliage dry"],
        diseaseFertilizers: ["Nitrogen-rich fertilizer", "Liquid fish fertilizer"],
        cureDuration: 8,
        diseaseSeason: .winter
    )
    
    var dampingOff:Diseases = Diseases(
        diseaseName: "Damping Off",
        diseaseID: 6,
        diseaseSymptoms: ["Seedlings collapsing", "Rotting at soil level", "Poor germination"],
        diseaseImage: ["dampingoff1.jpg", "dampingoff2.jpg"],
        diseaseCure: ["Use sterile soil mix", "Avoid overwatering", "Apply biological fungicides"],
        diseaseFertilizers: ["Weak liquid fertilizer", "Seaweed extract"],
        cureDuration: 5,
        diseaseSeason: .Spring
    )
    
    var grayMold : Diseases = Diseases(
        diseaseName: "Botrytis (Gray Mold)",
        diseaseID: 7,
        diseaseSymptoms: ["Gray fuzzy mold on leaves", "Brown water-soaked spots", "Stems collapsing"],
        diseaseImage: ["botrytis1.jpg", "botrytis2.jpg"],
        diseaseCure: ["Improve air circulation", "Apply neem oil spray", "Remove affected plant parts"],
        diseaseFertilizers: ["Calcium nitrate", "Organic compost"],
        cureDuration: 9,
        diseaseSeason: .summer
    )
    
    var anthracnose : Diseases =  Diseases(
        diseaseName: "Anthracnose",
        diseaseID: 8,
        diseaseSymptoms: ["Dark sunken lesions on stems and leaves", "Defoliation", "Brown streaks on flowers"],
        diseaseImage: ["anthracnose1.jpg", "anthracnose2.jpg"],
        diseaseCure: ["Apply copper-based fungicide", "Prune infected branches", "Ensure good drainage"],
        diseaseFertilizers: ["Phosphorus-rich fertilizer", "Epsom salt spray"],
        cureDuration: 11,
        diseaseSeason: .winter
    )

    var mosaicVirus : Diseases = Diseases(
    diseaseName: "Mosaic Virus",
    diseaseID: 9,
    diseaseSymptoms: ["Yellow-green mottling on leaves", "Stunted growth", "Distorted leaf shapes"],
    diseaseImage: ["mosaicvirus1.jpg", "mosaicvirus2.jpg"],
    diseaseCure: ["Remove infected plants", "Control aphids", "Use disease-resistant varieties"],
    diseaseFertilizers: ["Balanced organic fertilizer", "Liquid potassium supplement"],
    cureDuration: 15,
    diseaseSeason: .winter
)

class DataControllerGG {
    
     
    
      
    let plants: [Plant] = [
        Plant(
            plantName: "Parlor Palm",
            plantNickName: "Indoor Beauty",
            plantImage: ["parlor_palm_1.jpg", "parlor_palm_2.jpg"],
            plantBotanicalName: "Chamaedorea elegans",
            category: .Ornamental,
            plantDescription:
                "A low-maintenance indoor plant known for its lush green fronds. \n Thrives in indirect light and improves air quality.",
            favourableSeason: .winter,
            disease: [mosaicVirus , rust , powderyMildew],
            waterFrequency :90,
            fertilizerFrequency: 7, // Once a week
            repottingFrequency: 30, // Monthly
            pruningFrequency: 365 // Yearly
        ),
        
        Plant(
            plantName: "String Of Pearls",
            plantNickName: "Pearl Vine",
            plantImage: ["string_of_pearls_1.jpg", "string_of_pearls_2.jpg"],
            plantBotanicalName: "Senecio rowleyanus",
            category: .Ornamental,
            plantDescription:
                "A trailing succulent with bead-like leaves, ideal for hanging baskets . \n Requires bright, indirect sunlight and minimal watering.",
            favourableSeason: .summer,
            disease: [mosaicVirus , rust],
            waterFrequency: 14, // Every 2 weeks
            fertilizerFrequency: 60, // Every 2 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120 // Every 4 months
            
        ),
        
        Plant(
            plantName: "Hibiscus",
            plantNickName: "Tropical Bloom",
            plantImage: ["hibiscus_1.jpg", "hibiscus_2.jpg"],
            plantBotanicalName: "Hibiscus rosa-sinensis",
            category: .Flowering,
            plantDescription:
                "A vibrant flowering plant known for its large, colorful blooms . \n Requires full sun and regular watering for optimal growth.",
            favourableSeason: .summer,
            disease: [anthracnose, dampingOff],
            waterFrequency: 3, // Every 3 days
            fertilizerFrequency: 15, // Twice a month
            repottingFrequency: 365, // Yearly
            pruningFrequency: 90  // Every 3 months
        ),
        
        Plant(
            plantName: "Jade Plant",
            plantNickName: "Money Plant",
            plantImage: ["jade_plant_1.jpg", "jade_plant_2.jpg"],
            plantBotanicalName: "Crassula ovata",
            category: .Ornamental,
            plantDescription:
                "A hardy succulent believed to bring good luck and prosperity. Requires minimal watering and bright light.",
            favourableSeason: .winter,
            disease: [leafSpot],
            waterFrequency: 14, // Every 2 weeks
            fertilizerFrequency: 90, // Every 3 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120 // Every 4 months
        ),
        
        Plant(
            plantName: "Peace Lily",
            plantNickName: "Elegant White",
            plantImage: ["peace_lily_1.jpg", "peace_lily_2.jpg"],
            plantBotanicalName: "Spathiphyllum",
            category: .Ornamental,
            plantDescription:
                "A graceful indoor plant with white blooms that purifies the air. Thrives in low to medium light with moderate watering.",
            favourableSeason: .winter,
            disease: [anthracnose, dampingOff],
            waterFrequency: 7, // Weekly
            fertilizerFrequency: 30, // Monthly
            repottingFrequency: 365, // Yearly
            pruningFrequency: 90 // Every 3 months
        ),
        
        Plant(
            plantName: "Tulsi (Holy Basil)",
            plantNickName: "Sacred Herb",
            plantImage: ["tulsi_1.jpg", "tulsi_2.jpg"],
            plantBotanicalName: "Ocimum sanctum",
            category: .Ornamental,
            plantDescription:
                "A sacred plant in Indian households known for its medicinal properties. Requires full sunlight and regular watering."
            ,
            favourableSeason: .summer,
            disease: [anthracnose, dampingOff],
            waterFrequency: 3, // Every 3 days
            fertilizerFrequency: 30, // Monthly
            repottingFrequency: 365, // Yearly
            pruningFrequency: 60 // Every 2 months
        ),
        
        Plant(
            plantName: "Areca Palm",
            plantNickName: "Golden Cane",
            plantImage: ["areca_palm_1.jpg", "areca_palm_2.jpg"],
            plantBotanicalName: "Dypsis lutescens",
            category: .Ornamental,
            plantDescription:
                "A popular indoor palm with feathery fronds that adds a tropical vibe. Prefers bright, indirect light and moderate watering."
            ,
            favourableSeason: .winter,
            disease: [anthracnose, dampingOff],
            waterFrequency: 5, // Every 5 days
            fertilizerFrequency: 60, // Every 2 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120// Every 4 months
        ),
        
        Plant(
            plantName: "Snake Plant",
            plantNickName: "Mother-in-law's Tongue",
            plantImage: ["snake_plant_1.jpg", "snake_plant_2.jpg"],
            plantBotanicalName: "Sansevieria trifasciata",
            category: .Ornamental,
            plantDescription:
                "A hardy, low-maintenance plant known for its air-purifying abilities. Can survive in low light and needs minimal watering."
            ,
            favourableSeason: .winter,
            disease: [anthracnose, dampingOff],
            waterFrequency: 14, // Every 2 weeks
            fertilizerFrequency: 90, // Every 3 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120// Every 4 months
        ),
        
        Plant(
            plantName: "Rose",
            plantNickName: "Queen of Flowers",
            plantImage: ["rose_1.jpg", "rose_2.jpg"],
            plantBotanicalName: "Rosa",
            category: .Flowering,
            plantDescription:
                "A classic flowering plant known for its beauty and fragrance. Requires full sun and regular pruning for healthy blooms."
            ,
            favourableSeason: .winter,
            disease: [anthracnose, dampingOff],
            waterFrequency: 3, // Every 3 days
            fertilizerFrequency: 15, // Twice a month
            repottingFrequency: 365, // Yearly
            pruningFrequency: 30 // Monthly
        ),
        
        Plant(
            plantName: "Aloe Vera",
            plantNickName: "Healing Succulent",
            plantImage: ["aloe_vera_1.jpg", "aloe_vera_2.jpg"],
            plantBotanicalName: "Aloe barbadensis miller",
            category: .medicinal,
            plantDescription:
                "A medicinal plant known for its soothing gel used in skincare. Needs bright light and minimal watering."
            ,
            favourableSeason: .summer,
            disease: [anthracnose, dampingOff],
            waterFrequency: 14, // Every 2 weeks
            fertilizerFrequency: 60, // Every 2 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120 // Every 4 months
        )
    ]
}
