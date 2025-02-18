//
//  PlatformIcon.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/24/22.
//

import SwiftUI
import SDWebImageSwiftUI

public class PlatformIconViewModel: PlatformViewModel {
    public enum IconType {
        case asset(name: String?, bundle: Bundle?)
        case url(url: URL?, placeholderContent: (() -> AnyView)? = nil)
        case system(name: String)
        case uiImage(image: UIImage)
        case any(viewModel: PlatformViewModel)
    }

    public enum IconClip {
        case noClip

        case circle(background: ThemeColor.SemanticColor,
                    spacing: CGFloat,
                    borderColor: ThemeColor.SemanticColor? = nil)

        public static var defaultCircle: Self {
            .circle(background: .transparent, spacing: 0)
        }
    }

    @Published public var type: IconType
    @Published public var clip: IconClip
    @Published public var size: CGSize
    @Published public var templateColor: ThemeColor.SemanticColor?
    @Published public var backgroundColor: ThemeColor.SemanticColor

    public init(type: IconType, clip: IconClip = .noClip, size: CGSize = CGSize(width: 32, height: 32), templateColor: ThemeColor.SemanticColor? = nil, backgroundColor: ThemeColor.SemanticColor = .transparent) {
        self.type = type
        self.clip = clip
        self.size = size
        self.templateColor = templateColor
        self.backgroundColor = backgroundColor
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = Group {
                switch self.type {
                case .system(let name):
                    Image(systemName: name)
                            .resizable()
                            .templateColor(self.templateColor)
                            .scaledToFit()
                            .themeColor(background: self.backgroundColor)
                case .asset(let name, let bundle):
                    if let name = name {
                        Image(name, bundle: bundle)
                            .resizable()
                            .templateColor(self.templateColor)
                            .scaledToFit()
                            .themeColor(background: self.backgroundColor)
                    } else {
                        PlatformView.nilView
                    }
                case .url(let url, let placeholderContent):
                    WebImage(url: url) { image in
                        image.resizable() // Control layout like SwiftUI.AsyncImage, you must use this modifier or the view will use the image bitmap size
                    } placeholder: {
                        placeholderContent?()
                    }
                        .resizable()
                        .templateColor(self.templateColor)
                        .scaledToFit()
                        .themeColor(background: self.backgroundColor)
                case .uiImage(let image):
                    if let cgImage = image.cgImage {
                        Image(decorative: cgImage, scale: 1)
                            .resizable()
                            .templateColor(self.templateColor)
                            .scaledToFit()
                    } else {
                        PlatformView.nilView
                    }
                case .any(let viewModel):
                    viewModel.createView(parentStyle: style)
                        .themeColor(background: self.backgroundColor)
                }
            }

            let size = self.size
            switch self.clip {
            case .noClip:
                return AnyView(
                    view.frame(width: size.width, height: size.height)
                        .themeStyle(style: style)
                )
            case .circle(let background, let spacing, let borderColor):
                if spacing <= 0 && size.width > spacing && size.height > spacing {
                    return AnyView(
                        view
                            .frame(width: size.width, height: size.height).clipShape(Circle())
                            .themeStyle(style: style)
                    )
                } else {
                    let clippedView = Group {

                        ZStack {
                            Circle()
                                .fill(background.color)
                                .frame(width: size.width, height: size.height)
                                .themeColor(background: background)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(borderColor?.color ?? .clear, lineWidth: 1)
                                )

                            view
                                .frame(width: size.width - spacing, height: size.height - spacing)
                                .clipped()
                        }
                        .themeStyle(style: style)
                    }
                    return AnyView(clippedView)
                }
            }
        }
    }
}

#if DEBUG
struct PlatformIcon_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings()

    static var imageView: some View {
       Image(systemName: "heart.fill")
               .resizable()
               .scaledToFit()
               .frame(width: 32, height: 32)
    }

    static var previews: some View {
        Group {
            PlatformIconViewModel(type: .system(name: "heart.fill"))
                .createView()
               .previewLayout(.sizeThatFits)

            PlatformIconViewModel(type: .system(name: "heart.fill"), size: CGSize(width: 64, height: 64))
                .createView()
               .previewLayout(.sizeThatFits)

            PlatformIconViewModel(type: .system(name: "heart.fill"), templateColor: .colorYellow)
                .createView()
               .previewLayout(.sizeThatFits)

            let url = URL(string: "https://s3.amazonaws.com/dydx.exchange/logos/walletconnect/lg/9d373b43ad4d2cf190fb1a774ec964a1addf406d6fd24af94ab7596e58c291b2.jpeg")

            PlatformIconViewModel(type: .url(url: url))
                .createView()
                .previewLayout(.sizeThatFits)

            PlatformIconViewModel(type: .url(url: url), clip: .defaultCircle)
                .createView()
                .previewLayout(.sizeThatFits)

            PlatformIconViewModel(type: .system(name: "heart.fill"), clip: .circle(background: .layer0, spacing: 10))
                .createView()
                .previewLayout(.sizeThatFits)

            let uiImage = UIImage(named: "heart.fill")
            PlatformIconViewModel(type: .uiImage(image: uiImage ?? UIImage()))
                .createView()
                .previewLayout(.sizeThatFits)

        }
        .environmentObject(themeSettings)
   }
}
#endif
