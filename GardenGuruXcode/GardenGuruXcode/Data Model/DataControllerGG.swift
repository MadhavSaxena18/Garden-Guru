import Foundation

class DataControllerGG {
    
    
    //    private var plants: [Plant] = []
    //    private var diseases: [Diseases] = []
    //    private var plantDiseases: [PlantDisease] = []
    //    private var user : [userInfo] = []
    //    private var userPlant : [UserPlant] = []
    //    let currentDate = Date()
    //    private var userPlantDisease : [UsersPlantDisease] = []
    
    
    
    private var plants: [Plant] = []
    private var diseases: [Diseases] = []
    private var plantDiseases: [PlantDisease] = []
    private var user : [userInfo] = []
    private var userPlant : [UserPlant] = []
    let currentDate = Date()
    private var userPlantDisease : [UsersPlantDisease] = []
    private var careReminders : [CareReminder_] = []
    private var reminderOfUserPlant : [CareReminderOfUserPlant] = []
    private var fertilizer : [Fertilizer] = []
    private var diseaseFertilizer : [DiseaseFertilizer] = []
    
    //    private var plants: [Plant] = []
    //    private var diseases: [Diseases] = []
    //    private var plantDiseases: [PlantDisease] = []
    //    private var user : [userInfo] = []
    //    private var userPlant : [UserPlant] = []
    //    let currentDate = Date()
    //    private var userPlantDisease : [UsersPlantDisease] = []
    
    
    
