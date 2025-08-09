import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var gridOpacity: Double = 0
    @State private var gridOffset: CGFloat = 50
    
    private let totalLevels = 3
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            VStack {
                HStack(alignment: .top) {
                    CircleButtonView(iconName: .home, height: 60) {
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    Image(.labelFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .overlay {
                            Text("choose a level")
                                .gFont(24)
                        }
                    
                    Spacer()
                    
                    // Coins counter
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 55
                    )
                }
                
                Spacer()
            }
            .padding()
            
            // Level grid
            HStack(spacing: 30) {
                ForEach(1...totalLevels, id: \.self) { level in
                    LevelTileView(
                        level: level
                    )
                    .environmentObject(appViewModel)
                }
            }
            .padding(.horizontal)
            .opacity(gridOpacity)
            .offset(y: gridOffset)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                gridOffset = 0
                gridOpacity = 1.0
            }
        }
    }
}

struct LevelTileView: View {
    private var isLocked: Bool {
        return level > appViewModel.gameState.maxAvailableLevel
    }
    
    let level: Int
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        Button {
            if !isLocked {
                appViewModel.startGame(level: level)
            }
        } label: {
            ZStack {
                if isLocked {
                    Image(.lvlBtnLocked)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                } else {
                    Image(getLvlImageName())
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                }
            }
        }
        .disabled(isLocked)
    }
    
    private func getLvlImageName() -> ImageResource {
        switch level {
        case 1:
            return .lvlBtnFirststeps
        case 2:
            return .lvlBtnDeepadaptation
        default:
            return .lvlBtnPeakofevolution
        }
    }
}

#Preview {
    LevelSelectView()
        .environmentObject(AppViewModel())
}
