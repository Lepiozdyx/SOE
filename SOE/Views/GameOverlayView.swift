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
                
                // DEBUG: Show mutation state
                Text("DEBUG: Resources: \(mutationViewModel.availableResources), Cost: \(mutationViewModel.nextMutationCost), CanShow: \(mutationViewModel.canShowMutationButton())")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                
                Spacer()
                
                // Mutation button - appears when player can afford mutation
                if mutationViewModel.canShowMutationButton() {
                    Button {
                        print("DEBUG: Mutation button pressed")
                        mutationViewModel.openMutationOverlay()
                    } label: {
                        VStack(spacing: 4) {
                            // Mutation icon
                            Image(.btnCircle)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .overlay {
                                    Image(systemName: "shuffle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                        .foregroundStyle(.white)
                                }
                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                                .shadow(
                                    color: pulseAnimation ? .yellow.opacity(0.8) : .clear,
                                    radius: pulseAnimation ? 10 : 0
                                )
                                .animation(
                                    Animation.easeInOut(duration: 1.2)
                                        .repeatForever(autoreverses: true),
                                    value: pulseAnimation
                                )
                            
                            // Cost display
                            HStack(spacing: 2) {
                                Text("\(mutationViewModel.nextMutationCost)")
                                    .gFont(12)
                                
                                Image(.coin)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 15)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                        }
                    }
                    .scaleEffect(mutationButtonScale)
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