    init() {
        
        
        let John : userInfo = userInfo(
            userName: "John",
            location: "Greater Noida",
            reminderAllowed: true)
        
        user.append(John)
        
        
        
        let parlorPalm : Plant =  Plant(
            plantName: "Parlor-Palm",
            plantImage: ["parlor_palm_1.jpg", "parlor_palm_2.jpg"],
            plantBotanicalName: "Chamaedorea elegans",
            category: .Ornamental,
            plantDescription:
                "A low-maintenance indoor plant known for its lush green fronds. \n Thrives in indirect light and improves air quality.",
            favourableSeason: .winter,
            waterFrequency :3, // Twice in a week
            fertilizerFrequency: 7, // Once a week
            repottingFrequency: 30, // Monthly
            pruningFrequency: 365 // Yearly
        )
        
        let tulip : Plant = Plant(
            plantName: "Tulip",
            plantImage: ["Tulip1.jpg", "Tulip2.jpg"],
            plantBotanicalName: "Senecio rowleyanus",
            category: .Ornamental,
            plantDescription:
                "Tulips are one of the most iconic and beloved flowering plants, known for their vibrant colors and elegant, cup-shaped blooms. They grow from bulbs and produce long, slender green leaves with a smooth texture.",
            favourableSeason: .summer,
            waterFrequency: 4, // Every 2 weeks
            fertilizerFrequency: 60, // Every 2 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120 // Every 4 months
            
        )
        
        let hibiscus : Plant = Plant(
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
        
        let aloeVera : Plant = Plant(
            plantName: "Aloe Vera",
            plantImage: ["AloeVera1.jpg", "AloeVera2.jpg"],
            plantBotanicalName: "Crassula ovata",
            category: .Ornamental,
            plantDescription:
                "Aloe vera is a hardy, evergreen succulent known for its thick, fleshy, green leaves filled with a soothing gel. The leaves have serrated edges with small, soft spines. This plant stores water in its leaves, making it highly drought-resistant.",
            favourableSeason: .winter,
            waterFrequency: 14, // Every 2 weeks
            fertilizerFrequency: 90, // Every 3 months
            repottingFrequency: 730, // Every 2 years
            pruningFrequency: 120 // Every 4 months
        )
        
        let rainLily : Plant = Plant(
            plantName: "Rain Lily",
            plantImage: ["RainLily1.jpg", "RainLily2.jpg"],
            plantBotanicalName: "Spathiphyllum",
            category: .Ornamental,
            plantDescription:
                "Rain lilies are delicate, perennial flowering plants that bloom after rainfall, hence their name. They produce star-shaped or trumpet-like flowers in shades of pink, yellow, or white. The grass-like, slender green leaves add to their elegant appearance. ",
            favourableSeason: .winter,
            waterFrequency: 7, // Weekly
            fertilizerFrequency: 30, // Monthly
            repottingFrequency: 365, // Yearly
            pruningFrequency: 90 // Every 3 months
        )
        
        let arecaPalm : Plant = Plant(
            plantName: "Areca Palm (Dypsis lutescens)",
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
            plantName: "Mawar-Rose",
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
        
        
        
        let sunflower: Plant = Plant(
            plantName: "sunflower",
            plantImage: ["sunflower1.jpg" , "sunflower2.jpg"], //nam abhi change krna hai
            plantBotanicalName: "Helianthus annuus",
            category: .Ornamental,
            plantDescription: "Bright and cheerful flowers that follow the sun. Prefers full sun and well-draining soil.",
            favourableSeason: .summer,
            waterFrequency: 5,
            fertilizerFrequency: 20,
            repottingFrequency: 365,
            pruningFrequency: 60
        )
        
        let bellflower: Plant = Plant(
            plantName: "bellflower",
            plantImage: ["bellflower plant"],//name change
            plantBotanicalName: "Campanula spp.",
            category: .Ornamental,
            plantDescription: "Delicate, bell-shaped flowers that add charm to any garden. Grows well in partial sun.",
            favourableSeason: .summer,
            waterFrequency: 6,
            fertilizerFrequency: 25,
            repottingFrequency: 365,
            pruningFrequency: 75
        )
        
        let orchid: Plant = Plant(
            plantName: "Orchidaceae - Orchid",
            plantImage: ["orchidplant1.jpg" , "orchidplant2.jpg"],//name change
            plantBotanicalName: "Orchidaceae",
            category: .Ornamental,
            plantDescription: "Elegant and exotic flowers that thrive in indirect light with high humidity.",
            favourableSeason: .winter,
            waterFrequency: 7,
            fertilizerFrequency: 15,
            repottingFrequency: 730,
            pruningFrequency: 90
        )
        
        let snakePlant: Plant = Plant(
            plantName: "Snake plant (Sanseviera)",
            plantImage: ["snakeplant1.jpg" , "snakeplant2.jpg"],//name change
            plantBotanicalName: "Sansevieria trifasciata",
            category: .Ornamental,
            plantDescription: "A hardy, air-purifying plant that thrives in low light and requires minimal care.",
            favourableSeason: .summer,
            waterFrequency: 14,
            fertilizerFrequency: 60,
            repottingFrequency: 730,
            pruningFrequency: 180
        )
        
        let daisy: Plant = Plant(
            plantName: "daisy",
            plantImage: ["daisy1.jpg" , "daisy2.jpg"],//name change
            plantBotanicalName: "Bellis perennis",
            category: .Ornamental,
            plantDescription: "Cheerful flowers that bloom throughout the year, thriving in full sun and well-drained soil.",
            favourableSeason: .winter,
            waterFrequency: 5,
            fertilizerFrequency: 30,
            repottingFrequency: 365,
            pruningFrequency: 60
        )
        
        
        
        plants.append(contentsOf: [parlorPalm, tulip ,hibiscus  ,aloeVera , rainLily , arecaPalm , rose , sunflower , bellflower , daisy , snakePlant , orchid])
        
        
        //Diseases data
        let rootRot : Diseases = Diseases(
            diseaseName: "Black Rot",
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
        
        let powderyMildew : Diseases = Diseases(
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
        
        let leafSpot : Diseases = Diseases(
            diseaseName: "Leaf spot",
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
        
        let blight : Diseases = Diseases(
            diseaseName: "Rachis Blight",
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
        
        let rust : Diseases = Diseases(
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
        
        let dampingOff:Diseases = Diseases(
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
        
        let grayMold : Diseases = Diseases(
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
        
        let anthracnose : Diseases =  Diseases(
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
        
        let mosaicVirus : Diseases = Diseases(
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
        
        let potassiumDeficiency: Diseases = Diseases(
            diseaseName: "1.⁠ ⁠Potassium Deficiency",
            diseaseID: UUID(),
            diseaseSymptoms: ["Yellowing leaf edges", "Brown scorching on leaf tips", "Weak stems and slow growth"],
            diseaseImage: ["potassium_deficiency1.jpg", "potassium_deficiency2.jpg"],
            diseaseCure: ["Apply potassium-rich fertilizers", "Use compost containing banana peels", "Ensure proper watering to aid nutrient absorption"],
            diseaseFertilizers: ["Potassium sulfate", "Wood ash", "Kelp meal"],
            cureDuration: 10,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Apply potassium-rich fertilizers like potassium sulfate or muriate of potash.",
                    "Use organic compost such as banana peels or wood ash.",
                    "Avoid overwatering, which can leach potassium from the soil."
                ],
                "Preventive Measures": [
                    "Maintain balanced soil nutrients.",
                    "Test soil regularly to ensure potassium levels remain adequate.",
                    "Avoid excessive nitrogen fertilization, which can interfere with potassium uptake."
                ],
                "Symptoms": [
                    "Yellowing of leaf edges and tips.",
                    "Curling and browning of older leaves.",
                    "Reduced resistance to drought and diseases."
                ],
                "Vitamins Required": ["Potassium (K)"],
                "Related Images": ["Potassium deficiency affected leaf 1", "Potassium deficiency affected leaf 2"],
                "Video Solution": ["https://youtu.be/example3", "https://youtu.be/example4"]
            ], diseaseSeason: .summer
        )

        let manganeseDeficiency: Diseases = Diseases(
            diseaseName: "2.⁠ ⁠Manganese Deficiency",
            diseaseID: UUID(),
            diseaseSymptoms: ["Interveinal chlorosis on young leaves", "Stunted growth", "Leaf curling"],
            diseaseImage: ["manganese_deficiency1.jpg", "manganese_deficiency2.jpg"],
            diseaseCure: ["Apply manganese sulfate", "Use chelated manganese foliar spray", "Improve soil pH to 5.5-6.5"],
            diseaseFertilizers: ["Manganese sulfate", "Chelated manganese spray"],
            cureDuration: 12,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Spray manganese sulfate or chelated manganese on leaves.",
                    "Adjust soil pH to 5.5-6.5 to improve manganese availability.",
                    "Avoid over-application of phosphorus fertilizers, which can inhibit manganese uptake."
                ],
                "Preventive Measures": [
                    "Use balanced fertilizers with trace minerals.",
                    "Regularly test soil to maintain optimal manganese levels.",
                    "Ensure proper soil aeration to enhance root absorption."
                ],
                "Symptoms": [
                    "Yellowing between leaf veins.",
                    "Young leaves show paling and curling.",
                    "Reduced plant growth and weaker stems."
                ],
                "Vitamins Required": ["Manganese (Mn)"],
                "Related Images": ["Manganese deficiency affected leaf 1", "Manganese deficiency affected leaf 2"],
                "Video Solution": ["https://youtu.be/example5", "https://youtu.be/example6"]
            ], diseaseSeason: .summer
        )

        let magnesiumDeficiency: Diseases = Diseases(
            diseaseName: "3.⁠ ⁠Magnesium Deficiency",
            diseaseID: UUID(),
            diseaseSymptoms: ["Interveinal chlorosis on older leaves", "Purple or reddish discoloration", "Leaf curling"],
            diseaseImage: ["magnesium_deficiency1.jpg", "magnesium_deficiency2.jpg"],
            diseaseCure: ["Apply Epsom salt (magnesium sulfate)", "Use dolomitic lime to enrich soil", "Maintain soil pH above 6.0"],
            diseaseFertilizers: ["Magnesium sulfate (Epsom salt)", "Dolomitic lime"],
            cureDuration: 10,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Dissolve Epsom salt in water and spray it on the leaves.",
                    "Apply dolomitic lime to soil for long-term magnesium improvement.",
                    "Maintain soil pH at 6.0-6.5 for better magnesium availability."
                ],
                "Preventive Measures": [
                    "Use balanced fertilizers that include magnesium.",
                    "Avoid excessive potassium application, which competes with magnesium.",
                    "Regular soil testing for nutrient balance."
                ],
                "Symptoms": [
                    "Yellowing between veins in older leaves.",
                    "Leaves develop purple or reddish hues.",
                    "Weak plant growth and curling leaves."
                ],
                "Vitamins Required": ["Magnesium (Mg)"],
                "Related Images": ["Magnesium deficiency affected leaf 1", "Magnesium deficiency affected leaf 2"],
                "Video Solution": ["https://youtu.be/example7", "https://youtu.be/example8"]
            ], diseaseSeason: .rainy
        )

        let blackScorch: Diseases = Diseases(
            diseaseName: "4.⁠ ⁠Black Scorch",
            diseaseID: UUID(),
            diseaseSymptoms: ["Black necrotic patches on leaves", "Stem cracking", "Dieback of plant parts"],
            diseaseImage: ["black_scorch1.jpg", "black_scorch2.jpg"],
            diseaseCure: ["Prune infected parts", "Use copper-based fungicide", "Ensure proper ventilation"],
            diseaseFertilizers: ["Balanced NPK fertilizer", "Organic compost"],
            cureDuration: 20,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Prune and destroy infected plant parts.",
                    "Apply copper-based fungicides.",
                    "Ensure proper plant spacing for better air circulation."
                ],
                "Preventive Measures": [
                    "Avoid overhead watering to reduce moisture buildup.",
                    "Sterilize tools before pruning.",
                    "Use resistant plant varieties where available."
                ],
                "Symptoms": [
                    "Dark, necrotic lesions on leaves.",
                    "Cracking and dieback of stems.",
                    "Weak plant structure and stunted growth."
                ],
                "Vitamins Required": ["None (fungal disease)."],
                "Related Images": ["Black Scorch affected leaf 1", "Black Scorch affected leaf 2"],
                "Video Solution": ["https://youtu.be/example9", "https://youtu.be/example10"]
            ], diseaseSeason: .summer
        )

        let leafSpots: Diseases = Diseases(
            diseaseName: "5.⁠ ⁠Leaf Spots",
            diseaseID: UUID(),
            diseaseSymptoms: ["Circular brown spots on leaves", "Yellow halos around spots", "Premature leaf drop"],
            diseaseImage: ["leaf_spots1.jpg", "leaf_spots2.jpg"],
            diseaseCure: ["Apply neem oil spray", "Use copper-based fungicides", "Remove affected leaves"],
            diseaseFertilizers: ["Compost tea", "Nitrogen-rich fertilizers"],
            cureDuration: 14,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Spray neem oil or copper fungicide.",
                    "Remove and dispose of infected leaves.",
                    "Avoid excessive watering to prevent fungal spread."
                ],
                "Preventive Measures": [
                    "Ensure good air circulation around plants.",
                    "Water plants at the base rather than overhead.",
                    "Maintain healthy soil with organic matter."
                ],
                "Symptoms": [
                    "Spots on leaves with yellow margins.",
                    "Leaves may turn brown and fall off prematurely.",
                    "Stunted plant growth in severe cases."
                ],
                "Vitamins Required": ["None (fungal disease)."],
                "Related Images": ["Leaf Spots affected leaf 1", "Leaf Spots affected leaf 2"],
                "Video Solution": ["https://youtu.be/example11", "https://youtu.be/example12"]
            ], diseaseSeason: .summer
        )
        
        let fusariumWilt: Diseases = Diseases(
            diseaseName: "6.⁠ ⁠Fusarium Wilt",
            diseaseID: UUID(),
            diseaseSymptoms: ["Yellowing and wilting of lower leaves", "Vascular browning in stems", "Stunted growth and plant death"],
            diseaseImage: ["fusarium_wilt1.jpg", "fusarium_wilt2.jpg"],
            diseaseCure: ["Remove and destroy infected plants", "Use disease-resistant plant varieties", "Apply biofungicides"],
            diseaseFertilizers: ["Compost-enriched soil", "Phosphorus-rich fertilizers"],
            cureDuration: 25,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Remove and destroy infected plants to prevent further spread.",
                    "Use disease-resistant plant varieties whenever possible.",
                    "Apply biofungicides containing Trichoderma to suppress Fusarium spores.",
                    "Improve soil drainage and avoid overwatering."
                ],
                "Preventive Measures": [
                    "Rotate crops regularly to prevent soil-borne infections.",
                    "Maintain well-drained soil with organic compost.",
                    "Sterilize gardening tools and pots before use."
                ],
                "Symptoms": [
                    "Gradual yellowing and wilting of leaves, starting from the bottom.",
                    "Darkening of the vascular tissues inside the stem.",
                    "Plant stunting and eventual death."
                ],
                "Vitamins Required": ["None (fungal disease)."],
                "Related Images": ["Fusarium Wilt affected plant 1", "Fusarium Wilt affected plant 2"],
                "Video Solution": ["https://youtu.be/example13", "https://youtu.be/example14"]
            ], diseaseSeason: .summer
        )

