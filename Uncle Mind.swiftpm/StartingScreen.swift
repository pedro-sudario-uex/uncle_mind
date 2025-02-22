import SwiftUI
import AVFoundation

class AudioPlayerManager: ObservableObject {
    @Published var audioPlayer: AVAudioPlayer?
    
    func startLoopedMusic() {
        guard let musicURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicURL)
            audioPlayer?.numberOfLoops = -1 
            audioPlayer?.play()
        } catch {
            print("Error loading music: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
    }
}

struct StartingScreen: View {
    @State private var offset: CGFloat = 0
    @State private var timer: Timer? = nil
    @State private var timeElapsed: CGFloat = 0
    @State private var navigateToQuiz = false
    @StateObject private var audioManager = AudioPlayerManager()
    
    let parallaxLayers: [(nome: String, speed: CGFloat, width: CGFloat)] = [
        ("forest_sky",       0.0, 6000),
        ("forest_moon",      0.0, 1400),
        ("forest_mountain",  0.0, 6000),
        ("forest_back",      0.0, 6000),
        ("forest_long",      0.2, 1400),
        ("forest_mid",       0.5, 1400),
        ("forest_short",     0.5, 1400)
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
                            width: geometry.size.width * 1.5,
                            height: geometry.size.height * 1.5
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
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    startBackgroundMovement(screenWidth: geometry.size.width)
                    audioManager.startLoopedMusic()
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


