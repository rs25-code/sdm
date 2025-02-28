// ContentView.swift

import SwiftUI
import MapKit
import Charts

struct PopulationDataPoint: Identifiable {
    let id = UUID()
    let year: Int
    let count: Int
    let isProjected: Bool
    let confidence: Double?
    
    init(year: Int, count: Int, isProjected: Bool = false, confidence: Double? = nil) {
        self.year = year
        self.count = count
        self.isProjected = isProjected
        self.confidence = confidence
    }
}

struct AnimalSighting: Identifiable, Hashable {
        let id = UUID()
        let species: String
        let year: Int
        let count: Int
        let latitude: Double
        let longitude: Double
        let timeline: String  // "Historical" or "Projected"
        
        var coordinate: CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        
        func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
        
        static func == (lhs: AnimalSighting, rhs: AnimalSighting) -> Bool {
                lhs.id == rhs.id
            }
}

struct SpeciesInformation {
        let commonName: String
        let scientificName: String
        let currentPopulation: Int
        let conservationStatus: String
        let overview: String
        let imageName: String
}

class SpeciesDatabase {
        static let speciesInformation: [String: SpeciesInformation] = [
                "Condor": SpeciesInformation(
                        commonName: "California Condor",
                        scientificName: "Gymnogyps californianus",
                        currentPopulation: 561,
                        conservationStatus: "Critically Endangered",
                        overview: "The California condor is currently restricted to the western coastal mountains of the contiguous United States and Mexico, as well as the northern desert mountains of Arizona.",
                        imageName: "condor"  // Replace with actual image name
                    ),
                "Sierra Nevada Red Fox": SpeciesInformation(
                        commonName: "Sierra Nevada Red Fox",
                        scientificName: "Vulpes vulpes necator",
                        currentPopulation: 50,
                        conservationStatus: "Critically Imperiled",
                        overview: "The Sierra Nevada red fox, also known as the High Sierra fox, is a subspecies of red fox found in the Oregon Cascades and the Sierra Nevada. It is likely one of the most endangered mammals in North America.",
                        imageName: "red_fox"  // Replace with actual image name
                    ),
                "Red Wolf": SpeciesInformation(
                        commonName: "Red Wolf",
                        scientificName: "Canis lupus",
                        currentPopulation: 80,
                        conservationStatus: "Critically Endangered",
                        overview: "The Red Wolf is a canine native to the South Eastern United States. The red wolf was nearly driven into extinction by the mid-1900s due to aggressive predator-control programs, habitat destruction, and extensive hybridization with coyotes.",
                        imageName: "red_wolf"  // Replace with actual image name
                    ),
                "Florida Panther": SpeciesInformation(
                        commonName: "Florida Panther",
                        scientificName: "Puma concolor couguar",
                        currentPopulation: 250,
                        conservationStatus: "Critically Imperiled",
                        overview: "The Florida panther is a North American cougar present in South Florida. It lives in pinelands, tropical hardwood hammocks and mixed freshwater swamp forests. It is the only confirmed cougar population in the Eastern United States and currently occupies only 5% of its historic range.",
                        imageName: "panther"  // Replace with actual image name
                    ),
                "Ocelot": SpeciesInformation(
                        commonName: "Ocelot",
                        scientificName: "Leopardus pardalis",
                        currentPopulation: 250,
                        conservationStatus: "Least Concern",
                        overview: "The Ocelot is a medium-sized spotted wild cat that is native to the South Western US, Central and South America. While its range is very large, various populations are decreasing in many parts of its range due to habitat destruction, hunting, and traffic accidents.",
                        imageName: "ocelot"  // Replace with actual image name
                    )
            ]
}

struct InfoRow: View {
        let label: String
        let value: String
        
