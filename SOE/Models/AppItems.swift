import Foundation
import SwiftUI

enum AppScreen: CaseIterable {
    case menu
    case levelSelect
    case game
    case settings
    case shop
    case achievements
    case dailyReward
}

struct BackgroundItem: Identifiable, Codable, Equatable {
    let id: String
    let imageName: String
    let price: Int
    
    static func == (lhs: BackgroundItem, rhs: BackgroundItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let availableBackgrounds: [BackgroundItem] = [
        BackgroundItem(id: "bg1", imageName: "bg1", price: 0),
        BackgroundItem(id: "bg2", imageName: "bg2", price: 100),
        BackgroundItem(id: "bg3", imageName: "bg3", price: 100),
        BackgroundItem(id: "bg4", imageName: "bg4", price: 100)
    ]
    
    static func getBackground(id: String) -> BackgroundItem {
        return availableBackgrounds.first { $0.id == id } ?? availableBackgrounds[0]
    }
}

struct FishSkinItem: Identifiable, Codable, Equatable {
    let id: String
    let imageName: String
    let price: Int
    
    static func == (lhs: FishSkinItem, rhs: FishSkinItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let availableSkins: [FishSkinItem] = [
        FishSkinItem(id: "default", imageName: "skin_default", price: 0),
        FishSkinItem(id: "skin2", imageName: "skin2", price: 100),
        FishSkinItem(id: "skin3", imageName: "skin3", price: 100),
        FishSkinItem(id: "skin4", imageName: "skin4", price: 100)
    ]
    
    static func getSkin(id: String) -> FishSkinItem {
        return availableSkins.first { $0.id == id } ?? availableSkins[0]
    }
}

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let imageName: String
    let reward: Int
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
    
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
