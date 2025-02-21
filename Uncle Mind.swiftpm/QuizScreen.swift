import SwiftUI



struct DialogueNode: Identifiable {
    let id: Int
    let text: String
    let responses: [DialogueResponse]
}

struct DialogueResponse: Identifiable {
    let id = UUID()
    let text: String
    let nextNodeId: Int?
}

struct QuizScreen: View {
    @State private var currentNodeId = 0
    // Timer-based offset variables for continuous movement.
    @State private var offset: CGFloat = 0
    @State private var timer: Timer? = nil
    @State private var timeElapsed: CGFloat = 0

    private static let dialogueNodes: [DialogueNode] = [
        DialogueNode(id: 0, text: "Hello, my name is Martin and I'll teach you the basics of Clean Coding!", responses: [
            DialogueResponse(text: "Let's Start!", nextNodeId: 1),
            DialogueResponse(text: "Tell me more", nextNodeId: 2)
        ]),
        DialogueNode(id: 1, text: "Woah, not so fast little one! It won't be a simple task! Took me years to master it! I know you are very excited but.....", responses: [
            DialogueResponse(text: "I'm ready!", nextNodeId: 3),
            DialogueResponse(text: "Maybe not...", nextNodeId: 0)
        ]),
        DialogueNode(id: 2, text: "I've been living in this forest all my life, mastering the art of code and nature. Are you sure you want to proceed?", responses: [
            DialogueResponse(text: "Yes, show me", nextNodeId: 1),
            DialogueResponse(text: "I need time", nextNodeId: nil)
        ]),
        DialogueNode(id: 3, text: "You see this tree here? It's strong because it's built on deep roots. Code is no different! If your code isn't readable, it's like a tangled vine—no one can make sense of it.", responses: [
            DialogueResponse(text: "Tell me more", nextNodeId: 4)
        ]),
        DialogueNode(id: 4, text: "Functions should be small, like branches, focused and clear. Don't try to grow a whole forest from one branch, or you'll topple over!", responses: [
            DialogueResponse(text: "Got it", nextNodeId: nil)
        ])
    ]
    
    private var dialogueNodes: [DialogueNode] {
        Self.dialogueNodes
    }
    
    private var currentNode: DialogueNode {
        dialogueNodes.first(where: { $0.id == currentNodeId }) ?? dialogueNodes[0]
    }
    
    // Define each layer with its image name and parallax speed.
    private let parallaxLayers: [(nome: String, speed: CGFloat)] = [
        ("forest_sky",       0.0),
        ("forest_moon",      0.0),
        ("forest_mountain",  0.0),
        ("forest_back",      0.0),
        ("forest_long",      0.2),
        ("forest_mid",       0.5),
        ("forest_short",     0.5)
    ]
    
    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 16) {
                uncleImage
                Text(currentNode.text)
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding()
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
    
    private var uncleImage: some View {
        Image("uncle")
            .resizable()
            .scaledToFit()
            .frame(width: 250, height: 350)
            .scaleEffect(1.1)
            .offset(y: 20)
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
            if let nextId = response.nextNodeId {
                currentNodeId = nextId
            } else {
                currentNodeId = 0
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
