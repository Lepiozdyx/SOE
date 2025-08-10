import SwiftUI

struct CoinBoardView: View {
    let coins: Int
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Image(.buttonM)
            .resizable()
            .frame(maxWidth: width, maxHeight: height)
            .overlay {
                Text("\(coins)")
                    .gFont(24)
                    .offset(x: 12)
            }
            .overlay(alignment: .leading) {
                Image(.coin)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .padding(.leading, 8)
            }
    }
}

#Preview {
    CoinBoardView(coins: 1000, width: 150, height: 60)
}
