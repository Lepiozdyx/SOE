import SwiftUI

struct DefeatOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isAnimating = false
    @State private var isProcessingAction = false
    @State private var overlayScale: CGFloat = 0.8
    @State private var overlayOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Затемнение фона
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            // Основной контент
            VStack(spacing: 20) {
                HStack {
                    Text("Prize: 0")
                        .gFont(22)
                    
                    Image(.coin)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25)
                }
                
                // Кнопки
                VStack(spacing: 8) {
                    ActionButtonView(title: "Retry", fontSize: 22, width: 200, height: 55) {
                        // Предотвращаем многократное нажатие
                        guard !isProcessingAction else { return }
                        isProcessingAction = true
                        
                        // Перезапуск уровня
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.restartLevel()
                        }
                    }
                    
                    ActionButtonView(title: "Menu", fontSize: 22, width: 200, height: 55) {
                        // Предотвращаем многократное нажатие
                        guard !isProcessingAction else { return }
                        isProcessingAction = true
                        
                        // Переход в меню
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.goToMenu()
                        }
                    }
                }
                .padding(.top, 20)
                .opacity(isProcessingAction ? 0.7 : 1.0)
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 50)
            .background(
                Image(.frameBubble)
                    .resizable()
                    .overlay(alignment: .top) {
                        Image(.labelFrame)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .overlay {
                                Text("you lost")
                                    .gFont(24)
                            }
                            .offset(y: -30)
                            .shadow(color: .red.opacity(0.7), radius: 10)
                    }
            )
            .scaleEffect(overlayScale)
            .opacity(overlayOpacity)
            .onAppear {
                isAnimating = true
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    overlayScale = 1.0
                    overlayOpacity = 1.0
                }
            }
        }
    }
}

#Preview {
    DefeatOverlayView()
        .environmentObject(AppViewModel())
}
