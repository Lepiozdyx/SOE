import Foundation
import SwiftUI

// Определяет различные экраны в приложении
enum AppScreen: CaseIterable {
    case menu
    case levelSelect
    case game
    case settings
    case shop
    case achievements
    case dailyReward
    case upgrades
}

// Структура для элементов фона
struct BackgroundItem: Identifiable, Codable, Equatable {
    let id: String
    let imageName: String
    let price: Int
    
    static func == (lhs: BackgroundItem, rhs: BackgroundItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Доступные фоны в магазине
    static let availableBackgrounds: [BackgroundItem] = [
        BackgroundItem(id: "bg1", imageName: "bg1", price: 0),
        BackgroundItem(id: "bg2", imageName: "bg2", price: 100),
        BackgroundItem(id: "bg3", imageName: "bg3", price: 200),
        BackgroundItem(id: "bg4", imageName: "bg4", price: 300)
    ]
    
    static func getBackground(id: String) -> BackgroundItem {
        return availableBackgrounds.first { $0.id == id } ?? availableBackgrounds[0]
    }
}

// Структура для скинов
struct FishSkinItem: Identifiable, Codable, Equatable {
    let id: String
    let imageName: String
    let price: Int
    
    static func == (lhs: FishSkinItem, rhs: FishSkinItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Доступные скины в магазине
    static let availableSkins: [FishSkinItem] = [
        FishSkinItem(id: "default", imageName: "skin_default", price: 0),
        FishSkinItem(id: "skin2", imageName: "skin2", price: 100),
        FishSkinItem(id: "skin3", imageName: "skin3", price: 200),
        FishSkinItem(id: "skin4", imageName: "skin4", price: 300)
    ]
    
    static func getSkin(id: String) -> FishSkinItem {
        return availableSkins.first { $0.id == id } ?? availableSkins[0]
    }
}

#warning("убрать из финальной версии приложения")
// Структура для типов улучшений скинов
struct EagleTypeUpgrade: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let typeNumber: Int
    let price: Int
    let imageName: String
    let rates: Int
    
    static func == (lhs: EagleTypeUpgrade, rhs: EagleTypeUpgrade) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Доступные типы улучшений скинов
    static let availableTypes: [EagleTypeUpgrade] = [
        EagleTypeUpgrade(id: "type1", name: "Basic", typeNumber: 1, price: 0, imageName: "type1", rates: 0),
        EagleTypeUpgrade(id: "type2", name: "Advanced", typeNumber: 2, price: 20, imageName: "type2", rates: 2),
        EagleTypeUpgrade(id: "type3", name: "Elite", typeNumber: 3, price: 40, imageName: "type3", rates: 4),
        EagleTypeUpgrade(id: "type4", name: "Ultimate", typeNumber: 4, price: 60, imageName: "type4", rates: 6)
    ]
    
    static func getType(id: String) -> EagleTypeUpgrade {
        return availableTypes.first { $0.id == id } ?? availableTypes[0]
    }
}

// Структура для достижений
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let imageName: String
    let reward: Int
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Список всех достижений
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_step",
            imageName: "achieve_first_step",
            reward: 10
        ),
        Achievement(
            id: "grindilka_veteran",
            imageName: "achieve_grindilka_veteran",
            reward: 10
        ),
        Achievement(
            id: "master_of_chaos",
            imageName: "achieve_master_of_chaos",
            reward: 10
        ),
        Achievement(
            id: "true_mutant",
            imageName: "achieve_true_mutant",
            reward: 10
        ),
        Achievement(
            id: "elusive",
            imageName: "achieve_elusive",
            reward: 10
        ),
        Achievement(
            id: "adaptation_champion",
            imageName: "achieve_adaptation_champion",
            reward: 10
        )
    ]
    
    static func byId(_ id: String) -> Achievement? {
        return allAchievements.first { $0.id == id }
    }
}
