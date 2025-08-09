import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @State private var showDailyReward = false
    // Animation states
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            
            VStack {
                // Top bar
                HStack(alignment: .top) {
                    CircleButtonView(iconName: .setting, height: 80) {
                        appViewModel.navigateTo(.settings)
                    }
                    
                    Spacer()
                    
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 55
                    )
                }
                .opacity(buttonsOpacity)
                
                Spacer()
                
                // Daily button
                HStack {
                    Spacer()
                    
                    Button {
                        appViewModel.navigateTo(.dailyReward)
                    } label: {
                        Image(.btnDaily)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                    }
                    .withSound()
                }
            }
            .padding()
            
            // Main buttons
            HStack(spacing: 30) {
                // Shop
                Button {
                    appViewModel.navigateTo(.shop)
                } label: {
                    Image(.btnShop)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
                .withSound()
                
                // Play
                Button {
                    appViewModel.navigateTo(.levelSelect)
                } label: {
                    Image(.btnPlay)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
                .withSound()
                .offset(y: -20)
                
                // Achievements
                Button {
                    appViewModel.navigateTo(.achievements)
                } label: {
                    Image(.btnAchieves)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
                .withSound()
            }
            .offset(y: buttonsOffset)
            .opacity(buttonsOpacity)
            
            // Daily reward overlay
            if showDailyReward {
                dailyRewardOverlay()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                buttonsOffset = 0
                buttonsOpacity = 1.0
            }
            
            // Show daily reward overlay if available
            if appViewModel.canClaimDailyReward() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showDailyReward = true
                }
            }
        }
    }
    
    // Daily reward overlay
    func dailyRewardOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showDailyReward = false
                }
            
            Image(.popapBonus)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .overlay(alignment: .bottom) {
                    ActionButtonView(
                        title: "Get",
                        fontSize: 18,
                        width: 160,
                        height: 55
                    ) {
                        appViewModel.claimDailyReward()
                        showDailyReward = false
                    }
                    .padding(.bottom)
                }
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}
