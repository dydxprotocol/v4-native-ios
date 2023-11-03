//
//  MapDataPoolInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 1/25/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Utilities

@objc open class MapDataPoolInteractor: DataPoolInteractor {
    private var mapProvider: MapProviderProtocol? {
        didSet {
            changeObservation(from: oldValue, to: mapProvider, keyPath: #keyPath(MapProviderProtocol.mapRect), block: { [weak self] _, _, _, _ in
                if let self = self {
                    self.visibleMapRect = self.mapProvider?.mapRect
                }
            })
        }
    }

    @objc public dynamic var visibleMapRect: MapArea? {
        didSet {
            if visibleMapRect != oldValue {
                loading = true
            }
        }
    }

    @objc public dynamic var loading: Bool = false {
        didSet {
            if loading != oldValue {
                if loading {
                    loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [weak self] _ in
                        if let self = self {
                            self.load()
                            self.loading = false
                        }
                    })
                } else {
                    loadingTimer = nil
                }
            }
        }
    }

    open override var loadingParams: [String: Any]? {
        if let northWest = mapProvider?.mapRect?.topLeft, let southEast = mapProvider?.mapRect?.bottomRight {
            return formatParam(northWest: northWest, southEast: southEast)
        }
        return nil
    }

    @objc public dynamic var loadingTimer: Timer?

    open override func load() {
        if loadingParams != nil {
            super.load()
        }
    }

    open func formatParam(northWest: MapPoint, southEast: MapPoint) -> [String: Any]? {
        return nil
    }
}
