import SwiftUI
import AVFoundation

struct DialogueNode: Identifiable {
    let id: Int
    let text: String
    let responses: [DialogueResponse]
}

struct DialogueResponse: Identifiable {
    let id = UUID()
    let text: String
    let nextNodeId: Int?
    let isCorrect: Bool?
    let isProgression: Bool
}

struct QuizScreen: View {
    @State private var currentNodeId = 0
    @State private var offset: CGFloat = 0
    @State private var timer: Timer? = nil
    @State private var timeElapsed: CGFloat = 0
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var correctAnswerPlayer: AVAudioPlayer? = nil

    private static let dialogueNodes: [DialogueNode] = [
        DialogueNode(id: 0, text: "Hello, my name is Martin and I'll teach you the basics of Clean Coding!", responses: [
            DialogueResponse(text: "Let's Start!", nextNodeId: 1, isCorrect: true, isProgression: true),
            DialogueResponse(text: "Tell me more", nextNodeId: 2, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 1, text: "Woah, not so fast little one! It won't be a simple task! Took me years to master it! I know you are very excited but.....", responses: [
            DialogueResponse(text: "I'm ready!", nextNodeId: 3, isCorrect: true, isProgression: true),
            DialogueResponse(text: "Maybe not...", nextNodeId: 0, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 2, text: "I've been living in this forest all my life, mastering the art of code and nature. Are you sure you want to proceed?", responses: [
            DialogueResponse(text: "Yes, show me", nextNodeId: 1, isCorrect: true, isProgression: true),
            DialogueResponse(text: "I need time", nextNodeId: nil, isCorrect: nil, isProgression: true)
        ]),
        DialogueNode(id: 3, text: "You see this tree here? It's strong because it's built on deep roots. Code is no different! If your code isn't readable, it's like a tangled vine—no one can make sense of it.", responses: [
            DialogueResponse(text: "Tell me more", nextNodeId: 4, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 4, text: "Functions should be small, like branches, focused and clear. Don't try to grow a whole forest from one branch, or you'll topple over!", responses: [
            DialogueResponse(text: "Got it", nextNodeId: 5, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 5, text: "Rivers flow smoothly because they follow a clear path. Your code should do the same—avoid unnecessary twists and turns. Keep it simple!", responses: [
            DialogueResponse(text: "Makes sense!", nextNodeId: 6, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 6, text: "Birds build their nests with care, choosing only what’s necessary. Write your code the same way—don’t clutter it with unnecessary elements.", responses: [
            DialogueResponse(text: "Understood", nextNodeId: 7, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 7, text: "The sun rises and sets predictably every day. Your code should be predictable too—consistent naming and structure make it easier to follow.", responses: [
            DialogueResponse(text: "Good point", nextNodeId: 8, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 8, text: "Ants work in teams with clear roles. Your functions and classes should do the same—single responsibility makes everything efficient!", responses: [
            DialogueResponse(text: "I see now!", nextNodeId: 9, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 9, text: "Now, let's see if you were paying attention!", responses: [
            DialogueResponse(text: "Bring it on!", nextNodeId: 10, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 10, text: "Which nature example teaches us to keep our code readable and structured?", responses: [
            DialogueResponse(text: "The tree with deep roots", nextNodeId: 11, isCorrect: true, isProgression: false),
            DialogueResponse(text: "The sun rising and setting", nextNodeId: 12, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 11, text: "Correct! Code needs strong foundations, just like a tree!", responses: [
            DialogueResponse(text: "Next question!", nextNodeId: 13, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 12, text: "Not quite! The sun example was about consistency. Try again!", responses: [
            DialogueResponse(text: "Retry", nextNodeId: 10, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 13, text: "Which example represents the importance of avoiding clutter?", responses: [
            DialogueResponse(text: "The birds building their nests", nextNodeId: 14, isCorrect: true, isProgression: false),
            DialogueResponse(text: "The river flowing smoothly", nextNodeId: 15, isCorrect: false, isProgression: tru)
        ]),
        DialogueNode(id: 14, text: "Correct! Keep your code lean, just like a well-built nest!", responses: [
            DialogueResponse(text: "I learned a lot!", nextNodeId: nil, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 15, text: "Close! The river was about simplicity. Try again!", responses: [
            DialogueResponse(text: "Retry", nextNodeId: 13, isCorrect: false, isProgression: false)
        ])
    ]

    private var dialogueNodes: [DialogueNode] {
        Self.dialogueNodes
    }

    private var currentNode: DialogueNode {
        dialogueNodes.first(where: { $0.id == currentNodeId }) ?? dialogueNodes[0]
    }

    private let parallaxLayers: [(nome: String, speed: CGFloat)] = [
        ("forest_sky", 0.0),
        ("forest_moon", 0.0),
        ("forest_mountain", 0.0),
        ("forest_back", 0.0),
        ("forest_long", 0.2),
        ("forest_mid", 0.5),
        ("forest_short", 0.5)
    ]

    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 16) {
                uncleImage
                if currentNodeId == 6 {
                    Image("bird")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                        .padding(.bottom, 20)
                }
                Text(currentNode.text)
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.8), radius: 4, x: 2, y: 2)
                    .padding()

                if currentNodeId == 3 {
                    Image("tree")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                        .padding(.bottom, 20)
                }

                if currentNodeId == 4 {
                    Image("tree_branch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                        .padding(.bottom, 20)
                }

                ForEach(currentNode.responses) { response in
                    Button(action: {
                        handleResponse(response)
                    }) {
                        Text(response.text)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .frame(width: 200)
                            .background(Color(hex: "E0CFB1"))
                            .foregroundColor(Color(hex: "#2E8B57"))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                    }
                }
            }
        }
        .onAppear {
            startBackgroundMovement()
            setupAudioPlayer()
            setupCorrectAnswerPlayer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .edgesIgnoringSafeArea(.all)
    }

    private var backgroundView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(parallaxLayers, id: \.nome) { layer in
                    ParallaxLayer(
                        imageName: layer.nome,
                        offset: offset,
                        speed: layer.speed,
                        width: 1920,
                        height: 1200
                    )
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .allowsHitTesting(false)
    }
    
    // hide uncle sometimes (poor old man)
    private var uncleImage: some View {
        if [3, 4, 6].contains(currentNodeId) {
            return AnyView(EmptyView())
        } else {
            return AnyView(
                Image("uncle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 350)
                    .scaleEffect(1.1)
                    .offset(y: 20)
            )
        }
    }

    private func startBackgroundMovement() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            offset -= 2
            timeElapsed += 0.02
            if timeElapsed >= 15 {
                offset = 0
                timeElapsed = 0
            }
        }
    }

    private func handleResponse(_ response: DialogueResponse) {
        withAnimation {
            playClickSFX()

            if response.isProgression {
                if let nextId = response.nextNodeId {
                    currentNodeId = nextId
                }
            } else if let isCorrect = response.isCorrect, isCorrect {
                playCorrectAnswerSFX()
                if let nextId = response.nextNodeId {
                    currentNodeId = nextId
                }
            } else {
                if let nextId = response.nextNodeId {
                    currentNodeId = nextId
                }
            }
        }
    }

    private func playClickSFX() {
        audioPlayer?.play()
    }

    private func playCorrectAnswerSFX() {
        correctAnswerPlayer?.play()
    }

    private func setupAudioPlayer() {
        guard let musicURL = Bundle.main.url(forResource: "click_sfx", withExtension: "mp3") else {
            print("Click sound file not found.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicURL)
        } catch {
            print("Error loading click sound: \(error.localizedDescription)")
        }
    }
    
    private func setupCorrectAnswerPlayer() {
        guard let correctAnswerURL = Bundle.main.url(forResource: "correct_answer_sfx", withExtension: "mp3") else {
            print("Correct answer sound file not found.")
            return
        }

        do {
            correctAnswerPlayer = try AVAudioPlayer(contentsOf: correctAnswerURL)
        } catch {
            print("Error loading correct answer sound: \(error.localizedDescription)")
        }
    }
}


private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
