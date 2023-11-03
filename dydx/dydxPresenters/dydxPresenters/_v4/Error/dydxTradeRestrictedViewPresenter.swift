//
//  dydxTradeRestrictedViewPresenter.swift
//  dydxUI
//
//  Created by Michael Maguire on 9/25/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PanModal

public class dydxTradeRestrictedViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTradeRestrictedPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTradeRestrictedController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxTradeRestrictedController: HostingViewController<PlatformView, dydxTradeRestrictedViewModel> {
    override var modalPresentationStyle: UIModalPresentationStyle { get { .overFullScreen } set {} }

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/error/geo" {
            return true
        }
        return false
    }
}

private protocol dydxTradeRestrictedPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeRestrictedViewModel? { get }
}

private class dydxTradeRestrictedPresenter: HostedViewPresenter<dydxTradeRestrictedViewModel>, dydxTradeRestrictedPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTradeRestrictedViewModel()
    }
}

public class dydxTradeRestrictedViewModel: PlatformViewModel {

    public init() { }

    public static var previewValue: dydxTradeRestrictedViewModel {
        let vm = dydxTradeRestrictedViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                ZStack(alignment: .bottom) {
                    ThemeColor.SemanticColor.layer0.color
                        .opacity(0.8)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 0) {
                            Text(DataLocalizer.shared?.localize(path: "ERRORS.ONBOARDING.REGION_NOT_PERMITTED_TITLE", params: nil) ?? "")
                                .themeFont(fontType: .bold, fontSize: .larger)
                                .themeColor(foreground: .textPrimary)
                            Spacer()
                        }
                        Text(DataLocalizer.shared?.localize(path: "ERRORS.ONBOARDING.REGION_NOT_PERMITTED_SUBTITLE", params: nil) ?? "")
                            .themeFont(fontType: .text, fontSize: .medium)
                            .themeColor(foreground: .textSecondary)
                    }
                    .padding([.top, .leading, .trailing], 36)
                    .padding(.bottom, self.safeAreaInsets?.bottom)
                    .themeColor(background: .layer3)
                    .cornerRadius(36, corners: [.topLeft, .topRight])
                    .frame(width: UIScreen.main.bounds.width)
                }
                .edgesIgnoringSafeArea(.vertical)
            )
        }
    }
}

#if DEBUG
struct dydxTradeRestricted_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeRestrictedViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeRestricted_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeRestrictedViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
