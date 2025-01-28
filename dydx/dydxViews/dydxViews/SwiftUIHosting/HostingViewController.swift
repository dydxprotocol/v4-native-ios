//
//  HostingViewController.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/15/22.
//

import Foundation
import UIKit
import SwiftUI
import ParticlesKit
import SnapKit
import PlatformParticles
import PlatformUI
import UIToolkits
import PlatformRouting
import FloatingPanel
import Utilities
import Combine
import RoutingKit

public struct HostingViewControllerConfiguration {
    public init(ignoreSafeArea: Bool = true, fixedHeight: CGFloat? = nil, gradientTabbar: Bool = false, disableNavigationController: Bool = false, fullScreenSheet: Bool = false) {
        self.ignoreSafeArea = ignoreSafeArea
        self.fixedHeight = fixedHeight
        self.gradientTabbar = gradientTabbar
        self.disableNavigationController = disableNavigationController
        self.fullScreenSheet = fullScreenSheet
    }

    var ignoreSafeArea: Bool
    var fixedHeight: CGFloat?
    var gradientTabbar: Bool
    var disableNavigationController: Bool
    var fullScreenSheet: Bool

    public static let `default` = HostingViewControllerConfiguration(ignoreSafeArea: false, fixedHeight: nil, gradientTabbar: false)
    public static let ignoreSafeArea = HostingViewControllerConfiguration(ignoreSafeArea: true)
    public static let tabbarItemView = HostingViewControllerConfiguration(ignoreSafeArea: false, fixedHeight: nil, gradientTabbar: true)
    public static let fullScreenSheet = HostingViewControllerConfiguration(ignoreSafeArea: true, fullScreenSheet: true)
}

open class HostingViewController<V: View, VM: PlatformViewModel>: TrackingViewController, UIViewControllerEmbeddingProtocol, UITabBarControllerDelegate, UISheetPresentationControllerDelegate {

    open override var routingRequest: RoutingRequest? {
        didSet {
            presenter?.currentRoute = routingRequest
        }
    }

    private var hostingController: UIHostingController<AnyView>?
    private let presenterView = ObjectPresenterView()
    public var configuration: HostingViewControllerConfiguration = .default
    private var subscriptions = Set<AnyCancellable>()

    static private var gradientColors: [UIColor] { [ThemeColor.SemanticColor.layer2.uiColor.withAlphaComponent(0.01),
                                                     ThemeColor.SemanticColor.layer2.uiColor.withAlphaComponent(0.90)] }
    private let gradientView = GradientView(gradientColors: HostingViewController.gradientColors,
                                                          startPoint: CGPoint(x: 0.5, y: 0),
                                                          endPoint: CGPoint(x: 0.5, y: 0.25))

    public private(set) var presenter: HostedViewPresenter<VM>?

    public convenience init(presenter: HostedViewPresenter<VM> = SimpleHostedViewPresenter(), view: V, configuration: HostingViewControllerConfiguration = .default) {
        self.init(nibName: nil, bundle: nil)
        self.configuration = configuration
        self.presenter = presenter
        let view = view
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) {[weak self] _ in
                self?.screenshotDetected()
            }
            .wrappedInAnyView()
        hostingController = UIHostingController<AnyView>(rootView: view, ignoreSafeArea: configuration.ignoreSafeArea)
        presenterView.presenter = presenter

