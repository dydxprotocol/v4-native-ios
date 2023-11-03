//
//  CircularProgressBar.swift
//  dydxUI
//
//  Created by Rui Huang on 8/26/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI

public class CircularProgressViewModel: PlatformViewModel {
    @Published public var progress: Double = 0
    @Published public var outerTrackColor: Color = Color.pink
    @Published public var innerTrackColor: Color = Color.red
    @Published public var lineWidth: Double = 20
   
    public static var previewValue: CircularProgressViewModel = {
        let vm = CircularProgressViewModel()
        vm.progress = 0.6
        return vm
    }()
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                ZStack {
                    Circle()
                        .stroke(lineWidth: self.lineWidth)
                        .opacity(0.2)
                        .foregroundColor(self.outerTrackColor)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round, lineJoin: .round))
                        .foregroundColor(self.innerTrackColor)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(Animation.linear, value: self.progress)
                }
            )
        }
    }
}

#if DEBUG
struct CircularProgressBar_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            CircularProgressViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif

