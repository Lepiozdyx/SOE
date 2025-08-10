import SwiftUI

struct ActionButtonView: View {
    let title: String
    let fontSize: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Image(.btnAction)
                    .resizable()
                    .frame(maxWidth: width, maxHeight: height)
                
                Text(title)
                    .gFont(fontSize)
            }
        }
        .withSound()
    }
}

#Preview {
    ActionButtonView(title: "Tournament", fontSize: 20, width: 250, height: 100) {}
}
