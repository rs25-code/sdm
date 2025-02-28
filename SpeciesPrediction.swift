// SpeciesPrediction.swift

import SwiftUI
import CoreML
import Foundation

public struct SpeciesPredictionInput {
    public let species: String
    public let latitude: Double
    public let longitude: Double
    public let temperature: Double
    public let precipitation: Double
    public let ndvi: Double
    public let fireOccurred: Bool
    public let fireSize: Double
    
    public init(species: String, latitude: Double, longitude: Double, temperature: Double, 
                precipitation: Double, ndvi: Double, fireOccurred: Bool, fireSize: Double) {
        self.species = species
        self.latitude = latitude
        self.longitude = longitude
        self.temperature = temperature
        self.precipitation = precipitation
        self.ndvi = ndvi
        self.fireOccurred = fireOccurred
        self.fireSize = fireSize
    }
}

public struct SpeciesPredictionResult {
    public let predictedCount: Double
    public let year: Int
    public let latitude: Double
    public let longitude: Double
    public let confidence: Double
    public let climateData: ClimateData
}

public struct ClimateData {
    public let temperature: Double
    public let precipitation: Double
    public let ndvi: Double
    public let fireProbability: Double
}

public class MLPredictionManager {
    private let model: Ecotrax
    private var climateProjections: [ClimateProjection] = []
    
    private func parseBool(_ string: String) -> Bool? {
        let lowercased = string.lowercased().trimmingCharacters(in: .whitespaces)
            switch lowercased {
                case "true", "1", "yes": return true
                case "false", "0", "no": return false
                default: return nil
            }
    }
    
    private func calculateConfidence(fireProbability: Double) -> Double {
        return 1.0 - fireProbability
    }

    init() throws {
        print("Initializing ML Prediction Manager")
        guard let modelURL = Bundle.main.url(forResource: "Ecotrax", withExtension: "mlmodel") else {
            print("❌ Error: Model file not found")
            throw MLError.modelNotFound
        }
        
        do {
            let compiledURL = try MLModel.compileModel(at: modelURL)
            let config = MLModelConfiguration()
            self.model = try Ecotrax(contentsOf: compiledURL, configuration: config)
            print("✅ Model loaded successfully")
            
            try loadClimateProjections()
        } catch {
            print("❌ Error loading model: \(error)")
            throw MLError.modelLoadError(error)
        }
    }
    
    func loadClimateProjections() throws {
        print("📊 Loading climate projections...")
        guard let csvURL = Bundle.main.url(forResource: "spatial_climate_projections_ssp370", withExtension: "csv") else {
            print("❌ Climate projections CSV file not found")
            throw MLError.dataNotFound
        }
        
        do {
            let csvData = try String(contentsOf: csvURL, encoding: .utf8)
            let rows = csvData.components(separatedBy: "\n")
            
            print("Found \(rows.count) rows in climate projections CSV")
            
            // Skip header row and parse data
            climateProjections = rows.dropFirst().compactMap { row in
                let columns = row.components(separatedBy: ",").map { 
                    $0.trimmingCharacters(in: .whitespaces) 
                }
                
                guard columns.count == 10,
                      let year = Int(columns[0]),
                      let latitude = Double(columns[2]),
                      let longitude = Double(columns[3]),
                      let temperature = Double(columns[4]),
                      let precipitation = Double(columns[5]),
                      let ndvi = Double(columns[6]),
                      let fireOccurred = parseBool(columns[7]),
                      let fireSize = Double(columns[8]),
                      let fireProbability = Double(columns[9]) else {
                    print("Failed to parse row: \(row)")
                    return nil
                }
                
                return ClimateProjection(
                    year: year,
                    species: columns[1],
                    latitude: latitude,
                    longitude: longitude,
                    temperature: temperature,
                    precipitation: precipitation,
                    ndvi: ndvi,
                    fireOccurred: fireOccurred,
                    fireSize: fireSize,
                    fireProbability: fireProbability
                )
            }
            
            print("Successfully loaded \(climateProjections.count) climate projections")
            // Print sample of data
            if let sample = climateProjections.first {
                print("Sample projection: \n" +
                      "Species: \(sample.species)\n" +
                      "Location: (\(sample.latitude), \(sample.longitude))\n" +
                      "Temperature: \(sample.temperature)°C\n" +
                      "Precipitation: \(sample.precipitation)mm")
            }
            
        } catch {
            print("Error reading climate projections: \(error)")
            throw MLError.dataLoadError(error)
        }
    }
    
