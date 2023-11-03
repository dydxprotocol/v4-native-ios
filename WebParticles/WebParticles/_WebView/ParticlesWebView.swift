//
//  ParticlesWebView.swift
//  WebParticles
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities
import WebKit

@objc open class ParticlesWebView: UIView {
    public static var initialized: Bool = false

    public static func setup(urlString: String?) {
        if !initialized {
            if let view = ViewControllerStack.shared?.root()?.view {
                let webview = WKWebView(frame: view.bounds)
                webview.isHidden = true
                view.addSubview(webview)
                if let urlString = urlString, let url = URL(string: urlString) {
                    webview.load(URLRequest(url: url))
                }
                ParticlesWebView.initialized = true
            }
        }
    }

    public var cookieInjections: [WebApiRequestInjectionProtocol]?

    @objc public dynamic var canGoBack: Bool = false
    @objc public dynamic var canGoForward: Bool = false
    @objc public dynamic var title: String?
    @objc public dynamic var url: URL?

    @IBInspectable var domain: String? {
        didSet {
            if domain != oldValue {
                if let domain = domain {
                    cookieDomain = WebCookieDomain(domain: domain, userAgent: UserAgentProvider.shared?.userAgent())
                } else {
                    cookieDomain = nil
                }
            }
        }
    }

    open var cookieDomain: WebCookieDomain? {
        didSet {
            if cookieDomain !== oldValue {
                _webView = nil
            }
//            changeObservation(from: oldValue, to: cookieDomain, keyPath: #keyPath(WebCookieDomain.location)) { [weak self] _, _, _, _ in
//                self?.locationChanged()
//            }
        }
    }

    @objc open dynamic var _webView: WKWebView? {
        didSet {
            changeObservation(from: oldValue, to: _webView, keyPath: #keyPath(WKWebView.canGoBack)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.canGoBack = self._webView?.canGoBack ?? false
                }
            }
            changeObservation(from: oldValue, to: _webView, keyPath: #keyPath(WKWebView.canGoForward)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.canGoForward = self._webView?.canGoForward ?? false
                }
            }
            changeObservation(from: oldValue, to: _webView, keyPath: #keyPath(WKWebView.title)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.title = self._webView?.title
                }
            }
            changeObservation(from: oldValue, to: _webView, keyPath: #keyPath(WKWebView.url)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.url = self._webView?.url
                }
            }
        }
    }

    open var webView: WKWebView? {
        if _webView == nil {
            let configuration = cookieDomain?.configuration ?? WKWebViewConfiguration()
            let view = WKWebView(frame: self.bounds, configuration: configuration)
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.allowsBackForwardNavigationGestures = true
            view.backgroundColor = backgroundColor

            self.addSubview(view)

            leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            _webView = view
        }
        return _webView
    }

    open func set(cookies: [WebCookieProtocol], completion: WebCookieCompletion?) {
        set(cookies: cookies, index: 0, completion: completion)
    }

    open func set(cookies: [WebCookieProtocol], index: Int, completion: WebCookieCompletion?) {
        if index >= cookies.count {
            completion?()
        } else {
            let cookie = cookies[index]
            if let storage = cookieDomain?.cookieStorage {
                storage.set(cookie: cookie) { [weak self] in
                    self?.set(cookies: cookies, index: index + 1, completion: completion)
                }
            } else {
                completion?()
            }
        }
    }

    open func navigate(to path: String?) {
        if let path = path, let url = URL(string: path) {
            let request = URLRequest(url: url)
            load(request)
        }
    }

    open func load(_ request: URLRequest) {
        _ = webView
        prepare(request: request) { [weak self] modified in
            self?.webView?.load(modified)
        }
    }

    open func prepare(request: URLRequest, completion: @escaping (_: URLRequest) -> Void) {
        if let path = request.url?.absoluteString {
            injectCookies(request: request) { [weak self] in
                if let self = self {
                    if let cookieStorage = self.cookieDomain?.cookieStorage {
                        cookieStorage.cookies(path: path, secure: false, completion: { cookies in
                            if let cookies = cookies {
                                var modified = request
                                modified.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)

                                completion(modified)
                            } else {
                                completion(request)
                            }
                        })
                    } else {
                        completion(request)
                    }
                }
            }
        } else {
            completion(request)
        }
    }

    open func injectCookies(request: URLRequest, completion: @escaping () -> Void) {
        if let domain = request.url?.host {
            injectCookies(index: 0, cookies: [String: String]()) { [weak self] cookies in
                if let self = self, cookies.count > 0 {
                    var webCookies: [WebCookie] = [WebCookie]()
                    for (key, value) in cookies {
                        webCookies.append(self.cookie(domain: domain, name: key, value: value))
                    }
                    self.set(cookies: webCookies) {
                        completion()
                    }
                } else {
                    completion()
                }
            }
        } else {
            completion()
        }
    }

    open func cookie(domain: String, name: String, value: String) -> WebCookie {
        let expiration = Date().add(day: 20)
        let cookie = WebCookie(domain: domain, isSecure: false, name: name, value: value, expires: expiration)
        cookie.isSessionOnly = false
        return cookie
    }

    open func injectCookies(index: Int, cookies: [String: String], completion: @escaping ([String: String]) -> Void) {
        if let cookieInjections = cookieInjections, cookieInjections.count > index {
            let injection = cookieInjections[index]
            injection.cookies { injectedCookies in
                if let injectedCookies = injectedCookies {
                    completion(cookies.merging(injectedCookies, uniquingKeysWith: { (_, value2) -> String in
                        value2
                    }))
                } else {
                    completion(cookies)
                }
            }
        } else {
            completion(cookies)
        }
    }

    open func load(htmlString: String, baseUrl: URL?) {
        webView?.loadHTMLString(htmlString, baseURL: baseUrl)
    }

//    open func locationChanged() {
//        if let location = cookieDomain?.location {
//            let script = "getLocation(\(location.coordinate.latitude) ,\(location.coordinate.longitude))"
//            webView?.evaluateJavaScript(script)
//        }
//    }

    open func goBack() {
        webView?.goBack()
    }

    open func goForward() {
        webView?.goForward()
    }

    open func reload() {
        webView?.reload()
    }
}

extension ParticlesWebView: WKNavigationDelegate {
}

extension ParticlesWebView: WKUIDelegate {
    open func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popup = WKWebView(frame: webView.frame, configuration: webView.configuration)
        popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popup.navigationDelegate = self
        popup.uiDelegate = self
        webView.addSubview(popup)
        return popup
    }

    open func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
    }
}
