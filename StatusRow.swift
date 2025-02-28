// StatusRow.swift

import SwiftUI

struct StatusRow: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = .blue
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
    }
}
