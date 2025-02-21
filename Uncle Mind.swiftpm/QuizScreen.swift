import SwiftUI

struct QuizScreen: View {
    @State private var showText = false
    @State private var offsetY: CGFloat = 0
    @State private var scaleEffect: CGFloat = 1
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F5DC")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("uncle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 350)
                    .scaleEffect(scaleEffect)
                    .offset(y: offsetY)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: scaleEffect)
                    .onAppear {
                        offsetY = 20
                        scaleEffect = 1.1
                    }
                
                if showText {
                    Text("Hello, my name is Martin and I'll teach you the basics of Clean Coding!")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "#2E8B57"))
                        .multilineTextAlignment(.center)
                        .padding()
                        .transition(.opacity)
                        .animation(.easeIn(duration: 2), value: showText)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showText = true
                }
            }
        }
    }
}

