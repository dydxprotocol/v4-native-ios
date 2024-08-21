//
//  ProgressStepView.swift
//  dydxUI
//
//  Created by Rui Huang on 7/13/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class ProgressStepViewModel: PlatformViewModel {
    public enum Status {
        case custom(String)
        case inProgress, completed
    }

    @Published public var title: String?
    @Published public var subtitle: String?
    @Published public var status: Status = .custom("1")
    @Published public var tapAction: (() -> Void)?

    public init() { }

    public init(title: String? = nil, subtitle: String? = nil, status: ProgressStepViewModel.Status = .custom("1"), tapAction: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.tapAction = tapAction
    }

    public static var previewValue: ProgressStepViewModel {
        let vm = ProgressStepViewModel()
        vm.title = "Test String"
        vm.subtitle = "Subtitle String"
        vm.status = .inProgress
        vm.tapAction = { }
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            var main: any View = VStack(alignment: .leading, spacing: 4) {
                Text(self.title ?? "")
                    .themeFont(fontSize: .large)
                if let subtitle = self.subtitle {
                    Text(subtitle)
                        .themeFont(fontSize: .medium)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            let logo: PlatformViewModel
            switch self.status {
            case .completed:
                logo = PlatformIconViewModel(type: .system(name: "checkmark"),
                                             size: CGSize(width: 16, height: 16),
                                             templateColor: .colorGreen)
                .createView(parentStyle: style)
                .circleBackground()
                .wrappedViewModel

                main = main
                    .themeColor(foreground: .textPrimary)

            case .custom(let text):
                logo = Text(text)
                    .themeColor(foreground: .textTertiary)
                    .clipped()
                    .circleBackground()
                    .wrappedViewModel

                main = main
                    .themeColor(foreground: .textTertiary)

            case .inProgress:
                logo = ProgressView()
                    .tint(ThemeColor.SemanticColor.textPrimary.color)
                    .progressViewStyle(.circular)
                    .circleBackground()
                    .wrappedViewModel

                main = main
                    .themeColor(foreground: .textPrimary)
            }

            let trailing = (self.tapAction != nil) ?
                PlatformIconViewModel(type: .asset(name: "icon_external_link", bundle: Bundle.dydxView),
                                                 size: CGSize(width: 24, height: 24)) :
                PlatformView.nilViewModel

            return AnyView(
                PlatformTableViewCellViewModel(leading: PlatformView.nilViewModel,
                                               logo: logo,
                                               main: main.wrappedViewModel,
                                               trailing: trailing)
                .createView(parentStyle: style)
                .frame(width: UIScreen.main.bounds.width - 32, height: 100)
                .onTapGesture { [weak self] in
                    self?.tapAction?()
                }
            )
        }
    }
}

#if DEBUG
struct ProgressStepView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return ProgressStepViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct ProgressStepView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return ProgressStepViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
