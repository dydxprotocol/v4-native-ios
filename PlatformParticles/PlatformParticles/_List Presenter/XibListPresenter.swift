//
//  XibListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/9/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

open class XibListPresenter: NativeListPresenter, XibPresenterProtocol {
    @IBOutlet open var selector: SegmentedProtocol? {
        didSet {
            if selector !== oldValue {
                oldValue?.removeTarget()
                selector?.add(target: self, action: #selector(scroll(_:)), for: .valueChanged)
            }
        }
    }

    public var syncingSelector: Bool = false

    public var xibCache: XibPresenterCache = XibPresenterCache()

    @IBInspectable public var xibMap: String? {
        didSet {
            xibCache.xibMap = xibMap
        }
    }

    public var xibRegister: XibRegisterProtocol?
    public var headerXibRegister: XibRegisterProtocol?

    public func xib(object: ModelObjectProtocol?) -> String? {
        if let xibFile = xibCache.xib(object: object) {
            xibRegister?.registerXibIfNeeded(xibFile)
            return xibFile
        }
        return nil
    }

    public func headerXib(object: ModelObjectProtocol?) -> String? {
        if let xibFile = xibCache.xib(object: object) {
            headerXibRegister?.registerXibIfNeeded(xibFile)
            return xibFile
        }
        return nil
    }

    public func defaultSize(at index: Int) -> CGSize? {
        if let object = self.object(at: index), let xib = self.xib(object: object) {
            return defaultSize(xib: xib)
        }
        return nil
    }

    open override func updateCompleted(firstContent: Bool) {
        syncSelector()
    }

    open func syncSelector() {
        if let selector = selector {
            if let titles = current?.map({ obj -> String in
                if let title = obj.displayTitle {
                    return title ?? "-"
                } else {
                    return "-"
                }
            }) {
                selector.fill(titles: titles)
//                DispatchQueue.main.async {[weak self] in
//                    self?.selectCurrent()
//                }
            } else {
                selector.fill(titles: nil)
            }
        }
    }

    // get current visible item and set the selector index
    open func selectCurrent() {
        if !syncingSelector, let selector = selector, let visibleIndice = visibleIndice(), selector.selectedIndex != visibleIndice.first {
            syncingSelector = true
            scrollSelectTo(index: visibleIndice.first) { [weak self] in
                self?.syncingSelector = false
            }
        }
    }

    // scroll to item when selector index changed
    @IBAction open func scroll(_ sender: Any?) {
        if !syncingSelector, let index = selector?.selectedIndex {
            syncingSelector = true
            selectScrollTo(index: index) { [weak self] in
                self?.syncingSelector = false
            }
        }
    }

    open func isVisible(index: Int?, in indice: [Int]?) -> Bool {
        if let indice = indice, indice.count > 0 {
            if let index = index {
                return indice.contains(index)
            } else {
                return false
            }
        } else {
            return true
        }
    }

    open func visibleIndice() -> [Int]? {
        return nil
    }

    open func selectScrollTo(index: Int, completion: @escaping () -> Void) {
        completion()
    }

    open func scrollSelectTo(index: Int?, completion: @escaping () -> Void) {
        if let index = index {
            selector?.selectedIndex = index
        }
        completion()
    }
}
