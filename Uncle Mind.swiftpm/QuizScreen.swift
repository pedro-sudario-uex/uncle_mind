import SwiftUI

struct QuizScreen: View {
    @State private var offset: CGFloat = 0
    @State private var timer: Timer? = nil
    @State private var timeElapsed: CGFloat = 0
    
    let parallaxLayers: [(nome: String, speed: CGFloat)] = [
        ("forest_sky",       0.0),
        ("forest_moon",      0.0),
        ("forest_mountain",  0.0),
        ("forest_back",      0.0),
        ("forest_long",      0.2),
        ("forest_mid",       0.5),
        ("forest_short",     0.5)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(parallaxLayers, id: \.nome) { layer in
                    ParallaxLayer(
                        imageName: layer.nome,
                        offset: offset,
                        speed: layer.speed,
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                }
                
                VStack {
                    Text("Quiz Screen")
                        .font(.largeTitle)
                        .padding()
                }
            }
            .onAppear {
                startBackgroundMovement(screenWidth: geometry.size.width)
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private func startBackgroundMovement(screenWidth: CGFloat) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            offset -= 2
            timeElapsed += 0.02
            
            if timeElapsed >= 15 {
                resetParallax()
                timeElapsed = 0
            }
        }
    }
    
    private func resetParallax() {
        // Reset the offset
        offset = 0
    }
}
