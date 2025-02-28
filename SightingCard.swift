// SightingCard.swift

import SwiftUI

struct SightingDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label): ")
                .foregroundColor(.gray)
            Text(value)
            Spacer()
        }
    }
}

struct SightingCardView: View {
    let sighting: AnimalSighting
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            
            Image(systemName: "pawprint.fill")
                .foregroundColor(.red)
                .font(.title)
            
            Text(sighting.species)
                .font(.headline)
            
            VStack(spacing: 8) {
                SightingDetailRow(label: "Year", value: String(sighting.year))
                SightingDetailRow(label: "Population Count", value: String(sighting.count))
                SightingDetailRow(
                    label: "Location",
                    value: "\(String(format: "%.4f", sighting.latitude)), \(String(format: "%.4f", sighting.longitude))"
                )
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}
