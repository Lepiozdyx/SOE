import SwiftUI

@main
struct SOEApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SourceView()
                .preferredColorScheme(.light)
        }
    }
}
