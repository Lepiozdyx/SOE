import SwiftUI

struct LoadingView: View {
    @State private var loading: CGFloat = 0
    
    var body: some View {
        ZStack {
            BgView()
            
            VStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Text("Loading...")
                        .gFont(26)
                    
                    Rectangle()
                        .foregroundStyle(.blue.opacity(0.5))
                        .frame(maxWidth: 300, maxHeight: 20)
                        .overlay {
                            Rectangle()
                                .stroke(.blue, lineWidth: 2)
                        }
                        .overlay(alignment: .top) {
                            Capsule()
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(height: 4)
                                .padding(.horizontal, 10)
                                .padding(.top, 3)
                        }
                        .shadow(radius: 2)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .foregroundStyle(.teal.opacity(0.8))
                                .frame(width: 298 * loading, height: 18)
                                .padding(.horizontal, 1)
                        }
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5)) {
                loading = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}
