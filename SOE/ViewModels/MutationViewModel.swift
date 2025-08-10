import SwiftUI

class MutationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var mutationState = GameMutationState()
    @Published var showMutationOverlay = false
    @Published var showPreGameOverlay = true
    @Published var currentMutationResult: Mutation?
    @Published var isProcessingMutation = false
    
    // MARK: - Dependencies
    weak var appViewModel: AppViewModel?
    weak var gameViewModel: GameViewModel?
    
    // MARK: - Initialization
    init() {
        setupMutationState()
    }
    
    // MARK: - Public Methods
    func setupMutationState() {
        mutationState.reset()
        showPreGameOverlay = true
        currentMutationResult = nil
        isProcessingMutation = false
        
        // Pause the game while showing pre-game overlay (if gameViewModel exists)
        if gameViewModel != nil {
            gameViewModel?.togglePause(true)
        }
        
        objectWillChange.send()
    }
    
    func startGame() {
        showPreGameOverlay = false
        gameViewModel?.togglePause(false)
        
        objectWillChange.send()
    }
    
    func addResources(_ amount: Int) {
        mutationState.addResources(amount)
        
        // Force UI update
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
        // Check for victory after adding resources
        if mutationState.hasWon {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.gameViewModel?.gameOver(win: true)
            }
        }
    }
    
    func canShowMutationButton() -> Bool {
        return mutationState.canAffordMutation && !showMutationOverlay && !isProcessingMutation
    }
    
    func openMutationOverlay() {
        guard !isProcessingMutation else { return }
        
        isProcessingMutation = true
        
        // Perform mutation and deduct resources immediately
        if let mutation = mutationState.performMutation() {
            currentMutationResult = mutation
            showMutationOverlay = true
            
            gameViewModel?.togglePause(true)
        }
        
        isProcessingMutation = false
        objectWillChange.send()
    }
    
    func acceptMutation() {
        guard let mutation = currentMutationResult else { return }
        
        mutationState.applyMutation(mutation)
        
        // Update the fish texture in the game scene
        gameViewModel?.updateFishTexture(mutation.type.textureName)
        
        // Check for victory
        if mutationState.hasWon {
            closeMutationOverlay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.gameViewModel?.gameOver(win: true)
            }
            return
        }
        
        closeMutationOverlay()
    }
    
    func rejectMutation() {
        // Resources are already deducted, just close overlay
        // This is the core mechanic - resources are not returned
        closeMutationOverlay()
    }
    
    func getCurrentSkinTexture() -> String {
        // If there's an active mutation, use that
        if let currentMutation = mutationState.currentSkinType {
            return currentMutation.textureName
        }
        
        // Otherwise, use the skin selected in shop (not hardcoded default)
        return getBaseSkinTexture()
    }
    
    func getTargetSkinTexture() -> String {
        return mutationState.targetMutationType?.textureName ?? getBaseSkinTexture()
    }
    
    func getTargetMutationName() -> String {
        return mutationState.targetMutationType?.displayName ?? "Unknown"
    }
    
    func getCurrentMutationName() -> String {
        return mutationState.currentSkinType?.displayName ?? "Basic"
    }
    
    // MARK: - Private Methods
    
    private func getBaseSkinTexture() -> String {
        return appViewModel?.gameState.currentSkinId ?? "skin_default"
    }
    
    private func closeMutationOverlay() {
        showMutationOverlay = false
        currentMutationResult = nil
        
        gameViewModel?.togglePause(false)
        
        objectWillChange.send()
    }
    
    // MARK: - Reset Methods
    
    func resetForNewLevel() {
        setupMutationState()
        
        if gameViewModel != nil {
            // Use selected skin from shop, not hardcoded default
            gameViewModel?.updateFishTexture(getBaseSkinTexture())
            gameViewModel?.togglePause(true)
        }
    }
    
    func resetForRestart() {
        // Keep the same target mutation but reset progress
        let currentTarget = mutationState.targetMutationType
        mutationState.reset()
        mutationState.targetMutationType = currentTarget
        
        showPreGameOverlay = true
        showMutationOverlay = false
        currentMutationResult = nil
        isProcessingMutation = false
        
        // Reset fish texture to selected shop skin, not hardcoded default
        if gameViewModel != nil {
            gameViewModel?.updateFishTexture(getBaseSkinTexture())
            gameViewModel?.togglePause(true)
        }
        
        objectWillChange.send()
    }
}

// MARK: - Computed Properties
extension MutationViewModel {
    var availableResources: Int {
        mutationState.availableResources
    }
    
    var nextMutationCost: Int {
        mutationState.nextMutationCost
    }
    
    var mutationCount: Int {
        mutationState.mutationCount
    }
    
    var hasWon: Bool {
        mutationState.hasWon
    }
}
