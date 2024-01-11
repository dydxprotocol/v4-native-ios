//
//  PlatformWebView.swift
//  PlatformUI
//
//  Created by Rui Huang on 2/7/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import WebKit
import Utilities

public class PlatformWebViewModel: PlatformViewModel {
    @Published public var url: URL? {
        didSet {
            webViewDelegate.url = url
        }
    }
     
    public var pageLoaded: (() -> ())? {
        didSet {
            webViewDelegate.pageLoaded = pageLoaded
        }
    }

    public var canGoBack: Bool {
        webView.canGoBack
    }

    public var canGoForward: Bool {
        webView.canGoForward
    }

    public func goBack() {
        webView.goBack()
    }

    public func goForward() {
        webView.goForward()
    }

    private let webView = WKWebView()
    private let webViewDelegate = WebViewDelegate()

    public static var previewValue: PlatformWebViewModel = {
        let vm = PlatformWebViewModel()
        vm.url = URL(string: "http://google.com")
        return vm
    }()
    

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            self.webView.addObserver(self.webViewDelegate, forKeyPath: "URL", options: .new, context: nil)
            self.webView.navigationDelegate = self.webViewDelegate
            return AnyView(
                Group {
                    if let url = self.url {
                        let request = URLRequest(url: url)
                        WebView(webView: self.webView, request: request)
                    } else {
                        PlatformView.nilView
                    }
                }
            )
        }
    }

}

private class WebViewDelegate: NSObject, WKNavigationDelegate {
    var url: URL?
    init(pageLoaded: (() -> ())? = nil) {

        self.pageLoaded = pageLoaded
    }
    var pageLoaded: (() -> ())?


    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async { [weak self] in
            self?.pageLoaded?()
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.mainDocumentURL?.path == url?.path {
            decisionHandler(.allow)
        } else {
            if let url = navigationAction.request.mainDocumentURL, URLHandler.shared?.canOpenURL(url) ?? false {
                URLHandler.shared?.open(url, completionHandler: nil)
            }
            decisionHandler(.cancel)
        }
    }

     // Observe URL change
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
           // print("observeValue \(key)") // url value
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.pageLoaded?()
            }
        }
    }
}

private struct WebView: UIViewRepresentable {
    let request: URLRequest
    var webView: WKWebView?

    init(webView: WKWebView?, request: URLRequest) {
        self.webView = webView
        self.request = request
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = webView ?? WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}

#if DEBUG
struct PlatformWebView_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            PlatformWebViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