    func generatePredictions(for species: String) throws -> [SpeciesPredictionResult] {
        print("\nGenerating predictions for \(species) from 2025 to 2050")
        
        // Filter climate projections for the specified species
        let speciesProjections = climateProjections.filter { 
            $0.species == species 
        }
        
        print("Found \(speciesProjections.count) climate projections for \(species)")
        
        var predictions: [SpeciesPredictionResult] = []
        var successCount = 0
        var failureCount = 0
        
        // For each projection, use its specific year
        for projection in speciesProjections {
            let input = SpeciesPredictionInput(
                species: species,
                latitude: projection.latitude,
                longitude: projection.longitude,
                temperature: projection.temperature,
                precipitation: projection.precipitation,
                ndvi: projection.ndvi,
                fireOccurred: projection.fireOccurred,
                fireSize: projection.fireSize
            )
            
            do {
                let prediction = try predict(with: input)
                let climateData = ClimateData(
                    temperature: projection.temperature,
                    precipitation: projection.precipitation,
                    ndvi: projection.ndvi,
                    fireProbability: projection.fireProbability
                )
                
                let result = SpeciesPredictionResult(
                    predictedCount: prediction,
                    year: projection.year,  // Use the year from the climate projection
                    latitude: input.latitude,
                    longitude: input.longitude,
                    confidence: calculateConfidence(fireProbability: projection.fireProbability),
                    climateData: climateData
                )
                
                predictions.append(result)
                successCount += 1
                
                if successCount % 50 == 0 {
                    print("Generated prediction #\(successCount): Count: \(Int(prediction)) at (\(input.latitude), \(input.longitude)) for year \(projection.year)")
                }
                
            } catch {
                print("Prediction failed for \(species) at (\(projection.latitude), \(projection.longitude)) for year \(projection.year): \(error)")
                failureCount += 1
                continue
            }
        }
        
        print("\nPrediction Summary for \(species):")
        print("Total predictions: \(predictions.count)")
        print("Successful: \(successCount)")
        print("Failed: \(failureCount)")
        print("Year range: \(predictions.map { $0.year }.min() ?? 0) to \(predictions.map { $0.year }.max() ?? 0)")
        
        // Sort predictions by year for cleaner output
        let sortedPredictions = predictions.sorted { $0.year < $1.year }
        
        // Print sample predictions for different years
        print("\nSample predictions across years:")
        let sampleYears = [2025, 2035, 2050]
        for year in sampleYears {
            if let yearPred = sortedPredictions.first(where: { $0.year == year }) {
                print("Year \(year): Count: \(Int(yearPred.predictedCount)) at (\(yearPred.latitude), \(yearPred.longitude))")
            }
        }
        
        return predictions
    }
    
    
    private func predict(with input: SpeciesPredictionInput) throws -> Double {
        let modelInput = EcotraxInput(
            Species: input.species,
            Latitude: input.latitude,
            Longitude: input.longitude,
            Temperature_C: input.temperature,
            Precipitation_mm: input.precipitation,
            NDVI: input.ndvi,
            Fire_Occurred: input.fireOccurred ? "TRUE" : "FALSE",
            Fire_Size_km2: input.fireSize
        )
        
        let output = try model.prediction(input: modelInput)
        return output.Count
    }
}

private struct ClimateProjection {
    let year: Int
    let species: String
    let latitude: Double
    let longitude: Double
    let temperature: Double
    let precipitation: Double
    let ndvi: Double
    let fireOccurred: Bool
    let fireSize: Double
    let fireProbability: Double
}

public enum MLError: Error {
    case modelNotFound
    case modelLoadError(Error)
    case dataNotFound
    case dataLoadError(Error)
    case predictionError(Error)
}
