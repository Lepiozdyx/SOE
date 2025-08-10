import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var mutationViewModel = MutationViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main SpriteKit scene
                SpriteKitGameView(size: geometry.size, mutationViewModel: mutationViewModel)
                    .environmentObject(appViewModel)
                    .edgesIgnoringSafeArea(.all)
                
                // Pre-game mutation overlay
                if mutationViewModel.showPreGameOverlay {
                    PreGameMutationView(mutationViewModel: mutationViewModel)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: mutationViewModel.showPreGameOverlay)
                        .zIndex(200)
                }
                
                // Game UI overlay (only when game is active)
                if !mutationViewModel.showPreGameOverlay,
                   let gameViewModel = appViewModel.gameViewModel {
                    GameOverlayView(
                        gameViewModel: gameViewModel,
                        mutationViewModel: mutationViewModel
                    )
                    .environmentObject(appViewModel)
                }
                
                // Mutation overlay
                if mutationViewModel.showMutationOverlay {
                    MutationOverlayView(mutationViewModel: mutationViewModel)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: mutationViewModel.showMutationOverlay)
                        .zIndex(150)
                }
                
                if let gameVM = appViewModel.gameViewModel {
                    Group {
                        // Pause overlay
                        if gameVM.isPaused && !gameVM.showVictoryOverlay && !gameVM.showDefeatOverlay && !mutationViewModel.showMutationOverlay {
                            PauseOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.isPaused)
                                .zIndex(90)
                        }
                        
                        // Victory overlay
                        if gameVM.showVictoryOverlay {
                            VictoryOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.showVictoryOverlay)
                                .zIndex(100)
                        }
                        
                        // Defeat overlay
                        if gameVM.showDefeatOverlay {
                            DefeatOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.showDefeatOverlay)
                                .zIndex(100)
                        }
                    }
                }
            }
            .onDisappear {
                // Pause game when leaving the view
                if let gameVM = appViewModel.gameViewModel {
                    gameVM.togglePause(true)
                }
            }
        }
        .onAppear {
            setupMutationViewModel()
        }
    }
    
    private func setupMutationViewModel() {
        mutationViewModel.appViewModel = appViewModel
        
        // Setup mutation state for current level
        mutationViewModel.setupMutationState()
    }
}

// MARK: - SpriteKitGameView

struct SpriteKitGameView: UIViewRepresentable {
    @EnvironmentObject private var appViewModel: AppViewModel
    let size: CGSize
    let mutationViewModel: MutationViewModel
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.preferredFramesPerSecond = 60
        view.showsFPS = false
        view.showsNodeCount = false
        
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        // Ensure GameViewModel exists and is properly connected
        if appViewModel.gameViewModel == nil {
            appViewModel.gameViewModel = GameViewModel()
        }
        
        // Setup connections
        appViewModel.gameViewModel?.appViewModel = appViewModel
        appViewModel.gameViewModel?.mutationViewModel = mutationViewModel
        mutationViewModel.gameViewModel = appViewModel.gameViewModel
        mutationViewModel.appViewModel = appViewModel
        
        if view.scene == nil {
            let scene = appViewModel.gameViewModel?.setupScene(size: size)
            view.presentScene(scene)
            
            // Immediately pause the game until pre-game overlay is dismissed
            appViewModel.gameViewModel?.togglePause(true)
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