        let parlatoriaBlanchard: Diseases = Diseases(
            diseaseName: "8.⁠ ⁠Parlatoria Blanchardi",
            diseaseID: UUID(),
            diseaseSymptoms: ["Tiny yellow spots on leaves", "Sticky honeydew secretion", "Weak and stunted plant growth"],
            diseaseImage: ["parlatoria_blanchard1.jpg", "parlatoria_blanchard2.jpg"],
            diseaseCure: ["Apply neem oil or insecticidal soap", "Introduce natural predators like ladybugs", "Prune heavily infested branches"],
            diseaseFertilizers: ["Balanced NPK fertilizer", "Compost-based organic fertilizers"],
            cureDuration: 15,
            diseaseDetail: [
                "Cure and Treatment": [
                    "Spray neem oil or insecticidal soap to control scale insects.",
                    "Encourage beneficial insects like ladybugs that feed on scales.",
                    "Prune and discard heavily infested plant parts."
                ],
                "Preventive Measures": [
                    "Inspect new plants before introducing them to the garden.",
                    "Avoid excessive nitrogen fertilizers, which attract pests.",
                    "Regularly clean plant leaves to remove early signs of infestation."
                ],
                "Symptoms": [
                    "Tiny yellow or white spots on leaves.",
                    "Sticky honeydew secretion, leading to sooty mold.",
                    "Leaves and stems become weak and stunted."
                ],
                "Vitamins Required": ["None (pest infestation)."],
                "Related Images": ["Parlatoria Blanchard affected plant 1", "Parlatoria Blanchard affected plant 2"],
                "Video Solution": ["https://youtu.be/example15", "https://youtu.be/example16"]
            ], diseaseSeason: .winter
        )


        
        diseases.append(contentsOf: [mosaicVirus, rootRot ,anthracnose ,grayMold ,dampingOff ,rust ,blight ,leafSpot , powderyMildew , potassiumDeficiency , manganeseDeficiency , magnesiumDeficiency , blackScorch , leafSpot , fusariumWilt , parlatoriaBlanchard])
        
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: rootRot.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: rust.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: grayMold.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: blight.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: parlorPalm.plantID, diseaseID: grayMold.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: rainLily.plantID, diseaseID: rootRot.diseaseID))
        plantDiseases.append(PlantDisease(plantDiseaseID: UUID(), plantID: rainLily.plantID, diseaseID: blight.diseaseID))
        
        let john1Plant : UserPlant = UserPlant(
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
        
        let john2Plant : UserPlant = UserPlant(
            userId: John.userId,
            userplantID: rainLily.plantID,
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
        
        
        var reminderofUserPlant1 : CareReminder_ = CareReminder_(
            upcomingReminderForWater: currentDate,
            upcomingReminderForFertilizers: Calendar.current.date(byAdding: .day, value: 4, to: currentDate)!,
            upcomingReminderForRepotted: Calendar.current.date(byAdding: .day, value: 120, to: currentDate)!,
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        var reminderOfUserPlant2 : CareReminder_ = CareReminder_(
            upcomingReminderForWater: currentDate,
            upcomingReminderForFertilizers: Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!,
            upcomingReminderForRepotted: Calendar.current.date(byAdding: .day, value: 100, to: currentDate)!,
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        
        careReminders.append(contentsOf: [reminderofUserPlant1, reminderOfUserPlant2])
        
        //        var reminderofUserPlant1 : CareReminder_ = CareReminder_(upcomingReminderForWater: currentDate, upcomingReminderForFertilizers: Calendar.current.date(byAdding: .day, value: 4, to: currentDate)!, upcomingReminderForRepotted:  Calendar.current.date(byAdding: .day, value: 120, to: currentDate)! , isCompleted: true)
        //
        //        var reminderOfUserPlant2 : CareReminder_ = CareReminder_(upcomingReminderForWater: currentDate, upcomingReminderForFertilizers: Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!, upcomingReminderForRepotted:  Calendar.current.date(byAdding: .day, value: 100, to: currentDate)!, isCompleted: true)
        //
        //        careReminders.append(contentsOf: [reminderofUserPlant1 , reminderOfUserPlant2])
        
        
        //        var userPlantReminder : CareReminderOfUserPlant = CareReminderOfUserPlant(careReminderID: UUID(), userPlantRelationID: john1Plant.userPlantRelationID)
      

        // Creating 5 fertilizer objects
        let npk = Fertilizer(
            fertilizerName: "NPK 20-20-20",
            fertilizerImage: "https://your-supabase-url/storage/v1/object/public/fertilizers/npk_20_20_20.jpg",
            fertilizerDescription: "Balanced fertilizer for overall plant growth."
        )

        let urea = Fertilizer(
            fertilizerName: "Urea",
            fertilizerImage: "https://your-supabase-url/storage/v1/object/public/fertilizers/urea.jpg",
            fertilizerDescription: "High nitrogen fertilizer for leafy plant growth."
        )

        let boneMeal = Fertilizer(
            fertilizerName: "Bone Meal",
            fertilizerImage: "https://your-supabase-url/storage/v1/object/public/fertilizers/bone_meal.jpg",
            fertilizerDescription: "Organic phosphorus-rich fertilizer for root development."
        )

        let vermicompost = Fertilizer(
            fertilizerName: "Vermicompost",
            fertilizerImage: "https://your-supabase-url/storage/v1/object/public/fertilizers/vermicompost.jpg",
            fertilizerDescription: "Organic compost that improves soil health and fertility."
        )

        let potash = Fertilizer(
            fertilizerName: "Potash",
            fertilizerImage: "https://your-supabase-url/storage/v1/object/public/fertilizers/potash.jpg",
            fertilizerDescription: "Essential for flower and fruit development in plants."
        )
        
        fertilizer.append(contentsOf : [npk , urea , boneMeal , vermicompost , potash])
        
        diseaseFertilizer.append(DiseaseFertilizer(diseaseID: blight.diseaseID, fertilizerId: potash.fertilizerId))
        diseaseFertilizer.append(DiseaseFertilizer(diseaseID: rust.diseaseID, fertilizerId: vermicompost.fertilizerId))
        diseaseFertilizer.append(DiseaseFertilizer(diseaseID: rootRot.diseaseID, fertilizerId: boneMeal.fertilizerId))
        diseaseFertilizer.append(DiseaseFertilizer(diseaseID: grayMold.diseaseID, fertilizerId: urea.fertilizerId))
        diseaseFertilizer.append(DiseaseFertilizer(diseaseID: rust.diseaseID, fertilizerId: npk.fertilizerId))
        diseaseFertilizer.append(DiseaseFertilizer(diseaseID: blight.diseaseID, fertilizerId: urea.fertilizerId))
        diseaseFertilizer.append(DiseaseFertilizer(diseaseID: rootRot.diseaseID, fertilizerId: vermicompost.fertilizerId))
        diseaseFertilizer.append(DiseaseFertilizer(diseaseID: rust.diseaseID, fertilizerId: potash.fertilizerId))
        
        
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
    func getTopSeasonPlants() -> [Plant] {
        return plants.filter { $0.favourableSeason == .winter }
    }
    
    func getCommonIssues() -> [Diseases] {
        return diseases.filter { $0.diseaseSeason == .winter } // Filtering common winter issues
    }
    
    func getPlantbyName (by name : String) -> Plant? {
        return plants.first(where: {$0.plantName == name})
    }
//    
//    
//    func getCommonIssuesForRose() -> [Diseases] {
//        guard let rosePlant = plants.first(where: { $0.plantName == "Rose" }) else { return [] }
//        print("hellllllllllllllllloooooooooo")
//        print(getDiseases(for: rosePlant.plantID))
//        return getDiseases(for: rosePlant.plantID)
//    }
    
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
    func getCareReminders(for userId: UUID) -> [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] {
        
        // 1. Get only the user plants that exist in userPlant array
        let userPlants = userPlant.filter { $0.userId == userId }
        var reminders: [(userPlant: UserPlant, plant: Plant, reminder: CareReminder_)] = []
        
        for userPlant in userPlants {
            // 2. Verify the plant exists
            if let plant = getPlant(by: userPlant.userplantID) {
                // 3. Check if there's a valid reminder relationship
                if let relationIndex = reminderOfUserPlant.firstIndex(where: { $0.userPlantRelationID == userPlant.userPlantRelationID }) {
                    // 4. Find the existing reminder
                    if let existingReminder = careReminders.first(where: { reminder in
                        reminder.upcomingReminderForWater == userPlant.lastWatered &&
                        reminder.upcomingReminderForFertilizers == userPlant.lastFertilized &&
                        reminder.upcomingReminderForRepotted == userPlant.lastRepotted
                    }) {
                        reminders.append((userPlant: userPlant, plant: plant, reminder: existingReminder))
                    }
                } else {
                    // 5. Create new reminder only if needed
                    let waterReminder = CareReminder_(
                        upcomingReminderForWater: userPlant.lastWatered.addingTimeInterval(TimeInterval(plant.waterFrequency * 24 * 60 * 60)),
                        upcomingReminderForFertilizers: userPlant.lastFertilized.addingTimeInterval(TimeInterval(plant.fertilizerFrequency * 24 * 60 * 60)),
                        upcomingReminderForRepotted: userPlant.lastRepotted.addingTimeInterval(TimeInterval(plant.repottingFrequency * 24 * 60 * 60)),
                        isWateringCompleted: userPlant.isWateringCompleted,
                        isFertilizingCompleted: userPlant.isFertilizingCompleted,
                        isRepottingCompleted: userPlant.isRepottingCompleted
                    )
                    reminders.append((userPlant: userPlant, plant: plant, reminder: waterReminder))
                }
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
        
    }
    
    // Add this function to get users (moved outside of updateCareReminderStatus)
    func getUsers() -> [userInfo] {
        return user
    }
    
    
    func getUserPlants(for userId: UUID) -> [UserPlant] {
        return userPlant.filter { $0.userId == userId }
    }
    
    
    func getCareReminder(for userPlant: UserPlant) -> CareReminder_? {
        return careReminders.first { _ in true }
    }
    
    func deleteUserPlant(_ userPlant: UserPlant) {
        print("Deleting plant with ID: \(userPlant.userPlantRelationID)")
        print("Before deletion:")
        print("- User plants count: \(self.userPlant.count)")
        print("- Care reminders count: \(careReminders.count)")
        print("- Reminder relations count: \(reminderOfUserPlant.count)")
        
        // 1. Remove from user plants array
        if let index = self.userPlant.firstIndex(where: { $0.userPlantRelationID == userPlant.userPlantRelationID }) {
            self.userPlant.remove(at: index)
            
            // 2. Find and remove the reminder relation first
            if let relationIndex = reminderOfUserPlant.firstIndex(where: { $0.userPlantRelationID == userPlant.userPlantRelationID }) {
                let removedRelation = reminderOfUserPlant.remove(at: relationIndex)
                
                // 3. Now remove the actual reminder using the relation
                if let reminderIndex = careReminders.firstIndex(where: { reminder in
                    // Match reminder with the relation we just removed
                    reminder.upcomingReminderForWater == userPlant.lastWatered &&
                    reminder.upcomingReminderForFertilizers == userPlant.lastFertilized &&
                    reminder.upcomingReminderForRepotted == userPlant.lastRepotted
                }) {
                    careReminders.remove(at: reminderIndex)
                }
            }
            
            // 4. Remove any user plant diseases
            userPlantDisease.removeAll { $0.usersPlantRelationID == userPlant.userId }
        }
        
        print("After deletion:")
        print("- User plants count: \(self.userPlant.count)")
        print("- Care reminders count: \(careReminders.count)")
        print("- Reminder relations count: \(reminderOfUserPlant.count)")
    }
    
    func getPlants() -> [Plant] {
        return plants
    }
    
    // Add this method to DataControllerGG
    func addUserPlant(_ userPlant: UserPlant) {
        self.userPlant.append(userPlant)
        
        // Create and add care reminder
        let reminder = CareReminder_(
            upcomingReminderForWater: userPlant.lastWatered,
            upcomingReminderForFertilizers: userPlant.lastFertilized,
            upcomingReminderForRepotted: userPlant.lastRepotted,
            isWateringCompleted: false,
            isFertilizingCompleted: false,
            isRepottingCompleted: false
        )
        careReminders.append(reminder)
        
        // Create relationship
        let relationship = CareReminderOfUserPlant(
            careReminderID: UUID(),
            userPlantRelationID: userPlant.userPlantRelationID
        )
        reminderOfUserPlant.append(relationship)
    }
}
