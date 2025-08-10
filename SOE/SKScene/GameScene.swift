import SpriteKit
import SwiftUI

protocol GameSceneDelegate: AnyObject {
    func didCollectCoin()
    func didCollideWithObstacle()
}

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let fish: UInt32 = 0x1 << 0
    static let shadow: UInt32 = 0x1 << 1
    static let coin: UInt32 = 0x1 << 2
    static let boundary: UInt32 = 0x1 << 3
}

// MARK: - GameScene
class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var gameDelegate: GameSceneDelegate?
    
    // Игровые ноды
    private var fish: SKSpriteNode!
    private var backgroundA: SKSpriteNode!
    private var backgroundB: SKSpriteNode!
    
    // Свойства для управления миганием
    private var flickerAction: SKAction?
    private var flickerRepeatAction: SKAction?
    
    // Препятствия и монеты
    private var obstacles: [SKSpriteNode] = []
    private var coins: [SKSpriteNode] = []
    
    // Управление временем
    private var lastUpdateTime: TimeInterval = 0
    private var lastObstacleSpawnTime: TimeInterval = 0
    private var lastCoinSpawnTime: TimeInterval = 0
    
    // Скорость игры
    private var baseSpeed: CGFloat = GameConstants.obstacleBaseMinSpeed
    
    // Параметры для синхронизации с вью-моделью
    private let backgroundId: String
    private let skinId: String
    private var isGamePaused: Bool = false
    private let typeId: String
    
    // Текущий уровень игры
    private let level: Int
    
    // Расчетные значения скоростей и интервалов в зависимости от уровня
    private var obstacleSpawnInterval: TimeInterval
    private var obstacleMinSpeed: CGFloat
    private var obstacleMaxSpeed: CGFloat

    // MARK: - Инициализация
    init(size: CGSize, backgroundId: String, skinId: String, typeId: String, level: Int) {
        self.backgroundId = backgroundId
        self.skinId = skinId
        self.typeId = typeId
        self.level = level
        
        // Используем настройки, основанные на уровне
        self.obstacleSpawnInterval = GameConstants.obstacleSpawnInterval(for: level)
        self.obstacleMinSpeed = GameConstants.obstacleMinSpeed(for: level)
        self.obstacleMaxSpeed = GameConstants.obstacleMaxSpeed(for: level)
        
        // Установка базовой скорости на основе минимальной скорости для уровня
        self.baseSpeed = self.obstacleMinSpeed
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - Жизненный цикл сцены
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        setupBackground()
        setupFish()
        setupBoundaries()
        startGame()
    }
    
    // MARK: - Настройка игры
    private func setupBackground() {
        // Получаем текстуру фона
        let backgroundTexture = SKTexture(imageNamed: getBackgroundImageName())
        
        #warning("тут нужен второй фон?")
        // Создаем два одинаковых фоновых изображения для бесконечного скроллинга
        backgroundA = SKSpriteNode(texture: backgroundTexture)
        backgroundB = SKSpriteNode(texture: backgroundTexture)
        
        // Настройка первого фона
        backgroundA.anchorPoint = CGPoint.zero
        let aspectRatio = backgroundA.size.width / backgroundA.size.height
        backgroundA.size = CGSize(width: self.size.height * aspectRatio, height: self.size.height)
        backgroundA.position = CGPoint(x: 0, y: 0)
        backgroundA.zPosition = -1
        
        // Настройка второго фона (сразу за первым)
        backgroundB.anchorPoint = CGPoint.zero
        backgroundB.size = backgroundA.size
        backgroundB.position = CGPoint(x: backgroundA.size.width, y: 0)
        backgroundB.zPosition = -1
        
        // Добавляем фоны на сцену
        addChild(backgroundA)
        addChild(backgroundB)
    }
    
    private func setupFish() {
        let fishTexture = SKTexture(imageNamed: "skin_default")
        fish = SKSpriteNode(texture: fishTexture)
        
        fish.size = GameConstants.fishSize
        
        let fishX = size.width * GameConstants.fishHorizontalPosition
        let fishY = size.height * GameConstants.fishInitialY
        fish.position = CGPoint(x: fishX, y: fishY)
        
        let smallerSize = CGSize(
            width: fish.size.width * GameConstants.fishPhysicsBodyScale,
            height: fish.size.height * GameConstants.fishPhysicsBodyScale
        )
        
        fish.physicsBody = SKPhysicsBody(rectangleOf: smallerSize)
        fish.physicsBody?.isDynamic = true
        fish.physicsBody?.categoryBitMask = PhysicsCategory.fish
        fish.physicsBody?.contactTestBitMask = PhysicsCategory.shadow | PhysicsCategory.coin
        fish.physicsBody?.collisionBitMask = PhysicsCategory.boundary
        fish.physicsBody?.usesPreciseCollisionDetection = true
        fish.zPosition = 5
        
        addChild(fish)
    }
    
    private func setupBoundaries() {
        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        borderBody.categoryBitMask = PhysicsCategory.boundary
        
        let border = SKNode()
        border.position = CGPoint(x: 0, y: 0)
        border.physicsBody = borderBody
        
        addChild(border)
    }
    
    // MARK: - Управление игрой
    func startGame() {
        isGamePaused = false
        lastUpdateTime = 0
        lastObstacleSpawnTime = 0
        lastCoinSpawnTime = 0
    }
    
    func pauseGame() {
        isGamePaused = true
        self.isPaused = true
    }
    
    func resumeGame() {
        // Проверяем, активна ли пауза перед её снятием
        if isGamePaused {
            isGamePaused = false
            // Сбрасываем счётчик времени для корректного обновления
            lastUpdateTime = CACurrentMediaTime()
            // Снимаем паузу с SpriteKit-сцены
            self.isPaused = false
        }
    }
    
    func resetGame() {
        // Удаляем все препятствия и монеты
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        obstacles.removeAll()
        
        for coin in coins {
            coin.removeFromParent()
        }
        coins.removeAll()
        
        // Возвращаем шарик в начальную позицию
        let eagleX = size.width * GameConstants.fishHorizontalPosition
        let eagleY = size.height * GameConstants.fishInitialY
        fish.position = CGPoint(x: eagleX, y: eagleY)
        
        // Сбрасываем скорость
        baseSpeed = obstacleMinSpeed
        
        // Запускаем игру заново - делаем паузу в любом случае,
        // чтобы GameViewModel мог явно управлять запуском
        isGamePaused = true
        self.isPaused = true
        
        // Сбрасываем таймеры
        lastUpdateTime = 0
        lastObstacleSpawnTime = 0
        lastCoinSpawnTime = 0
    }
    
    func makeFishFlicker() {
        // Останавливаем предыдущую анимацию мигания, если она была
        fish.removeAction(forKey: "flickerAction")
        
        // Создаем последовательность действий для мигания
        let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: 0.2)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let flickerSequence = SKAction.sequence([fadeOut, fadeIn])
        
        // Повторяем мигание
        flickerRepeatAction = SKAction.repeat(flickerSequence, count: GameConstants.fishFlickerCount)
        
        // Запускаем анимацию мигания
        fish.run(flickerRepeatAction!, withKey: "flickerAction")
    }
    
    func stopFishFlicker() {
        fish.removeAction(forKey: "flickerAction")
        fish.alpha = 1.0
    }
    
    // MARK: - Игровой цикл
    override func update(_ currentTime: TimeInterval) {
        // Инициализация lastUpdateTime при первом вызове
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Расчет времени, прошедшего с последнего обновления
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if isGamePaused {
            return
        }
        
        // Обновление фона (бесконечный скроллинг)
        updateBackground(with: dt)
        
        // Обновление препятствий и монет
        updateObstacles(with: dt)
        updateCoins(with: dt)
        
        // Спавн новых объектов
        spawnObjectsIfNeeded(at: currentTime)
        
        // Удаление объектов, вышедших за границы экрана
        cleanupObjects()
    }
    
    private func updateBackground(with dt: TimeInterval) {
        // Рассчитываем скорость движения фона
        let speed = GameConstants.backgroundMovePointsPerSec
        
        // Смещаем оба фона
        backgroundA.position.x -= speed * CGFloat(dt)
        backgroundB.position.x -= speed * CGFloat(dt)
        
        // Проверяем, если фон A полностью ушел за экран, перемещаем его сразу за фоном B
        if backgroundA.position.x <= -backgroundA.size.width {
            backgroundA.position.x = backgroundB.position.x + backgroundB.size.width
        }
        
        // Проверяем, если фон B полностью ушел за экран, перемещаем его сразу за фоном A
        if backgroundB.position.x <= -backgroundB.size.width {
            backgroundB.position.x = backgroundA.position.x + backgroundA.size.width
        }
    }
    
    private func updateObstacles(with dt: TimeInterval) {
        // Рассчитываем текущую скорость препятствий
        let currentSpeed = baseSpeed
        
        // Обновляем позиции всех препятствий
        for obstacle in obstacles {
            obstacle.position.x -= currentSpeed * CGFloat(dt)
        }
    }
    
    private func updateCoins(with dt: TimeInterval) {
        // Обновляем позиции всех монет
        let currentSpeed = baseSpeed
        
        for coin in coins {
            coin.position.x -= currentSpeed * CGFloat(dt)
        }
    }
    
    private func spawnObjectsIfNeeded(at currentTime: TimeInterval) {
        // Спавн препятствий с интервалом, зависящим от уровня
        if currentTime - lastObstacleSpawnTime > obstacleSpawnInterval {
            spawnObstacle()
            lastObstacleSpawnTime = currentTime
            
            // Случайный спавн монет
            if Double.random(in: 0...1) < GameConstants.coinSpawnChance {
                spawnCoin()
                lastCoinSpawnTime = currentTime
            }
        }
    }
    
    private func spawnObstacle() {
        // Выбираем тип препятствия
//        let obstacleType = ObstacleType.random()
        let obstacleType = ObstacleType.shadow
        
        // Создаем препятствие
        let texture = SKTexture(imageNamed: obstacleType.imageName)
        let obstacle = SKSpriteNode(texture: texture)
        
        // Устанавливаем размер в зависимости от типа
//        switch obstacleType {
//        case .shadow:
//            obstacle.size = GameConstants.ObstacleSizes.shadow
//        }
        
        obstacle.size = GameConstants.ObstacleSizes.shadow
        
        // Случайная позиция по вертикали с отступами
        let minY = obstacle.size.height / 2 + 20 // Отступ снизу 20 пунктов
        let maxY = size.height - obstacle.size.height / 2 - 40 // Отступ сверху 40 пунктов
        let randomY = CGFloat.random(in: minY...maxY)
        
        // Устанавливаем позицию препятствия за правым краем экрана
        obstacle.position = CGPoint(x: size.width + obstacle.size.width/2, y: randomY)
        obstacle.zPosition = 3
        
        // Настройка физического тела
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.shadow
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.fish
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // Добавляем препятствие на сцену и в массив
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    private func spawnCoin() {
        // Создаем монету
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = GameConstants.coinSize
        
        // Случайная позиция по вертикали, избегая крайних позиций
        let minY = coin.size.height * 2
        let maxY = size.height - coin.size.height * 2
        let randomY = CGFloat.random(in: minY...maxY)
        
        // Устанавливаем позицию за правым краем экрана
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: randomY)
        coin.zPosition = 2
        
        // Настройка физического тела
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
        coin.physicsBody?.isDynamic = true
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.fish
        coin.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // Добавляем монету на сцену и в массив
        addChild(coin)
        coins.append(coin)
        
        // Добавляем анимацию вращения
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: GameConstants.coinRotationDuration)
        let rotateForever = SKAction.repeatForever(rotateAction)
        coin.run(rotateForever)
    }
    
    private func cleanupObjects() {
        // Удаляем препятствия, вышедшие за левый край экрана
        obstacles = obstacles.filter { obstacle in
            if obstacle.position.x < -obstacle.size.width {
                obstacle.removeFromParent()
                return false
            }
            return true
        }
        
        // Удаляем монеты, вышедшие за левый край экрана
        coins = coins.filter { coin in
            if coin.position.x < -coin.size.width {
                coin.removeFromParent()
                return false
            }
            return true
        }
    }
    
    // MARK: - Коллизии
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Столкновение шарика с препятствием
        if collision == PhysicsCategory.fish | PhysicsCategory.shadow {
            handleCollisionWithObstacle()
        }
        
        // Столкновение шарика с монетой
        if collision == PhysicsCategory.fish | PhysicsCategory.coin {
            if let coin = contact.bodyA.categoryBitMask == PhysicsCategory.coin ?
                contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                handleCollectionOfCoin(coin)
            }
        }
    }
    
    private func handleCollisionWithObstacle() {
        gameDelegate?.didCollideWithObstacle()
    }
    
    private func handleCollectionOfCoin(_ coin: SKSpriteNode) {
        coin.removeFromParent()
        if let index = coins.firstIndex(of: coin) {
            coins.remove(at: index)
        }
        
        gameDelegate?.didCollectCoin()
    }
    
    // MARK: - Обработка касаний
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Получаем новую Y-позицию для орла
        let newY = touchLocation.y
        
        // Проверяем, чтобы шарик не вышел за пределы экрана
        let minY = fish.size.height / 2
        let maxY = size.height - fish.size.height / 2
        let clampedY = max(minY, min(maxY, newY))
        
        // Перемещаем шарик с анимацией
        let moveAction = SKAction.moveTo(y: clampedY, duration: GameConstants.defaultAnimationDuration)
        moveAction.timingMode = .easeOut
        fish.run(moveAction)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Получаем новую Y-позицию для орла
        let newY = touchLocation.y
        
        // Проверяем, чтобы шарик не вышел за пределы экрана
        let minY = fish.size.height / 2
        let maxY = size.height - fish.size.height / 2
        let clampedY = max(minY, min(maxY, newY))
        
        // Перемещаем шарик мгновенно
        fish.position.y = clampedY
    }
    
    // MARK: - Утилиты
    private func getBackgroundImageName() -> String {
        // Получаем имя фонового изображения в зависимости от выбранного фона
        if let item = BackgroundItem.availableBackgrounds.first(where: { $0.id == backgroundId }) {
            return item.imageName
        }
        return "bg1" // Дефолтный фон
    }
}
