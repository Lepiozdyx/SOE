import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @ObservedObject private var settings = SettingsViewModel.shared
    
    @Environment(\.scenePhase) private var phase
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                
            case .levelSelect:
                LevelSelectView()
                    .environmentObject(appViewModel)
                
            case .game:
                GameView()
                    .environmentObject(appViewModel)
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                
            case .achievements:
                AchievementView()
                    .environmentObject(appViewModel)
                
            case .dailyReward:
                DailyRewardView()
                    .environmentObject(appViewModel)
                
            case .upgrades:
                UpgradesView()
                    .environmentObject(appViewModel)
            }
        }
        .onAppear {
            if settings.isMusicOn {
                settings.playMusic()
            }
        }
        .onChange(of: phase) { state in
            switch state {
            case .active:
                settings.playMusic()
            case .background, .inactive:
                settings.stopMusic()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
