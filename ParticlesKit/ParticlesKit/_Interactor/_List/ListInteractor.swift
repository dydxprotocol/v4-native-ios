//
//  ListInteractor.swift
//  InteractorLib
//
//  Created by John Huang on 10/9/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import Utilities

@objc open class ListInteractor: BaseInteractor, ModelListProtocol {
    
    @objc open dynamic var loading: Bool = false
    @objc open dynamic var title: String?
    open var parent: ModelObjectProtocol?

    open var displayTitle: String? {
        return title ?? parent?.displayTitle ?? nil
    }

    open var displaySubtitle: String? {
        return parent?.displaySubtitle ?? nil
    }

    open var displayImageUrl: String? {
        return parent?.displayImageUrl ?? nil
    }

    @objc open dynamic var list: [ModelObjectProtocol]?
    @objc open dynamic var prefix: ModelObjectProtocol?
    @objc open dynamic var postfix: ModelObjectProtocol?
    @objc open var count: Int {
        return list?.count ?? 0
    }

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

    open func sync(_ list: [ModelObjectProtocol]?) {
        if !(self.list?.containsSame(as: list) ?? false) {
            self.list = list
        }
    }

    open func move(from: Int, to: Int, update: Bool = false) {
        if let item = list?[from], from != to {
            if var list = self.list {
                list.remove(at: from)
                list.insert(item, at: to)
                self.list = list
            }
        }
    }

    public func order(ascending another: ModelObjectProtocol?) -> Bool {
        return stringAscending(string: title, another: (another as? ListInteractor)?.title) ?? false
    }
}
