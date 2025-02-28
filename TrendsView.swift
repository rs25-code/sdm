// TrendsView.swift

import SwiftUI
import Charts

struct TrendsView: View {
    let sightings: [AnimalSighting]
    let species: String
    @Binding var selectedYear: Int
    @State private var predictions: [SpeciesPredictionResult] = []
    
    var combinedPopulationData: [PopulationDataPoint] {
        let historicalPoints = Dictionary(grouping: sightings.filter { $0.species == species }) { $0.year }
            .mapValues { sightings in
                sightings.map { $0.count }.reduce(0, +)
            }
            .map { year, count in
                PopulationDataPoint(year: year, count: count, isProjected: false, confidence: nil)
            }
        
        let filteredPredictions = predictions.filter { $0.year >= 2025 }
        let groupedPredictions = Dictionary(grouping: filteredPredictions) { $0.year }
        
        let projectedPoints = groupedPredictions.map { year, yearPredictions in
            let totalCount = Int(yearPredictions.map { $0.predictedCount }.reduce(0, +))
            let avgConfidence = yearPredictions.map { $0.confidence }.reduce(0, +) / Double(yearPredictions.count)
            
            return PopulationDataPoint(
                year: year,
                count: totalCount,
                isProjected: true,
                confidence: avgConfidence
            )
        }
        
        return (historicalPoints + projectedPoints).sorted { $0.year < $1.year }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(species)
                .font(.headline)
            
            if combinedPopulationData.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
            } else {
                Chart {
                    // Historical data line
                    ForEach(combinedPopulationData.filter { !$0.isProjected }) { dataPoint in
                        LineMark(
                            x: .value("Year", dataPoint.year),
                            y: .value("Population", dataPoint.count)
                        )
                        .foregroundStyle(.blue)
                        
                        PointMark(
                            x: .value("Year", dataPoint.year),
                            y: .value("Population", dataPoint.count)
                        )
                        .foregroundStyle(.blue)
                    }
                    
                    // Projected data line with confidence interval
                    ForEach(combinedPopulationData.filter { $0.isProjected }) { dataPoint in
                        // Confidence interval area
                        if let confidence = dataPoint.confidence {
                            AreaMark(
                                x: .value("Year", dataPoint.year),
                                yStart: .value("Lower", Double(dataPoint.count) * (1 - confidence)),
                                yEnd: .value("Upper", Double(dataPoint.count) * (1 + confidence))
                            )
                            .foregroundStyle(.orange.opacity(0.2))
                        }
                        
                        LineMark(
                            x: .value("Year", dataPoint.year),
                            y: .value("Population", dataPoint.count)
                        )
                        .foregroundStyle(.orange)
                        
                        PointMark(
                            x: .value("Year", dataPoint.year),
                            y: .value("Population", dataPoint.count)
                        )
                        .foregroundStyle(.orange)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(preset: .extended) { value in
                        if let year = value.as(Int.self) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                Text(String(year))
                                    .font(.footnote)
                            }
                        }
                    }
                }
                .chartXScale(domain: [2010, 2050])
                .chartLegend(position: .bottom) {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                        Text("Historical")
                        Circle()
                            .fill(.orange)
                            .frame(width: 8, height: 8)
                        Text("Projected")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Historical Change (2010-2024):")
                        .font(.subheadline)
                        .bold()
                    
                    let historicalChange = calculateChange(
                        start: combinedPopulationData.first { $0.year == 2010 }?.count ?? 0,
                        end: combinedPopulationData.first { $0.year == 2024 }?.count ?? 0
                    )
                    
                    DisplayChange(change: historicalChange)
                    
                    Text("Projected Change (2025-2050):")
                        .font(.subheadline)
                        .bold()
                        .padding(.top, 8)
                    
                    let projectedChange = calculateChange(
                        start: combinedPopulationData.first { $0.year == 2025 }?.count ?? 0,
                        end: combinedPopulationData.last?.count ?? 0
                    )
                    
                    DisplayChange(change: projectedChange)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .onAppear {
            loadProjectedData()
        }
    }
    
    private func loadProjectedData() {
        do {
            let mlManager = try MLPredictionManager()
            self.predictions = try mlManager.generatePredictions(for: species)
        } catch {
            print("Error loading projections: \(error)")
        }
    }
    
    private func calculateChange(start: Int, end: Int) -> (amount: Int, percent: Double) {
        let change = end - start
        let percent = start > 0 ? (Double(change) / Double(start)) * 100 : 0
        return (change, percent)
    }
}

struct DisplayChange: View {
    let change: (amount: Int, percent: Double)
    
    var body: some View {
        HStack {
            Text("\(change.amount >= 0 ? "+" : "")\(change.amount) individuals")
            Text("(\(String(format: "%.1f", change.percent))%)")
                .foregroundColor(change.amount >= 0 ? .green : .red)
        }
        .font(.subheadline)
    }
}
