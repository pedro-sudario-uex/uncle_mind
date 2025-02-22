import SwiftUI
import AVFoundation

struct DialogueNode: Identifiable {
    let id: Int
    var text: String
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
    @State private var playerName: String = "" 
    @State private var isNameEntered: Bool = false 
    @State private var shuffledResponses: [DialogueResponse] = []
    
    private var dialogueNodes: [DialogueNode] = [
        DialogueNode(id: 0, text: "Hello, what’s your name?", responses: [
            DialogueResponse(text: "My name is Martin!", nextNodeId: 1, isCorrect: true, isProgression: false),
            DialogueResponse(text: "I'm not sure if I want to tell you.", nextNodeId: 0, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 1, text: "Nice to meet you, {name}! I’ll teach you the basics of Clean Coding!", responses: [
            DialogueResponse(text: "Yay! Let's start!!!", nextNodeId: 3, isCorrect: true, isProgression: true),
            DialogueResponse(text: "Tell me about yourself Martin!", nextNodeId: 2, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 2, text: "I've been living in this forest all my life gathering examples of how code works. When you stop for a long time to analyze and it and compare with nature, a lot of principles of coding are very similar to concepts in nature. So I decided to reunite these examples and teach them to people.", responses: [
            DialogueResponse(text: "Loved your story!", nextNodeId: 1, isCorrect: true, isProgression: true),
        ]),
        DialogueNode(id: 3, text: "You see this tree here? It's strong because it's built on deep roots. Code is no different! If your code isn't readable, it's like a tangled vine—no one can make sense of it.", responses: [
            DialogueResponse(text: "Got it! No messy codes!", nextNodeId: 4, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 4, text: "Functions should be small, like branches, focused and clear. Don't try to grow a whole forest from one branch, or you'll topple over!", responses: [
            DialogueResponse(text: "Small and mighty!", nextNodeId: 5, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 5, text: "Rivers flow smoothly because they follow a clear path. Your code should do the same. Avoid unnecessary twists and turns. Keep it simple!", responses: [
            DialogueResponse(text: "Simplicity? Okay!", nextNodeId: 6, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 6, text: "Birds build their nests with care, choosing only what’s necessary. Write your code the same way, {name}—don’t clutter it with unnecessary elements.", responses: [
            DialogueResponse(text: "I see, no clutter, just essentials.", nextNodeId: 7, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 7, text: "The sun rises and sets predictably every day. Your code should be predictable too. Consistent naming and structure make it easier to follow.", responses: [
            DialogueResponse(text: "Consistency is key! Got it.", nextNodeId: 8, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 8, text: "Ants work in teams with clear roles. Your functions and classes should do the same—single responsibility makes everything efficient!", responses: [
            DialogueResponse(text: "Efficiency, just like the ants!", nextNodeId: 9, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 9, text: "Now, {name}, let's see if you were paying attention!", responses: [
            DialogueResponse(text: "I’m ready for the quiz! Hit me with it.", nextNodeId: 10, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 10, text: "Which nature example teaches us to keep our code readable and structured?", responses: [
            DialogueResponse(text: "The tree with deep roots", nextNodeId: 11, isCorrect: true, isProgression: false),
            DialogueResponse(text: "The sun rising and setting", nextNodeId: 12, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 11, text: "Correct! {name}, code needs strong foundations, just like a tree!", responses: [
            DialogueResponse(text: "Next question, let’s keep it rolling!", nextNodeId: 13, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 12, text: "Not quite! The sun example was about consistency. Try again!", responses: [
            DialogueResponse(text: "I’ll give it another shot!", nextNodeId: 10, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 13, text: "Which example represents the importance of avoiding clutter?", responses: [
            DialogueResponse(text: "The birds building their nests", nextNodeId: 14, isCorrect: true, isProgression: false),
            DialogueResponse(text: "The river flowing smoothly", nextNodeId: 15, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 14, text: "Correct! {name}, keep your code lean, just like a well-built nest!", responses: [
            DialogueResponse(text: "I’m on fire! What’s next?", nextNodeId: 16, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 15, text: "Close! The river was about simplicity. Try again!", responses: [
            DialogueResponse(text: "Let's do this again!", nextNodeId: 13, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 16, text: "Which nature example teaches us to avoid unnecessary twists and turns?", responses: [
            DialogueResponse(text: "The river flowing smoothly", nextNodeId: 17, isCorrect: true, isProgression: false),
            DialogueResponse(text: "The birds building their nests", nextNodeId: 18, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 17, text: "Correct! {name}, keep your code flowing without distractions, just like a river!", responses: [
            DialogueResponse(text: "What’s next? I’m ready!", nextNodeId: 19, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 18, text: "Not quite! The birds' example was about avoiding clutter. Try again!", responses: [
            DialogueResponse(text: "I'll try again!", nextNodeId: 16, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 19, text: "Which nature example teaches us the importance of small and focused functions?", responses: [
            DialogueResponse(text: "The branches of the tree", nextNodeId: 20, isCorrect: true, isProgression: false),
            DialogueResponse(text: "The ants working in teams", nextNodeId: 21, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 20, text: "Great! {name}, small branches lead to a stronger tree. Keep your functions focused and small!", responses: [
            DialogueResponse(text: "Let’s keep going!", nextNodeId: 22, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 21, text: "Close! Ants work efficiently as a team, but the branches example was about small functions. Try again!", responses: [
            DialogueResponse(text: "I’ll give it another go!", nextNodeId: 19, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 22, text: "Now, let’s wrap it up! Which example shows the importance of consistency in code?", responses: [
            DialogueResponse(text: "The sun", nextNodeId: 23, isCorrect: true, isProgression: false),
            DialogueResponse(text: "The tree with deep roots", nextNodeId: 24, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 23, text: "Exactly! {name}, just like the sun, your code should always be predictable and consistent.", responses: [
            DialogueResponse(text: "I’m feeling confident! What’s next?", nextNodeId: 25, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 24, text: "Not quite! The tree example was about strong foundations. Try again!", responses: [
            DialogueResponse(text: "Let’s try again!", nextNodeId: 22, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 25, text: "You’ve learned well, {name}. One last question: What’s the most important thing to remember when writing clean code?", responses: [
            DialogueResponse(text: "Keep it simple, readable, and predictable!", nextNodeId: 26, isCorrect: true, isProgression: true),
            DialogueResponse(text: "Always try to make it complex and feature-rich!", nextNodeId: 27, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 26, text: "Well done {name}!, you got a nice starting glimpse of clean code. Let's dive deeper?", responses: [
            DialogueResponse(text: "Yeah!!", nextNodeId: 27, isCorrect: nil, isProgression: true)
        ]),

        DialogueNode(id: 27, text: "Great! Just like a river needs banks to guide its flow, your code needs structure. Without it, it will overflow into chaos.", responses: [
            DialogueResponse(text: "I see, structure brings order to the code.", nextNodeId: 28, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 28, text: "Think of your code like a well-tended garden. Each plant has its place, and each function has its purpose. Don't let it become a wild jungle!", responses: [
            DialogueResponse(text: "I'll prune my code carefully!", nextNodeId: 29, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 29, text: "Here’s the key: Make sure your functions do one thing, and do it well. {name}, that’s the way to keep your code clean and efficient.", responses: [
            DialogueResponse(text: "One thing at a time, I got it!", nextNodeId: 30, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 30, text: "Let’s talk about comments. Don’t use them to explain bad code! Use them to explain why you wrote it the way you did. Clean code should be self-explanatory.", responses: [
            DialogueResponse(text: "So comments are for context, not explanations?", nextNodeId: 31, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 31, text: "Exactly, {name}! Now, let's talk about testing. Like a farmer checks the soil before planting, you should test your code to ensure it grows as expected.", responses: [
            DialogueResponse(text: "Testing, got it! I'll make sure everything’s in order before I deploy.", nextNodeId: 32, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 32, text: "Perfect! Now let's take a last quiz on what you've learned so far, {name}!", responses: [
            DialogueResponse(text: "Bring it on! I’m ready for the challenge.", nextNodeId: 33, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 33, text: "What does clean code need most?", responses: [
            DialogueResponse(text: "Structure and clarity", nextNodeId: 34, isCorrect: true, isProgression: false),
            DialogueResponse(text: "Size and speed", nextNodeId: 35, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 34, text: "Correct, {name}! Clean code needs structure and clarity to be effective. Well done!", responses: [
            DialogueResponse(text: "What’s next? I’m feeling confident!", nextNodeId: 36, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 35, text: "Not quite, {name}! Size and speed are important, but structure and clarity are essential for clean code. Try again!", responses: [
            DialogueResponse(text: "I’ll get it right this time!", nextNodeId: 33, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 36, text: "What’s the purpose of comments in clean code, {name}?", responses: [
            DialogueResponse(text: "To explain why the code was written a certain way", nextNodeId: 37, isCorrect: true, isProgression: false),
            DialogueResponse(text: "To explain what the code is doing", nextNodeId: 38, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 37, text: "Exactly, {name}! Comments should explain the rationale behind your decisions, not the obvious parts. Great job!", responses: [
            DialogueResponse(text: "I'm on fire! Keep it coming!", nextNodeId: 30, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 38, text: "Hmm, not quite, {name}. The code should speak for itself. Comments are for explaining why, not what. Try again!", responses: [
            DialogueResponse(text: "Let me try again, Martin.", nextNodeId: 36, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 39, text: "Which of these is true about testing, {name}?", responses: [
            DialogueResponse(text: "Testing ensures the code behaves as expected", nextNodeId: 40, isCorrect: true, isProgression: false),
            DialogueResponse(text: "Testing is only for large applications", nextNodeId: 41, isCorrect: false, isProgression: true)
        ]),
        DialogueNode(id: 40, text: "Correct! Testing helps catch issues early, just like inspecting crops before harvest. Keep it up, {name}!", responses: [
            DialogueResponse(text: "I'm ready for the next challenge, Martin!", nextNodeId: 33, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 41, text: "Not exactly, {name}! Testing is important for any code, big or small. Don’t skip it! Try again!", responses: [
            DialogueResponse(text: "I’m getting back on track!", nextNodeId: 39, isCorrect: false, isProgression: false)
        ]),
        DialogueNode(id: 42, text: "You’ve done an amazing job, {name}! You’re well on your way to mastering clean code. Ready to test your skills in a real coding challenge?", responses: [
            DialogueResponse(text: "Let’s do this! I’m ready for the challenge.", nextNodeId: 34, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 43, text: "Look at this function written in Swift, {name}. It performs multiple tasks and has some side effects. How would you improve it to make it more readable and maintainable while adhering to clean code principles?", responses: [
            DialogueResponse(text: "Split the function into smaller, single-responsibility functions, eliminate side effects, and ensure each function does one thing well.", nextNodeId: 44, isCorrect: true, isProgression: false),
            DialogueResponse(text: "Focus only on optimizing the performance of the function and leave the structure as is.", nextNodeId: 45, isCorrect: false, isProgression: false),
            DialogueResponse(text: "Refactor by adding more error handling and logging without changing the structure of the function.", nextNodeId: 45, isCorrect: false, isProgression: false)
        ], codeSnippet: """
    func handleDataProcessing(data: String, shouldLog: Bool, completion: (Bool) -> Void) {
        let processedData = data.lowercased()
        let dataLength = processedData.count
        if shouldLog {
            print("Processing data: \\(data)")
        }
        if dataLength < 5 {
            print("Data is too short.")
            completion(false)
        } else {
            let result = processedData.reversed()
            print("Processed Result: \\(result)")
            completion(true)
        }
    }
    """),
        
        DialogueNode(id: 44, text: "Well done! You've identified that the function should be split into smaller functions with a single responsibility. You also recognized that side effects like printing and logging should be handled separately from core logic. Great job, {name}!", responses: [
            DialogueResponse(text: "Thanks, Martin! What’s next?", nextNodeId: 44, isCorrect: true, isProgression: true)
        ]),
        DialogueNode(id: 45, text: "Wrong! Try again. I won't give hints this time!", responses: [
            DialogueResponse(text: "Ouch, okay..", nextNodeId: 43, isCorrect: true, isProgression: true)
        ]),
        

    ]

    private var currentNode: DialogueNode {
        var node = dialogueNodes.first(where: { $0.id == currentNodeId }) ?? dialogueNodes[0]
        
        node.text = node.text.replacingOccurrences(of: "{name}", with: playerName)
 
        return node
    }


    let parallaxLayers: [(nome: String, speed: CGFloat, width: CGFloat)] = [
        ("forest_sky",       0.0, 6000),
        ("forest_moon",      0.0, 1400),
        ("forest_mountain",  0.0, 6000),
        ("forest_back",      0.0, 6000),
        ("forest_long",      0.2, 1400),
        ("forest_mid",       0.5, 1400),
        ("forest_short",     0.5, 1400)
    ]
    
    @State private var showButtons = false

    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 16) {
                uncleImage
                if currentNodeId == 0 {
                    Text(currentNode.text)
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: Color.black.opacity(0.8), radius: 4, x: 2, y: 2)
                        .padding()
                    
                    TextField("Enter your name", text: $playerName)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding([.leading, .trailing], 20)
                    
                    Button("Submit Name") {
                        if !playerName.isEmpty {
                            isNameEntered = true
                            currentNodeId = 1
                            shuffleResponses()
                        }
                    }
                    .padding()
                    .background(Color(hex: "E0CFB1"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
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
                        .onAppear() {
                            showButtons = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showButtons = true 
                            }
                        }
                        .onChange(of: currentNode.text) { _ in
                            showButtons = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showButtons = true 
                            }
                        }
   
                    
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
                    
                    
                    if showButtons { // Only show buttons after 5 seconds
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
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                            }
                        }
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
                        width: geometry.size.width * 1.5,
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
