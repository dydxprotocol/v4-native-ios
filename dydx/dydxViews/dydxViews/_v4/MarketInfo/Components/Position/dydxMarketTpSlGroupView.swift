//
//  dydxMarketTpSlGroupView.swift
//  dydxUI
//
//  Created by Rui Huang on 16/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

/*
// Move the builder code to the dydxPresenters module for v4, or dydxUI modules for v3
 
import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxMarketTpSlGroupViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxMarketTpSlGroupViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxMarketTpSlGroupViewController(presenter: presenter, view: view, configuration: .default) as? T
        // return HostingViewController(presenter: presenter, view: view) as? T
    }
}

private class dydxMarketTpSlGroupViewController: HostingViewController<PlatformView, dydxMarketTpSlGroupViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "<Replace>" {
            return true
        }
        return false
    }
}
 
private protocol dydxMarketTpSlGroupViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketTpSlGroupViewModel? { get }
}

private class dydxMarketTpSlGroupViewPresenter: HostedViewPresenter<dydxMarketTpSlGroupViewModel>, dydxMarketTpSlGroupViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxMarketTpSlGroupViewModel()
    }

    override func start() {
        super.start()

        /* Add observation and update viewModel */
    }
}
*/

public class dydxMarketTpSlGroupViewModel: PlatformViewModel {
    @Published public var text: String?

    public init() { }

    public static var previewValue: dydxMarketTpSlGroupViewModel {
        let vm = dydxMarketTpSlGroupViewModel()
        vm.text = "Test String"
        return vm
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Text(self.text ?? "")
            )
        }
    }
}

#if DEBUG
struct dydxMarketTpSlGroupView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTpSlGroupViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketTpSlGroupView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTpSlGroupViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

