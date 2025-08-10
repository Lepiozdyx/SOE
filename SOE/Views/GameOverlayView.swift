import SwiftUI

struct GameOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var mutationViewModel: MutationViewModel
    
    @State private var mutationButtonScale: CGFloat = 1.0
    @State private var mutationButtonOpacity: Double = 1.0
    @State private var pulseAnimation: Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                // Pause button
                CircleButtonView(iconName: .home, height: 50) {
                    appViewModel.pauseGame()
                }
                
                Spacer()
     
                // Mutation button
                if mutationViewModel.canShowMutationButton() {
                    ActionButtonView(
                        title: "Mutation",
                        fontSize: 20,
                        width: 150,
                        height: 50
                    ) {
                        mutationViewModel.openMutationOverlay()
                    }
                    .scaleEffect(pulseAnimation ? 1.0 : 0.9)
                    .shadow(
                        color: pulseAnimation ? .yellow.opacity(0.8) : .clear,
                        radius: pulseAnimation ? 10 : 0
                    )
                    .animation(
                        Animation.easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
                    .opacity(mutationButtonOpacity)
                    .onAppear {
                        pulseAnimation = true
                    }
                    .onDisappear {
                        pulseAnimation = false
                    }
                }
                
                Spacer()
                
                // DNA counter (resources)
                CoinBoardView(
                    coins: mutationViewModel.availableResources,
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
    let mutationVM = MutationViewModel()
    
    // Setup for preview
    mutationVM.mutationState.availableResources = 15
    appVM.gameViewModel = gameVM
    
    return GameOverlayView(
        gameViewModel: gameVM,
        mutationViewModel: mutationVM
    )
    .environmentObject(appVM)
    .background(Color.blue.opacity(0.3))
}