        var body: some View {
                VStack(alignment: .leading, spacing: 4) {
                        Text(label)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(value)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
            }
}

class CSVManager {
        static func loadSightings() -> [AnimalSighting] {
                guard let csvPath = Bundle.main.path(forResource: "animal_data", ofType: "csv") else {
                        print("Could not find CSV file")
                        return []
                    }
                
                do {
                        let csvContent = try String(contentsOfFile: csvPath, encoding: .utf8)
                        let rows = csvContent.components(separatedBy: .newlines)
                        
                        let sightings = rows.dropFirst().compactMap { row -> AnimalSighting? in
                                let columns = row.components(separatedBy: ",")
                                guard columns.count == 6,
                                      let year = Int(columns[1].trimmingCharacters(in: .whitespaces)),
                                      let count = Int(columns[2].trimmingCharacters(in: .whitespaces)),
                                      let latitude = Double(columns[3].trimmingCharacters(in: .whitespaces)),
                                      let longitude = Double(columns[4].trimmingCharacters(in: .whitespaces)) else {
                                        return nil
                                    }
                                
                                return AnimalSighting(
                                        species: columns[0].trimmingCharacters(in: .whitespaces),
                                        year: year,
                                        count: count,
                                        latitude: latitude,
                                        longitude: longitude,
                                        timeline: columns[5].trimmingCharacters(in: .whitespaces)
                                    )
                            }
                        
                        return sightings
                    } catch {
                            print("Error reading CSV file: \(error)")
                            return []
                        }
            }
}

struct MapLegendView: View {
    let species: [String]
    
    func colorForSpecies(_ species: String) -> Color {
        let speciesColors: [String: Color] = [
            "Condor": .blue,
            "Sierra Nevada Red Fox": .brown,
            "Florida Panther": .orange,
            "Ocelot": .purple,
            "Red Wolf": .red
        ]
        return speciesColors[species] ?? .purple
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Species")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(species, id: \.self) { speciesName in
                HStack(spacing: 12) {
                    Circle()
                        .fill(colorForSpecies(speciesName))
                        .frame(width: 12, height: 12)
                    
                    Text(speciesName)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition
    @State private var selectedSighting: AnimalSighting?
    @State private var selectedSpecies: String?
    @State private var availableSpecies: [String] = []
    @State private var showingTrends = false
    @State private var selectedYear: Int
    @State private var isPulsing = false
    @State private var speciesCardVisible = false
    @State private var sliderValue: Double = 2010
    @State private var isSliding = false
    @State private var showingSightingOverlay = false
    @State private var mlManager: MLPredictionManager?
    @State private var predictions: [SpeciesPredictionResult] = []
    @State private var isShowingPredictions = false
    @State private var isLoadingPredictions = false
    @State private var predictionError: Error?
    @State private var showTutorial = true
    @State private var ShowTutorialButton = false
    
    private var sliderMinValue: Double {
        isShowingPredictions ? 2025 : 2010
    }
    
    private var sliderMaxValue: Double {
        isShowingPredictions ? 2050 : 2024
    }
    
    let sightings: [AnimalSighting]
    
    init(sightings: [AnimalSighting]) {
        self.sightings = sightings
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40, longitude: -100),
            span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
        )
        self._cameraPosition = State(initialValue: .region(initialRegion))
        self._selectedYear = State(initialValue: 2010)
        
        // Initialize ML Manager
        do {
            let manager = try MLPredictionManager()
            self._mlManager = State(initialValue: manager)
        } catch {
            print("Error initializing ML manager: \(error)")
        }
    }
    
    var filteredSightings: [AnimalSighting] {
        var filtered = sightings
        if let selectedSpecies = selectedSpecies {
            filtered = filtered.filter { $0.species == selectedSpecies }
        }
        
        filtered = filtered.filter { sighting in
            sighting.year == selectedYear
        }
        return filtered
    }
    
