import SwiftUI
import AVFoundation

struct DialogueNode: Identifiable {
    let id: Int
    let text: String
    var responses: [DialogueResponse]
    var codeSnippet: String?
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
    
    @State private var shuffledResponses: [DialogueResponse] = []
    
    private static let dialogueNodes: [DialogueNode] = [
        DialogueNode(id: 0, text: "Hello, my name is Martin and I'll teach you the basics of Clean Coding!", responses: [
            DialogueResponse(text: "Let’s jump into the world of clean code!", nextNodeId: 1, isCorrect: true, isProgression: true),
            DialogueResponse(text: "I’m curious, tell me more about you first!", nextNodeId: 2, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 1, text: "Woah, not so fast little one! It won't be a simple task! Took me years to master it! I know you are very excited but.....", responses: [
            DialogueResponse(text: "Bring it on, Martin! I’m ready for the challenge!", nextNodeId: 3, isCorrect: true, isProgression: true),
            DialogueResponse(text: "Uh-oh, maybe this isn't for me...", nextNodeId: 0, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 2, text: "I've been living in this forest all my life, mastering the art of code and nature. Are you sure you want to proceed?", responses: [
            DialogueResponse(text: "Absolutely! Show me the way!", nextNodeId: 1, isCorrect: true, isProgression: true),
            DialogueResponse(text: "I need some time to think", nextNodeId: nil, isCorrect: nil, isProgression: true)
        ]),
        DialogueNode(id: 3, text: "You see this tree here? It's strong because it's built on deep roots. Code is no different! If your code isn't readable, it's like a tangled vine—no one can make sense of it.", responses: [
            DialogueResponse(text: "I like that! Tell me more about the roots of clean code.", nextNodeId: 4, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 4, text: "Functions should be small, like branches, focused and clear. Don't try to grow a whole forest from one branch, or you'll topple over!", responses: [
            DialogueResponse(text: "Got it! Small and mighty!", nextNodeId: 5, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 5, text: "Rivers flow smoothly because they follow a clear path. Your code should do the same—avoid unnecessary twists and turns. Keep it simple!", responses: [
            DialogueResponse(text: "Like a river of code! I get it.", nextNodeId: 6, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 6, text: "Birds build their nests with care, choosing only what’s necessary. Write your code the same way—don’t clutter it with unnecessary elements.", responses: [
            DialogueResponse(text: "I see, no clutter, just essentials.", nextNodeId: 7, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 7, text: "The sun rises and sets predictably every day. Your code should be predictable too—consistent naming and structure make it easier to follow.", responses: [
            DialogueResponse(text: "Consistency is key! Got it.", nextNodeId: 8, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 8, text: "Ants work in teams with clear roles. Your functions and classes should do the same—single responsibility makes everything efficient!", responses: [
            DialogueResponse(text: "Efficiency, just like the ants!", nextNodeId: 9, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 9, text: "Now, let's see if you were paying attention!", responses: [
            DialogueResponse(text: "I’m ready for the quiz! Hit me with it.", nextNodeId: 10, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 10, text: "Which nature example teaches us to keep our code readable and structured?", responses: [
            DialogueResponse(text: "The tree with deep roots", nextNodeId: 11, isCorrect: true, isProgression: false),
            DialogueResponse(text: "The sun rising and setting", nextNodeId: 12, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 11, text: "Correct! Code needs strong foundations, just like a tree!", responses: [
            DialogueResponse(text: "Next question, let’s keep it rolling!", nextNodeId: 13, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 12, text: "Not quite! The sun example was about consistency. Try again!", responses: [
            DialogueResponse(text: "I’ll give it another shot!", nextNodeId: 10, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 13, text: "Which example represents the importance of avoiding clutter?", responses: [
            DialogueResponse(text: "The birds building their nests", nextNodeId: 14, isCorrect: true, isProgression: false),
            DialogueResponse(text: "The river flowing smoothly", nextNodeId: 15, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 14, text: "Correct! Keep your code lean, just like a well-built nest!", responses: [
            DialogueResponse(text: "I’m on fire! What’s next?", nextNodeId: 16, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 15, text: "Close! The river was about simplicity. Try again!", responses: [
            DialogueResponse(text: "Let's do this again!", nextNodeId: 13, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 16, text: "You did great with the first questions! Keep it up, you're on the right track!", responses: [
            DialogueResponse(text: "Thanks, Martin! I’m ready for more!", nextNodeId: 17, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 17, text: "You’re on a roll! But remember, not everything in code is always easy. Let's dive deeper into clean code. Are you ready?", responses: [
            DialogueResponse(text: "I was born ready, Martin! Let’s keep going!", nextNodeId: 18, isCorrect: true, isProgression: true),
            DialogueResponse(text: "Maybe I need a little break first...", nextNodeId: 0, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 18, text: "Great! Just like a river needs banks to guide its flow, your code needs structure. Without it, it will overflow into chaos.", responses: [
            DialogueResponse(text: "I see, structure brings order to the code.", nextNodeId: 19, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 19, text: "Think of your code like a well-tended garden. Each plant has its place, and each function has its purpose. Don't let it become a wild jungle!", responses: [
            DialogueResponse(text: "I'll prune my code carefully!", nextNodeId: 20, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 20, text: "Here’s the key: Make sure your functions do one thing, and do it well. That’s the way to keep your code clean and efficient.", responses: [
            DialogueResponse(text: "One thing at a time, I got it!", nextNodeId: 21, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 21, text: "Let’s talk about comments. Don’t use them to explain bad code! Use them to explain why you wrote it the way you did. Clean code should be self-explanatory.", responses: [
            DialogueResponse(text: "So comments are for context, not explanations?", nextNodeId: 22, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 22, text: "Exactly! Now, let's talk about testing. Like a farmer checks the soil before planting, you should test your code to ensure it grows as expected.", responses: [
            DialogueResponse(text: "Testing, got it! I'll make sure everything’s in order before I deploy.", nextNodeId: 23, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 23, text: "Perfect! Now let's take a quiz on what you've learned so far!", responses: [
            DialogueResponse(text: "Bring it on! I’m ready for the challenge.", nextNodeId: 24, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 24, text: "What does clean code need most?", responses: [
            DialogueResponse(text: "Structure and clarity", nextNodeId: 25, isCorrect: true, isProgression: false),
            DialogueResponse(text: "Size and speed", nextNodeId: 26, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 25, text: "Correct! Clean code needs structure and clarity to be effective. Well done!", responses: [
            DialogueResponse(text: "What’s next? I’m feeling confident!", nextNodeId: 27, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 26, text: "Not quite! Size and speed are important, but structure and clarity are essential for clean code. Try again!", responses: [
            DialogueResponse(text: "I’ll get it right this time!", nextNodeId: 24, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 27, text: "What’s the purpose of comments in clean code?", responses: [
            DialogueResponse(text: "To explain why the code was written a certain way", nextNodeId: 28, isCorrect: true, isProgression: false),
            DialogueResponse(text: "To explain what the code is doing", nextNodeId: 29, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 28, text: "Exactly! Comments should explain the rationale behind your decisions, not the obvious parts. Great job!", responses: [
            DialogueResponse(text: "I'm on fire! Keep it coming!", nextNodeId: 30, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 29, text: "Hmm, not quite. The code should speak for itself. Comments are for explaining why, not what. Try again!", responses: [
            DialogueResponse(text: "Let me try again, Martin.", nextNodeId: 27, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 30, text: "Which of these is true about testing?", responses: [
            DialogueResponse(text: "Testing ensures the code behaves as expected", nextNodeId: 31, isCorrect: true, isProgression: false),
            DialogueResponse(text: "Testing is only for large applications", nextNodeId: 32, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 31, text: "Correct! Testing helps catch issues early, just like inspecting crops before harvest. Keep it up!", responses: [
            DialogueResponse(text: "I'm ready for the next challenge, Martin!", nextNodeId: 33, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 32, text: "Not exactly! Testing is important for any code, big or small. Don’t skip it! Try again!", responses: [
            DialogueResponse(text: "I’m getting back on track!", nextNodeId: 30, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 33, text: "You’ve done an amazing job! You’re well on your way to mastering clean code. Ready to test your skills in a real coding challenge?", responses: [
            DialogueResponse(text: "Let’s do this! I’m ready for the challenge.", nextNodeId: 34, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 34, text: "What would you change to make it clean and readable?", responses: [
            DialogueResponse(text: "Refactor this code by splitting it into smaller functions with clear names and removing unnecessary comments.", nextNodeId: 35, isCorrect: true, isProgression: false),
            DialogueResponse(text: "Leave it as it is. It's working fine.", nextNodeId: 36, isCorrect: false, isProgression: false),
            DialogueResponse(text: "Add more comments to explain the code.", nextNodeId: 36, isCorrect: false, isProgression: false)
        ], codeSnippet: """
                func processData(data: String) {
                    let processedData = data.uppercased()
                    print("Processed Data: (processedData)")
                    if processedData.count > 5 {
                        print("Data is long")
                    } else {
                        print("Data is short")
                    }
                }
                """),
        
        DialogueNode(id: 35, text: "You did it! You've mastered the art of clean code. You're ready for any coding challenge that comes your way!", responses: [
            DialogueResponse(text: "Thank you, Martin! I’m ready for the next step!", nextNodeId: nil, isCorrect: true, isProgression: true)
        ]),
        
        DialogueNode(id: 36, text: "Nope. Not like that.", responses: [
            DialogueResponse(text: "Oof, okay I will try again", nextNodeId: 34, isCorrect: false, isProgression: false)
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
                if let codeSnippet = currentNode.codeSnippet {
                    Text(codeSnippet)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .background(.black)
                        .foregroundColor(.white)
                        .padding()
                        .border(Color.white, width: 2)
                        .frame(width: 300, height: 200)
                        .multilineTextAlignment(.leading)
                }
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

                ForEach(shuffledResponses) { response in
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
            shuffleResponses()
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
                        width: geometry.size.width,
                        height: geometry.size.height * 1.5  
                    )
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .allowsHitTesting(false)
    }
    
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
                    shuffleResponses()
                }
            } else if let isCorrect = response.isCorrect, isCorrect {
                playCorrectAnswerSFX()
                if let nextId = response.nextNodeId {
                    currentNodeId = nextId
                    shuffleResponses()
                }
            } else {
                if let nextId = response.nextNodeId {
                    currentNodeId = nextId
                    shuffleResponses()
                }
            }
        }
    }

    private func shuffleResponses() {
        let currentNode = self.currentNode
        shuffledResponses = currentNode.responses.shuffled()
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
