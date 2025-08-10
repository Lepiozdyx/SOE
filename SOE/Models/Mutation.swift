import SwiftUI

// MARK: - Mutation Types
enum MutationType: String, CaseIterable, Codable {
    case finMask = "skin_fin_mask"
    case fin = "skin_fin"
    case jawMask = "skin_jaw_mask"
    case spikesFin = "skin_spikes_fin"
    case spikesFinMask = "skin_spikes_fin_mask"
    case spikesMask = "skin_spikes_mask"
    case spikes = "skin_spikes"
    
    var textureName: String {
        return self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .finMask, .fin:
            return "Fins"
        case .jawMask:
            return "Jaw"
        case .spikesFin, .spikesFinMask:
            return "Spikes + Fins"
        case .spikesMask, .spikes:
            return "Spikes"
        }
    }
    
    // Get random mutation excluding default skin
    static func randomMutation() -> MutationType {
        return MutationType.allCases.randomElement() ?? .fin
    }
}

// MARK: - Mutation Model
struct Mutation: Identifiable, Codable, Equatable {
    var id = UUID()
    let type: MutationType
    let cost: Int
    
    init(type: MutationType, cost: Int) {
        self.type = type
        self.cost = cost
    }
    
    static func == (lhs: Mutation, rhs: Mutation) -> Bool {
        return lhs.type == rhs.type
    }
}

// MARK: - Game Mutation State
struct GameMutationState: Codable {
    var currentSkinType: MutationType?
    var targetMutationType: MutationType?
    var mutationCount: Int = 0
    var totalResourcesSpent: Int = 0
    var availableResources: Int = 0
    
    // Calculate cost for next mutation
    var nextMutationCost: Int {
        let baseCost = 10
        if mutationCount == 0 {
            return baseCost
        }
        return Int(Double(baseCost) * pow(1.5, Double(mutationCount)))
    }
    
    // Check if can afford next mutation
    var canAffordMutation: Bool {
        return availableResources >= nextMutationCost
    }
    
    // Check if current mutation matches target
    var hasWon: Bool {
        guard let current = currentSkinType,
              let target = targetMutationType else { return false }
        return current == target
    }
    
    // Reset for new level
    mutating func reset() {
        currentSkinType = nil
        targetMutationType = MutationType.randomMutation()
        mutationCount = 0
        totalResourcesSpent = 0
        availableResources = 0
    }
    
    // Add resources
    mutating func addResources(_ amount: Int) {
        availableResources += amount
    }
    
    // Perform mutation
    mutating func performMutation() -> Mutation? {
        guard canAffordMutation else { return nil }
        
        let cost = nextMutationCost
        availableResources -= cost
        totalResourcesSpent += cost
        mutationCount += 1
        
        let randomMutation = MutationType.randomMutation()
        let mutation = Mutation(type: randomMutation, cost: cost)
        
        return mutation
    }
    
    // Apply mutation result
    mutating func applyMutation(_ mutation: Mutation) {
        currentSkinType = mutation.type
    }
}
