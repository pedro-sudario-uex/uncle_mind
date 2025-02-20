import SwiftUI

struct ParallaxLayer: View {
    let imageName: String
    let offset: CGFloat
    let speed: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .offset(x: offset * speed, y: 0)
            
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .offset(x: offset * speed + width, y: 0)
        }
        .clipped()
    }
}
