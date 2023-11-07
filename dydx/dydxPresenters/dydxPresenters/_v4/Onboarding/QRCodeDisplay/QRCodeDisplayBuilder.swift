//
//  QRCodeDisplayBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 11/16/22.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class QRCodeDisplayBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = QRCodeDisplayPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return QRCodeDisplayController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class QRCodeDisplayController: HostingViewController<PlatformView, QRCodeDisplayModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/qrcode/display", let presenter = presenter as? QRCodeDisplayPresenterProtocol {
            if let code = request?.params?["code"] as? String {
                presenter.viewModel?.content = .code(code)
            } else if let image = request?.params?["image"] as? UIImage {
                presenter.viewModel?.content = .image(image)
            }
            return true
        }
        return false
    }
}

private protocol QRCodeDisplayPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: QRCodeDisplayModel? { get }
}

private class QRCodeDisplayPresenter: HostedViewPresenter<QRCodeDisplayModel>, QRCodeDisplayPresenterProtocol {
    override init() {
        super.init()

        viewModel = QRCodeDisplayModel()
    }
}
