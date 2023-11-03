//
//  EmbeddingProtocols.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 1/20/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import FloatingPanel

public protocol EmbeddedDelegate: AnyObject {
    var floatingEdge: CGFloat? { get set }
}

public protocol FloatedDelegate: AnyObject {
    var position: FloatingPanelState? { get set }
    var floatTracking: UIScrollView? { get }
    func floatingChanged()
    func shouldPan(currentState: FloatingPanelState, velocity: CGPoint) -> Bool
}

public protocol FloatingInsetProvider: AnyObject {
    var anchors: [FloatingPanel.FloatingPanelState: FloatingPanel.FloatingPanelLayoutAnchoring] { get }
    var initialPosition: FloatingPanelState { get }
}

public extension FloatingInsetProvider {
    var initialPosition: FloatingPanelState {
        .tip
    }
}

extension UINavigationController: FloatedDelegate {
    public var position: FloatingPanelState? {
        get {
            return (topViewController as? FloatedDelegate)?.position
        }
        set {
            (topViewController as? FloatedDelegate)?.position = newValue
        }
    }

    public var floatTracking: UIScrollView? {
        return (topViewController as? FloatedDelegate)?.floatTracking
    }

    public func floatingChanged() {
        (topViewController as? FloatedDelegate)?.floatingChanged()
    }
    
    public func shouldPan(currentState: FloatingPanelState, velocity: CGPoint) -> Bool {
        true
    }
}
