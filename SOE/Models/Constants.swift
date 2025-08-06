import Foundation
import SwiftUI

// Константы игры
struct GameConstants {
    // Общие константы
    static let defaultAnimationDuration: Double = 0.3
    
    // Константы для игрового процесса
    static let gameDuration: TimeInterval = 30 // 30 секунд на уровень
    static let fishInitialY: CGFloat = 0.5 // Начальная позиция персонажа (в процентах от высоты экрана)
    static let fishHorizontalPosition: CGFloat = 0.15 // Позиция орла по горизонтали (в процентах от ширины экрана)
    static let fishSize = CGSize(width: 60, height: 50) // Размер орла
    
    // Константы для фона
    static let backgroundMovePointsPerSec: CGFloat = 100.0 // Скорость движения фона
    
    // Константы для препятствий
    static let obstacleBaseSpawnInterval: TimeInterval = 2 // Базовый интервал появления препятствий
    static let obstacleBaseMinSpeed: CGFloat = 150 // Базовая минимальная скорость препятствий
    static let obstacleBaseMaxSpeed: CGFloat = 300 // Базовая максимальная скорость препятствий
    
    #warning("убрать из финальной версии приложения")
    // Константы для турнирного режима
    static let tournamentSpawnInterval: TimeInterval = 0.6 // Интервал появления препятствий в турнире
    static let tournamentMinSpeed: CGFloat = 450 // Минимальная скорость препятствий в турнире
    static let tournamentMaxSpeed: CGFloat = 600 // Максимальная скорость препятствий в турнире
    static let tournamentCoinValue: Int = 20 // Стоимость монеты в турнирном режиме
    static let tournamentEntryFee: Int = 100 // Стоимость входа в турнирный режим
    
    // Расчет интервала появления препятствий в зависимости от уровня
    static func obstacleSpawnInterval(for level: Int) -> TimeInterval {
        let reduction = min(0.7, Double(level - 1) * 0.08) // Максимальное уменьшение интервала 0.7
        return max(0.8, obstacleBaseSpawnInterval - reduction) // Минимальный интервал 0.8
    }
    
    // Расчет минимальной скорости препятствий в зависимости от уровня
    static func obstacleMinSpeed(for level: Int) -> CGFloat {
        let increase = CGFloat(level - 1) * 15.0 // Увеличиваем на 15 единиц за каждый уровень
        return obstacleBaseMinSpeed + increase
    }
    
    // Расчет максимальной скорости препятствий в зависимости от уровня
    static func obstacleMaxSpeed(for level: Int) -> CGFloat {
        let increase = CGFloat(level - 1) * 30.0 // Увеличиваем на 30 единиц за каждый уровень
        return obstacleBaseMaxSpeed + increase
    }
    
    // Размеры препятствий
    struct ObstacleSizes {
        static let shadow = CGSize(width: 140, height: 80)
    }
    
    // Константы для бонусов
    static let coinSpawnChance: Double = 0.5 // Вероятность появления монетки (0-1)
    static let coinSize = CGSize(width: 30, height: 25) // Размер монеты
    static let coinValue: Int = 1 // Стоимость монеты в игровых очках
    
    #warning("убрать из финальной версии приложения")
    // Значения для ускорения и выносливости
    static let accelerationMultiplier: CGFloat = 1.5 // Множитель скорости при ускорении
    static let staminaDepletionRate: CGFloat = 20 // Скорость расхода выносливости (поинтов в секунду)
    static let staminaRecoveryRate: CGFloat = 10 // Скорость восстановления выносливости (поинтов в секунду)
    static let maxStamina: CGFloat = 100 // Максимальный запас выносливости
    
    #warning("убрать из финальной версии приложения")
    // Константы для UI
    static let progressBarHeight: CGFloat = 18 // Высота шкалы прогресса
    static let staminaBarHeight: CGFloat = 16 // Высота шкалы выносливости
    static let progressBarWidth: CGFloat = 400
    static let staminaBarWidth: CGFloat = 250
    
    // Награды за игровые действия
    static let levelCompletionReward: Int = 50 // Награда за прохождение уровня
    static let coinReward: Int = 1 // Награда за сбор монетки во время игры
    static let achievementReward: Int = 10 // Награда за достижение
    static let dailyReward: Int = 10 // Ежедневная награда
    
    // Физические константы
    static let fishPhysicsBodyScale: CGFloat = 0.7 // Масштаб физического тела персонажа относительно спрайта
    static let coinRotationDuration: TimeInterval = 2.0 // Время полного оборота монеты
    
    // Игровые механики
    static let maxLevels: Int = 3 // Общее количество уровней в игре
    static let maxLives: Int = 1 // Максимальное количество жизней
    static let fishFlickerCount: Int = 5 // Количество миганий персонажа
}
