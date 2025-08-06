import Foundation

// Типы препятствий в игре
enum ObstacleType: String, CaseIterable {
    case shadow = "shadow"
    
    var imageName: String {
        return self.rawValue
    }
    
//    static func random() -> ObstacleType {
//        let allTypes = ObstacleType.allCases
//        return allTypes.randomElement() ?? .shadow
//    }
}

struct Obstacle: Identifiable {
    let id = UUID()
    let type: ObstacleType
    var position: CGPoint
    var size: CGSize
    
    init(type: ObstacleType, position: CGPoint) {
        self.type = type
        self.position = position
        
        switch type {
        case .shadow:
            self.size = GameConstants.ObstacleSizes.shadow
        }
    }
}

struct Coin: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size = GameConstants.coinSize
    let value = GameConstants.coinValue
}
