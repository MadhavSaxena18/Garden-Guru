import Foundation

//
//
//    var rootRot : Diseases = Diseases(
//        diseaseName: "Root Rot",
//        diseaseID: UUID(),
//        diseaseSymptoms: ["Yellowing leaves", "Soft, mushy roots", "Wilting despite watering"],
//        diseaseImage: ["rootrot1.jpg", "rootrot2.jpg"],
//        diseaseCure: ["Remove affected roots", "Repot with well-draining soil", "Reduce watering"],
//        diseaseFertilizers: ["Organic compost", "Neem-based fungicide"],
//        cureDuration: 14,
//        diseaseSeason: .winter
//    )
//
//    var powderyMildew : Diseases = Diseases(
//        diseaseName: "Powdery Mildew",
//        diseaseID: UUID(),
//        diseaseSymptoms: ["White powdery spots on leaves", "Distorted growth", "Leaves turning yellow"],
//        diseaseImage: ["powderymildew1.jpg", "powderymildew2.jpg"],
//        diseaseCure: ["Apply sulfur-based fungicide", "Increase air circulation", "Remove infected leaves"],
//        diseaseFertilizers: ["Compost tea", "Liquid seaweed fertilizer"],
//        cureDuration: 10,
//        diseaseSeason: .rainy
//    )
//
//    var leafSpot : Diseases = Diseases(
//        diseaseName: "Leaf Spot",
//        diseaseID: UUID(),
//        diseaseSymptoms: ["Dark brown or black spots on leaves", "Yellowing of leaves", "Leaves dropping prematurely"],
//        diseaseImage: ["leafspot1.jpg", "leafspot2.jpg"],
//        diseaseCure: ["Remove infected leaves", "Apply copper-based fungicide", "Ensure proper air circulation"],
//        diseaseFertilizers: ["Fish emulsion", "Balanced NPK fertilizer (10-10-10)"],
//        cureDuration: 7,
//        diseaseSeason: .summer
//    )
//
//    var blight : Diseases = Diseases(
//        diseaseName: "Blight",
//        diseaseID: UUID(),
//        diseaseSymptoms: ["Brown, sunken spots on stems and leaves", "Rapid wilting", "Fungal growth on plant surface"],
//        diseaseImage: ["blight1.jpg", "blight2.jpg"],
//        diseaseCure: ["Use copper fungicide", "Remove infected parts", "Avoid overhead watering"],
//        diseaseFertilizers: ["Bone meal", "Slow-release potassium fertilizer"],
//        cureDuration: 12,
//        diseaseSeason: .winter
//    )
//
//    var rust : Diseases = Diseases(
//        diseaseName: "Rust",
//        diseaseID: UUID(),
//        diseaseSymptoms: ["Orange or brown pustules on leaves", "Leaf curling", "Early leaf drop"],
//        diseaseImage: ["rust1.jpg", "rust2.jpg"],
//        diseaseCure: ["Remove infected leaves", "Apply sulfur-based fungicide", "Keep foliage dry"],
//        diseaseFertilizers: ["Nitrogen-rich fertilizer", "Liquid fish fertilizer"],
//        cureDuration: 8,
//        diseaseSeason: .winter
//    )
//
//    var dampingOff:Diseases = Diseases(
//        diseaseName: "Damping Off",
//        diseaseID: UUID(),
//        diseaseSymptoms: ["Seedlings collapsing", "Rotting at soil level", "Poor germination"],
//        diseaseImage: ["dampingoff1.jpg", "dampingoff2.jpg"],
//        diseaseCure: ["Use sterile soil mix", "Avoid overwatering", "Apply biological fungicides"],
//        diseaseFertilizers: ["Weak liquid fertilizer", "Seaweed extract"],
//        cureDuration: 5,
//        diseaseSeason: .Spring
//    )
//
//    var grayMold : Diseases = Diseases(
//        diseaseName: "Botrytis (Gray Mold)",
//        diseaseID: UUID(),
//        diseaseSymptoms: ["Gray fuzzy mold on leaves", "Brown water-soaked spots", "Stems collapsing"],
//        diseaseImage: ["botrytis1.jpg", "botrytis2.jpg"],
//        diseaseCure: ["Improve air circulation", "Apply neem oil spray", "Remove affected plant parts"],
//        diseaseFertilizers: ["Calcium nitrate", "Organic compost"],
//        cureDuration: 9,
//        diseaseSeason: .summer
//    )
//
//    var anthracnose : Diseases =  Diseases(
//        diseaseName: "Anthracnose",
//        diseaseID: UUID(),
//        diseaseSymptoms: ["Dark sunken lesions on stems and leaves", "Defoliation", "Brown streaks on flowers"],
//        diseaseImage: ["anthracnose1.jpg", "anthracnose2.jpg"],
//        diseaseCure: ["Apply copper-based fungicide", "Prune infected branches", "Ensure good drainage"],
//        diseaseFertilizers: ["Phosphorus-rich fertilizer", "Epsom salt spray"],
//        cureDuration: 11,
//        diseaseSeason: .winter
//    )
//
//    var mosaicVirus : Diseases = Diseases(
//        diseaseName: "Mosaic Virus",
//        diseaseID: UUID(),
//        diseaseSymptoms: ["Yellow-green mottling on leaves", "Stunted growth", "Distorted leaf shapes"],
//        diseaseImage: ["mosaicvirus1.jpg", "mosaicvirus2.jpg"],
//        diseaseCure: ["Remove infected plants", "Control aphids", "Use disease-resistant varieties"],
//        diseaseFertilizers: ["Balanced organic fertilizer", "Liquid potassium supplement"],
//        cureDuration: 15,
//        diseaseSeason: .winter
//    )
//
//    // PLANT DATA
//
//    var parlorPalm : Plant =  Plant(
//        plantName: "Parlor Palm",
//        plantImage: ["parlor_palm_1.jpg", "parlor_palm_2.jpg"],
//        plantBotanicalName: "Chamaedorea elegans",
//        category: .Ornamental,
//        plantDescription:
//            "A low-maintenance indoor plant known for its lush green fronds. \n Thrives in indirect light and improves air quality.",
//        favourableSeason: .winter,
//        waterFrequency :90,
//        fertilizerFrequency: 7, // Once a week
//        repottingFrequency: 30, // Monthly
//        pruningFrequency: 365 // Yearly
//    )
//
//    var stringOfPearls : Plant = Plant(
//        plantName: "String Of Pearls",
//        plantImage: ["string_of_pearls_1.jpg", "string_of_pearls_2.jpg"],
//        plantBotanicalName: "Senecio rowleyanus",
//        category: .Ornamental,
//        plantDescription:
//            "A trailing succulent with bead-like leaves, ideal for hanging baskets . \n Requires bright, indirect sunlight and minimal watering.",
//        favourableSeason: .summer,
//        waterFrequency: 14, // Every 2 weeks
//        fertilizerFrequency: 60, // Every 2 months
//        repottingFrequency: 730, // Every 2 years
//        pruningFrequency: 120 // Every 4 months
//
//    )
//
//    var hibiscus : Plant = Plant(
//        plantName: "Hibiscus",
//        plantImage: ["hibiscus_1.jpg", "hibiscus_2.jpg"],
//        plantBotanicalName: "Hibiscus rosa-sinensis",
//        category: .Flowering,
//        plantDescription:
//            "A vibrant flowering plant known for its large, colorful blooms . \n Requires full sun and regular watering for optimal growth.",
//        favourableSeason: .summer,
//        waterFrequency: 3, // Every 3 days
//        fertilizerFrequency: 15, // Twice a month
//        repottingFrequency: 365, // Yearly
//        pruningFrequency: 90  // Every 3 months
//    )
//
//    var jadePlant : Plant = Plant(
//        plantName: "Jade Plant",
//        plantImage: ["jade_plant_1.jpg", "jade_plant_2.jpg"],
//        plantBotanicalName: "Crassula ovata",
//        category: .Ornamental,
//        plantDescription:
//            "A hardy succulent believed to bring good luck and prosperity. Requires minimal watering and bright light.",
//        favourableSeason: .winter,
//        waterFrequency: 14, // Every 2 weeks
//        fertilizerFrequency: 90, // Every 3 months
//        repottingFrequency: 730, // Every 2 years
//        pruningFrequency: 120 // Every 4 months
//    )
//
//    var peaceLily : Plant = Plant(
//        plantName: "Peace Lily",
//        plantImage: ["peace_lily_1.jpg", "peace_lily_2.jpg"],
//        plantBotanicalName: "Spathiphyllum",
//        category: .Ornamental,
//        plantDescription:
//            "A graceful indoor plant with white blooms that purifies the air. Thrives in low to medium light with moderate watering.",
//        favourableSeason: .winter,
//        waterFrequency: 7, // Weekly
//        fertilizerFrequency: 30, // Monthly
//        repottingFrequency: 365, // Yearly
//        pruningFrequency: 90 // Every 3 months
//    )
//
//    var arecaPalm : Plant = Plant(
//        plantName: "Areca Palm",
//        plantImage: ["areca_palm_1.jpg", "areca_palm_2.jpg"],
//        plantBotanicalName: "Dypsis lutescens",
//        category: .Ornamental,
//        plantDescription:
//            "A popular indoor palm with feathery fronds that adds a tropical vibe. Prefers bright, indirect light and moderate watering."
//        ,
//        favourableSeason: .winter,
//        waterFrequency: 5, // Every 5 days
//        fertilizerFrequency: 60, // Every 2 months
//        repottingFrequency: 730, // Every 2 years
//        pruningFrequency: 120// Every 4 months
//    )
//
//
//
//    //Plant Disease
//
//    var parlorPalmRust : PlantDisease = PlantDisease(
//        plantDiseaseID: UUID(),
//        plantID: parlorPalm.plantID,
//        diseaseID: rust.diseaseID
//    )
//
//    var arecaPalmAnthracnose : PlantDisease = PlantDisease(
//    plantDiseaseID: UUID(),
//    plantID: arecaPalm.plantID,
//    diseaseID: anthracnose.diseaseID
//    )

