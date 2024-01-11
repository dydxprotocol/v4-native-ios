//
//  ___FILEBASENAMEASIDENTIFIER___.swift
//  dydxUI
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ dYdX Trading Inc. All rights reserved.
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

public class ___FILEBASENAMEASIDENTIFIER___Builder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = ___FILEBASENAMEASIDENTIFIER___Presenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return ___FILEBASENAMEASIDENTIFIER___Controller(presenter: presenter, view: view, configuration: .default) as? T
        // return HostingViewController(presenter: presenter, view: view) as? T
    }
}

private class ___FILEBASENAMEASIDENTIFIER___Controller: HostingViewController<PlatformView, ___FILEBASENAMEASIDENTIFIER___Model> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "<Replace>" {
            return true
        }
        return false
    }
}
 
private protocol ___FILEBASENAMEASIDENTIFIER___PresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: ___FILEBASENAMEASIDENTIFIER___Model? { get }
}

private class ___FILEBASENAMEASIDENTIFIER___Presenter: HostedViewPresenter<___FILEBASENAMEASIDENTIFIER___Model>, ___FILEBASENAMEASIDENTIFIER___PresenterProtocol {
    override init() {
        super.init()

        viewModel = ___FILEBASENAMEASIDENTIFIER___Model()
    }

    override func start() {
        super.start()

        /* Add observation and update viewModel */
    }
}
*/

public class ___FILEBASENAMEASIDENTIFIER___Model: PlatformViewModel {
    @Published public var text: String?

    public init() { }

    public static var previewValue: ___FILEBASENAMEASIDENTIFIER___Model {
        let vm = ___FILEBASENAMEASIDENTIFIER___Model()
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
struct ___FILEBASENAMEASIDENTIFIER____Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return ___FILEBASENAMEASIDENTIFIER___Model.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct ___FILEBASENAMEASIDENTIFIER____Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return ___FILEBASENAMEASIDENTIFIER___Model.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
