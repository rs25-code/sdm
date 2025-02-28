// SplashScreenView.swift

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var titleOpacity = 0.0
    @State private var imageScale = 0.8
    @State private var imageOpacity = 0.0
    @State private var textOpacity = 0.0
    
    var body: some View {
        if isActive {
            ContentView(sightings: CSVManager.loadSightings())
        } else {
            ZStack {
                LinearGradient(gradient: 
                                Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Ecotrax")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.80))
                        .opacity(titleOpacity)
                    
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 400, height: 400)
                            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image("condor_splash")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .clipShape(Circle())
                            .scaleEffect(imageScale)
                            .opacity(imageOpacity)
                    }
                    
                    VStack(spacing: 20) {
                        Text("Track and forecast the habitat of earth's most endangered species.")
                            .font(.system(size: 20, weight: .light, design: .default))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black.opacity(0.75))
                        
                        Spacer()
                            .frame(height: 10)
                        
                        Text("Assess the impact of climate change on their habitat and support conservation efforts.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black.opacity(0.75))
                    }
                    .padding(.horizontal, 40)
                    .opacity(textOpacity)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    titleOpacity = 1
                }
                
                withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                    imageOpacity = 1
                    imageScale = 1
                }
                
                withAnimation(.easeOut(duration: 1.0).delay(1.0)) {
                    textOpacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
