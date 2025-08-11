import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject private var settings = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    
    @State private var settingsOpacity: Double = 0
    @State private var settingsOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            VStack {
                HStack(alignment: .top) {
                    CircleButtonView(iconName: .home, height: 60) {
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
            
            // Settings block
            HStack(spacing: 25) {
                VStack(spacing: 2) {
                    Text("Music")
                        .gFont(22)
                    
                    Button {
                        settings.toggleMusic()
                    } label: {
                        Image(settings.isMusicOn ? .btnMusicOn : .btnMusicOff)
                            .frame(width: 100, height: 100)
                    }
                    .buttonStyle(.plain)
                    .disabled(!settings.isSoundOn)
                }
                
                VStack(spacing: 2) {
                    Text("Sound")
                        .gFont(22)
                    
                    Button {
                        settings.toggleSound()
                    } label: {
                        Image(settings.isSoundOn ? .btnSoundOn : .btnSoundOff)
                            .frame(width: 100, height: 100)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: 300)
            .padding(.vertical, 60)
            .padding(.horizontal)
            .background(
                Image(.frameBubble)
                    .resizable()
                    .overlay(alignment: .top) {
                        Image(.labelFrame)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .overlay {
                                Text("Settings")
                                    .gFont(24)
                            }
                            .offset(y: -30)
                    }
            )
            .opacity(settingsOpacity)
            .offset(y: settingsOffset)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                settingsOpacity = 1.0
                settingsOffset = 0
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
