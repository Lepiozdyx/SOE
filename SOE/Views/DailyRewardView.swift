import SwiftUI

struct DailyRewardView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @State private var isAnimating = false
    @State private var hasClaimedReward = false
    @State private var showCoinsAnimation = false
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            BgView()
            
            Image(.rays)
                .resizable()
                .opacity(0.5)
                .ignoresSafeArea()
            
            // Main reward content
            VStack(spacing: 10) {
                if hasClaimedReward {
                    HStack {
                        Text("+10")
                            .gFont(30)
                        
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                    }
                    .scaleEffect(showCoinsAnimation ? 1.5 : 0.7)
                    .opacity(showCoinsAnimation ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8), value: showCoinsAnimation)
                }
                
                if appViewModel.canClaimDailyReward() {
                    if !hasClaimedReward {
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
                                    claimReward()
                                }
                                .padding(.bottom)
                            }
                    } else {
                        Text("You already got the award! Come back tomorrow.")
                            .gFont(18)
                    }
                } else {
                    Text("Come back tomorrow")
                        .gFont(14)
                }
            }
            .opacity(contentOpacity)
            .offset(y: contentOffset)
            
            VStack {
                HStack(alignment: .top) {
                    CircleButtonView(iconName: .home, height: 60) {
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 55
                    )
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                isAnimating = true
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                    titleScale = 1.0
                    titleOpacity = 1.0
                }
                
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    contentOpacity = 1.0
                    contentOffset = 0
                }
                
                if !appViewModel.canClaimDailyReward() {
                    hasClaimedReward = true
                    showCoinsAnimation = true
                }
            }
        }
    }
    
    private func claimReward() {
        hasClaimedReward = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCoinsAnimation = true
        }
        
        appViewModel.claimDailyReward()
    }
}

#Preview {
    DailyRewardView()
        .environmentObject(AppViewModel())
}
