//
//  ParticlesWebPresenter.swift
//  WebParticles
//
//  Created by Qiang Huang on 10/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import PlatformRouting
import RoutingKit
import SDWebImage
import UIToolkits
import Utilities
import WebKit

public typealias SharingHandler = ([Any]?) -> Void

open class ParticlesWebPresenter: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
    @objc public dynamic var title: String?
    @objc public dynamic var url: URL?
    @IBInspectable var navigateToSafari: Bool = false

    @IBInspectable open var domain: String? {
        didSet {
            if domain != oldValue {
                webview?.domain = domain
            }
        }
    }

    open var sharingImageUrl: String?

    @IBOutlet var goBackButton: UIBarButtonItem? {
        didSet {
            if goBackButton !== oldValue {
                oldValue?.removeTarget()
                goBackButton?.addTarget(self, action: #selector(goBack(_:)))
            }
        }
    }

    @IBOutlet var goForwadButton: UIBarButtonItem? {
        didSet {
            if goForwadButton !== oldValue {
                oldValue?.removeTarget()
                goForwadButton?.addTarget(self, action: #selector(goForward(_:)))
            }
        }
    }

    @IBOutlet var reloadButton: UIBarButtonItem? {
        didSet {
            if reloadButton !== oldValue {
                oldValue?.removeTarget()
                reloadButton?.addTarget(self, action: #selector(reload(_:)))
            }
        }
    }

    @IBOutlet @objc open dynamic var webview: ParticlesWebView? {
        didSet {
            webview?.domain = domain
            changeObservation(from: oldValue, to: webview, keyPath: #keyPath(ParticlesWebView.title)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.title = self.webview?.title
                }
            }
            changeObservation(from: oldValue, to: webview, keyPath: #keyPath(ParticlesWebView.url)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.url = self.webview?.url
                }
            }
            changeObservation(from: oldValue, to: webview, keyPath: "_webView") { [weak self] _, _, _, _ in
                if let self = self {
                    self.webview?._webView?.scrollView.delegate = self
                    self.webview?._webView?.navigationDelegate = self
                }
            }
        }
    }

    open var htmlString: String?

    open var urlRequest: URLRequest? {
        didSet {
            if urlRequest != oldValue {
                isUrlLoaded = false
                reachedEnd = false
                navigate()
            }
        }
    }

    @objc open dynamic var isUrlLoaded: Bool = false
    @objc open dynamic var reachedEnd: Bool = false

    open func prepare(completion: @escaping WebCookieCompletion) {
        completion()
    }

    open func navigate() {
        prepare { [weak self] in
            self?.loadWeb()
        }
    }

    open func loadWeb() {
        if let webview = webview {
            if let htmlString = htmlString {
                webview.load(htmlString: htmlString, baseUrl: nil)
            } else if let urlRequest = transform(request: urlRequest) {
                webview.load(urlRequest)
            }
        }
    }

    open func transform(request: URLRequest?) -> URLRequest? {
        return request
    }

    @IBAction func goBack(_ sender: Any?) {
        webview?.goBack()
    }

    @IBAction func goForward(_ sender: Any?) {
        webview?.goForward()
    }

    @IBAction func reload(_ sender: Any?) {
        webview?.reload()
    }

    @IBAction open func share(_ sender: Any?) {
        sharing { [weak self] items in
            self?.share(sender: sender, items: items)
        }
    }

    open func share(sender: Any?, items: [Any]?) {
        if let items = items {
            UserInteraction.shared.sender = sender
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.excludedActivityTypes = [
                UIActivity.ActivityType.airDrop,
                UIActivity.ActivityType.addToReadingList,
            ]

            activityVC.popoverPresentationController?.sourceView = UserInteraction.shared.sender as? UIView
            activityVC.popoverPresentationController?.barButtonItem = UserInteraction.shared.sender as? UIBarButtonItem
            ViewControllerStack.shared?.topmost()?.present(activityVC, animated: true, completion: nil)
        }
    }

    open func sharing(share: @escaping SharingHandler) {
        if let url = urlRequest?.url {
            if let sharingImageUrl = sharingImageUrl, let imageUrl = URL(string: sharingImageUrl) {
                SDWebImageManager.shared.loadImage(with: imageUrl, options: .retryFailed, progress: nil) { [weak self] image, _, _, _, _, _ in
                    self?.sharing(url: url, title: self?.webview?.title, image: image, share: share)
                }
            } else {
                sharing(url: url, title: webview?.title, image: nil, share: share)
            }
        } else {
            share(nil)
        }
    }

    open func sharing(url: URL?, title: String?, image: UIImage?, share: @escaping SharingHandler) {
        if let url = url {
            var toShare = [Any]()
            if let title = title {
                toShare.append(title)
            }
            if let image = image {
                toShare.append(image)
            }
            toShare.append(url)
            share(toShare)
        } else {
            share(nil)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isUrlLoaded {
            if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
                reachedEnd = true
            } else if scrollView.contentOffset.y < scrollView.contentSize.height {
                reachedEnd = false
            }
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isUrlLoaded = true
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigateToSafari && isUrlLoaded {
            if let url = navigationAction.request.url {
                URLHandler.shared?.open(url, completionHandler: { _ in
                    decisionHandler(.cancel)
                })
            } else {
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}
