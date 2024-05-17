//
//  TrackingViewController+Ext.swift
//  dydxV4
//
//  Created by Michael Maguire on 5/17/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import Utilities
import PlatformParticles
import dydxPresenters

extension TrackingViewController: ScreenIdentifiable, TrackingViewProtocol {
    public var mobilePath: String {
        switch path {
        case "/market", "/trade":
            return "\(path)/\(marketId)"
        default:
            //TODO: replace default with all acceptable paths (this will force developers to add analytics and not forget)
            //assertionFailure("add mobile path handling for \(history?.path)")
            return path
        }
    }
    
    /// the web-equivalent web page (if there is a good match)
    public var correspondingWebPath: String? {
        switch path {
        case "/market", "/trade":
            // web does not have a /market/<MARKET> path
            return "trade/\(marketId)"
        default:
            return nil
        }
    }
    
    public var screenClass: String {
        String(describing: type(of: self))
    }

    public func logScreenView() {
        Tracking.shared?.log(event: .navigatePage(screen: self))
    }
    
}

// MARK: Convenience Accessors
private extension TrackingViewController {
    private var path: String {
        guard let path = history?.path else {
            assertionFailure("no path for \(screenClass)")
            return ""
        }
        return path
    }
    
    private var marketId: String {
        history?.params?["market"] as? String ?? dydxSelectedMarketsStore.shared.lastSelectedMarket
    }
}
