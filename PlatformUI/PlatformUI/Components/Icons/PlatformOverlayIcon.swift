//
//  PlatformOverlayIcon.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/24/22.
//

import SwiftUI

public class PlatformOverlayIconViewModel<MainIcon: PlatformViewModeling, OverlayIcon: PlatformViewModeling>: PlatformViewModel {
    @Published public var mainIcon: MainIcon
    @Published public var overlayIcon: OverlayIcon?
    @Published public var size: CGSize
    @Published public var offset: CGPoint

    public init(mainIcon: MainIcon, overlayIcon: OverlayIcon? = nil, size: CGSize = CGSize(width: 32, height: 32), offset: CGPoint = CGPoint(x: 12, y: -12)) {
        self.mainIcon = mainIcon
        self.overlayIcon = overlayIcon
        self.size = size
        self.offset = offset
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Group {
                    ZStack {
                        self.mainIcon.createView(parentStyle: style, styleKey: nil)

                        if let overlayIcon = self.overlayIcon {
                            overlayIcon.createView(parentStyle: style, styleKey: nil)
                                .offset(x: self.offset.x, y: self.offset.y)
                        }
                    }
                }
                .frame(width: self.size.width, height: self.size.height)
            )
        }
    }
}

#if DEBUG
struct PlatformOverlayIcon_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings()

    static var imageView: some View {
       Image(systemName: "heart.fill")
               .resizable()
               .scaledToFit()
               .frame(width: 32, height: 32)
    }

    static var previews: some View {
        Group {
            let mainIcon = PlatformIconViewModel(type: .system(name: "heart.fill"), size: CGSize(width: 24, height: 24))
            let overlayIcon = PlatformIconViewModel(type: .system(name: "heart.fill"), size: CGSize(width: 8, height: 8))

            PlatformOverlayIconViewModel(mainIcon: mainIcon,
                                         overlayIcon: overlayIcon)
                .createView()
                .previewLayout(.sizeThatFits)
        }
   }
}
#endif
