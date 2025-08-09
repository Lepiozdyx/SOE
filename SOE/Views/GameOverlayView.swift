import SwiftUI

struct GameOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                // Кнопка паузы
                CircleButtonView(iconName: .home, height: 50) {
                    appViewModel.pauseGame()
                }
                
                Spacer()
                
                // Появляющаяся кнопка Upgrade
                
                Spacer()
                
                CoinBoardView(
                    coins: gameViewModel.score,
                    width: 140,
                    height: 45
                )
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let appVM = AppViewModel()
    let gameVM = GameViewModel()
    appVM.gameViewModel = gameVM
    
    return GameOverlayView(gameViewModel: gameVM)
        .environmentObject(appVM)
        .background(Color.blue.opacity(0.3))
}