class DataControllerGG {

       private var plants: [Plant] = []
       private var diseases: [Diseases] = []
       private var plantDiseases: [PlantDisease] = []
       private var user : [userInfo] = []
       private var userPlant : [UserPlant] = []
       let currentDate = Date()
       private var userPlantDisease : [UsersPlantDisease] = []
       private var careReminders : [CareReminder_] = []
       private var reminderOfUserPlant : [CareReminderOfUserPlant] = []

//    private var plants: [Plant] = []
//    private var diseases: [Diseases] = []
//    private var plantDiseases: [PlantDisease] = []
//    private var user : [userInfo] = []
//    private var userPlant : [UserPlant] = []
//    let currentDate = Date()
//    private var userPlantDisease : [UsersPlantDisease] = []

    
    init() {
        
        
        var John : userInfo = userInfo(
            userName: "John",
            location: "Greater Noida",
            reminderAllowed: true)
        
        user.append(John)
        
       
        
        var parlorPalm : Plant =  Plant(
            plantName: "Parlor Palm",
            plantImage: ["parlor_palm_1.jpg", "parlor_palm_2.jpg"],
            plantBotanicalName: "Chamaedorea elegans",
            category: .Ornamental,
            plantDescription:
                "A low-maintenance indoor plant known for its lush green fronds. \n Thrives in indirect light and improves air quality.",
            favourableSeason: .winter,
            waterFrequency :90,
            fertilizerFrequency: 7, // Once a week
            repottingFrequency: 30, // Monthly
            pruningFrequency: 365 // Yearly
        )
        
        var stringOfPearls : Plant = Plant(
            plantName: "String Of Pearls",
            plantImage: ["string_of_pearls_1.jpg", "string_of_pearls_2.jpg"],
            plantBotanicalName: "Senecio rowleyanus",
            category: .Ornamental,
            plantDescription:
                "A trailing succulent with bead-like leaves, ideal for hanging baskets . \n Requires bright, indirect sunlight and minimal watering.",
            favourableSeason: .summer,
            waterFrequency: 14, // Every 2 weeks
            fertilizerFrequency: 60, // Every 2 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120 // Every 4 months
            
        )
        
        var hibiscus : Plant = Plant(
            plantName: "Hibiscus",
            plantImage: ["hibiscus_1.jpg", "hibiscus_2.jpg"],
            plantBotanicalName: "Hibiscus rosa-sinensis",
            category: .Flowering,
            plantDescription:
                "A vibrant flowering plant known for its large, colorful blooms . \n Requires full sun and regular watering for optimal growth.",
            favourableSeason: .summer,
            waterFrequency: 3, // Every 3 days
            fertilizerFrequency: 15, // Twice a month
            repottingFrequency: 365, // Yearly
            pruningFrequency: 90  // Every 3 months
        )
        
        var jadePlant : Plant = Plant(
            plantName: "Jade Plant",
            plantImage: ["jade_plant_1.jpg", "jade_plant_2.jpg"],
            plantBotanicalName: "Crassula ovata",
            category: .Ornamental,
            plantDescription:
                "A hardy succulent believed to bring good luck and prosperity. Requires minimal watering and bright light.",
            favourableSeason: .winter,
            waterFrequency: 14, // Every 2 weeks
            fertilizerFrequency: 90, // Every 3 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120 // Every 4 months
        )
        
        var peaceLily : Plant = Plant(
            plantName: "Peace Lily",
            plantImage: ["peace_lily_1.jpg", "peace_lily_2.jpg"],
            plantBotanicalName: "Spathiphyllum",
            category: .Ornamental,
            plantDescription:
                "A graceful indoor plant with white blooms that purifies the air. Thrives in low to medium light with moderate watering.",
            favourableSeason: .winter,
            waterFrequency: 7, // Weekly
            fertilizerFrequency: 30, // Monthly
            repottingFrequency: 365, // Yearly
            pruningFrequency: 90 // Every 3 months
        )
        
        var arecaPalm : Plant = Plant(
            plantName: "Areca Palm",
            plantImage: ["areca_palm_1.jpg", "areca_palm_2.jpg"],
            plantBotanicalName: "Dypsis lutescens",
            category: .Ornamental,
            plantDescription:
                "A popular indoor palm with feathery fronds that adds a tropical vibe. Prefers bright, indirect light and moderate watering."
            ,
            favourableSeason: .winter,
            waterFrequency: 5, // Every 5 days
            fertilizerFrequency: 60, // Every 2 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120// Every 4 months
        )
        var rose: Plant = Plant(
                    plantName: "Rose",
                    plantImage: ["rose plant"],
                    plantBotanicalName: "Rosa spp.",
                    category: .Ornamental,
                    plantDescription: "A classic choice for any home. Thrives in full sun and well-draining soil.",
                    favourableSeason: .winter,
                    waterFrequency: 7,
                    fertilizerFrequency: 30,
                    repottingFrequency: 365,
                    pruningFrequency: 90
                )
        
        plants.append(contentsOf: [parlorPalm, stringOfPearls ,hibiscus  ,jadePlant , peaceLily , arecaPalm , rose])
        
        
        //Diseases data
        var rootRot : Diseases = Diseases(
            diseaseName: "Root Rot",
            diseaseID: UUID(),
            diseaseSymptoms: ["Yellowing leaves", "Soft, mushy roots", "Wilting despite watering"],
            diseaseImage: ["rootrot1.jpg", "rootrot2.jpg"],
            diseaseCure: ["Remove affected roots", "Repot with well-draining soil", "Reduce watering"],
            diseaseFertilizers: ["Organic compost", "Neem-based fungicide"],
            cureDuration: 14,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Remove the plant from the pot and inspect the roots.",
                    "Trim off mushy, blackened roots with sterilized scissors.",
                    "Repot the plant in fresh, well-draining soil.",
                    "Reduce watering and ensure proper drainage."
                ],
                "Preventive Measures": [
                    "Use well-draining soil and pots with drainage holes.",
                    "Avoid overwatering; let the soil dry slightly between waterings.",
                    "Ensure good air circulation around the plant."
                ],
                "Symptoms": [
                    "Yellowing leaves and wilting.",
                    "Soft, brown, or black roots.",
                    "Foul smell from the soil."
                ],
                "Vitamins Required": ["Calcium", "Magnesium"],
                "Related Images": ["Root Rot affected plant 1", "Root Rot affected plant 2"],
                "Video Solution": ["https://youtu.be/example3", "https://youtu.be/example4"]
            ], diseaseSeason: .winter
        )
        
        var powderyMildew : Diseases = Diseases(
            diseaseName: "Powdery Mildew",
            diseaseID: UUID(),
            diseaseSymptoms: ["White powdery spots on leaves", "Distorted growth", "Leaves turning yellow"],
            diseaseImage: ["powderymildew1.jpg", "powderymildew2.jpg"],
            diseaseCure: ["Apply sulfur-based fungicide", "Increase air circulation", "Remove infected leaves"],
            diseaseFertilizers: ["Compost tea", "Liquid seaweed fertilizer"],
            cureDuration: 10,
            diseaseDetail:  [
                "Cure and Treatment": [
                    "Spray affected leaves with a mix of water and baking soda.",
                    "Use sulfur-based or neem oil fungicides.",
                    "Increase sunlight exposure to affected plants."
                ],
                "Preventive Measures": [
                    "Avoid excessive nitrogen fertilization.",
                    "Improve air circulation and reduce humidity.",
                    "Water at the base to keep foliage dry."
                ],
                "Symptoms": [
                    "White, powdery fungal growth on leaves and stems.",
                    "Leaves may curl or become distorted.",
                    "Reduced plant vigor and growth."
                ],
                "Vitamins Required": ["Sulfur", "Calcium"],
                "Related Images": ["Powdery Mildew affected leaf 1", "Powdery Mildew affected leaf 2"],
                "Video Solution": ["https://youtu.be/example17", "https://youtu.be/example18"]
            ],
            diseaseSeason: .rainy
        )
        
        var leafSpot : Diseases = Diseases(
            diseaseName: "Leaf Spot",
            diseaseID: UUID(),
            diseaseSymptoms: ["Dark brown or black spots on leaves", "Yellowing of leaves", "Leaves dropping prematurely"],
            diseaseImage: ["leafspot1.jpg", "leafspot2.jpg"],
            diseaseCure: ["Remove infected leaves", "Apply copper-based fungicide", "Ensure proper air circulation"],
            diseaseFertilizers: ["Fish emulsion", "Balanced NPK fertilizer (10-10-10)"],
            cureDuration: 7,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Remove affected leaves to prevent spread.",
                    "Use a copper or neem oil-based fungicide.",
                    "Avoid wetting foliage when watering."
                ],
                "Preventive Measures": [
                    "Ensure good air circulation.",
                    "Use disease-resistant plant varieties.",
                    "Water plants early in the day so leaves dry quickly."
                ],
                "Symptoms": [
                    "Small brown, black, or yellow spots on leaves.",
                    "Spots may enlarge and merge over time.",
                    "Leaf drop in severe cases."
                ],
                "Vitamins Required": ["Boron", "Manganese"],
                "Related Images": ["Leaf Spot affected leaf 1", "Leaf Spot affected leaf 2"],
                "Video Solution": ["https://youtu.be/example15", "https://youtu.be/example16"]
            ], diseaseSeason: .summer
        )
        
        var blight : Diseases = Diseases(
            diseaseName: "Blight",
            diseaseID: UUID(),
            diseaseSymptoms: ["Brown, sunken spots on stems and leaves", "Rapid wilting", "Fungal growth on plant surface"],
            diseaseImage: ["blight1.jpg", "blight2.jpg"],
            diseaseCure: ["Use copper fungicide", "Remove infected parts", "Avoid overhead watering"],
            diseaseFertilizers: ["Bone meal", "Slow-release potassium fertilizer"],
            cureDuration: 12,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Remove and discard infected plant parts.",
                    "Apply copper-based fungicides.",
                    "Improve ventilation to reduce humidity."
                ],
                "Preventive Measures": [
                    "Rotate crops to prevent pathogen buildup.",
                    "Avoid overhead watering.",
                    "Sanitize tools and plant debris."
                ],
                "Symptoms": [
                    "Dark, rapidly spreading leaf spots.",
                    "Wilting and plant collapse.",
                    "Fungal spores visible on stems and leaves."
                ],
                "Vitamins Required": ["Magnesium", "Potassium"],
                "Related Images": ["Blight affected plant 1", "Blight affected plant 2"],
                "Video Solution": ["https://youtu.be/example13", "https://youtu.be/example14"]
            ], diseaseSeason: .winter
        )
        
        var rust : Diseases = Diseases(
            diseaseName: "Rust",
            diseaseID: UUID(),
            diseaseSymptoms: ["Orange or brown pustules on leaves", "Leaf curling", "Early leaf drop"],
            diseaseImage: ["rust1.jpg", "rust2.jpg"],
            diseaseCure: ["Remove infected leaves", "Apply sulfur-based fungicide", "Keep foliage dry"],
            diseaseFertilizers: ["Nitrogen-rich fertilizer", "Liquid fish fertilizer"],
            cureDuration: 8,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Remove affected leaves immediately.",
                    "Apply a sulfur-based fungicide.",
                    "Improve air circulation to reduce moisture buildup."
                ],
                "Preventive Measures": [
                    "Avoid overhead watering to keep leaves dry.",
                    "Space plants properly to allow airflow.",
                    "Use rust-resistant plant varieties."
                ],
                "Symptoms": [
                    "Orange or reddish-brown spots on leaves.",
                    "Leaves may curl and fall off prematurely.",
                    "Powdery spores may rub off on fingers."
                ],
                "Vitamins Required": ["Iron", "Zinc"],
                "Related Images": ["Rust affected leaf 1", "Rust affected leaf 2"],
                "Video Solution": ["https://youtu.be/example11", "https://youtu.be/example12"]
            ], diseaseSeason: .winter
        )
        
        var dampingOff:Diseases = Diseases(
            diseaseName: "Damping Off",
            diseaseID: UUID(),
            diseaseSymptoms: ["Seedlings collapsing", "Rotting at soil level", "Poor germination"],
            diseaseImage: ["dampingoff1.jpg", "dampingoff2.jpg"],
            diseaseCure: ["Use sterile soil mix", "Avoid overwatering", "Apply biological fungicides"],
            diseaseFertilizers: ["Weak liquid fertilizer", "Seaweed extract"],
            cureDuration: 5,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Remove and destroy infected seedlings.",
                    "Use a fungicide on affected soil.",
                    "Ensure good drainage and avoid waterlogging."
                ],
                "Preventive Measures": [
                    "Use sterile soil and containers.",
                    "Avoid overwatering and keep seedlings well-ventilated.",
                    "Plant seeds at the right depth to encourage strong roots."
                ],
                "Symptoms": [
                    "Seedlings collapse and wither.",
                    "Dark, water-soaked stem bases.",
                    "Mold growth on soil surface."
                ],
                "Vitamins Required": ["Calcium", "Potassium"],
                "Related Images": ["Damping Off affected seedling 1", "Damping Off affected seedling 2"],
                "Video Solution": ["https://youtu.be/example9", "https://youtu.be/example10"]
            ], diseaseSeason: .Spring
        )
        
        var grayMold : Diseases = Diseases(
            diseaseName: "Botrytis (Gray Mold)",
            diseaseID: UUID(),
            diseaseSymptoms: ["Gray fuzzy mold on leaves", "Brown water-soaked spots", "Stems collapsing"],
            diseaseImage: ["botrytis1.jpg", "botrytis2.jpg"],
            diseaseCure: ["Improve air circulation", "Apply neem oil spray", "Remove affected plant parts"],
            diseaseFertilizers: ["Calcium nitrate", "Organic compost"],
            cureDuration: 9,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Remove and discard affected plant parts.",
                    "Improve air circulation and avoid high humidity.",
                    "Apply fungicides like copper-based sprays."
                ],
                "Preventive Measures": [
                    "Water plants at the base to avoid wet leaves.",
                    "Avoid overcrowding to ensure proper airflow.",
                    "Use resistant plant varieties if available."
                ],
                "Symptoms": [
                    "Gray, fuzzy mold on leaves, stems, and flowers.",
                    "Rapid decay of affected plant parts.",
                    "Soft, mushy spots on stems and leaves."
                ],
                "Vitamins Required": ["Silicon", "Calcium"],
                "Related Images": ["Gray Mold affected plant 1", "Gray Mold affected plant 2"],
                "Video Solution": ["https://youtu.be/example7", "https://youtu.be/example8"]
            ], diseaseSeason: .summer
        )
        
        var anthracnose : Diseases =  Diseases(
            diseaseName: "Anthracnose",
            diseaseID: UUID(),
            diseaseSymptoms: ["Dark sunken lesions on stems and leaves", "Defoliation", "Brown streaks on flowers"],
            diseaseImage: ["anthracnose1.jpg", "anthracnose2.jpg"],
            diseaseCure: ["Apply copper-based fungicide", "Prune infected branches", "Ensure good drainage"],
            diseaseFertilizers: ["Phosphorus-rich fertilizer", "Epsom salt spray"],
            cureDuration: 11,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Remove and destroy infected leaves and branches.",
                    "Apply a copper-based fungicide to prevent further spread.",
                    "Improve air circulation around the plant."
                ],
                "Preventive Measures": [
                    "Avoid overhead watering to keep leaves dry.",
                    "Ensure good air circulation around plants.",
                    "Sanitize gardening tools to prevent the spread."
                ],
                "Symptoms": [
                    "Brown or black lesions on leaves and stems.",
                    "Sunken, water-soaked spots on fruits and stems.",
                    "Premature leaf drop."
                ],
                "Vitamins Required": ["Potassium", "Phosphorus"],
                "Related Images": ["Anthracnose affected leaf 1", "Anthracnose affected leaf 2"],
                "Video Solution": ["https://youtu.be/example5", "https://youtu.be/example6"]
            ], diseaseSeason: .winter
        )
        
        var mosaicVirus : Diseases = Diseases(
            diseaseName: "Mosaic Virus",
            diseaseID: UUID(),
            diseaseSymptoms: ["Yellow-green mottling on leaves", "Stunted growth", "Distorted leaf shapes"],
            diseaseImage: ["mosaicvirus1.jpg", "mosaicvirus2.jpg"],
            diseaseCure: ["Remove infected plants", "Control aphids", "Use disease-resistant varieties"],
            diseaseFertilizers: ["Balanced organic fertilizer", "Liquid potassium supplement"],
            cureDuration: 15,
            diseaseDetail: [
                "Cure and Treatment": [
                    "There is no cure for Mosaic Virus; infected plants should be removed to prevent spread.",
                    "Isolate affected plants immediately.",
                    "Sterilize pruning tools to prevent contamination.",
                    "Control pests like aphids, which spread the virus.",
                    "Choose resistant plant varieties if available."
                ],
                "Preventive Measures": [
                    "Use virus-free seeds or plants.",
                    "Control insect vectors like aphids and leafhoppers.",
                    "Avoid handling infected plants and then touching healthy ones."
                ],
                "Symptoms": [
                    "Irregular mottling and discoloration of leaves.",
                    "Distorted or stunted leaf growth.",
                    "Reduced plant vigor and yield."
                ],
                "Vitamins Required": ["None (since it's a viral infection)."],
                "Related Images": ["Mosaic Virus affected leaf 1", "Mosaic Virus affected leaf 2"],
                "Video Solution": ["https://youtu.be/example1", "https://youtu.be/example2"]
            ], diseaseSeason: .winter
        )
        
        diseases.append(contentsOf: [mosaicVirus, rootRot ,anthracnose ,grayMold ,dampingOff ,rust ,blight ,leafSpot , powderyMildew ])
        
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: rootRot.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: rust.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: grayMold.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: blight.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: grayMold.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: peaceLily.plantID, diseaseID: rootRot.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: peaceLily.plantID, diseaseID: blight.diseaseID))
        
        var john1Plant : UserPlant = UserPlant(
            userId: John.userId,
            userplantID: parlorPalm.plantID,
            userPlantNickName: "Near Sofa",
            lastWatered: currentDate,
            lastFertilized: currentDate,
            lastRepotted: currentDate,
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        var john2Plant : UserPlant = UserPlant(
            userId: John.userId,
            userplantID: peaceLily.plantID,
            userPlantNickName: "In Garden",
            lastWatered: currentDate,
            lastFertilized: currentDate,
            lastRepotted: currentDate,
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        // Add the user plants to the array
        userPlant.append(john1Plant)
        userPlant.append(john2Plant)
        
        userPlantDisease.append(UsersPlantDisease(usersPlantDisease: UUID(), usersPlantRelationID: john1Plant.userId, diseaseID: rootRot.diseaseID))
        userPlantDisease.append(UsersPlantDisease(usersPlantDisease: UUID(), usersPlantRelationID: john1Plant.userId, diseaseID: rust.diseaseID))
        userPlantDisease.append(UsersPlantDisease(usersPlantDisease: UUID(), usersPlantRelationID: john2Plant.userId, diseaseID: rust.diseaseID))
        
//        var reminderofUserPlant1 : CareReminder_ = CareReminder_(upcomingReminderForWater: currentDate, upcomingReminderForFertilizers: Calendar.current.date(byAdding: .day, value: 4, to: currentDate)!, upcomingReminderForRepotted:  Calendar.current.date(byAdding: .day, value: 120, to: currentDate)! , isCompleted: true)
//        
//        var reminderOfUserPlant2 : CareReminder_ = CareReminder_(upcomingReminderForWater: currentDate, upcomingReminderForFertilizers: Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!, upcomingReminderForRepotted:  Calendar.current.date(byAdding: .day, value: 100, to: currentDate)!, isCompleted: true)
//        
//        careReminders.append(contentsOf: [reminderofUserPlant1 , reminderOfUserPlant2])
        
//        var userPlantReminder : CareReminderOfUserPlant = CareReminderOfUserPlant(careReminderID: UUID(), userPlantRelationID: john1Plant.userPlantRelationID)
        
        
        
    }

        func getPlant(by plantID: UUID) -> Plant? {
            return plants.first { $0.plantID == plantID }
        }
    
        func getDiseases(for plantID: UUID) -> [Diseases] {
            let diseaseIDs = plantDiseases
                .filter { $0.plantID == plantID }
                .map { $0.diseaseID }
            
            return diseases.filter { diseaseIDs.contains($0.diseaseID) }
        }
    
        func getPlantbyName (by name : String) -> Plant? {
        return plants.first(where: {$0.plantName == name})
    }
    
    
        func getTopWinterPlants() -> [Plant] {
            return plants.filter { $0.favourableSeason == .winter }
        }

        func getCommonIssues() -> [Diseases] {
            return diseases.filter { $0.diseaseSeason == .winter } // Filtering common winter issues
        }

//    func getPlant(by plantID: UUID) -> Plant? {
//        return plants.first { $0.plantID == plantID }
//    }
//    
//    func getDiseases(for plantID: UUID) -> [Diseases] {
//        let diseaseIDs = plantDiseases
//            .filter { $0.plantID == plantID }
//            .map { $0.diseaseID }
//        
//        return diseases.filter { diseaseIDs.contains($0.diseaseID) }
//    }
//    func getTopWinterPlants() -> [Plant] {
//        return plants.filter { $0.favourableSeason == .winter }
//    }
//    
//    func getCommonIssues() -> [Diseases] {
//        return diseases.filter { $0.diseaseSeason == .winter } // Filtering common winter issues
//    }
    
    func getCommonIssuesForRose() -> [Diseases] {
        guard let rosePlant = plants.first(where: { $0.plantName == "Rose" }) else { return [] }
        print("hellllllllllllllllloooooooooo")
        print(getDiseases(for: rosePlant.plantID))
        return getDiseases(for: rosePlant.plantID)
    }
    
    func getDiseasesForUserPlants(userId: UUID) -> [Diseases] {
            // Get all plants belonging to the user
            let userPlants = userPlant.filter { $0.userId == userId }
            
            // Get all diseases for these plants
            var allDiseases: [Diseases] = []
            for userPlant in userPlants {
                let plantDiseases = getDiseases(for: userPlant.userplantID)
                allDiseases.append(contentsOf: plantDiseases)
            }
            
            // Remove duplicates by using diseaseID instead of Set
            return Array(Dictionary(grouping: allDiseases) { $0.diseaseID }.values.map { $0[0] })
        }
        
        // Replace the existing getCommonIssuesForRose function with this:
    func getCommonIssuesForUserPlants() -> [Diseases] {
            // For now, we'll use the first user's plants
            // In a real app, you'd pass the current user's ID
            if let firstUser = user.first {
                return getDiseasesForUserPlants(userId: firstUser.userId)
            }
            return []
        }
    
    func getCommonFertilizersForParlorPalm() -> [String] {
        return ["Organic Compost", "Liquid Fertilizer", "Seaweed Extract"] // Custom fertilizers for Parlour Palm
    }
    
    // Get user's plants with their care reminders
    func getCareReminders(for userId: UUID) -> [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] {
        let userPlants = userPlant.filter { $0.userId == userId }
        var reminders: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []

        
        for userPlant in userPlants {
            if let plant = getPlant(by: userPlant.userplantID) {
                // Calculate next reminder dates based on frequencies
                let nextWateringDate = userPlant.lastWatered.addingTimeInterval(TimeInterval(plant.waterFrequency * 24 * 60 * 60))
                let nextFertilizingDate = userPlant.lastFertilized.addingTimeInterval(TimeInterval(plant.fertilizerFrequency * 24 * 60 * 60))
                let nextRepottingDate = userPlant.lastRepotted.addingTimeInterval(TimeInterval(plant.repottingFrequency * 24 * 60 * 60))
                
                let waterReminder = CareReminder_(
                    upcomingReminderForWater: nextWateringDate,
                    upcomingReminderForFertilizers: nextFertilizingDate,
                    upcomingReminderForRepotted: nextRepottingDate,
                    isWateringCompleted: userPlant.isWateringCompleted,
                    isFertilizingCompleted: userPlant.isFertilizingCompleted,
                    isRepottingCompleted: userPlant.isRepottingCompleted
                )
                reminders.append((userPlant: userPlant, plant: plant, reminder: waterReminder))
            }
        }
        return reminders
    }
    
    // Update care reminder completion status
    func updateCareReminderStatus(for userPlantId: UUID, reminderType: String, isCompleted: Bool, currentDate: Date) {
        if let index = userPlant.firstIndex(where: { $0.userPlantRelationID == userPlantId }) {
            switch reminderType {
            case "Watering":
                userPlant[index].isWateringCompleted = isCompleted
                if isCompleted {
                    userPlant[index].lastWatered = currentDate
                }
            case "Fertilization":
                userPlant[index].isFertilizingCompleted = isCompleted
                if isCompleted {
                    userPlant[index].lastFertilized = currentDate
                }
            case "Pruning":
                userPlant[index].isRepottingCompleted = isCompleted
                if isCompleted {
                    userPlant[index].lastRepotted = currentDate
                }
            default:
                break
            }
        }

    func getUserPlants(for userId: UUID) -> [UserPlant] {
            return userPlant.filter { $0.userId == userId }
        }
        
        
    func getCareReminder(for userPlant: UserPlant) -> CareReminder_? {
            return careReminders.first { _ in true } 
        }
        

    }
    
    // Add this function to get users (moved outside of updateCareReminderStatus)
    func getUsers() -> [userInfo] {
        return user
    }
    

}
    //if let parlourPalm = dataController.plants.first(where: { $0.plantName == "Parlour Palm" }) {
    //    let diseasesForParlourPalm = dataController.getDiseases(for: parlourPalm.plantID)
    //    print("Diseases for \(parlourPalm.plantName): \(diseasesForParlourPalm.map { $0.diseaseName })")
    //}
    
    
    
    
    
    
    //    let plants: [Plant] = [
    //        Plant(
    //            plantName: "Parlor Palm",
    //            plantNickName: "Indoor Beauty",
    //            plantImage: ["parlor_palm_1.jpg", "parlor_palm_2.jpg"],
    //            plantBotanicalName: "Chamaedorea elegans",
    //            category: .Ornamental,
    //            plantDescription:
    //                "A low-maintenance indoor plant known for its lush green fronds. \n Thrives in indirect light and improves air quality.",
    //            favourableSeason: .winter,
    //            disease: [mosaicVirus , rust , powderyMildew],
    //            waterFrequency :90,
    //            fertilizerFrequency: 7, // Once a week
    //            repottingFrequency: 30, // Monthly
    //            pruningFrequency: 365 // Yearly
    //        ),
    //
    //        Plant(
    //            plantName: "String Of Pearls",
    //            plantNickName: "Pearl Vine",
    //            plantImage: ["string_of_pearls_1.jpg", "string_of_pearls_2.jpg"],
    //            plantBotanicalName: "Senecio rowleyanus",
    //            category: .Ornamental,
    //            plantDescription:
    //                "A trailing succulent with bead-like leaves, ideal for hanging baskets . \n Requires bright, indirect sunlight and minimal watering.",
    //            favourableSeason: .summer,
    //            disease: [mosaicVirus , rust],
    //            waterFrequency: 14, // Every 2 weeks
    //            fertilizerFrequency: 60, // Every 2 months
    //            repottingFrequency: 730, // Every 2 years
    //            pruningFrequency: 120 // Every 4 months
    //
    //        ),
    //
    //        Plant(
    //            plantName: "Hibiscus",
    //            plantNickName: "Tropical Bloom",
    //            plantImage: ["hibiscus_1.jpg", "hibiscus_2.jpg"],
    //            plantBotanicalName: "Hibiscus rosa-sinensis",
    //            category: .Flowering,
    //            plantDescription:
    //                "A vibrant flowering plant known for its large, colorful blooms . \n Requires full sun and regular watering for optimal growth.",
    //            favourableSeason: .summer,
    //            disease: [anthracnose, dampingOff],
    //            waterFrequency: 3, // Every 3 days
    //            fertilizerFrequency: 15, // Twice a month
    //            repottingFrequency: 365, // Yearly
    //            pruningFrequency: 90  // Every 3 months
    //        ),
    //
    //        Plant(
    //            plantName: "Jade Plant",
    //            plantNickName: "Money Plant",
    //            plantImage: ["jade_plant_1.jpg", "jade_plant_2.jpg"],
    //            plantBotanicalName: "Crassula ovata",
    //            category: .Ornamental,
    //            plantDescription:
    //                "A hardy succulent believed to bring good luck and prosperity. Requires minimal watering and bright light.",
    //            favourableSeason: .winter,
    //            disease: [leafSpot],
    //            waterFrequency: 14, // Every 2 weeks
    //            fertilizerFrequency: 90, // Every 3 months
    //            repottingFrequency: 730, // Every 2 years
    //            pruningFrequency: 120 // Every 4 months
    //        ),
    //
    //        Plant(
    //            plantName: "Peace Lily",
    //            plantNickName: "Elegant White",
    //            plantImage: ["peace_lily_1.jpg", "peace_lily_2.jpg"],
    //            plantBotanicalName: "Spathiphyllum",
    //            category: .Ornamental,
    //            plantDescription:
    //                "A graceful indoor plant with white blooms that purifies the air. Thrives in low to medium light with moderate watering.",
    //            favourableSeason: .winter,
    //            disease: [anthracnose, dampingOff],
    //            waterFrequency: 7, // Weekly
    //            fertilizerFrequency: 30, // Monthly
    //            repottingFrequency: 365, // Yearly
    //            pruningFrequency: 90 // Every 3 months
    //        ),
    //
    //        Plant(
    //            plantName: "Tulsi (Holy Basil)",
    //            plantNickName: "Sacred Herb",
    //            plantImage: ["tulsi_1.jpg", "tulsi_2.jpg"],
    //            plantBotanicalName: "Ocimum sanctum",
    //            category: .Ornamental,
    //            plantDescription:
    //                "A sacred plant in Indian households known for its medicinal properties. Requires full sunlight and regular watering."
    //            ,
    //            favourableSeason: .summer,
    //            disease: [anthracnose, dampingOff],
    //            waterFrequency: 3, // Every 3 days
    //            fertilizerFrequency: 30, // Monthly
    //            repottingFrequency: 365, // Yearly
    //            pruningFrequency: 60 // Every 2 months
    //        ),
    //
    //        Plant(
    //            plantName: "Areca Palm",
    //            plantNickName: "Golden Cane",
    //            plantImage: ["areca_palm_1.jpg", "areca_palm_2.jpg"],
    //            plantBotanicalName: "Dypsis lutescens",
    //            category: .Ornamental,
    //            plantDescription:
    //                "A popular indoor palm with feathery fronds that adds a tropical vibe. Prefers bright, indirect light and moderate watering."
    //            ,
    //            favourableSeason: .winter,
    //            disease: [anthracnose, dampingOff],
    //            waterFrequency: 5, // Every 5 days
    //            fertilizerFrequency: 60, // Every 2 months
    //            repottingFrequency: 730, // Every 2 years
    //            pruningFrequency: 120// Every 4 months
    //        ),
    //
    //        Plant(
    //            plantName: "Snake Plant",
    //            plantNickName: "Mother-in-law's Tongue",
    //            plantImage: ["snake_plant_1.jpg", "snake_plant_2.jpg"],
    //            plantBotanicalName: "Sansevieria trifasciata",
    //            category: .Ornamental,
    //            plantDescription:
    //                "A hardy, low-maintenance plant known for its air-purifying abilities. Can survive in low light and needs minimal watering."
    //            ,
    //            favourableSeason: .winter,
    //            disease: [anthracnose, dampingOff],
    //            waterFrequency: 14, // Every 2 weeks
    //            fertilizerFrequency: 90, // Every 3 months
    //            repottingFrequency: 730, // Every 2 years
    //            pruningFrequency: 120// Every 4 months
    //        ),
    //
    //        Plant(
    //            plantName: "Rose",
    //            plantNickName: "Queen of Flowers",
    //            plantImage: ["rose_1.jpg", "rose_2.jpg"],
    //            plantBotanicalName: "Rosa",
    //            category: .Flowering,
    //            plantDescription:
    //                "A classic flowering plant known for its beauty and fragrance. Requires full sun and regular pruning for healthy blooms."
    //            ,
    //            favourableSeason: .winter,
    //            disease: [anthracnose, dampingOff],
    //            waterFrequency: 3, // Every 3 days
    //            fertilizerFrequency: 15, // Twice a month
    //            repottingFrequency: 365, // Yearly
    //            pruningFrequency: 30 // Monthly
    //        ),
    //
    //        Plant(
    //            plantName: "Aloe Vera",
    //            plantNickName: "Healing Succulent",
    //            plantImage: ["aloe_vera_1.jpg", "aloe_vera_2.jpg"],
    //            plantBotanicalName: "Aloe barbadensis miller",
    //            category: .medicinal,
    //            plantDescription:
    //                "A medicinal plant known for its soothing gel used in skincare. Needs bright light and minimal watering."
    //            ,
    //            favourableSeason: .summer,
    //            disease: [anthracnose, dampingOff],
    //            waterFrequency: 14, // Every 2 weeks
    //            fertilizerFrequency: 60, // Every 2 months
    //            repottingFrequency: 730, // Every 2 years
    //            pruningFrequency: 120 // Every 4 months
    //        )
    //    ]
    //}

