import Foundation
import SwiftUI

// Game constants
struct GameConstants {
    // General constants
    static let defaultAnimationDuration: Double = 0.3
    
    // Gameplay constants
    static let gameDuration: TimeInterval = 300 // 300 seconds per level
    static let fishInitialY: CGFloat = 0.5 // Fish initial position (percentage of screen height)
    static let fishHorizontalPosition: CGFloat = 0.15 // Fish horizontal position (percentage of screen width)
    static let fishSize = CGSize(width: 60, height: 50) // Fish size
    
    // Background constants
    static let backgroundMovePointsPerSec: CGFloat = 100.0 // Background movement speed
    
    // Obstacle constants
    static let obstacleBaseSpawnInterval: TimeInterval = 4 // Increased interval - obstacles appear less frequently
    static let obstacleBaseMinSpeed: CGFloat = 350 // Increased base minimum obstacle speed
    static let obstacleBaseMaxSpeed: CGFloat = 450 // Increased base maximum obstacle speed
    
    // Particle (DNA/coins) constants
    static let particleSpawnInterval: TimeInterval = 0.8 // Particles appear frequently
    static let particleSpeed: CGFloat = 150 // Low constant particle speed
    static let particleSpawnChance: Double = 0.95 // High probability of particle appearance
    
    // Calculate obstacle spawn interval based on level
    static func obstacleSpawnInterval(for level: Int) -> TimeInterval {
        let reduction = min(1.5, Double(level - 1) * 0.3) // Reduce interval for higher levels
        return max(2.5, obstacleBaseSpawnInterval - reduction) // Minimum interval 2.5 seconds
    }
    
    // Calculate minimum obstacle speed based on level
    static func obstacleMinSpeed(for level: Int) -> CGFloat {
        let increase = CGFloat(level - 1) * 25.0 // Increase by 25 units per level
        return obstacleBaseMinSpeed + increase
    }
    
    // Calculate maximum obstacle speed based on level
    static func obstacleMaxSpeed(for level: Int) -> CGFloat {
        let increase = CGFloat(level - 1) * 35.0 // Increase by 35 units per level
        return obstacleBaseMaxSpeed + increase
    }
    
    // Obstacle sizes
    struct ObstacleSizes {
        static let shadow = CGSize(width: 140, height: 80)
    }
    
    // Legacy coin constants (kept for compatibility)
    static let coinSize = CGSize(width: 30, height: 25) // Coin size
    static let coinValue: Int = 1 // Coin value in game points
    
    // Game rewards
    static let levelCompletionReward: Int = 100 // Level completion reward
    static let coinReward: Int = 1 // Coin collection reward during game
    static let achievementReward: Int = 10 // Achievement reward
    static let dailyReward: Int = 10 // Daily reward
    
    // Physics constants
    static let fishPhysicsBodyScale: CGFloat = 0.7 // Fish physics body scale relative to sprite
    static let coinRotationDuration: TimeInterval = 2.5 // Full coin rotation time
    
    // Game mechanics
    static let maxLevels: Int = 3 // Total number of levels in game
    static let maxLives: Int = 1 // Maximum number of lives
    static let fishFlickerCount: Int = 5 // Number of fish flickers
}
