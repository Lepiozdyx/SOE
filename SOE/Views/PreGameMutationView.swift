import SwiftUI

struct PreGameMutationView: View {
    @ObservedObject var mutationViewModel: MutationViewModel
    
    @State private var targetScale: CGFloat = 0.8
    @State private var targetOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.8
    @State private var buttonOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var glowAnimation: Bool = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title
                Text("Your Target Evolution")
                    .gFont(24)
                
                // Target mutation display
                VStack(spacing: 5) {
                    // Target skin image
                    Image(mutationViewModel.getTargetSkinTexture())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 60)
                        .scaleEffect(targetScale)
                        .opacity(targetOpacity)
                        .shadow(
                            color: glowAnimation ? .cyan.opacity(0.8) : .blue.opacity(0.4),
                            radius: glowAnimation ? 20 : 10
                        )
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: glowAnimation
                        )
                    
                    // Target mutation name
                    Text(mutationViewModel.getTargetMutationName())
                        .gFont(24)
                        .opacity(targetOpacity)
                        .foregroundStyle(.cyan)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 40)
                .background(
                    Image(.frameUpgrade)
                        .resizable()
                        .scaledToFit()
                )
                
                // Instructions
                VStack(spacing: 8) {
                    Text("Collect DNA particles to evolve")
                        .gFont(16)
                        .opacity(targetOpacity)
                    
                    Text("Spend resources wisely - they won't return!")
                        .gFont(14)
                        .opacity(targetOpacity)
                        .foregroundStyle(.orange)
                }
                
                // Start game button
                ActionButtonView(
                    title: "Start Evolution",
                    fontSize: 20,
                    width: 250,
                    height: 60
                ) {
                    startGame()
                }
                .scaleEffect(buttonScale)
                .opacity(buttonOpacity)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Title animation
        withAnimation(.easeOut(duration: 0.6)) {
            titleOpacity = 1.0
        }
        
        // Target display animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            targetScale = 1.0
            targetOpacity = 1.0
        }
        
        // Button animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8)) {
            buttonScale = 1.0
            buttonOpacity = 1.0
        }
        
        // Start glow animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            glowAnimation = true
        }
    }
    
    private func startGame() {
        // Start exit animations
        withAnimation(.easeIn(duration: 0.4)) {
            targetScale = 0.8
            targetOpacity = 0
            buttonScale = 0.8
            buttonOpacity = 0
            titleOpacity = 0
        }
        
        // Start the game after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            mutationViewModel.startGame()
        }
    }
}

#Preview {
    let mutationVM = MutationViewModel()
    return PreGameMutationView(mutationViewModel: mutationVM)
}
