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
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            Image(.frameUpgrade)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .overlay(alignment: .topTrailing) {
                    // Reject button
                    Button {
                        rejectMutation()
                    } label: {
                        Image(.btnClose)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                }
                .overlay(alignment: .bottom) {
                    // Action buttons
                    HStack(spacing: 20) {
                        // Accept button
                        ActionButtonView(
                            title: "mutate",
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
            
            VStack(spacing: 8) {
                // Title
                Text("New Mutation Available!")
                    .gFont(18)
                
                // Mutation result display
                if let mutation = mutationViewModel.currentMutationResult {
                    HStack(spacing: 15) {
                        // Current skin image
                        Image(getBaseSkinTexture())
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .padding()
                            .background(
                                Image(.buttonB)
                                    .resizable()
                                    .scaledToFit()
                            )
                        
                        VStack {
                            VStack(spacing: 5) {
                                Text("Speed")
                                    .gFont(14)
                                
                                Rectangle()
                                    .foregroundStyle(.black.opacity(0.3))
                                    .frame(maxWidth: 80, maxHeight: 12)
                                    .overlay {
                                        Rectangle()
                                            .stroke(.blue, lineWidth: 2)
                                    }
                                    .overlay(alignment: .leading) {
                                        Rectangle()
                                            .foregroundStyle(.yellow.opacity(0.9))
                                            .frame(width: 20, height: 10)
                                            .padding(.horizontal, 1)
                                    }
                            }
                            
                            VStack(spacing: 5) {
                                Text("Resource")
                                    .gFont(14)
                                
                                Rectangle()
                                    .foregroundStyle(.black.opacity(0.3))
                                    .frame(maxWidth: 80, maxHeight: 12)
                                    .overlay {
                                        Rectangle()
                                            .stroke(.blue, lineWidth: 2)
                                    }
                                    .overlay(alignment: .leading) {
                                        Rectangle()
                                            .foregroundStyle(.yellow.opacity(0.9))
                                            .frame(width: 30, height: 10)
                                            .padding(.horizontal, 1)
                                    }
                            }
                        }
                        
                        // Result skin image
                        Image(mutation.type.textureName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
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
                            .padding()
                            .background(
                                Image(.buttonB)
                                    .resizable()
                                    .scaledToFit()
                            )
                    }
                }

                HStack {
                    Image(.slotSpikes)
                        .resizable()
                        .scaledToFit()
                    
                    Image(.slotJaw)
                        .resizable()
                        .scaledToFit()
                    
                    Image(.slotFins)
                        .resizable()
                        .scaledToFit()
                }
                .frame(height: 45)
                
                // Cost display
                HStack(alignment: .bottom) {
                    Text("Cost:")
                        .gFont(12)
                    
                    Text("\(mutationViewModel.currentMutationResult?.cost ?? 0)")
                        .gFont(16)
                        .foregroundStyle(.red)
                    
                    Image(.coin)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                }
            }
            .padding()
            .scaleEffect(overlayScale)
            .opacity(overlayOpacity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func getBaseSkinTexture() -> String {
        // Get the base skin selected in shop
        return mutationViewModel.appViewModel?.gameState.currentSkinId ?? "skin_default"
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
