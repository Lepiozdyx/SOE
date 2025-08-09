import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ShopViewModel()
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
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
                    
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 55
                    )
                }
                
                Spacer()
            }
            .padding()
            
            HStack {
                Image(.frameShop)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                
                VStack {
                    // Tab selector
                    TabSelectorView(
                        selectedTab: $viewModel.currentTab
                    )
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                    
                    // Shop items grid
                    VStack {
                        LazyVGrid(columns: columns, spacing: 10) {
                            if viewModel.currentTab == .skins {
                                ForEach(viewModel.availableSkins) { skin in
                                    ShopItemView(
                                        itemType: .skin,
                                        imageName: skin.imageName,
                                        name: skin.id,
                                        price: skin.price,
                                        isPurchased: viewModel.isSkinPurchased(skin.id),
                                        isSelected: viewModel.isSkinSelected(skin.id),
                                        canAfford: appViewModel.coins >= skin.price,
                                        onBuy: {
                                            viewModel.purchaseSkin(skin.id)
                                        },
                                        onSelect: {
                                            viewModel.selectSkin(skin.id)
                                        }
                                    )
                                }
                            } else {
                                ForEach(viewModel.availableBackgrounds) { background in
                                    ShopItemView(
                                        itemType: .background,
                                        imageName: background.imageName,
                                        name: background.id,
                                        price: background.price,
                                        isPurchased: viewModel.isBackgroundPurchased(background.id),
                                        isSelected: viewModel.isBackgroundSelected(background.id),
                                        canAfford: appViewModel.coins >= background.price,
                                        onBuy: {
                                            viewModel.purchaseBackground(background.id)
                                        },
                                        onSelect: {
                                            viewModel.selectBackground(background.id)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 200)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                }
            }
        }
        .onAppear {
            viewModel.appViewModel = appViewModel
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
}

// Tab selector between shop categories
struct TabSelectorView: View {
    @Binding var selectedTab: ShopViewModel.ShopTab
    
    var body: some View {
        HStack(spacing: 20) {
            TabButton(
                title: "Skin",
                isSelected: selectedTab == .skins,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .skins
                    }
                }
            )
            
            TabButton(
                title: "BG",
                isSelected: selectedTab == .backgrounds,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .backgrounds
                    }
                }
            )
        }
    }
}

// Tab button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(.btnAction)
                .resizable()
                .frame(width: 100, height: 40)
                .overlay(
                    Text(title)
                        .gFont(16)
                )
                .scaleEffect(isSelected ? 1 : 0.85)
        }
    }
}

// Shop item view
struct ShopItemView: View {
    enum ItemType {
        case skin
        case background
    }
    
    let itemType: ItemType
    let imageName: String
    let name: String
    let price: Int
    let isPurchased: Bool
    let isSelected: Bool
    let canAfford: Bool
    let onBuy: () -> Void
    let onSelect: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            // Item image
            Image(getPreviewImageName())
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 70)
                .overlay(alignment: .bottom) {
                    // Buy/select button
                    Button {
                        if isPurchased {
                            if !isSelected {
                                onSelect()
                            }
                        } else if canAfford {
                            onBuy()
                        }
                    } label: {
                        if isPurchased {
                            Image(.buttonM)
                                .resizable()
                                .frame(maxWidth: 100, maxHeight: 35)
                                .overlay {
                                    Text(isSelected ? "Selected" : "Select")
                                        .gFont(12)
                                }
                        } else {
                            Image(.btnBy)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                        }
                    }
                    .disabled((isPurchased && isSelected) || (!isPurchased && !canAfford))
                    .opacity((isPurchased && isSelected) || (!isPurchased && !canAfford) ? 0.6 : 1)
                }
        }
    }
    
    private func getPreviewImageName() -> String {
        switch itemType {
        case .skin:
            if imageName.contains("default") {
                return "skin_default"
            } else if imageName.contains("skin2") {
                return "skin2"
            } else if imageName.contains("skin3") {
                return "skin3"
            } else if imageName.contains("skin4") {
                return "skin4"
            } else {
                return "skin_default"
            }
            
        case .background:
            if imageName.contains("bg1") {
                return "bg1Preview"
            } else if imageName.contains("bg2") {
                return "bg2Preview"
            } else if imageName.contains("bg3") {
                return "bg3Preview"
            } else if imageName.contains("bg4") {
                return "bg4Preview"
            } else {
                return "bg1Preview"
            }
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppViewModel())
}
