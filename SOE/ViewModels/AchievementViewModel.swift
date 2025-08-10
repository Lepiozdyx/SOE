import SwiftUI
import Combine

class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement] = Achievement.allAchievements
    @Published var isReady: Bool = false
    
    private var gameState: GameState?
    private var cancellables = Set<AnyCancellable>()
    
    weak var appViewModel: AppViewModel? {
        didSet {
            if let appViewModel = appViewModel {
                self.gameState = appViewModel.gameState
                self.isReady = true
                self.objectWillChange.send()
            }
        }
    }
    
    func isAchievementCompleted(_ id: String) -> Bool {
        guard isReady, let gameState = gameState else { return false }
        return gameState.completedAchievements.contains(id)
    }
    
    func isAchievementNotified(_ id: String) -> Bool {
        guard isReady, let gameState = gameState else { return false }
        return gameState.notifiedAchievements.contains(id)
    }
    
    func claimReward(for achievementId: String) {
        guard let appViewModel = appViewModel,
              isAchievementCompleted(achievementId),
              !isAchievementNotified(achievementId) else { return }
        
        appViewModel.addCoins(GameConstants.achievementReward)
        
        if !appViewModel.gameState.notifiedAchievements.contains(achievementId) {
            appViewModel.gameState.notifiedAchievements.append(achievementId)
            
            self.gameState = appViewModel.gameState
            appViewModel.saveGameState()
        }
        
        objectWillChange.send()
    }
    
    func checkAndUnlockAchievements(gameViewModel: GameViewModel) {
        guard let appViewModel = appViewModel else { return }
        let gameState = appViewModel.gameState
        
        if gameState.levelsCompleted > 0 {
            unlockAchievement("first_step")
        }
        
        if gameViewModel.consecutiveNoCollisionLevels >= 3 {
            unlockAchievement("achieve_master_of_chaos")
        }
        
        if gameState.maxCompletedLevel >= 3 {
            unlockAchievement("adaptation_champion")
        }
        
        let allSkinsPurchased = gameState.purchasedSkins.count >= FishSkinItem.availableSkins.count
        if allSkinsPurchased {
            unlockAchievement("grindilka_veteran")
        }
        
        appViewModel.saveGameState()
        self.gameState = appViewModel.gameState
    }
    
    func unlockAchievement(_ id: String) {
        guard let appViewModel = appViewModel,
              !appViewModel.gameState.completedAchievements.contains(id) else { return }
        
        appViewModel.gameState.completedAchievements.append(id)
        self.gameState = appViewModel.gameState
        appViewModel.saveGameState()
    }
}
