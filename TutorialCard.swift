// TutorialCard.swift

import SwiftUI
import SwiftUI

struct TutorialOverlay: View {
    @Binding var isVisible: Bool
    @State private var selectedTab = 0
    @State private var opacity = 0.0
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) {
                        isVisible = false
                    }
                }
            
            // Tutorial Card
            VStack(spacing: 0) {
                // Close Button
                HStack {
                    Spacer()
                    Button(action: { 
                        withAnimation(.spring()) {
                            isVisible = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                //Title
                Text("Ecotrax Navigation Tutorial")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)
                
                // Tab Selection
                HStack(spacing: 0) {
                    ForEach(["Species Tracking", "Population Analysis"], id: \.self) { tab in
                        TabButton(
                            title: tab,
                            isSelected: selectedTab == (tab == "Species Tracking" ? 0 : 1),
                            namespace: animation
                        ) {
                            withAnimation(.spring()) {
                                selectedTab = tab == "Species Tracking" ? 0 : 1
                            }
                        }
                    }
                }
                
                // Content
                TabView(selection: $selectedTab) {
                    // First Tab - Species Tracking
                    VStack(alignment: .leading, spacing: 24) {
                        TutorialStep(
                            icon: "magnifyingglass",
                            title: "Select a Species",
                            description: "Use the dropdown menu at the top to choose from endangered species in our database."
                        )
                        
                        TutorialStep(
                            icon: "map",
                            title: "Explore Distribution",
                            description: "View historical sightings on the map. Larger circles show higher population counts. Colors indicate different species."
                        )
                        
                        TutorialStep(
                            icon: "slider.horizontal.3",
                            title: "Time Travel",
                            description: "Use the year slider to see how species distribution has changed over time."
                        )
                        
                        TutorialStep(
                            icon: "info.circle",
                            title: "Detailed Information",
                            description: "Tap any circle marker to view specific sighting details, or select a species name to see comprehensive information."
                        )
                    }
                    .tag(0)
                    .padding(.horizontal, 24)
                    
                    // Second Tab - Population Analysis
                    VStack(alignment: .leading, spacing: 24) {
                        TutorialStep(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Population Trends",
                            description: "Click 'Show Trends' to visualize population changes over time and see percentage changes between periods."
                        )
                        
                        TutorialStep(
                            icon: "arrow.forward.circle",
                            title: "Future Projections",
                            description: "Toggle 'Show Predictions' to view AI-powered population forecasts based on climate data and habitat changes."
                        )
                        
                        TutorialStep(
                            icon: "chart.bar.fill",
                            title: "Understanding Data",
                            description: "Blue markers show historical data, while orange indicates projected populations. Transparency reflects prediction confidence."
                        )
                    }
                    .tag(1)
                    .padding(.horizontal, 24)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)
                
                Text("Click on the questionmark icon at the bottom right of the app screen to relaunch this tutorial")
                    .padding(.bottom, 8)
                
                // Get Started Button
                Button(action: {
                    withAnimation(.spring()) {
                        isVisible = false
                    }
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 24)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }
        }
    }
}

struct TutorialStep: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                
                if isSelected {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "tab_indicator", in: namespace)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
        }
    }
}

