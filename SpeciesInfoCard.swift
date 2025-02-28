// SpeciesInfoCard.swift

import SwiftUI

struct SpeciesInfoCard: View {
    let species: String?
    @State private var selectedTab = 0
    @Namespace private var animation
    @Binding var isVisible: Bool  // New binding for visibility control
    
    var body: some View {
        if let speciesName = species,
           let info = SpeciesDatabase.speciesInformation[speciesName] {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { isVisible = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                    .padding([.top, .trailing], 12)
                }
                
                // Species Image and Info
                ZStack(alignment: .bottomLeading) {
                    Image(info.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(info.commonName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(info.scientificName)
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                
                HStack(spacing: 0) {
                    ForEach(["Overview", "Status", "Conservation"], id: \.self) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = ["Overview", "Status", "Conservation"].firstIndex(of: tab) ?? 0
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(tab)
                                    .fontWeight(selectedTab == ["Overview", "Status", "Conservation"].firstIndex(of: tab) ? .semibold : .regular)
                                    .foregroundColor(selectedTab == ["Overview", "Status", "Conservation"].firstIndex(of: tab) ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedTab == ["Overview", "Status", "Conservation"].firstIndex(of: tab) 
                                        ? Color.blue.opacity(0.1) 
                                        : Color.clear
                                    )
                                
                                if selectedTab == ["Overview", "Status", "Conservation"].firstIndex(of: tab) {
                                    Rectangle()
                                        .fill(Color.blue)
                                        .frame(height: 2)
                                        .matchedGeometryEffect(id: "tab", in: animation)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 2)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal)
                
                TabView(selection: $selectedTab) {
                    // Overview Tab
                    ScrollView {
                        Text(info.overview)
                            .padding()
                    }
                    .tag(0)
                    
                    // Status Tab
                    VStack(alignment: .leading, spacing: 16) {
                        StatusRow(
                            icon: "number.circle.fill",
                            title: "Current Population",
                            value: "\(info.currentPopulation) individuals"
                        )
                        
                        StatusRow(
                            icon: "exclamationmark.triangle.fill",
                            title: "Conservation Status",
                            value: info.conservationStatus,
                            color: statusColor(info.conservationStatus)
                        )
                    }
                    .padding()
                    .tag(1)
                    
                    // Conservation Tab
                    ConservationView(species: speciesName)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 300)
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 5)
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Critically Endangered":
            return .red
        case "Critically Imperiled":
            return .orange
        case "Least Concern":
            return .green
        default:
            return .yellow
        }
    }
}
