import SwiftUI

struct PauseOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isProcessingAction = false
    @State private var overlayScale: CGFloat = 0.8
    @State private var overlayOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 8) {
                
                
                // Continue button
                ActionButtonView(title: "Continue", fontSize: 22, width: 200, height: 60) {
                    appViewModel.resumeGame()
                }
                
                // Restart button
                ActionButtonView(title: "Restart", fontSize: 22, width: 200, height: 60) {
                    guard !isProcessingAction else { return }
                    isProcessingAction = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        appViewModel.restartLevel()
                    }
                }
                .opacity(isProcessingAction ? 0.7 : 1.0)
                
                // Menu button
                ActionButtonView(title: "Menu", fontSize: 22, width: 200, height: 60) {
                    guard !isProcessingAction else { return }
                    isProcessingAction = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        appViewModel.goToMenu()
                    }
                }
                .opacity(isProcessingAction ? 0.7 : 1.0)
            }
            .scaleEffect(overlayScale)
            .opacity(overlayOpacity)
            .padding(.vertical, 40)
            .padding(.horizontal, 60)
            .background(
                Image(.frameBubble)
                    .resizable()
                    .overlay(alignment: .top) {
                        Image(.labelFrame)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .overlay {
                                Text("Pause")
                                    .gFont(24)
                            }
                            .offset(y: -30)
                    }
            )
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    overlayScale = 1.0
                    overlayOpacity = 1.0
                }
            }
        }
    }
}

#Preview {
    PauseOverlayView()
        .environmentObject(AppViewModel())
}
