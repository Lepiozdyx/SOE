import SwiftUI

struct AchievementView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = AchievementViewModel()
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            BgView()
            
            VStack {
                HStack(alignment: .top) {
                    CircleButtonView(iconName: .home, height: 60) {
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    Image(.labelFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .overlay {
                            Text("Achievements")
                                .gFont(24)
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
            
            ScrollView(.horizontal) {
                HStack(spacing: 30) {
                    ForEach(viewModel.achievements) { achievement in
                        AchievementItemView(
                            achievement: achievement,
                            isCompleted: viewModel.isAchievementCompleted(achievement.id),
                            isNotified: viewModel.isAchievementNotified(achievement.id),
                            onClaim: {
                                viewModel.claimReward(for: achievement.id)
                            }
                        )
                    }
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            viewModel.appViewModel = appViewModel
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
}

struct AchievementItemView: View {
    let achievement: Achievement
    let isCompleted: Bool
    let isNotified: Bool
    let onClaim: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        VStack {
            // Achievement icon
            Image(achievement.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .scaleEffect(animate && isCompleted && !isNotified ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animate
                )
                .onAppear {
                    animate = true
                }
                .overlay(alignment: .trailing) {
                    // Claim reward button or status
                    VStack {
                        if isCompleted {
                            if isNotified {
                                // Completed status
                                Image(.done)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 25)
                                    .offset(y: -25)
                            } else {
                                // Claim reward button
                                Button(action: onClaim) {
                                    Image(.btnAchievesGet)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 40)
                                        .scaleEffect(animate ? 1.05 : 1.0)
                                        .animation(
                                            Animation.easeInOut(duration: 0.8)
                                                .repeatForever(autoreverses: true),
                                            value: animate
                                        )
                                }
                                .padding(.trailing, 12)
                            }
                        } else {
                            // "Locked" status
                            Image(.btnAchievesEmpty)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .padding(.trailing, 12)
                        }
                    }
                }
        }
    }
}

#Preview {
    AchievementView()
        .environmentObject(AppViewModel())
}
