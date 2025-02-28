// ConservationVIew.swift

import SwiftUI

struct ConservationView: View {
    let species: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ConservationSection(
                    title: "Primary Threats",
                    items: getThreats(for: species)
                )
                
                ConservationSection(
                    title: "Conservation Actions",
                    items: getActions(for: species)
                )
            }
            .padding()
        }
    }
    
    private func getThreats(for species: String) -> [String] {
        switch species {
        case "Condor":
            return ["Lead poisoning", "Habitat loss", "Power line collisions"]
        case "Sierra Nevada Red Fox":
            return ["Climate change", "Habitat fragmentation", "Competition with coyotes"]
        default:
            return ["Habitat loss", "Human conflict", "Climate change"]
        }
    }
    
    private func getActions(for species: String) -> [String] {
        switch species {
        case "Condor":
            return ["Captive breeding program", "Lead ammunition bans", "Nest site protection"]
        case "Sierra Nevada Red Fox":
            return ["Habitat restoration", "Population monitoring", "Genetic research"]
        default:
            return ["Protected areas", "Population monitoring", "Public education"]
        }
    }
}
