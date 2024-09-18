//
//  dydxAlertsViewBuilder.swift
//  dydxUI
//
//  Created by Michael Maguire on 9/17/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

// Move the builder code to the dydxPresenters module for v4, or dydxUI modules for v3
 
import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxAlertsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxAlertsViewBuilderPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxAlertsViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxAlertsViewController: HostingViewController<PlatformView, dydxAlertsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/alerts" {
            return true
        }
        return false
    }
}
 
private protocol dydxAlertsViewBuilderPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxAlertsViewModel? { get }
}

private class dydxAlertsViewBuilderPresenter: HostedViewPresenter<dydxAlertsViewModel>, dydxAlertsViewBuilderPresenterProtocol {
    private let alertsProvider = dydxAlertsProvider.shared

    override init() {
        super.init()

        viewModel = dydxAlertsViewModel()
        
        viewModel?.listViewModel.contentChanged = { [weak self] in
            self?.viewModel?.objectWillChange.send()
        }
    }

    override func start() {
        super.start()

        alertsProvider.items
            .sink { [weak self] viewModels in
                self?.viewModel?.listViewModel.items = viewModels
            }
            .store(in: &subscriptions)
    }
}

//public class dydxAlertsViewModel: PlatformViewModel {
//    @Published public var text: String?
//
//    public init() { }
//
//    public static var previewValue: dydxAlertsViewModel {
//        let vm = dydxAlertsViewModel()
//        vm.text = "Test String"
//        return vm
//    }
//    
//    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
//        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
//            guard let self = self else { return AnyView(PlatformView.nilView) }
//
//            return AnyView(
//                Text(self.text ?? "")
//            )
//        }
//    }
//}

#if DEBUG
struct dydxAlertsViewBuilder_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAlertsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAlertsViewBuilder_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAlertsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

