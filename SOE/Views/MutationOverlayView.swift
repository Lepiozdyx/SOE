import SwiftUI

struct MutationOverlayView: View {
    @ObservedObject var mutationViewModel: MutationViewModel
    
    @State private var overlayScale: CGFloat = 0.8
    @State private var overlayOpacity: Double = 0
    @State private var mutationScale: CGFloat = 0.5
    @State private var mutationOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 20
    @State private var pulseAnimation: Bool = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title
                Text("Mutation Available!")
                    .gFont(24)
                
                // Cost display
                HStack {
                    Text("Cost:")
                        .gFont(18)
                    
                    Text("\(mutationViewModel.currentMutationResult?.cost ?? 0)")
                        .gFont(20)
                        .foregroundStyle(.red)
                    
                    Image(.coin)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25)
                }
                
                // Mutation result display
                if let mutation = mutationViewModel.currentMutationResult {
                    VStack(spacing: 15) {
                        // Result skin image
                        Image(mutation.type.textureName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 40)
                            .scaleEffect(mutationScale)
                            .opacity(mutationOpacity)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .shadow(
                                color: pulseAnimation ? .green.opacity(0.8) : .white.opacity(0.5),
                                radius: pulseAnimation ? 15 : 5
                            )
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: pulseAnimation
                            )
                        
                        // Mutation name
                        Text(mutation.type.displayName)
                            .gFont(22)
                            .foregroundStyle(.green)
                            .opacity(mutationOpacity)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 40)
                    .background(
                        Image(.frameUpgrade)
                            .resizable()
                            .scaledToFit()
                    )
                }
                
                // Warning text
                Text("Resources spent cannot be returned!")
                    .gFont(14)
                    .foregroundStyle(.orange)
                    .opacity(mutationOpacity)
                
                // Action buttons
                HStack(spacing: 20) {
                    // Reject button
                    ActionButtonView(
                        title: "Reject",
                        fontSize: 18,
                        width: 150,
                        height: 50
                    ) {
                        rejectMutation()
                    }
                    
                    // Accept button
                    ActionButtonView(
                        title: "Accept",
                        fontSize: 18,
                        width: 150,
                        height: 50
                    ) {
                        acceptMutation()
                    }
                }
                .opacity(buttonOpacity)
                .offset(y: buttonOffset)
            }
            .padding()
            .scaleEffect(overlayScale)
            .opacity(overlayOpacity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Main overlay animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            overlayScale = 1.0
            overlayOpacity = 1.0
        }
        
        // Mutation display animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            mutationScale = 1.0
            mutationOpacity = 1.0
        }
        
        // Buttons animation
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            buttonOpacity = 1.0
            buttonOffset = 0
        }
        
        // Start pulse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            pulseAnimation = true
        }
    }
    
    private func acceptMutation() {
        // Exit animations
        withAnimation(.easeIn(duration: 0.3)) {
            overlayScale = 1.2
            overlayOpacity = 0
        }
        
        // Apply mutation after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            mutationViewModel.acceptMutation()
        }
    }
    
    private func rejectMutation() {
        // Exit animations
        withAnimation(.easeIn(duration: 0.3)) {
            overlayScale = 0.8
            overlayOpacity = 0
        }
        
        // Reject mutation after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            mutationViewModel.rejectMutation()
        }
    }
}

#Preview {
    let mutationVM = MutationViewModel()
    mutationVM.currentMutationResult = Mutation(type: .fin, cost: 15)
    mutationVM.showMutationOverlay = true
    
    return MutationOverlayView(mutationViewModel: mutationVM)
}