        floatingManager = HostingViewEmbeddingFloatingManager(parent: self)
    }

    private func screenshotDetected() {
        if UIViewController.topmost() == self {
            Tracking.shared?.log(event: "ScreenshotCaptured", data: ["view_controller_class_name": String(describing: type(of: self))])
        }
    }

    open override func loadView() {
        // Do not call super!
        view = presenterView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        if configuration.fullScreenSheet, let sheet = sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.delegate = self
        }

        tabBarController?.delegate = self

        if let hostingController = hostingController {
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.navigationController?.navigationBar.isHidden = true
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.snp.updateConstraints {  make in
                make.edges.equalToSuperview()
                if let fixedHeight = configuration.fixedHeight {
                    make.height.equalTo(fixedHeight)
                }
            }
            hostingController.didMove(toParent: self)

            hostingController.view.backgroundColor = .clear
        }

        if configuration.gradientTabbar {
            tabBarController?.tabBar.backgroundColor = .clear
            tabBarController?.tabBar.isTranslucent = true
            tabBarController?.tabBar.shadowImage = UIImage()
            tabBarController?.tabBar.backgroundImage = UIImage()

            view.addSubview(gradientView)
            gradientView.snp.updateConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(96)
            }
        }

        dydxThemeSettings.shared.$currentThemeType.sink { [weak self] _ in
            self?.updateTabItemGradient()
        }.store(in: &subscriptions)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateTabItemGradient()

        if presenter?.isStarted ?? false == false {
            presenter?.start()
            // bug fix in PanModal lib
            // https://github.com/slackhq/PanModal/issues/105#issuecomment-1671658458
            if isPanModalPresented {
                DispatchQueue.main.async { [weak self] in
                    self?.panModalSetNeedsLayoutUpdate()
                    self?.panModalTransition(to: .shortForm)
                }
            }
        }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        presenter?.stop()
    }

    open override func panModalDidDismiss() {
        presenter?.onHalfSheetDismissal()
    }

    // https://stackoverflow.com/a/79006732
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        UIView.setAnimationsEnabled(false)
        return true
    }

    // https://stackoverflow.com/a/79006732
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UIView.setAnimationsEnabled(true)
    }
    /// The hosting controller may in some cases want to make the navigation bar be not hidden.
    /// Restrict the access to the outside world, by setting the navigation controller to nil when internally accessed.
    open override var navigationController: UINavigationController? {
        super.navigationController?.navigationBar.isHidden = true
        if configuration.disableNavigationController {
            return nil
        } else {
            return super.navigationController
        }
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        switch dydxThemeSettings.shared.currentThemeType {
        case .dark, .system, .classicDark:
            return .lightContent
        case .light:
            return .darkContent
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if ThemeSettings.respondsToSystemTheme {
            if UITraitCollection.current.userInterfaceStyle == .dark, dydxThemeSettings.shared.currentThemeType != .dark {
                ThemeSettings.applyDarkTheme()
            } else if UITraitCollection.current.userInterfaceStyle == .light, dydxThemeSettings.shared.currentThemeType != .light {
                ThemeSettings.applyLightTheme()
            }
            updateTabItemGradient()
        }
    }

    // MARK: UISheetPresentationControllerDelegate

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presenter?.onHalfSheetDismissal()
    }

    // MARK: UIViewControllerEmbeddingProtocol

    public var floated: UIViewController? {
        get {
            return embeddingFloatingManager?.floated
        }
        set {
            embeddingFloatingManager?.float(newValue, animated: true)
        }
    }

    public var embedded: UIViewController? {
        get {
            return embeddingFloatingManager?.embedded
        }
        set {
            embeddingFloatingManager?.embed(newValue, animated: true)
        }
    }

    public func embed(_ viewController: UIViewController?, animated: Bool) -> Bool {
        if let embeddingFloatingManager = embeddingFloatingManager {
            embeddingFloatingManager.embed(viewController, animated: animated)
            return true
        }
        return false
    }

    public func float(_ viewController: UIViewController?, animated: Bool) -> Bool {
        if let embeddingFloatingManager = embeddingFloatingManager {
            embeddingFloatingManager.float(viewController, animated: animated)
            return true
        }
        return false
    }

    public var embeddingFloatingManager: EmbeddingProtocol? {
        return floatingManager as? EmbeddingProtocol
    }

    private func updateTabItemGradient() {
        gradientView.gradientColors = HostingViewController.gradientColors
    }
}

private class HostingViewEmbeddingFloatingManager: EmbeddingFloatingManager {
    override var floating: FloatingPanelController? {
        didSet {
            floating?.surfaceView.layer.cornerRadius = 36
            floating?.surfaceView.layer.masksToBounds = true

            let color: UIColor?
            color = .clear

            //            floating?.view.backgroundColor = color
            floating?.backdropView.backgroundColor = color
            floating?.surfaceView.backgroundColor = color
            floating?.surfaceView.grabberHandle.isHidden = true
        }
    }

    override func float(_ viewController: UIViewController?) {
        let color = ThemeColor.SemanticColor.layer6.uiColor

        floating?.view.backgroundColor = color

        let height = viewController?.intrinsicHeight?.doubleValue
        if let height = height {
            HostingViewDefaultLayout.tipHeight = CGFloat(height)
        } else {
            HostingViewDefaultLayout.tipHeight = nil
        }
        super.float(viewController)
    }

    override func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        if vc == half {
            return super.floatingPanel(vc, layoutFor: newCollection)
        } else {
            return (floated as? FloatingLayoutProviderProtocol)?.floatingLayout(traitCollection: newCollection) ?? HostingViewDefaultLayout(viewController: vc.contentViewController)
        }
    }
}

private class HostingViewDefaultLayout: FloatingPanelLayout {
    let position: FloatingPanel.FloatingPanelPosition = .bottom

    var anchors: [FloatingPanel.FloatingPanelState: FloatingPanel.FloatingPanelLayoutAnchoring] {
        if let provider = viewController as? FloatingInsetProvider {
            return provider.anchors
        } else {
            return [
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 60, edge: .bottom, referenceGuide: .safeArea),
                .full: FloatingPanelLayoutAnchor(absoluteInset: 72, edge: .top, referenceGuide: .safeArea)
            ]
        }
    }

    var initialState: FloatingPanelState {
        if let provider = viewController as? FloatingInsetProvider {
            return provider.initialPosition
        } else {
            return .tip
        }
    }

    weak var viewController: UIViewController?

    static var tipHeight: CGFloat?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        surfaceView.backgroundColor =  ThemeColor.SemanticColor.layer6.uiColor
        if ViewControllerStack.shared?.root()?.traitCollection.horizontalSizeClass == .compact {
            return [
                surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
                surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0)
            ]
        } else {
            return [
                surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 320.0)
            ]
        }
    }
}
