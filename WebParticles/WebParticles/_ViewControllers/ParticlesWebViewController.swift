//
//  ParticlesWebViewController.swift
//  WebParticles
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import PlatformRouting
import RoutingKit
import UIToolkits
import WebKit

open class ParticlesWebViewController: NavigableViewController, WKNavigationDelegate {
    @IBOutlet open var presenter: ParticlesWebPresenter? {
        didSet {
            didSetPresenter(oldValue: oldValue)
        }
    }

    @IBInspectable open var domain: String? {
        didSet {
            if domain != oldValue {
                presenter?.domain = domain
            }
        }
    }

    @IBInspectable open var path: String? {
        didSet {
            if path != oldValue {
                paths = path?.components(separatedBy: ",")
            }
        }
    }

    private var paths: [String]?

    private var shown: Bool = false
    private var previousPath: String?

    @IBOutlet var doneButton: UIBarButtonItem? {
        didSet {
            if doneButton !== oldValue {
                oldValue?.removeTarget()
                doneButton?.addTarget(self, action: #selector(dismiss(_:)))
            }
        }
    }

    @IBOutlet var shareButton: UIBarButtonItem? {
        didSet {
            if shareButton !== oldValue {
                oldValue?.removeTarget()
                shareButton?.addTarget(self, action: #selector(share(_:)))
            }
        }
    }

    open var htmlString: String? {
        didSet {
            if htmlString != oldValue {
                presenter?.htmlString = htmlString
            }
        }
    }

    open var urlRequest: URLRequest? {
        didSet {
            if urlRequest != oldValue {
                if isViewLoaded {
                    presenter?.urlRequest = urlRequest
                }
            }
        }
    }

    open func setupWebview() {
    }

    open func didSetPresenter(oldValue: ParticlesWebPresenter?) {
        changeObservation(from: oldValue, to: presenter, keyPath: #keyPath(ParticlesWebPresenter.webview)) { [weak self] _, _, _, _ in
            self?.setupWebview()
        }
        changeObservation(from: oldValue, to: presenter, keyPath: #keyPath(ParticlesWebPresenter.title)) { [weak self] _, _, _, _ in
            self?.updateTitle()
        }
        changeObservation(from: oldValue, to: presenter, keyPath: #keyPath(ParticlesWebPresenter.url)) { [weak self] _, _, _, _ in
            self?.updateUrl()
        }
        if presenter !== oldValue {
            presenter?.domain = domain
            presenter?.htmlString = htmlString
            presenter?.urlRequest = urlRequest
        }
    }

    override open func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if let request = request {
            let path = request.path ?? "/"
            var pass = path == previousPath
            if !pass {
                if previousPath == nil {
                    if let paths = paths {
                        pass = paths.contains(path)
                    } else {
                        pass = true
                    }
                }
            }
            if pass {
                urlRequest = urlRequest(from: request)
                if urlRequest != nil {
                    htmlString = htmlString(from: request)
                    previousPath = request.path
                    return true
                }
            }
        }
        return false
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = presenter?.title
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !shown {
            var buttons = [UIBarButtonItem]()
            if let doneButton = doneButton, presenting() {
                buttons.append(doneButton)
            }
            if let shareButton = shareButton {
                buttons.append(shareButton)
            }
            navigationItem.rightBarButtonItems = buttons
            presenter?.urlRequest = urlRequest
            shown = true
        } else {
//            webview?.reload()
        }
    }

    open func htmlString(from routingRequest: RoutingRequest?) -> String? {
        if let path = routingRequest?.path {
            let bundlePath = Bundle.main.bundlePath
            let webPath = bundlePath.stringByAppendingPathComponent(path: "_Web")
            let filePath = webPath.stringByAppendingPathComponent(path: path)
            return try? String(contentsOfFile: filePath)
        }
        return nil
    }

    open func urlRequest(from routingRequest: RoutingRequest?) -> URLRequest? {
        if let routingRequest = routingRequest {
            if let urlString = parser.asString(routingRequest.params?["url"]), let url = URL(string: urlString) {
                return URLRequest(url: url)
            } else if let scheme = routingRequest.scheme, let host = routingRequest.host {
                let path = routingRequest.path ?? "/"
                var urlComponents = URLComponents()
                urlComponents.scheme = scheme
                urlComponents.host = host
                urlComponents.path = path
                if let params = routingRequest.params {
                    var queryItems = [URLQueryItem]()
                    for (key, value) in params {
                        let queryItem = URLQueryItem(name: key, value: parser.asString(value))
                        queryItems.append(queryItem)
                    }
                    if queryItems.count > 0 {
                        urlComponents.queryItems = queryItems
                    }
                }
                if let url = urlComponents.url {
                    return URLRequest(url: url)
                }
            }
        }
        return nil
    }

    open func updateTitle() {
        navigationItem.title = presenter?.title
    }

    open func updateUrl() {
    }

    @IBAction open func share(_ sender: Any?) {
        presenter?.share(sender)
    }
}
