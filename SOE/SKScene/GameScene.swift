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
    
    // Game nodes
    private var fish: SKSpriteNode!
    private var backgroundA: SKSpriteNode!
    private var backgroundB: SKSpriteNode!
    
    // Flicker properties
    private var flickerAction: SKAction?
    private var flickerRepeatAction: SKAction?
    
    // Obstacles and particles
    private var obstacles: [SKSpriteNode] = []
    private var particles: [SKSpriteNode] = []
    
    // Time management
    private var lastUpdateTime: TimeInterval = 0
    private var lastObstacleSpawnTime: TimeInterval = 0
    private var lastParticleSpawnTime: TimeInterval = 0
    
    // Game speed
    private var baseObstacleSpeed: CGFloat = GameConstants.obstacleBaseMinSpeed
    
    // Parameters for view model synchronization
    private let backgroundId: String
    private var currentSkinId: String
    private let baseSkinId: String // Store the selected shop skin
    private var isGamePaused: Bool = false
    
    // Current game level
    private let level: Int
    
    // Calculated speed and interval values based on level
    private var obstacleSpawnInterval: TimeInterval
    private var obstacleMinSpeed: CGFloat
    private var obstacleMaxSpeed: CGFloat

    // MARK: - Initialization
    init(size: CGSize, backgroundId: String, skinId: String, level: Int) {
        self.backgroundId = backgroundId
        self.currentSkinId = skinId
        self.baseSkinId = skinId // Store the base skin selected in shop
        self.level = level
        
        // Use level-based settings
        self.obstacleSpawnInterval = GameConstants.obstacleSpawnInterval(for: level)
        self.obstacleMinSpeed = GameConstants.obstacleMinSpeed(for: level)
        self.obstacleMaxSpeed = GameConstants.obstacleMaxSpeed(for: level)
        
        // Set base speed based on minimum speed for level
        self.baseObstacleSpeed = self.obstacleMinSpeed
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - Scene lifecycle
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        setupBackground()
        setupFish()
        setupBoundaries()
        startGame()
    }
    
    // MARK: - Game setup
    private func setupBackground() {
        let backgroundTexture = SKTexture(imageNamed: getBackgroundImageName())
        
        // Create two identical background images for infinite scrolling
        backgroundA = SKSpriteNode(texture: backgroundTexture)
        backgroundB = SKSpriteNode(texture: backgroundTexture)
        
        // Setup first background
        backgroundA.anchorPoint = CGPoint.zero
        let aspectRatio = backgroundA.size.width / backgroundA.size.height
        backgroundA.size = CGSize(width: self.size.height * aspectRatio, height: self.size.height)
        backgroundA.position = CGPoint(x: 0, y: 0)
        backgroundA.zPosition = -1
        
        // Setup second background (right after first)
        backgroundB.anchorPoint = CGPoint.zero
        backgroundB.size = backgroundA.size
        backgroundB.position = CGPoint(x: backgroundA.size.width, y: 0)
        backgroundB.zPosition = -1
        
        // Add backgrounds to scene
        addChild(backgroundA)
        addChild(backgroundB)
    }
    
    private func setupFish() {
        // Use the base skin selected in shop
        let fishTexture = SKTexture(imageNamed: baseSkinId)
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
    
    // MARK: - Public methods for texture management
    
    func updateFishTexture(_ newSkinId: String) {
        guard fish != nil else { return }
        
        currentSkinId = newSkinId
        let newTexture = SKTexture(imageNamed: newSkinId)
        
        // Update texture with animation
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.2)
        let changeTexture = SKAction.run {
            self.fish.texture = newTexture
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        
        let sequenceAction = SKAction.sequence([fadeOut, changeTexture, fadeIn])
        fish.run(sequenceAction)
        
        // Add visual mutation effect
        addMutationEffect()
    }
    
    private func addMutationEffect() {
        // Create mutation effect - glow and particles
        let glowEffect = SKAction.sequence([
            SKAction.run {
                self.fish.run(SKAction.scale(to: 1.2, duration: 0.3))
            },
            SKAction.wait(forDuration: 0.3),
            SKAction.run {
                self.fish.run(SKAction.scale(to: 1.0, duration: 0.3))
            }
        ])
        
        // Glow effect
        let originalColor = fish.color
        let glowColor = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 0.5, duration: 0.2),
            SKAction.colorize(with: originalColor, colorBlendFactor: 0.0, duration: 0.4)
        ])
        
        fish.run(SKAction.group([glowEffect, glowColor]))
        
        // Add particle effects
        createMutationParticles()
    }
    
    private func createMutationParticles() {
        // Create simple particles around character
        for i in 0..<8 {
            let particle = SKSpriteNode(imageNamed: "coin")
            particle.size = CGSize(width: 15, height: 15)
            particle.alpha = 0.7
            
            let angle = CGFloat(i) * CGFloat.pi / 4
            let radius: CGFloat = 50
            let startX = fish.position.x + cos(angle) * radius
            let startY = fish.position.y + sin(angle) * radius
            
            particle.position = CGPoint(x: startX, y: startY)
            particle.zPosition = 6
            
            addChild(particle)
            
            // Particle animation
            let moveOut = SKAction.move(by: CGVector(dx: cos(angle) * 30, dy: sin(angle) * 30), duration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scale = SKAction.scale(to: 0.3, duration: 0.5)
            let remove = SKAction.removeFromParent()
            
            let particleSequence = SKAction.sequence([
                SKAction.group([moveOut, fadeOut, scale]),
                remove
            ])
            
            particle.run(particleSequence)
        }
    }
    
    // MARK: - Game control
    func startGame() {
        isGamePaused = false
        lastUpdateTime = 0
        lastObstacleSpawnTime = 0
        lastParticleSpawnTime = 0
    }
    
    func pauseGame() {
        isGamePaused = true
        self.isPaused = true
    }
    
    func resumeGame() {
        if isGamePaused {
            isGamePaused = false
            lastUpdateTime = CACurrentMediaTime()
            self.isPaused = false
        }
    }
    
    func resetGame() {
        // Remove all obstacles and particles
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        obstacles.removeAll()
        
        for particle in particles {
            particle.removeFromParent()
        }
        particles.removeAll()
        
        // Return fish to initial position
        let fishX = size.width * GameConstants.fishHorizontalPosition
        let fishY = size.height * GameConstants.fishInitialY
        fish.position = CGPoint(x: fishX, y: fishY)
        
        // Reset texture to base skin selected in shop (not hardcoded default)
        currentSkinId = baseSkinId
        let baseTexture = SKTexture(imageNamed: baseSkinId)
        fish.texture = baseTexture
        fish.alpha = 1.0
        fish.setScale(1.0)
        fish.color = .white
        fish.colorBlendFactor = 0.0
        
        // Reset speed
        baseObstacleSpeed = obstacleMinSpeed
        
        // Restart game with pause
        isGamePaused = true
        self.isPaused = true
        
        // Reset timers
        lastUpdateTime = 0
        lastObstacleSpawnTime = 0
        lastParticleSpawnTime = 0
    }
    
    func makeFishFlicker() {
        fish.removeAction(forKey: "flickerAction")
        
        let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: 0.2)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let flickerSequence = SKAction.sequence([fadeOut, fadeIn])
        
        flickerRepeatAction = SKAction.repeat(flickerSequence, count: GameConstants.fishFlickerCount)
        
        fish.run(flickerRepeatAction!, withKey: "flickerAction")
    }
    
    func stopFishFlicker() {
        fish.removeAction(forKey: "flickerAction")
        fish.alpha = 1.0
    }
    
    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if isGamePaused {
            return
        }
        
        // Update background (infinite scrolling)
        updateBackground(with: dt)
        
        // Update obstacles and particles
        updateObstacles(with: dt)
        updateParticles(with: dt)
        
        // Spawn new objects
        spawnObjectsIfNeeded(at: currentTime)
        
        // Remove objects that left screen
        cleanupObjects()
    }
    
    private func updateBackground(with dt: TimeInterval) {
        let speed = GameConstants.backgroundMovePointsPerSec
        
        backgroundA.position.x -= speed * CGFloat(dt)
        backgroundB.position.x -= speed * CGFloat(dt)
        
        if backgroundA.position.x <= -backgroundA.size.width {
            backgroundA.position.x = backgroundB.position.x + backgroundB.size.width
        }
        
        if backgroundB.position.x <= -backgroundB.size.width {
            backgroundB.position.x = backgroundA.position.x + backgroundA.size.width
        }
    }
    
    private func updateObstacles(with dt: TimeInterval) {
        let currentSpeed = baseObstacleSpeed
        
        for obstacle in obstacles {
            obstacle.position.x -= currentSpeed * CGFloat(dt)
        }
    }
    
    private func updateParticles(with dt: TimeInterval) {
        let particleSpeed = GameConstants.particleSpeed
        
        for particle in particles {
            particle.position.x -= particleSpeed * CGFloat(dt)
        }
    }
    
    private func spawnObjectsIfNeeded(at currentTime: TimeInterval) {
        // Spawn obstacles
        if currentTime - lastObstacleSpawnTime > obstacleSpawnInterval {
            spawnObstacle()
            lastObstacleSpawnTime = currentTime
        }
        
        // Spawn particles independently
        if currentTime - lastParticleSpawnTime > GameConstants.particleSpawnInterval {
            if Double.random(in: 0...1) < GameConstants.particleSpawnChance {
                spawnParticle()
            }
            lastParticleSpawnTime = currentTime
        }
    }
    
    private func spawnObstacle() {
        let obstacleType = ObstacleType.shadow
        
        let texture = SKTexture(imageNamed: obstacleType.imageName)
        let obstacle = SKSpriteNode(texture: texture)
        
        obstacle.size = GameConstants.ObstacleSizes.shadow
        
        let minY = obstacle.size.height / 2 + 20
        let maxY = size.height - obstacle.size.height / 2 - 40
        let randomY = CGFloat.random(in: minY...maxY)
        
        obstacle.position = CGPoint(x: size.width + obstacle.size.width/2, y: randomY)
        obstacle.zPosition = 3
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.shadow
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.fish
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    private func spawnParticle() {
        let particle = SKSpriteNode(imageNamed: "coin")
        particle.size = GameConstants.coinSize
        
        let minY = particle.size.height * 2
        let maxY = size.height - particle.size.height * 2
        let randomY = CGFloat.random(in: minY...maxY)
        
        particle.position = CGPoint(x: size.width + particle.size.width/2, y: randomY)
        particle.zPosition = 2
        
        particle.physicsBody = SKPhysicsBody(circleOfRadius: particle.size.width/2)
        particle.physicsBody?.isDynamic = true
        particle.physicsBody?.categoryBitMask = PhysicsCategory.coin
        particle.physicsBody?.contactTestBitMask = PhysicsCategory.fish
        particle.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(particle)
        particles.append(particle)
        
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: GameConstants.coinRotationDuration)
        let rotateForever = SKAction.repeatForever(rotateAction)
        particle.run(rotateForever)
    }
    
    private func cleanupObjects() {
        obstacles = obstacles.filter { obstacle in
            if obstacle.position.x < -obstacle.size.width {
                obstacle.removeFromParent()
                return false
            }
            return true
        }
        
        particles = particles.filter { particle in
            if particle.position.x < -particle.size.width {
                particle.removeFromParent()
                return false
            }
            return true
        }
    }
    
    // MARK: - Collisions
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.fish | PhysicsCategory.shadow {
            handleCollisionWithObstacle()
        }
        
        if collision == PhysicsCategory.fish | PhysicsCategory.coin {
            if let particle = contact.bodyA.categoryBitMask == PhysicsCategory.coin ?
                contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                handleCollectionOfParticle(particle)
            }
        }
    }
    
    private func handleCollisionWithObstacle() {
        gameDelegate?.didCollideWithObstacle()
    }
    
    private func handleCollectionOfParticle(_ particle: SKSpriteNode) {
        particle.removeFromParent()
        if let index = particles.firstIndex(of: particle) {
            particles.remove(at: index)
        }
        
        gameDelegate?.didCollectCoin()
    }
    
    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        let newY = touchLocation.y
        
        let minY = fish.size.height / 2
        let maxY = size.height - fish.size.height / 2
        let clampedY = max(minY, min(maxY, newY))
        
        let moveAction = SKAction.moveTo(y: clampedY, duration: GameConstants.defaultAnimationDuration)
        moveAction.timingMode = .easeOut
        fish.run(moveAction)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        let newY = touchLocation.y
        
        let minY = fish.size.height / 2
        let maxY = size.height - fish.size.height / 2
        let clampedY = max(minY, min(maxY, newY))
        
        fish.position.y = clampedY
    }
    
    // MARK: - Utilities
    private func getBackgroundImageName() -> String {
        if let item = BackgroundItem.availableBackgrounds.first(where: { $0.id == backgroundId }) {
            return item.imageName
        }
        return "bg1"
    }
}
