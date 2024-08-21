//
//  GridInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 1/16/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

@objc open class GridInteractor: BaseInteractor, InteractorProtocol, ModelGridProtocol {
    public var width: Int {
        return grid?.count ?? 0
    }

    public var height: Int {
        return grid?.first?.count ?? 0
    }

    @objc open dynamic var entity: ModelObjectProtocol?

    @objc open dynamic var loading: Bool = false

    open var displayTitle: String? {
        return entity?.displayTitle ?? nil
    }

    open var displaySubtitle: String? {
        return entity?.displaySubtitle ?? nil
    }

    open var displayImageUrl: String? {
        return entity?.displayImageUrl ?? nil
    }

    @objc public dynamic var grid: [[ModelObjectProtocol]]?

    private func indexOf(_ sourceObject: ModelObjectProtocol?, in destination: NSArray?, startingAt startIndex: Int) -> Int? {
        let index = destination?.indexOfObject(passingTest: { (object: Any, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
            if index < startIndex {
                return false
            }
            if self.compare(object as? (ModelObjectProtocol), with: sourceObject) {
                stop.pointee = true
                return true
            }
            return false
        })
        if index != NSNotFound {
            return index
        }
        return nil
    }

    private func compare(_ destination: ModelObjectProtocol?, with source: ModelObjectProtocol?) -> Bool {
        if destination === source {
            return true
        } else {
            return destination?.isEqual(source) ?? false
        }
    }

    open func sync(_ grid: [[ModelObjectProtocol]]?) {
        DispatchQueue.runInMainThread { [weak self] in
            self?.grid = grid
        }
    }
}
