import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject private var settings = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    
    @State private var settingsOpacity: Double = 0
    @State private var settingsOffset: CGFloat = 20
    
    @State private var showingAlert = false
    
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
                    
                    #warning("Delete after all")
                    // Reset progress button
                    Button {
                        showingAlert.toggle()
                    } label: {
                        VStack {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 25)
                                .foregroundStyle(.red)
                            
                            Text("Reset")
                                .gFont(10)
                        }
                    }
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
        .confirmationDialog("This action will reset all progress!", isPresented: $showingAlert, titleVisibility: .visible) {
            Button("Yes. Reset!", role: .destructive) {
                appViewModel.resetAllProgress()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
