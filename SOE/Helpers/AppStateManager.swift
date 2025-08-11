import Foundation

@MainActor
final class AppStateManager: ObservableObject {
    enum AppState {
        case initial
        case support
        case game
    }
    
    @Published private(set) var appState: AppState = .initial
    let webManager: NetworkManager
    
    private var timeoutTask: Task<Void, Never>?
    private let maxLoadingTime: TimeInterval = 10.0
    
    init(webManager: NetworkManager = NetworkManager()) {
        self.webManager = webManager
    }
    
    func stateCheck() {
        timeoutTask?.cancel()
        
        Task { @MainActor in
            do {
                if webManager.targetURL != nil {
                    updateState(.support)
                    return
                }
                
                let shouldShowWebView = try await webManager.checkInitialURL()
                
                if shouldShowWebView {
                    updateState(.support)
                } else {
                    updateState(.game)
                }
                
            } catch {
                updateState(.game)
            }
        }
        
        startTimeoutTask()
    }
    
    private func updateState(_ newState: AppState) {
        timeoutTask?.cancel()
        timeoutTask = nil
        
        appState = newState
    }
    
    private func startTimeoutTask() {
        timeoutTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: UInt64(maxLoadingTime * 1_000_000_000))
                
                if self.appState == .initial {
                    self.appState = .game
                }
            } catch {}
        }
    }
    
    deinit {
        timeoutTask?.cancel()
    }
}