    var displayedSightings: [AnimalSighting] {
        if isShowingPredictions {
            print("\nFiltering predictions for year \(selectedYear)")
            let yearPredictions = predictions.filter { $0.year == selectedYear }
            print("Found \(yearPredictions.count) predictions for year \(selectedYear)")
            if let first = yearPredictions.first {
                print("Sample prediction: Year: \(first.year), Count: \(first.predictedCount)")
            }
            
            return yearPredictions.map { prediction in
                AnimalSighting(
                    species: selectedSpecies ?? "",
                    year: prediction.year,
                    count: Int(prediction.predictedCount),
                    latitude: prediction.latitude,
                    longitude: prediction.longitude,
                    timeline: "Projected"
                )
            }
        } else {
            return filteredSightings
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Show tutorial
                if showTutorial {
                    TutorialOverlay(isVisible: $showTutorial)
                        .zIndex(100)
                }
                // Main Map View
                Map(position: $cameraPosition) {
                    ForEach(displayedSightings) { sighting in
                        Annotation("", coordinate: sighting.coordinate) {
                            ZStack {
                                Circle()
                                    .fill(colorForSpecies(sighting.species, isPrediction: isShowingPredictions)
                                        .opacity(0.3))
                                    .frame(width: calculateDiameter(count: sighting.count) * 1.3,
                                           height: calculateDiameter(count: sighting.count) * 1.3)
                                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), 
                                               value: isPulsing)
                                    .onAppear {
                                        isPulsing = true
                                    }
                                
                                Circle()
                                    .fill(colorForSpecies(sighting.species, isPrediction: isShowingPredictions))
                                    .frame(width: calculateDiameter(count: sighting.count),
                                           height: calculateDiameter(count: sighting.count))
                                    .onTapGesture {
                                        withAnimation {
                                            selectedSighting = sighting
                                        }
                                    }
                                
                                if sighting.count > 25 {
                                    Text("\(sighting.count)")
                                        .font(.system(size: min(calculateDiameter(count: sighting.count) * 0.4, 14)))
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                        .zIndex(1)
                                }
                            }
                            .contentShape(Circle())
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedSighting = sighting
                                }
                            }
                        }
                    }
                }
                .overlay(mapOverlay)
                .overlay(alignment: .topLeading) {
                    if speciesCardVisible {
                        SpeciesInfoCard(species: selectedSpecies, isVisible: $speciesCardVisible)
                            .frame(width: 360)
                            .padding()
                            .transition(.move(edge: .leading))
                    }
                }
                .onTapGesture { location in
                    if speciesCardVisible {
                        speciesCardVisible = false
                    }
                }
                
                VStack(spacing: 0) {
                    // Navigation title view
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Historical Species Distribution Tracking and Future Projections")
                                .font(.headline)
                        }
                        Spacer()
                        
                        Button(action: {
                            showTutorial = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .font(.title3)
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        }
                        .padding(.trailing)
                    }
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    
                    Divider()
                    
                    HStack(spacing: 24) {
                        Spacer()
                        
                        // Year Slider section
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Year:")
                                    .font(.subheadline)
                                Text(String(Int(sliderValue)))
                                    .font(.subheadline.bold())
                                    .foregroundColor(.blue)
                                    .frame(width: 45, alignment: .leading)
                            }
                            
                            Slider(
                                value: $sliderValue,
                                in: sliderMinValue...sliderMaxValue,
                                step: 1
                            ) { editing in
                                isSliding = editing
                                if !editing {
                                    selectedYear = Int(sliderValue.rounded())
                                }
                            }
                            .tint(.blue)
                            .frame(width: 300)
                        }
                        Spacer()
                        
                        // Predictions toggle in its own group
                        if selectedSpecies != nil {
                            HStack(spacing: 8) { 
                                Toggle("", isOn: $isShowingPredictions) 
                                    .labelsHidden() 
                                
                                Text("Show Predictions") 
                                    .font(.subheadline)
                            }
                            .onChange(of: isShowingPredictions) { oldValue, newValue in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if newValue {
                                        sliderValue = 2025
                                        selectedYear = 2025
                                        handlePredictionGeneration()
                                    } else {
                                        sliderValue = 2010
                                        selectedYear = 2010
                                    }
                                }
                            }
                        }
                        
                        // Species Picker
                        Menu {
                            Button(action: {
                                selectedSpecies = nil
                                speciesCardVisible = false
                            }) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("All Species")
                                }
                            }
                            
                            ForEach(availableSpecies, id: \.self) { species in
                                Button(action: {
                                    selectedSpecies = species
                                    withAnimation {
                                        speciesCardVisible = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: getSpeciesIcon(species))
                                        Text(species)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: selectedSpecies == nil ? "globe" : getSpeciesIcon(selectedSpecies ?? ""))
                                    .foregroundColor(.blue)
                                Text(selectedSpecies ?? "All Species")
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .strokeBorder(.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Trends Button
                        if selectedSpecies != nil {
                            Button(action: { showingTrends = true }) {
                                Label("Show Trends", systemImage: "chart.line.uptrend.xyaxis")
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(.thinMaterial)
                }
            }
            .onChange(of: selectedSpecies) { oldValue, newSpecies in
                print("Selected species: \(oldValue ?? "none") to \(newSpecies ?? "none")")
                if let species = newSpecies {
                    let speciesSightings = sightings.filter { $0.species == species }
                    adjustMapRegion(for: speciesSightings)
                } else {
                    adjustMapRegion(for: sightings)
                }
            }
            .onChange(of: sliderValue) { oldValue, newValue in
                if isSliding {
                    selectedYear = Int(newValue.rounded())
                }
            }
            .sheet(isPresented: $showingTrends) {
                if let species = selectedSpecies {
                    NavigationStack {
                        TrendsView(
                            sightings: sightings,
                            species: species,
                            selectedYear: $selectedYear
                        )
                        .navigationTitle("Population Trends")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showingTrends = false
                                }
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
                }
            }
            .overlay {
                if let sighting = selectedSighting {
                    Rectangle()
                        .fill(.black.opacity(0.3))
                        .ignoresSafeArea()
                        .overlay {
                            SightingCardView(
                                sighting: sighting,
                                onDismiss: {
                                    selectedSighting = nil
                                }
                            )
                            .frame(maxWidth: 300)
                        }
                        .onTapGesture {
                            selectedSighting = nil
                        }
                }
            }
            .animation(.easeInOut, value: selectedSighting != nil)
            // And update your circle tap gesture to:
            .onAppear {
                print("App launched")
                availableSpecies = Array(Set(sightings.map { $0.species })).sorted()
                if !sightings.isEmpty {
                    adjustMapRegion(for: sightings)
                }
            }
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "hasSeenTutorial") {
                showTutorial = true
                UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
            }
        }
    }
    
    private func getSpeciesIcon(_ species: String) -> String {
        switch species {
        case "Condor":
            return "bird"
        case "Sierra Nevada Red Fox":
            return "hare"
        case "Red Wolf":
            return "pawprint"
        case "Florida Panther":
            return "cat"
        case "Ocelot":
            return "cat.fill"
        default:
            return "questionmark.circle"
        }
    }
    
    private func calculateDiameter(count: Int) -> CGFloat {
        // Base size of 10 points for count of 1
        // Maximum size of 50 points for count of 50 or more
        let minSize: CGFloat = 10
        let maxSize: CGFloat = 50
        let normalizedCount = min(count, 50)
        
        // Linear scaling between minSize and maxSize
        return minSize + (CGFloat(normalizedCount) / 50.0) * (maxSize - minSize)
    }
    
    private func colorForSpecies(_ species: String, isPrediction: Bool = false) -> Color {
        if isPrediction {
            return .gray
        }
        
        // Create a mapping of species to base colors
        let speciesColors: [String: Color] = [
            "Condor": .blue,
            "Sierra Nevada Red Fox": .brown,
            "Florida Panther": .orange,
            "Ocelot": .purple,
            "Red Wolf": .red
        ]
        
        // Get the base color for the species, or use purple as default
        return speciesColors[species] ?? .purple
    }
    
    private func handlePredictionGeneration() {
        guard let mlManager = mlManager,
              let species = selectedSpecies else { return }
        
        isLoadingPredictions = true
        predictionError = nil
        
        do {
            try mlManager.loadClimateProjections()
            
            // Generate predictions for the selected year
            let newPredictions = try mlManager.generatePredictions(for: species)
            print("Generated predictions:")
            print("Total predictions: \(newPredictions.count)")
            print("Year range: \(newPredictions.map { $0.year }.min() ?? 0) to \(newPredictions.map { $0.year }.max() ?? 0)")
            print("Sample counts: \(newPredictions.prefix(3).map { "\($0.year): \($0.predictedCount)" }.joined(separator: ", "))")
            
            predictions = newPredictions
            isLoadingPredictions = false
        } catch {
            predictionError = error
            isLoadingPredictions = false
        }
    }
    
    func adjustMapRegion(for sightings: [AnimalSighting]) {
        guard !sightings.isEmpty else { return }
        
        let minLat = sightings.map { $0.latitude }.min() ?? 0
        let maxLat = sightings.map { $0.latitude }.max() ?? 0
        let minLon = sightings.map { $0.longitude }.min() ?? 0
        let maxLon = sightings.map { $0.longitude }.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let latDelta = (maxLat - minLat) * 1.5
        let lonDelta = (maxLon - minLon) * 1.5
        let span = MKCoordinateSpan(
            latitudeDelta: max(latDelta, 5.0),  // Minimum 5 degrees of latitude
            longitudeDelta: max(lonDelta, 5.0)  // Minimum 5 degrees of longitude
        )
        
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
}
extension ContentView {
    var mapOverlay: some View {
        GeometryReader { geometry in
            if selectedSpecies == nil {
                MapLegendView(species: availableSpecies)
                    .frame(width: 200)
                    .padding()
                    .position(
                        x: geometry.size.width - 120,
                        y: geometry.safeAreaInsets.top + 100
                    )
            }
        }
    }
}

