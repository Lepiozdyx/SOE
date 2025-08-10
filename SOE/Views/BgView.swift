import SwiftUI

struct BgView: View {
    var body: some View {
        Image(.bg)
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    BgView()
}
