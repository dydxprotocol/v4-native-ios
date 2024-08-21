//
//  WebCookieDomain.swift
//  WebParticles
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import CoreLocation
import ParticlesKit
import Utilities
import WebKit

public class WebCookieDomain: NSObject, WebCookieDomainProtocol, WKScriptMessageHandler {
//    var locationPermission: LocationPermission? {
//        didSet {
//            changeObservation(from: oldValue, to: locationPermission, keyPath: #keyPath(LocationPermission.authorization)) { [weak self] _, _, _, _ in
//                self?.locationPermissionChanged()
//            }
//        }
//    }
//
//    var locationProvider: LocationProviderProtocol? {
//        didSet {
//            changeObservation(from: oldValue, to: locationProvider, keyPath: #keyPath(LocationProviderProtocol.location)) { [weak self] _, _, _, _ in
//                self?.locationChanged()
//            }
//        }
//    }
//
//    @objc public dynamic var location: CLLocation?

    public var domain: String
    public var userAgent: String?
    public var configuration: WKWebViewConfiguration = WKWebViewConfiguration()
    public var cookieStorage: WebCookieStorageProtocol?

    public init(domain: String, userAgent: String?) {
        self.domain = domain
        self.userAgent = userAgent

        super.init()

        if let userAgent = userAgent {
            configuration.applicationNameForUserAgent = userAgent
        }
        cookieStorage = WebCookieStorage(configuration: configuration, domain: domain)

        let controller = WKUserContentController()
        controller.add(self, name: "locationHandler")

        configuration.userContentController = controller

        let scriptSource = "navigator.geolocation.getCurrentPosition = function(success, error, options) {window.webkit.messageHandlers.locationHandler.postMessage('getCurrentPosition');};"
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        controller.addUserScript(script)
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "locationHandler", let messageBody = message.body as? String {
            if messageBody == "getCurrentPosition" {
//                locationProvider = LocationProvider.shared
//                locationPermission = LocationPermission.shared
            }
        }
    }

//    func locationPermissionChanged() {
//        if let locationPermission = locationPermission {
//            switch locationPermission.authorization {
//            case .notDetermined:
//                locationPermission.promptToAuthorize()
//
//            default:
//                break
//            }
//        }
//    }
//
//    func locationChanged() {
//        location = locationProvider?.location
//    }
}
