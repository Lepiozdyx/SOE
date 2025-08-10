import SwiftUI

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var score: Int = 0
    @Published var hasCollided: Bool = false
    @Published var isInvulnerable: Bool = false // Флаг неуязвимости после первого столкновения
    @Published var timeRemaining: Double = GameConstants.gameDuration
    
    @Published var isPaused: Bool = false
    @Published var showVictoryOverlay: Bool = false
    @Published var showDefeatOverlay: Bool = false
    
    // MARK: - Отслеживание достижений
    @Published var coinCollectedCount: Int = 0
    @Published var accelerationCount: Int = 0
    @Published var consecutiveNoCollisionLevels: Int = 0
    
    // MARK: - Приватные свойства
    private var gameScene: GameScene?
    private var gameTimer: Timer?
    private var invulnerabilityTimer: Timer?
    private var currentLevel: Int = 1 // Хранит текущий уровень игры
    
    // MARK: - Публичные свойства
    weak var appViewModel: AppViewModel?
    weak var mutationViewModel: MutationViewModel?
    
    // MARK: - Инициализация
    init() {
        setupGame()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Публичные методы
    
    func setupScene(size: CGSize) -> GameScene {
        // Получаем текущий уровень и режим из AppViewModel
        if let appVM = appViewModel {
            currentLevel = appVM.gameLevel
        }
        
        let backgroundId = appViewModel?.gameState.currentBackgroundId ?? "bg1"
        let skinId = mutationViewModel?.getCurrentSkinTexture() ?? "skin_default"
        
        // Создаем игровую сцену с передачей уровня
        let scene = GameScene(
            size: size,
            backgroundId: backgroundId,
            skinId: skinId,
            level: currentLevel
        )
        scene.scaleMode = .aspectFill
        scene.gameDelegate = self
        gameScene = scene
        return scene
    }
    
    func togglePause(_ paused: Bool) {
        // Если есть активный оверлей победы, поражения, не переключаем паузу
        if (showVictoryOverlay || showDefeatOverlay) {
            return
        }
        
        // Если показывается оверлей мутации, не разрешаем снятие паузы
        if let mutationVM = mutationViewModel, mutationVM.showMutationOverlay && !paused {
            return
        }
        
        isPaused = paused
        
        if paused {
            gameTimer?.invalidate()
            gameScene?.pauseGame()
        } else {
            gameScene?.resumeGame()
            startGameTimer()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func pauseGame() {
        togglePause(true)
    }
    
    func resumeGame() {
        togglePause(false)
    }
    
    func resetGame() {
        // Обновляем текущий уровень и режим из AppViewModel
        if let appVM = appViewModel {
            currentLevel = appVM.gameLevel
        }
        
        // Отменяем все текущие таймеры и оверлеи
        gameTimer?.invalidate()
        invulnerabilityTimer?.invalidate()
        
        showVictoryOverlay = false
        showDefeatOverlay = false
        
        // Очищаем и перезапускаем игру в синхронизированном порядке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Сбрасываем все игровые параметры
            self.score = 0
            self.hasCollided = false
            self.isInvulnerable = false
            self.timeRemaining = GameConstants.gameDuration
            self.isPaused = false
            
            self.coinCollectedCount = 0
            self.accelerationCount = 0
            
            // Сбрасываем все визуальные состояния
            self.showVictoryOverlay = false
            self.showDefeatOverlay = false
            
            // Сбрасываем состояние мутаций
            self.mutationViewModel?.resetForRestart()
            
            // Важно: сначала сбрасываем сцену
            self.gameScene?.resetGame()
            
            // Явно возобновляем игру после полного сброса
            self.gameScene?.resumeGame()
            
            // Запускаем новый игровой таймер
            self.startGameTimer()
            
            // Обновляем UI
            self.objectWillChange.send()
        }
    }
    
    // Публичный метод для завершения игры (вызывается из MutationViewModel)
    func gameOver(win: Bool) {
        cleanup()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if win {
                self.showVictoryOverlay = true
                if !self.hasCollided {
                    self.consecutiveNoCollisionLevels += 1
                } else {
                    self.consecutiveNoCollisionLevels = 0
                }
                self.appViewModel?.checkAchievements(gameViewModel: self)
                self.appViewModel?.showVictory()
            } else {
                self.showDefeatOverlay = true
                self.consecutiveNoCollisionLevels = 0
                self.appViewModel?.showDefeat()
            }
            
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Mutation Support
    
    func updateFishTexture(_ newSkinId: String) {
        gameScene?.updateFishTexture(newSkinId)
    }
    
    // MARK: - Приватные методы
    private func setupGame() {
        startGameTimer()
    }
    
    private func startGameTimer() {
        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            
            // Обновляем оставшееся время
            self.timeRemaining -= 0.1
            
            // Проверяем окончание уровня по времени (только если нет системы мутаций)
            if self.timeRemaining <= 0 {
                // В новой системе мутаций время может закончиться, но это не победа
                // Победа определяется только через мутации
                self.gameOverByTime()
            }
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    private func gameOverByTime() {
        // Если время закончилось, но цель мутации не достигнута - это поражение
        if let mutationVM = mutationViewModel, !mutationVM.hasWon {
            gameOver(win: false)
        }
    }
    
    // Метод для обработки неуязвимости
    private func startInvulnerabilityTimer() {
        invulnerabilityTimer?.invalidate()
        
        isInvulnerable = true
        gameScene?.makeFishFlicker()
        
        invulnerabilityTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isInvulnerable = false
            self.gameScene?.stopFishFlicker()
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    private func cleanup() {
        gameTimer?.invalidate()
        invulnerabilityTimer?.invalidate()
        gameScene?.pauseGame()
        isPaused = true
    }
}

// MARK: - GameSceneDelegate
extension GameViewModel: GameSceneDelegate {
    func didCollectCoin() {
        let coinValue = GameConstants.coinValue
        
        score += coinValue
        coinCollectedCount += 1
        
        // Добавляем ресурсы в систему мутаций
        mutationViewModel?.addResources(coinValue)
        
        // Также добавляем монеты в общий счет игрока
        appViewModel?.addCoins(coinValue)
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func didCollideWithObstacle() {
        // Если шарик неуязвим, игнорируем столкновение
        if isInvulnerable {
            return
        }
        
        if hasCollided {
            gameOver(win: false)
        } else {
            hasCollided = true
            startInvulnerabilityTimer()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
}
