//
//  ObjectWebLinePresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 6/24/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities
import WebKit

public class ObjectWebLinePresenter: ObjectValueLinePresenter {
    @IBOutlet var webView: WKWebView?

    override open func didSetLineValue(oldValue: Any?) {
        if let urlString = text, let url = URL(string: urlString) {
            webView?.load(URLRequest(url: url))
        } else if let url = URL(string: "blank") {
            webView?.load(URLRequest(url: url))
        }
    }
}
