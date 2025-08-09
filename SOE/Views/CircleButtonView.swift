//
//  CircleButtonView.swift
//  SoaringEagle
//
//  Created by Alex on 16.05.2025.
//

import SwiftUI

struct CircleButtonView: View {
    let iconName: ImageResource
    let height: CGFloat
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(.btnCircle)
                .resizable()
                .scaledToFit()
                .frame(height: height)
                .overlay {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
        }
        .withSound()
    }
}

#Preview {
    CircleButtonView(iconName: .home, height: 60, action: {})
}
