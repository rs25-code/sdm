// ConservationSection.swift
import SwiftUI

struct ConservationSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            ForEach(items, id: \.self) { item in
                HStack(spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.blue)
                    Text(item)
                        .font(.subheadline)
                }
            }
        }
    }
}
