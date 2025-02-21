import SwiftUI

struct StartingScreen: View {
    @State private var offset: CGFloat = 0
    @State private var timer: Timer? = nil
    @State private var timeElapsed: CGFloat = 0
    @State private var navigateToQuiz = false
    
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
            NavigationStack {
                ZStack {
                    ForEach(parallaxLayers, id: \.nome) { layer in
                        ParallaxLayer(
                            imageName: layer.nome,
                            offset: offset,
                            speed: layer.speed,
                            width: 1920,
                            height: 1250
                        )
                    }
                    
                    VStack(spacing: 20) {
                        Image("uncle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 400)
                        
                        Text("Uncle Mind")
                            .font(.system(size: 80, weight: .heavy, design: .serif))
                            .foregroundColor(Color(.white))
                        
                        Text("Not just a game, but your teacher too!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.white))
                        
                        Button(action: {
                            navigateToQuiz = true
                        }) {
                            Text("Start Game")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .frame(width: 200)
                                .background(Color(hex: "E0CFB1"))
                                .cornerRadius(20)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    startBackgroundMovement(screenWidth: geometry.size.width)
                }
                .onDisappear {
                    timer?.invalidate()
                }
                
                NavigationLink(value: navigateToQuiz) {
                    EmptyView()
                }
                .navigationDestination(isPresented: $navigateToQuiz) {
                    QuizScreen()
                        .onAppear {
                            startBackgroundMovement(screenWidth: geometry.size.width)
                        }
                }
            }
            .edgesIgnoringSafeArea(.all)
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
        offset = 0
    }
}
