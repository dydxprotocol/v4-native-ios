//
//  LoadingDots.swift
//  PlatformUI
//
//  Created by Rui Huang on 22/01/2025.
//

import SwiftUI

public struct LoadingDots: View {
    public init(color: Color = .gray, size: CGFloat = 10) {
        self.color = color
        self.size = size
    }
    
    public let color: Color
    public let size: CGFloat
    
    @State var loading = false
    
    public var body: some View {
        HStack(spacing: 20) {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .scaleEffect(loading ? 1.5 : 0.5)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: loading)
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .scaleEffect(loading ? 1.5 : 0.5)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.2), value: loading)
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .scaleEffect(loading ? 1.5 : 0.5)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.4), value: loading)
        }
        .onAppear() {
            self.loading = true
        }
    }
}
