import SwiftUI

extension Text {
    func gFont(_ size: CGFloat) -> some View {
        let baseFont = UIFont(name: "ITC Bauhaus Heavy", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
        let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        
        return self
            .font(Font(scaledFont))
            .foregroundStyle(.white)
            .shadow(color: .blue, radius: 1, x: 0.5, y: 0.5)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
    }
}

struct Extension_Text: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .gFont(32)
    }
}

#Preview {
    Extension_Text()
}
