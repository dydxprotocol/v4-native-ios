//
//  dydxTitledCardView.swift
//  dydxViews
//
//  Created by Michael Maguire on 12/1/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTitledCardViewModel: PlatformViewModel {

    public let title: String
    @Published public var tapAction: (() -> Void)?

    public init(title: String) {
        self.title = title
        super.init()
    }

    fileprivate static var previewValue: dydxTitledCardViewModel {
        let vm = dydxTitledCardViewModel(title: "TEST")
        return vm
    }

    func createContent(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        PlatformView.nilView?.wrappedInAnyView()
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 0) {
                HStack {
                    Text(self.title)
                        .themeFont(fontSize: .small)
                    Spacer()
                    if self.tapAction != nil {
                        PlatformIconViewModel(type: .system(name: "chevron.right"),
                                              size: CGSize(width: 10, height: 10),
                                              templateColor: .textSecondary)
                        .createView(parentStyle: style)
                    }
                }
                .padding()

                DividerModel()
                    .createView(parentStyle: style)
                self.createContent(parentStyle: style)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
            }
            .themeColor(background: .layer3)
            .cornerRadius(12, corners: .allCorners)
            .onTapGesture { [weak self] in
                self?.tapAction?()
            }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxTitledCardViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTitledCardViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTitledCardViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTitledCardViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
